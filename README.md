# Tumblr Theme Parser
[![Build Status](http://img.shields.io/travis/slang800/tumblr-theme-parser.svg?style=flat-square)](https://travis-ci.org/slang800/tumblr-theme-parser) [![NPM version](http://img.shields.io/npm/v/tumblr-theme-parser.svg?style=flat-square)](https://www.npmjs.org/package/tumblr-theme-parser) [![NPM license](http://img.shields.io/npm/l/tumblr-theme-parser.svg?style=flat-square)](https://www.npmjs.org/package/tumblr-theme-parser)

A Tumblr theme parser / compiler.

I've working in a static microblogging generator that is compatible with Tumblr themes [http://www.tumblr.com/themes/](http://www.tumblr.com/themes/) so I wrote a parser for the Tumblr's template language used on custom themes [http://www.tumblr.com/docs/en/custom_themes](http://www.tumblr.com/docs/en/custom_themes) and thanks to [pyparsing](http://pyparsing.wikispaces.com/) was not so hard to create it.

## Usage
For example running

```bash
$ tumblr-theme-parser -t theme.html -j options.json
```

with an HTML theme like this

```html
<html>
  <head>
    <title>{Title}</title>
  </head>
  <body>
    <ol id="posts">
      {block:Posts}
      {block:Text}
        <li class="{PostType}">
          {block:Title}
          <h3><a href="{Permalink}">{Title}</a></h3>
          {/block:Title}
          {Body}
        </li>
      {/block:Text}
      {/block:Posts}
    </ol>
  </body>
<html>
```

The HTML rendered looks like this

```html
<html>
  <head>
    <title>My personal blog</title>
  </head>
  <body>
    <ol id="posts">
      <li class="text">
        <h3><a href="/post/1/">My first post</a></h3>
        Content.
      </li>
      <li class="text">
        <h3><a href="/post/2/">My second post</a></h3>
        Content.
      </li>
    </ol>
  </body>
<html>
```

`options.json` is a JSON-encoded file with options to render the template. For example

```json
{
  "Title": "My personal blog",
  "Posts": [
    {
      "PostType": "text",
      "Title": "My first post",
      "Permalink": "/post/1/",
      "Body": "Content."
    },
    {
      "PostType": "text",
      "Title": "My second post",
      "Permalink": "/post/2/",
      "Body": "Content."
    }
  ]
}
```
