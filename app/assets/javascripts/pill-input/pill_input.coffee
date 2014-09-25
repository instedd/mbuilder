BUTTON = "button"
DIV = "div"
SPAN = "SPAN"
BR = "BR"
A = "A"

MENU = "menu"
DROP_ZONE = "dropZone"
INPUT = "input"
PILL = "pill"
ARROW = "arrow"
OPTION = "option"
PILL_BUTTON = "pillButton"

DATA_OPTION = "data-option"
DATA_LABEL = "data-label"
MOVE = "move"
TEXT = "text"

DRAG_OVER = "dragover"
DROP = "drop"
KEYDOWN = "keydown"
KEYUP = "keyup"
CONTEXT_MENU = "contextmenu"
MOUSE_DOWN = "mousedown"
MOUSE_MOVE = "mousemove"
MOUSE_UP = "mouseup"
CLICK = "click"
FOCUS = "focus"
BLUR = "blur"
COPY = "copy"
CUT = "cut"

class PillInput
  # options
  #  - renderPill: function(pill, pillDom)
  #    manipulates pillDom in order to reflect pill
  constructor: (@dom, @options) ->
    @dom.attr('contentEditable', true)
    @dom.addClass(INPUT)
    @dom.on 'input', =>
      @dom.trigger 'pillinput:changed'
    @controller = new PillInputController(@)
    @safe_html = $('<div/>')

  on: (eventName, callback) ->
    @dom.on eventName, callback

  # [String | objects for pills]
  value: (value) ->
    if arguments.length == 1
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
      .addClass(PILL)
      .attr('draggable', true)
      .attr('contentEditable', false)
    @pillData(pillDom, object)
    @options.renderPill(object, pillDom)
    res = pillDom[0].outerHTML
    pillDom.remove()
    res

