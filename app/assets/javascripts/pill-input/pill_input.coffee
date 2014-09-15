class PillInput
  constructor: (@dom, @options) ->
    @dom.attr('contentEditable', true)
    @safe_html = $('<div/>')

  # [String | objects for pills]
  value: (value) ->
    if arguments.length == 1
      # TODO val setter
      innerHTML = ""
      for piece in value
        if typeof(piece) == "string"
          innerHTML += @_htmlEscape(piece)
        else
          innerHTML += @_renderObject(piece)
      @dom.html(innerHTML)
    else
      # TODO val getter

  _htmlEscape : (string) ->
    @safe_html.text(string).html()

  _renderObject : (object) ->
    pillDom = $("<a/>")
      .addClass('pill')
      .attr('draggable', true)
      .attr('contentEditable', false)
      .text('df')
    @options.renderPill(object, pillDom)
    res = pillDom[0].outerHTML
    pillDom.remove()
    res

window.PillInput = PillInput
