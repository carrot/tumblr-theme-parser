{parse} = require './parser'
cheerio = require 'cheerio'

transformKeysRecursive = (obj, fn) ->
  output = {}
  for i of obj
    if Object::toString.apply(obj[i]) is '[object Object]'
      output[fn(i)] = transformKeysRecursive(obj[i], fn)
    else if Array.isArray(obj[i])
      output[fn(i)] = []
      for e in obj[i]
        output[fn(i)].push transformKeysRecursive(e, fn)
    else
      output[fn(i)] = obj[i]
  output

compile = (text, data = {}) ->
  $ = cheerio.load(text)
  metaTags = $('meta')
  for tag in metaTags
    key = $(tag).attr('name')
    v = $(tag).attr('content')

    if not key? or data[key]? then continue

    if key[0...3] is 'if:'
      if v is '0'
        v = false
      else if v is '1'
        v = true

    data[key] = v

  # fix up tumblr data
  if data?['block:Posts']?
    for post in data['block:Posts']
      type = post['PostType']
      post["block:#{type}"] = true

  data = transformKeysRecursive(data, (key) ->
    # handle case insensitivity (matches the transformation applied to the AST)
    key = key.toLowerCase()

    if key[0...3] is 'if:'
      # if blocks don't have spaces (probably because they're blocks)
      key = key.replace(/\s/g, '')

    return key
  )

  output = ''
  compileBlock = (ast, data) ->
    for element in ast
      if typeof element is 'string'
        output += element
      else if element.type isnt 'block'
        type = element.type
        if type is ''
          value = data[element.tagName]
          if value?
            output += value
          else
            console.warn "Variable \"#{element.tagName}\" is undefined"
        else
          output += data["#{type}:#{element.tagName}"]
      else
        if element.tagName[0...5] is 'ifnot'
          value = not data["if:#{element.tagName[5...]}"]
        else if element.tagName[0...2] is 'if'
          value = data["if:#{element.tagName[2...]}"]
        else
          value = data["block:#{element.tagName}"]

        if typeof value is 'boolean' and value
          # process children in current context, if value is false or undefiend
          # then we just discard the children
          compileBlock(element.contents, data)
        else if Array.isArray(value)
          # process the contents of the element in each supplied context
          for context in value
            compileBlock(element.contents, context)
        else if typeof value is 'object'
          # process the contents of the element in the supplied context
          compileBlock(element.contents, value)

  ast = parse(text)
  compileBlock(ast, data)

  output = output.split('\n')

  # remove trailing whitespace
  for i in [0...output.length]
    output[i] = output[i].trimRight()

  # filter multiple sequential linebreaks
  output = output.filter (val, i, arr) -> not (val is '' and arr[i - 1] is '')

  return output.join('\n')

module.exports = {compile, parse}
