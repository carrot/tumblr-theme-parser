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
        tagName: 'title'
        attributes: {}
        type: ''
      }
    ])
    parse('<title>{Title}</title>').should.eql([
      '<title>'
      {
        tagName: 'title'
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
        tagName: 'content background'
        type: 'color'
      }
      ';\n    color: '
      {
        attributes: {}
        tagName: 'text'
        type: 'color'
      }
      ';\n  }\n</style>'

    ])

  it 'should parse interpolation with attributes', ->
    parse('{Likes width="200"}').should.eql([
      {
        tagName: 'likes'
        attributes: {
          width: '200'
        }
        type: ''
      }
    ])
    parse('{Likes width="200" limit="5"}').should.eql([
      {
        tagName: 'likes'
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
        tagName: 'posts'
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
        tagName: 'posts'
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
            tagName: 'caption'
            type: 'block'
          }
        ]
        attributes: {}
        tagName: 'posts'
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
            tagName: 'posttype'
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
                    tagName: 'permalink'
                    type: ''
                  }
                  '">\n        <h2>'
                  {
                    attributes: {}
                    tagName: 'title'
                    type: ''
                  }
                  '</h2>\n      </a>\n      '
                ]
                tagName: 'title'
                type: 'block'
              }
              '\n      '
              {
                attributes: {}
                tagName: 'body'
                type: ''
              }
              '\n      '
            ]
            tagName: 'text'
            type: 'block'
          }
          '\n      </article>\n    '
        ]
        tagName: 'posts'
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

  it 'should compile nested blocks', ->
    compile(
      '''
      <html>
        <head>
          <title>{Title}</title>
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
      '''
      'Title': 'My Title'
      'block:Posts': [
        {
          'block:Body': true
          'block:Title': true
          'Body': '<p>test<br></p>'
          'Permalink': 'http:/test.tumblr.com/post/118449891560/test'
          'PostType': 'text'
          'Title': 'My first post'
        }
        {
          'block:Body': true
          'block:Title': true
          'Body': '<p>test<br></p>'
          'Permalink': 'http:/test.tumblr.com/post/891560118449/test'
          'PostType': 'text'
          'Title': 'My second post'
        }
      ]
    ).should.equal('''
      <html>
        <head>
          <title>My Title</title>
        </head>
        <body>

          <article class="text">

            <a href="http:/test.tumblr.com/post/118449891560/test">
              <h2>My first post</h2>
            </a>

            <p>test<br></p>

          </article>

          <article class="text">

            <a href="http:/test.tumblr.com/post/891560118449/test">
              <h2>My second post</h2>
            </a>

            <p>test<br></p>

          </article>

        </body>
      </html>
    ''')

  it 'should compile with meta tag defaults', ->
    compile(
      '''
      <html>
        <head>
          <meta name="color:Background" content="#ccc"/>
          <meta name="color:Content Background" content="#fff"/>
          <meta name="font:Body" content="Arial, Helvetica, sans-serif"/>
          <meta name="color:Text" content="#000"/>
          <style type="text/css">
            #content {
              background-color: {color:Content Background};
              color: {color:Text};
              font: 30px {font:Body};
            }
          </style>
        </head>
        <body bgcolor="{color:Background}">
          ...
        </body>
      </html>
      '''
    ).should.equal('''
      <html>
        <head>
          <meta name="color:Background" content="#ccc"/>
          <meta name="color:Content Background" content="#fff"/>
          <meta name="font:Body" content="Arial, Helvetica, sans-serif"/>
          <meta name="color:Text" content="#000"/>
          <style type="text/css">
            #content {
              background-color: #fff;
              color: #000;
              font: 30px Arial, Helvetica, sans-serif;
            }
          </style>
        </head>
        <body bgcolor="#ccc">
          ...
        </body>
      </html>
    ''')