class PillInputController
  constructor : (@pillInput) ->
    @pillInput.dom.on("dragstart", @dragStartHandler)
    @pillInput.dom.on("dragend", @dragEndHandler)
    @pillInput.dom.on("dragenter", @dragEnterHandler)
    @pillInput.dom.on("dragleave", @dragLeaveHandler)
    @pillInput.dom.on("dragover", @dragOverHandler)
    @pillInput.dom.on("drop", @dropHandler)

    @pillInput.dom.on("keydown", @keyDownHandler)
    @pillInput.dom.on("keyup", @keyUpHandler)
    # @pillInput.dom.on("contextmenu", @clickHandler)
    @pillInput.dom.on("click", @clickHandler)
    @pillInput.dom.on("mousedown", @mouseDownHandler)
    # @pillInput.dom.on("blur", @blurHandler, true)

    # document.addEventListener("copy", @copyHandler);
    # document.addEventListener("cut", @cutHandler);
    # document.addEventListener("paste", @pasteHandler);
    @dragElement = null
    @dragSource = null

  clearSelection : ->
    if window.getSelection
      window.getSelection().removeAllRanges()
    else
      if document.selection
        document.selection.empty()

  deleteSelection : ->
    if window.getSelection
      selection = window.getSelection()
      selection.deleteFromDocument()
      selection.collapseToEnd()  unless selection.isCollapsed
    else
      document.selection.clear()  if document.selection

  getAncestor : (className, node) ->
    ancestor = null
    while (node && node != document && ancestor == null)
      if (node.classList && node.classList.contains(className))
        ancestor = node
      node = node.parentNode

    ancestor

  toArray : (obj) ->
    [].map.call obj, (element) ->
      element

  documentFragmentToString : (documentFragment) ->
    string = ""
    @toArray(documentFragment.childNodes).forEach (element) ->
      switch element.nodeType
        when Node.ELEMENT_NODE
          string += element.outerHTML
        when Node.TEXT_NODE
          string += element.data

    string

  insertAtPosition : (elements, x, y) ->
    elements = [elements]  unless elements instanceof Array
    range = @getRangeFromPoint(x, y)
    node = range.offsetNode or range.startContainer
    offset = range.offset or range.startOffset
    if node.nodeType is Node.TEXT_NODE
      container = node.parentNode
      node = node.splitText(offset)
      elements.forEach (element) ->
        container.insertBefore element, node
        return

    else
      elements.forEach (element) ->
        node.appendChild element
        return

  sanitize : (element) ->
    element.normalize()
    if element.hasChildNodes() and element.firstChild.nodeName is BR
      element.removeChild(element.firstChild)

  inputContainsRange : (range) ->
    result = false
    if range and not range.collapsed
      if @getAncestor(INPUT, range.commonAncestorContainer)
        result = true

    result

  intersectsRange : (node, range) ->
    result = false
    result = range.intersectsNode(node)  if range
    result

  getRange : () ->
    if window.getSelection? && window.getSelection().rangeCount > 0
      window.getSelection().getRangeAt(0)
    else
      null

  getRangeFromPoint : (x, y) ->
    if document.caretPositionFromPoint
      document.caretPositionFromPoint(x, y)
    else if document.caretRangeFromPoint
      document.caretRangeFromPoint(x, y)
    else
      null

  getElementsFromRange : (range, clone) ->
    if clone
      range.cloneContents()
    else
      range.extractContents()

  # Handlers
  selectHandler : (dispatcher) =>
    return  unless @getAncestor(INPUT, dispatcher)
    range = @getRange()
    rect = range and range.getBoundingClientRect()
    container = @getAncestor(INPUT, dispatcher)
    if container
      # TODO create pill
      # pillButton = container.querySelector("." + PILL_BUTTON)
      # pillButton.style.display = (if range and not range.collapsed then "block" else "none")
      # input = container.querySelector("." + INPUT)
      input = @pillInput.dom[0]
    @toArray(input.childNodes).forEach (element) ->
      if element.nodeType is Node.ELEMENT_NODE
        if range and range.intersectsNode(element) and rect.width
          element.classList.add FOCUS
        else if element.classList.contains(PILL) and range and range.collapsed and not range.startOffset and range.startContainer.previousSibling is element
          element.classList.add FOCUS
        else
          element.classList.remove FOCUS
      return

  dragStartHandler : (e) =>
    console.log 'dragStartHandler'

    range = @getRange()
    pill = @getAncestor(PILL, e.target)
    data = null

    if pill
      if @inputContainsRange(range) && @intersectsRange(pill, range)
        @dragElement = @getElementsFromRange(range, true)
        @dragSource = @getAncestor(INPUT, range.commonAncestorContainer)
        data = @documentFragmentToString(@dragElement)
      else
        @dragElement = pill
        @dragSource = pill.parentNode
        data = pill.outerHTML
    else if (@inputContainsRange(range))
      @dragElement = @getElementsFromRange(range, true)
      @dragSource = @getAncestor(INPUT, range.commonAncestorContainer)
      data = @documentFragmentToString(@dragElement)

    if data
      e.originalEvent.dataTransfer.effectAllowed = MOVE
      e.originalEvent.dataTransfer.setData(TEXT, data)
      e.stopPropagation()

  dragEnterHandler : (e) =>
    target = e.target
    if target.classList and target.classList.contains(DROP_ZONE)
      target.classList.add DRAG_OVER
      e.preventDefault()

  dragLeaveHandler : (e) =>
    target = e.target
    if target.classList and target.classList.contains(DROP_ZONE)
      target.classList.remove DRAG_OVER
      e.preventDefault()

  dragOverHandler : (e) =>
    target = e.target
    e.preventDefault()  if target.contenteditable isnt "true" and not bowser.firefox

  dropHandler : (e) =>
    console.log 'drop'
    target = e.target
    wrapper = document.createElement(DIV)
    wrapper.innerHTML = e.originalEvent.dataTransfer.getData(TEXT)
    console.log(e.originalEvent.dataTransfer.getData(TEXT))
    target.classList.remove DRAG_OVER
    if target.classList.contains(DROP_ZONE)
      unless target is @dragSource
        pills = @toArray(wrapper.querySelectorAll("." + PILL))
        pills.forEach (pill) ->
          target.appendChild pill
          return

    else if target.classList.contains(INPUT)
      elements = @toArray(wrapper.childNodes)
      # jquery bug(?): event clientX/Y is undefined in drop
      console.log 'drop2', e.originalEvent.clientX, e.originalEvent.clientY
      @insertAtPosition elements, e.originalEvent.clientX, e.originalEvent.clientY
      if target is @dragSource
        @deleteSelection()
        @dragElement.parentNode.removeChild @dragElement  if @dragElement.classList and @dragElement.classList.contains(PILL)
    @sanitize(target)
    @clearSelection()
    e.stopPropagation()
    e.preventDefault()

  keyDownHandler : (e) =>
    input = @getAncestor(INPUT, e.target)
    return  unless input
    switch e.keyCode
      when 8
        range = @getRange()
        if range and range.collapsed
          target = null
          switch range.startContainer.nodeType
            when Node.ELEMENT_NODE
              target = input.childNodes[range.startOffset - 1]
              if target
                switch target.nodeName
                  when BR, A
                  else
                    target = null
            when Node.TEXT_NODE
              target = range.startContainer.previousSibling  unless range.startOffset
    if target
      input.removeChild target
      e.preventDefault()
    window.setTimeout @selectHandler, 25, input

  keyUpHandler : (e) =>
    input = @getAncestor(INPUT, e.target)
    return  unless input
    @selectHandler input
    @sanitize input

  clickHandler : (e) =>
    console.log 'click'
    if e.target.classList.contains(PILL_BUTTON)
      @createPill()
      @clearSelection()
      @selectHandler getAncestor(INPUT, e.target.parentNode.querySelector("." + INPUT))
    else
      pill = @getAncestor(PILL, e.target)
      input = @getAncestor(INPUT, e.target)
      arrow = e.target.className is ARROW
      rightButton = e.which is 3
      console.log 'click 2'
      @selectHandler input
      return  if not pill or (not arrow and not rightButton)
      e.preventDefault()  if e.type is CONTEXT_MENU
      # TODO @hideMenu()
      # TODO @showMenu pill

  mouseDownHandler : (e) =>
    console.log 'mouse down'
    #TODO @hideMenu()  if @menu and not menu.contains(e.target)
    console.log @pillInput.dom
    @pillInput.dom.on(MOUSE_MOVE, @mouseMoveHandler)
    @pillInput.dom.on(MOUSE_UP, @mouseUpHandler)
    # document.addEventListener MOUSE_MOVE, @mouseMoveHandler
    # document.addEventListener MOUSE_UP, @mouseUpHandler
    @selectHandler e.target

  mouseMoveHandler : (e) =>
    console.log 'mouse mouve'
    @selectHandler e.target

  mouseUpHandler : (e) =>
    console.log 'mouse up'
    @pillInput.dom.off(MOUSE_MOVE)
    @pillInput.dom.off(MOUSE_UP)
    # document.removeEventListener MOUSE_MOVE, @mouseMoveHandler
    # document.removeEventListener MOUSE_UP, @mouseUpHandler
    @selectHandler e.target

  blurHandler : (e) =>
    @selectHandler e.target


window.PillInput = PillInput
# window.PillInputController = new PillInputController()
