start
  = wrapper+

wrapper
  = element
  / interpolation
  / content

// tag names must start with a capital letter, and can only contain letters,
// hyphens and numbers
tagName = $([A-Z][a-zA-Z-0-9]+)

attribute = ' '+ name:$[a-z]+ '="' value:$[0-9]+ '"' {
  return {name: name, value: value}
}

attributes = attributes:attribute* {
  res = {}
  for (i = 0, len = attributes.length; i < len; i++) {
    res[attributes[i].name] = attributes[i].value
  }
  return res
}

element
  = tagName:startBlock contents:wrapper attributes:attribute* endTagName:endBlock {
    e = {}
    if (tagName !== endTagName) {
      throw new Error(
        'Mismatched start and end tags: ' + tagName + ' and ' + endTagName
      )
    }
    e[tagName] = contents
  }

startBlock
  = '{block:' tagName:tagName '}' {return tagName}

endBlock
  = '{/block:' tagName:tagName '}' {return tagName}

interpolation
  = '{' tagName:tagName attr:attributes '}' {
    return {tagName: tagName, attributes: attr}
  }

content
  = $(!startBlock !endBlock !interpolation .)+
