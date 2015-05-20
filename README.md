# Tumblr Theme Parser
[![Build Status](http://img.shields.io/travis/carrot/tumblr-theme-parser.svg?style=flat-square)](https://travis-ci.org/carrot/tumblr-theme-parser) [![NPM version](http://img.shields.io/npm/v/tumblr-theme-parser.svg?style=flat-square)](https://www.npmjs.org/package/tumblr-theme-parser) [![NPM license](http://img.shields.io/npm/l/tumblr-theme-parser.svg?style=flat-square)](https://www.npmjs.org/package/tumblr-theme-parser)
[![dependencies](http://img.shields.io/gemnasium/carrot/tumblr-theme-parser.svg?style=flat-square)](https://gemnasium.com/carrot/tumblr-theme-parser)

This tool allows [custom Tumblr themes](http://www.tumblr.com/docs/en/custom_themes) to be parsed / rendered locally, so they can be used outside of Tumblr.

It should be noted that this parser is slightly more strict than the one Tumblr uses. For example, each block tag must be matched with a closing block tag (omitting it will cause the parser to fail), and tags must open and close in the correct order (`{block:a}{block:b}{/block:b}{/block:a}` is correct, but `{block:a}{block:b}{/block:a}{/block:b}` will fail).

This parser allows case insensitivity in tag and variable names (because we want to match the Tumblr compiler as closely as possible). However, you should still use PascalCase for all of your identifiers, because this is the convention in Tumblr themes.

## Usage
### CLI
The Markup of the theme is passed in via `STDIN`, and the compiled theme is sent to `STDOUT`. Data for the theme is passed in the form of a file path. Warnings (like undefined variables or other non-fatal issues) are sent to `STDERR`. A typical command might look like this:

```bash
$ tumblr-theme-parser -d data.json < theme.html > compiled-theme.html
```

For example, with a Tumblr theme like this (saved as `theme.html`):

```html
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
```

And this data from Tumblr (saved as `data.json`):

```json
{
  "Title": "My Title",
  "block:Posts": [
    {
      "block:Body": true,
      "block:Title": true,
      "Body": "<p>test<br></p>",
      "Permalink": "http:/test.tumblr.com/post/118449891560/test",
      "PostType": "text",
      "Title": "My first post"
    }, {
      "block:Body": true,
      "block:Title": true,
      "Body": "<p>test<br></p>",
      "Permalink": "http:/test.tumblr.com/post/891560118449/test",
      "PostType": "text",
      "Title": "My second post"
    }
  ]
}
```

The rendered HTML looks like this:

```html
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
```

## JavaScript
Usage in JavaScript is very simple. The module exports an object containing 2 functions: `compile` and `parse`. The `compile` function takes the input HTML & optional associated data, and returns the compiled HTML.

```javascript
compile = require('tumblr-theme-parser').compile
compiledHtml = compile(themeHtml, data)
```
