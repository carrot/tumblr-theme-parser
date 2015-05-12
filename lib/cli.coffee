{compile, parse} = require './'
fs = require 'fs'
packageInfo = require '../package'
ArgumentParser = require('argparse').ArgumentParser

argparser = new ArgumentParser(
  version: packageInfo.version
  addHelp: true
  description: packageInfo.description
)

# if --parse is set, then --data cannot be set
parseOptionSet = argparser.addMutuallyExclusiveGroup()
parseOptionSet.addArgument(
  ['--data', '-d']
  type: 'string'
  help: 'The path to the JSON file, containing data to pass to the compiler.'
  required: false
)
parseOptionSet.addArgument(
  ['--parse', '-p']
  help: 'Flag to parse the file into an AST, rather than compile it.'
  action: 'storeTrue'
  defaultValue: false
  required: false
)

argv = argparser.parseArgs()

if argv.data
  data = JSON.parse(fs.readFileSync(argv.data))

html = ''

process.stdin.on('data', (chunk) ->
  html += chunk
).on('end', ->
  process.stdout.write(
    if argv.parse
      JSON.stringify(parse(html))
    else
      compile(html, data)
  )
)
