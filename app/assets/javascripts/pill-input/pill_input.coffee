class PillInput
  # options
  #  - renderPill: function(pill, pillDom)
  #    manipulates pillDom in order to reflect pill
  constructor: (@dom, @options) ->
    @dom.attr('contentEditable', true)
    @dom.on 'input', =>
      @dom.trigger 'pillinput:changed'
    @safe_html = $('<div/>')

  on: (eventName, callback) ->
    @dom.on eventName, callback

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
      $.map @dom.contents(), (elem) =>
        if elem.nodeType == Node.TEXT_NODE
          elem.textContent
        else
          @pillData($(elem))

  pillData : (pillDom, object) ->
    if arguments.length == 1
      pillDom.data('pill-info')
    else if arguments.length == 2
      pillDom.attr('data-pill-info', JSON.stringify(object))

  _htmlEscape : (string) ->
    @safe_html.text(string).html()

  _renderObject : (object) ->
    pillDom = $("<a/>")
      .addClass('pill')
      .attr('draggable', true)
      .attr('contentEditable', false)
    @pillData(pillDom, object)
    @options.renderPill(object, pillDom)
    res = pillDom[0].outerHTML
    pillDom.remove()
    res

window.PillInput = PillInput
