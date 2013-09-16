class @MessageParser
  constructor: (element) ->
    @element = element

  onText: (fun) ->
    @onText = fun
    this

  onPill: (fun) ->
    @onPill = fun
    this

  lastPieceNeeded: (fun) ->
    @lastPieceNeeded = fun

  parse: ->
    sel = window.getSelection()
    if sel.rangeCount > 0
      @range = sel.getRangeAt(0)
      if @range.startOffset != @range.endOffset
        @selNode = sel.anchorNode
        if @selNode.nodeName == "#text" && $.trim(@selNode.textContent).length == 0
          @selNode = sel.focusNode

    lastPiece = null

    i = 0
    while i < @element.childNodes.length
      node = @element.childNodes[i]
      if node.nodeName == "#text"
        @onText(node.textContent, node == @selNode)
        @element.removeChild(node)
      else
        i += 1

        if $(node).hasClass('piece-container')
          j = 0
          while j < node.childNodes.length
            child = node.childNodes[j]
            if child.localName == "div"
              $child = $(child)
              if $child.hasClass('pill')
                if $child.css('display') == 'none'
                  j += 1
                  continue

                @onPill($child)
              else if $(child).hasClass('text')
                content = child.childNodes[0]
                @onText(content.textContent, content == @selNode)
              j += 1
            else if child.nodeName == "#comment"
              # Skip
              j += 1
            else
              @onText(child.textContent, child == @selNode)
              node.removeChild(child)
        else if $(node).hasClass('last-piece')
          lastPiece = node

          j = 0
          while j < node.childNodes.length
            child = node.childNodes[j]
            if child.nodeName == "#text"
              @onText(child.textContent, child == @selNode)
              unless child.textContent.length == 1 && child.textContent.charCodeAt(160)
                child.textContent = String.fromCharCode(160)
            j += 1

    lastPieceNeeded = @lastPieceNeeded()
    if lastPiece && !lastPieceNeeded
      lastPiece.parentNode.removeChild(lastPiece)
    else if !lastPiece && lastPieceNeeded
      MessageParser.appendLastPieceTo(@element)

  @appendLastPieceTo: (element) ->
    span = document.createElement("span")
    span.className = "last-piece"
    span.innerText = String.fromCharCode(160)
    element.appendChild(span)

