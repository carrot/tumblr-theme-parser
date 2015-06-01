{parse} = require './parser'
cheerio = require 'cheerio'
clone = require 'lodash.clone'

MIXINS = {
  likebutton: (data, {color, size}) ->
    parse("""
      <div class="like_button" data-post-id="#{data.attributes["post-id"]}" id="like_button_#{data.attributes["post-id"]}">
        <iframe id="like_iframe_#{data.attributes["post-id"]}" src="http://assets.tumblr.com/assets/html/like_iframe.html?_v=1af0c0fbf0ad9b4dc38445698d099106#name={Name}&amp;post_id=#{data.attributes["post-id"]}&amp;color=#{color}&amp;rk=#{data.attributes.rk}" scrolling="no" width="14" height="14" frameborder="0" class="like_toggle" allowTransparency="true"></iframe>
      </div>
    """)
  reblogbutton: (data, {color, size}) ->
    ["""
      <a href="#{data.attributes.reblog_url}" class="reblog_button" style="display: block; width:#{size}px; height:#{size}px;">
        <svg width="100%" height="100%" viewBox="0 0 21 21" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" fill="#{color}">
          <path d="M5.01092527,5.99908429 L16.0088498,5.99908429 L16.136,9.508 L20.836,4.752 L16.136,0.083 L16.1360004,3.01110845 L2.09985349,3.01110845 C1.50585349,3.01110845 0.979248041,3.44726568 0.979248041,4.45007306 L0.979248041,10.9999998 L3.98376463,8.30993634 L3.98376463,6.89801007 C3.98376463,6.20867902 4.71892527,5.99908429 5.01092527,5.99908429 Z"></path>
          <path d="M17.1420002,13.2800293 C17.1420002,13.5720293 17.022957,14.0490723 16.730957,14.0490723 L4.92919922,14.0490723 L4.92919922,11 L0.5,15.806 L4.92919922,20.5103758 L5.00469971,16.9990234 L18.9700928,16.9990234 C19.5640928,16.9990234 19.9453125,16.4010001 19.9453125,15.8060001 L19.9453125,9.5324707 L17.142,12.203"></path>
        </svg>
      </a>
    """]
}

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
  data = clone(data) # we're going to mutate it w/ info from meta tags
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

  compileBlock = (ast, data, searchParentScope) ->
    searchScope = (type, tagName) ->
      key = (
        if type is ''
          tagName
        else
          "#{type}:#{tagName}"
      )
      value = data[key]

      # if blocks can reference variables (which may have spaces in them), so we
      # need to check all the vars if we still didn't find it
      if not value? and type is 'if'
        for key in Object.keys(data)
          if tagName is key.replace(/\s/g, '').replace(/^[a-z]+:/, '')
            value = data[key]
            break

      if not value? and searchParentScope?
        value = searchParentScope(type, tagName)

      if type is '' and tagName in Object.keys(MIXINS)
        # mixins are global and just look like interpolation
        return MIXINS[tagName].bind(this, value)

      return value

    compileElement = (element) ->
      if typeof element is 'string'
        return element
      else if element.type isnt 'block'
        value = searchScope(element.type, element.tagName)
        if value?
          if typeof value is 'function'
            return compileBlock(value(element.attributes), data, searchScope)
          else
            return value
        else
          console.warn "Variable \"#{key}\" is undefined"
          return ''
      else
        [blockType, blockName, invert] = (
          if element.tagName[0...5] is 'ifnot'
            ['if', "#{element.tagName[5...]}", true]
          else if element.tagName[0...2] is 'if'
            ['if', "#{element.tagName[2...]}", false]
          else
            ['block', "#{element.tagName}", false]
        )
        value = searchScope(blockType, blockName)

        if blockType is 'if'
          if value? and value isnt ''
            if typeof value isnt 'boolean' then value = true
          else
            # if it still doesn't exist, then the if block is false
            value = false

          if invert then value = not value

        if typeof value is 'boolean' and value
          # process children in current context
          return compileBlock(element.contents, data, searchScope)
        else if Array.isArray(value)
          # process the contents of the element in each supplied context
          out = ''
          for context in value
            out += compileBlock(element.contents, context, searchScope)
          return out
        else if typeof value is 'object'
          # process the contents of the element in the supplied context
          return compileBlock(element.contents, value, searchScope)
        else
          # if value is falsey or undefined then we just discard the children
          return ''

    output = ''
    for element in ast
      output += compileElement(element)
    return output

  ast = parse(text)
  result = compileBlock(ast, data).split('\n')

  # remove trailing whitespace
  for i in [0...result.length]
    result[i] = result[i].trimRight()

  # filter multiple sequential linebreaks
  result = result.filter (val, i, arr) -> not (val is '' and arr[i - 1] is '')

  return result.join('\n')

module.exports = {compile, parse}
