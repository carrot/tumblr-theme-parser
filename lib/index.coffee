{parse} = require './parser'

compile = (text, data) ->
  output = ''
  compileBlock = (ast, data) ->
    for element in ast
      if typeof element is 'string'
        output += element
      else if element.type isnt 'block'
        type = element.type
        if type is ''
          output += data[element.tagName]
        else
          output += data["#{type}:#{element.tagName}"]

  ast = parse(text)
  compileBlock(ast, data)
  return output

module.exports = {compile, parse}
