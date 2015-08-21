BUTTON = "button"
DIV = "div"
SPAN = "SPAN"
BR = "BR"
A = "A"

MENU = "menu"
INPUT = "input"
PILL = "pill"
ARROW = "arrow"
OPTION = "option"
PILL_BUTTON = "pillButton"

DATA_OPTION = "data-option"
MOVE = "move"
LINK = "link"
ALL = "all"
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
      @trigger('pillinput:changed')
    unless @options.droppedObject
      @options.droppedObject = ->
        null
    @controller = new PillInputController(@)
    @safe_html = $('<div/>')

  on: (eventName, callback) ->
    @dom.on eventName, callback

  trigger: ->
    @dom.trigger.apply(@dom, arguments)

  # [String | objects for pills]
  value: (value) ->
    if arguments.length == 1
      @_renderValue(@dom, value)
    else
      $.map @dom.contents(), (elem) =>
        if elem.nodeType == Node.TEXT_NODE
          elem.textContent
        else
          @pillData($(elem))

  droppedObject : ->
    @options.droppedObject()

  pillData : (pillDom, object) ->
    if arguments.length == 1
      pillDom.data('pill-info')
    else if arguments.length == 2
      pillDom.attr('data-pill-info', JSON.stringify(object))

  selectedText : ->
    @controller.selectedText()

  replaceSelectedTextWith : (value) ->
    @controller.replaceSelectedTextWith(value)

  _renderValue : (domTarget, value) ->
    innerHTML = ""
    for piece in value
      if typeof(piece) == "string"
        innerHTML += @_htmlEscape(piece)
      else
        innerHTML += @_renderObject(piece)
    domTarget.html(innerHTML)

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
    @pillInput.dom.on("contextmenu", @clickHandler)
    @pillInput.dom.on("click", @clickHandler)
    @pillInput.dom.on("mousedown", @mouseDownHandler)
    @pillInput.dom.on("blur", @blurHandler)

    @pillInput.dom.on("copy", @copyHandler);
    @pillInput.dom.on("cut", @cutHandler);
    @pillInput.dom.on("paste", @pasteHandler);

    @dragElement = null
    @dragSource = null

  selectedText : ->
    range = @getRange()
    if @inputContainsRange(range)
      insertTarget = range.endContainer.nextSibling
      elements = @toArray(@getElementsFromRange(range, true).childNodes)
      input = @getAncestor(INPUT, range.endContainer)
      label = ""
      elements.forEach (element) ->
        switch element.nodeType
          when Node.ELEMENT_NODE
            label += element.textContent
          when Node.TEXT_NODE
            label += element.data

      return label
    else
      null

  replaceSelectedTextWith : (value) ->
    range = @getRange()
    if @inputContainsRange(range)
      @getElementsFromRange(range, false) # strip selection
      input = @pillInput.dom[0]

      wrapper = document.createElement(DIV)
      @pillInput._renderValue($(wrapper), [value])

      range.insertNode(wrapper.firstChild)
      @pillInput.trigger('pillinput:changed')

  insert : (elements) ->
    elements = [elements]  unless elements instanceof Array
    range = @getRange()
    if range and not range.collapsed
      @deleteSelection()
      range = @getRange()
    node = range.startContainer
    if node.nodeType is Node.TEXT_NODE
      node = node.splitText(range.startOffset)
      container = node.parentNode
      elements.forEach (element) ->
        container.insertBefore element, node
        return

    else
      if node.classList.contains(INPUT)
        elements.forEach (element) ->
          node.appendChild element
          return

      else
        elements.forEach (element) ->
          container.insertBefore element, node
          return

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

    # backspace generates spans in chrome
    $('span:not([class])', $(element)).contents().unwrap()
    $('*', $(element)).removeAttr('style')

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

  setSelection : (range) ->
    window.getSelection().addRange range

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

  # Handlers
  selectHandler : (dispatcher) =>
    return  unless @getAncestor(INPUT, dispatcher)
    range = @getRange()
    rect = range and range.getBoundingClientRect()
    container = @getAncestor(INPUT, dispatcher)
    if container
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
        @pillInput.trigger 'pillinput:pilldragstart', {pill:@pillInput.pillData($(pill))}
    else if (@inputContainsRange(range))
      @dragElement = @getElementsFromRange(range, true)
      @dragSource = @getAncestor(INPUT, range.commonAncestorContainer)
      data = @documentFragmentToString(@dragElement)

    if data
      e.originalEvent.dataTransfer.effectAllowed = ALL
      e.originalEvent.dataTransfer.setData(TEXT, data)
      e.stopPropagation()

  dragEndHandler : (e) =>
    # document.activeElement.blur()
    @dragSource = null

  dragEnterHandler : (e) =>
    target = e.target
    # if target.classList and target.classList.contains(DROP_ZONE)
    #   target.classList.add DRAG_OVER
    #   e.preventDefault()

  dragLeaveHandler : (e) =>
    target = e.target
    # if target.classList and target.classList.contains(DROP_ZONE)
    #   target.classList.remove DRAG_OVER
    #   e.preventDefault()

  dragOverHandler : (e) =>
    target = e.target
    e.preventDefault()  if target.contenteditable isnt "true" and not bowser.firefox

  dropHandler : (e) =>
    target = e.target
    wrapper = document.createElement(DIV)
    droppedObject = @pillInput.droppedObject()
    if droppedObject
      @pillInput._renderValue($(wrapper), [droppedObject])
    else
      wrapper.innerHTML = e.originalEvent.dataTransfer.getData(TEXT)
    target.classList.remove DRAG_OVER
    # if target.classList.contains(DROP_ZONE)
    #   unless target is @dragSource
    #     pills = @toArray(wrapper.querySelectorAll("." + PILL))
    #     pills.forEach (pill) ->
    #       target.appendChild pill
    #       return

    # else
    if target.classList.contains(INPUT)
      elements = @toArray(wrapper.childNodes)
      # jquery bug(?): event clientX/Y is undefined in drop
      @insertAtPosition elements, e.originalEvent.clientX, e.originalEvent.clientY
      if target is @dragSource
        @deleteSelection()
        @dragElement.parentNode.removeChild @dragElement  if @dragElement.classList and @dragElement.classList.contains(PILL)
    @sanitize(target)
    @clearSelection()
    @pillInput.trigger('pillinput:changed')
    # e.stopPropagation()
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
    @pillInput.trigger 'pillinput:changed'

  clickHandler : (e) =>
    # if e.target.classList.contains(PILL_BUTTON)
    #   @createPill()
    #   @clearSelection()
    #   @selectHandler getAncestor(INPUT, e.target.parentNode.querySelector("." + INPUT))
    # else
    pill = @getAncestor(PILL, e.target)
    input = @getAncestor(INPUT, e.target)
    arrow = e.target.className is ARROW
    rightButton = e.which is 3
    @selectHandler input
    return  if not pill or (not arrow and not rightButton)
    e.stopPropagation()
    e.preventDefault() # if e.type is CONTEXT_MENU
    @pillInput.trigger 'pillinput:pillclick', {
      pill: @pillInput.pillData($(pill))
      dom: $(pill)
    }
    # TODO @hideMenu()
    # TODO @showMenu pill

  mouseDownHandler : (e) =>
    #TODO @hideMenu()  if @menu and not menu.contains(e.target)
    @pillInput.dom.on(MOUSE_MOVE, @mouseMoveHandler)
    @pillInput.dom.on(MOUSE_UP, @mouseUpHandler)
    # document.addEventListener MOUSE_MOVE, @mouseMoveHandler
    # document.addEventListener MOUSE_UP, @mouseUpHandler
    @selectHandler e.target

  mouseMoveHandler : (e) =>
    @selectHandler e.target

  mouseUpHandler : (e) =>
    @pillInput.dom.off(MOUSE_MOVE)
    @pillInput.dom.off(MOUSE_UP)
    # document.removeEventListener MOUSE_MOVE, @mouseMoveHandler
    # document.removeEventListener MOUSE_UP, @mouseUpHandler
    @selectHandler e.target
    @pillInput.trigger 'pillinput:selection'

  blurHandler : (e) =>
    @selectHandler e.target

  copyHandler : (e) =>
    input = @getAncestor(INPUT, e.target)
    range = @getRange()
    if @inputContainsRange(range)
      elements = @toArray(@getElementsFromRange(range, true).childNodes)
      data = ""
      elements.forEach (element) ->
        switch element.nodeType
          when Node.TEXT_NODE
            data += element.data
          when Node.ELEMENT_NODE
            data += element.outerHTML

      e.originalEvent.clipboardData.setData TEXT, data
      e.preventDefault()

  cutHandler : (e) =>
    @copyHandler e
    input = @getAncestor(INPUT, e.target)
    range = @getRange()
    @deleteSelection()  if input and range

  pasteHandler : (e) =>
    input = @getAncestor(INPUT, e.target)
    if input
      wrapper = document.createElement(DIV)
      wrapper.innerHTML = e.originalEvent.clipboardData.getData(TEXT).replace(/\r?\n/g, ' ')
      elements = @toArray(wrapper.childNodes)
      @insert elements
      range = document.createRange()
      range.setStartAfter elements[elements.length - 1]
      @clearSelection()
      @setSelection range
      @selectHandler input
      e.preventDefault()
      @pillInput.trigger('pillinput:changed')


root = exports ? window
root.PillInput = PillInput
