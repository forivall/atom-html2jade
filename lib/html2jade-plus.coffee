html2jade = require 'html2jade'

module.exports =
  config:
    double:
      title: 'Use double quotes'
      type: 'boolean'
      default: false
      description: 'use double quotes for attributes'
    nspaces:
      title: 'Number of spaces'
      type: 'integer'
      default: 2
      description: 'the number of spaces to indent generated
       files with. Default is 2 spaces'
    tabs:
      title: 'Use tabs'
      type: 'boolean'
      default: false
      description: 'use tabs instead of spaces'
    donotencode:
      title: 'Do not encode'
      type: 'boolean'
      default: false
      description: 'do not html encode characters.
       This is useful for template files which may contain
       expressions like {{username}}'
    numeric:
      title: 'Use numeric'
      type: 'boolean'
      default: false
      description: 'use numeric character entities'
    scalate:
      title: 'Scalate'
      type: 'boolean'
      default: false
      description: 'generate Scalate(http://scalate.fusesource.org/)
       variant of jade syntax'
    noattrcomma:
      title: 'No attribute commas'
      type: 'boolean'
      default: false
      description: 'omit attribute separating commas'
    noemptypipe:
      title: 'No empty pipe'
      type: 'boolean'
      default: false
      description: 'omit lines with only pipe (\'|\') printable character'

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
    hasBody = "#{html}".indexOf('<body>') >= 0
    opts =
      double: atom.config.get 'html2jade-plus.double'
      nspaces: atom.config.get 'html2jade-plus.nspaces'
      tabs: atom.config.get 'html2jade-plus.tabs'
      donotencode: atom.config.get 'html2jade-plus.donotencode'
      bodyless: not hasBody
      numeric: atom.config.get 'html2jade-plus.numeric'
      scalate: atom.config.get 'html2jade-plus.scalate'
      noattrcomma: atom.config.get 'html2jade-plus.noattrcomma'
      noemptypipe: atom.config.get 'html2jade-plus.noemptypipe'
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
