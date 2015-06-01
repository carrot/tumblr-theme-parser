start
  = wrapper+

wrapper
  = element
  / interpolation
  / content

// can only contain letters, hyphens and numbers. we loweer-case these
// identifiers because they are case-insensitive & it makes comparison much
// easier later on. it would be nice to maintain PascalCase, but too much of a
// pain
tagName = name:$([a-zA-Z-0-9]+) {
  return name.toLowerCase()
}

// var names are tag names, but they can have spaces, apparently. we make sure
// we're hitting an attribute, then optionally consume a space (in case we're
// past the first word of a multi-word variable name), then consume the next
// word, and then finally loop back around to the start to check for another
// word
varName = name:$(!attribute ' '? [a-zA-Z-0-9]+)+ {
  return name.toLowerCase()
}

attribute = ' '+ name:$([a-z][a-zA-Z]+) '="' value:$[a-zA-Z0-9]+ '"' {
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
    res = {tagName: tagName, type: 'block', attributes: startBlock.attributes};
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

interpolationType = type:('lang:' / 'text:' / 'color:' / 'font:' / 'image:' / ''){
  return type.slice(0, -1);
}

interpolation
  = '{' type:interpolationType tagName:varName attr:attributes '}' {
    return {tagName: tagName, type: type, attributes: attr};
  }

content
  = $(!startBlock !endBlock !interpolation .)+
