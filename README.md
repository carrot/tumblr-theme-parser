# Tumblr Theme Parser
[![Build Status](http://img.shields.io/travis/slang800/tumblr-theme-parser.svg?style=flat-square)](https://travis-ci.org/slang800/tumblr-theme-parser) [![NPM version](http://img.shields.io/npm/v/tumblr-theme-parser.svg?style=flat-square)](https://www.npmjs.org/package/tumblr-theme-parser) [![NPM license](http://img.shields.io/npm/l/tumblr-theme-parser.svg?style=flat-square)](https://www.npmjs.org/package/tumblr-theme-parser)

This tool allows [custom Tumblr themes](http://www.tumblr.com/docs/en/custom_themes) to be parsed / rendered locally, so they can be used outside of Tumblr.


## Usage
```bash
$ tumblr-theme-parser -d data.json < theme.html
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
