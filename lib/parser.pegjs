start
  = wrapper+

wrapper
  = element
  / interpolation
  / content

// tag names must start with a capital letter, and can only contain letters,
// hyphens and numbers
tagName = $([A-Z][a-zA-Z-0-9]+)

attribute = ' '+ name:$([a-z][a-zA-Z]+) '="' value:$[0-9]+ '"' {
  return {name: name, value: value};
}

attributes = attributes:attribute* {
  res = {};
  for (i = 0, len = attributes.length; i < len; i++) {
    res[attributes[i].name] = attributes[i].value;
  }
  return res;
}

element
  = startBlock:startBlock contents:wrapper* endTagName:endBlock {
    tagName = startBlock.tagName
    if (tagName !== endTagName) {
      throw new Error(
        'Mismatched start and end tags: ' + tagName + ' and ' + endTagName
      );
    }
    res = {tagName: tagName, attributes: startBlock.attributes};
    if (contents !== null) {
      res.contents = contents
    } else {
      res.contents = []
    }
    return res
  }

startBlock
  = '{block:' tagName:tagName attr:attributes '}' {
    return {tagName: tagName, attributes: attr};
  }

endBlock
  = '{/block:' tagName:tagName '}' {return tagName;}

interpolation
  = '{'  tagName:tagName attr:attributes '}' {
    return {tagName: tagName, attributes: attr};
  }

content
  = $(!startBlock !endBlock !interpolation .)+
