html2jade = require 'html2jade'

module.exports =
  config:
    double:
      title: 'Use double quotes for attributes'
      type: 'boolean'
      default: false
    nspaces:
      title: 'Number of spaces'
      type: 'integer'
      default: 2
      description: 'The number of spaces to indent generated
       files with. Default is 2 spaces'
    tabs:
      title: 'Use tabs'
      type: 'boolean'
      default: false
      description: 'Use tabs instead of spaces'
    donotencode:
      title: 'Disable html encoding'
      type: 'boolean'
      default: false
      description: 'Do not html encode special characters.
       This is useful for template files which may contain
       expressions like {{username}}'
    bodyless:
      title: 'Omit surrounding body tags'
      type: 'string'
      default: 'auto'
      enum: [
        'auto'
        'true'
        'false'
      ]
      description: 'Do not output enveloping html and body tags.
       The default will omit body tags if the input does not
       contain a body tag'
    numeric:
      title: 'Use numeric character entities'
      type: 'boolean'
      default: false
    scalate:
      title: 'Scalate'
      type: 'boolean'
      default: false
      description: 'Generate Scalate (http://scalate.github.io/scalate/)
       variant of jade syntax'
    noattrcomma:
      title: 'No attribute commas'
      type: 'boolean'
      default: false
      description: 'Omit attribute separating commas'
    noemptypipe:
      title: 'No empty pipe'
      type: 'boolean'
      default: false
      description: 'Omit lines with only pipe (\'|\') printable character'

  activate: (state) ->

    # Register convert command.
    atom.commands.add 'atom-workspace',
      'html2jade-plus:convert': => @convert()

  convert: ->
    unless (editor = atom.workspace.getActiveTextEditor())
      return (atom.notifications.addWarning('No text editor found'))
    html =
      if (selection = editor.getLastSelection()) and not selection.isEmpty()
        selection.getText()
      else
        selection = null
        editor.getText()
    html = "#{html}".replace /\>\s+\</, '><' # HACK: FIXME:
    bodylessConfig = atom.config.get('html2jade-plus.bodyless')
    bodyless = if bodylessConfig is 'auto' then "#{html}".indexOf('<body') < 0
    else if bodylessConfig is 'true' then true else false
    opts =
      double: atom.config.get('html2jade-plus.double')
      nspaces: atom.config.get('html2jade-plus.nspaces')
      tabs: atom.config.get('html2jade-plus.tabs')
      donotencode: atom.config.get('html2jade-plus.donotencode')
      bodyless: bodyless
      numeric: atom.config.get('html2jade-plus.numeric')
      scalate: atom.config.get('html2jade-plus.scalate')
      noattrcomma: atom.config.get('html2jade-plus.noattrcomma')
      noemptypipe: atom.config.get('html2jade-plus.noemptypipe')
    html2jade.convertHtml html, opts, (err, jade) ->
      if err
        atom.notifications.addError(err.name or err.toString(), {detail: e.message})
        return
      if selection
        selection.insertText(jade)
      else
        atom.workspace.open().then (newEditor) ->
          newEditor.insertText(jade)
          if (jadeGrammar = atom.grammars.grammarForScopeName('source.jade'))
            newEditor.setGrammar(jadeGrammar)
