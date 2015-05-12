{compile, parse} = require '../lib'
should = require 'should'

describe 'parser', ->
  it 'should parse regular/static text', ->
    parse('<title>My Title</title>').should.eql([
      '<title>My Title</title>'
    ])

  it 'should parse interpolation', ->
    parse('{Title}').should.eql([
      {
        tagName: 'Title'
        attributes: {}
        type: ''
      }
    ])
    parse('<title>{Title}</title>').should.eql([
      '<title>'
      {
        tagName: 'Title'
        attributes: {}
        type: ''
      }
      '</title>'
    ])

  it 'should parse color interpolation', ->
    parse('''
      <style type="text/css">
        #content {
          background-color: {color:Content Background};
          color: {color:Text};
        }
      </style>
    ''').should.eql([
      '<style type="text/css">\n  #content {\n    background-color: '
      {
        attributes: {}
        tagName: 'Content Background'
        type: 'color'
      }
      ';\n    color: '
      {
        attributes: {}
        tagName: 'Text'
        type: 'color'
      }
      ';\n  }\n</style>'

    ])

  it 'should parse interpolation with attributes', ->
    parse('{Likes width="200"}').should.eql([
      {
        tagName: 'Likes'
        attributes: {
          width: '200'
        }
        type: ''
      }
    ])
    parse('{Likes width="200" limit="5"}').should.eql([
      {
        tagName: 'Likes'
        attributes: {
          width: '200'
          limit: '5'
        }
        type: ''
      }
    ])

  it 'should parse blocks', ->
    parse('{block:Posts}{/block:Posts}').should.eql([
      {
        contents: []
        attributes: {}
        tagName: 'Posts'
        type: 'block'
      }
    ])

  it 'should parse blocks with attributes', ->
    parse(
      '{block:Posts inlineMediaWidth="500"}{/block:Posts}'
    ).should.eql([
      {
        contents: []
        attributes: {
          inlineMediaWidth: '500'
        }
        tagName: 'Posts'
        type: 'block'
      }
    ])

  it 'should parse nested blocks', ->
    parse(
      '{block:Posts}{block:Caption}{/block:Caption}{/block:Posts}'
    ).should.eql([
      {
        contents: [
          {
            contents: []
            attributes: {}
            tagName: 'Caption'
            type: 'block'
          }
        ]
        attributes: {}
        tagName: 'Posts'
        type: 'block'
      }
    ])

  it 'should parse nested blocks', ->
    parse('''
      <html>
        <head>
        </head>
        <body>
          {block:Posts}
            <article class="{PostType}">
            {block:Text}
            {block:Title}
            <a href="{Permalink}">
              <h2>{Title}</h2>
            </a>
            {/block:Title}
            {Body}
            {/block:Text}
            </article>
          {/block:Posts}
         </body>
      </html>
    ''').should.eql([
      '<html>\n  <head>\n  </head>\n  <body>\n    '
      {
        attributes: {}
        contents: [
          '\n      <article class="'
          {
            attributes: {}
            tagName: 'PostType'
            type: ''
          }
          '">\n      '
          {
            attributes: {}
            contents: [
              '\n      '
              {
                attributes: {}
                contents: [
                  '\n      <a href="'
                  {
                    attributes: {}
                    tagName: 'Permalink'
                    type: ''
                  }
                  '">\n        <h2>'
                  {
                    attributes: {}
                    tagName: 'Title'
                    type: ''
                  }
                  '</h2>\n      </a>\n      '
                ]
                tagName: 'Title'
                type: 'block'
              }
              '\n      '
              {
                attributes: {}
                tagName: 'Body'
                type: ''
              }
              '\n      '
            ]
            tagName: 'Text'
            type: 'block'
          }
          '\n      </article>\n    '
        ]
        tagName: 'Posts'
        type: 'block'
      }
      '\n   </body>\n</html>'
    ])

describe 'compiler', ->
  it 'should compile regular/static text', ->
    compile(
      '<title>My Title</title>'
    ).should.equal(
      '<title>My Title</title>'
    )

  it 'should compile interpolation', ->
    compile(
      '<title>{Title}</title>'
      'Title': 'Untitled'
    ).should.equal(
      '<title>Untitled</title>'
    )

  it 'should compile color interpolation', ->
    compile(
      '''
      <style type="text/css">
        #content {
          background-color: {color:Content Background};
          color: {color:Text};
        }
      </style>
      '''
      'color:Content Background': '#ccc'
      'color:Text': '#000'
    ).should.equal('''
      <style type="text/css">
        #content {
          background-color: #ccc;
          color: #000;
        }
      </style>
    ''')
