parser = require '../lib/parser'
should = require 'should'

describe 'parser', ->
  it 'should parse regular/static text', ->
    parser.parse('<title>My Title</title>').should.eql([
      '<title>My Title</title>'
    ])

  it 'should parse interpolation', ->
    parser.parse('{Title}').should.eql([
      {tagName: 'Title', 'attributes': {}}
    ])
    parser.parse('<title>{Title}</title>').should.eql([
      '<title>'
      {tagName: 'Title', 'attributes': {}}
      '</title>'
    ])

  it 'should parse interpolation with attributes', ->
    parser.parse('{Likes width="200"}').should.eql([
      {
        'tagName': 'Likes'
        'attributes': {
          'width': '200'
        }
      }
    ])
    parser.parse('{Likes width="200" limit="5"}').should.eql([
      {
        'tagName': 'Likes'
        'attributes': {
          'width': '200'
          'limit': '5'
        }
      }
    ])

  it 'should parse blocks', ->
    parser.parse('{block:Posts}{/block:Posts}').should.eql([
      {
        'contents': []
        'attributes': {}
        'tagName': 'Posts'
      }
    ])

  it 'should parse blocks with attributes', ->
    parser.parse(
      '{block:Posts inlineMediaWidth="500"}{/block:Posts}'
    ).should.eql([
      {
        'contents': []
        'attributes': {
          "inlineMediaWidth": "500"
        }
        'tagName': 'Posts'
      }
    ])

  it 'should parse nested blocks', ->
    parser.parse(
      '{block:Posts}{block:Caption}{/block:Caption}{/block:Posts}'
    ).should.eql([
      {
        'contents': [
          {
            'contents': []
            'attributes': {}
            'tagName': 'Caption'
          }
        ]
        'attributes': {}
        'tagName': 'Posts'
      }
    ])
