parser = require '../lib/parser'
should = require 'should'

describe 'parser', ->
  it 'should parse interpolation', ->
    parser.parse('{Title}').should.eql(
      [{tagName: 'Title', 'attributes': {}}]
    )
    parser.parse('<title>{Title}</title>').should.eql(
      ['<title>', {tagName: 'Title', 'attributes': {}}, '</title>']
    )

  it 'should parse interpolation with attributes', ->
    parser.parse('{Likes width="200"}').should.eql([
      {
        'tagName': 'Likes',
        'attributes': {
          'width': '200'
        }
      }
    ])
