class @MessageParser
  constructor: (element) ->
    @element = element

  onText: (fun) ->
    @onText = fun
    this

  onPill: (fun) ->
    @onPill = fun
    this

  parse: ->
    sel = window.getSelection()
    if sel.rangeCount > 0
      @range = sel.getRangeAt(0)
      if @range.startOffset != @range.endOffset
        @selNode = sel.baseNode

    foundLastPiece = false

    i = 0
    while i < @element.childNodes.length
      node = @element.childNodes[i]
      if node.nodeName == "#text"
        @onText(node.textContent, node == @selNode)
        @element.removeChild(node)
      else
        i += 1

        if $(node).hasClass('piece-container')
          children = node.childNodes

          j = 0
          while j < children.length
            child = children[j]
            if child.localName == "div"
              $child = $(child)
              if $child.hasClass('pill')
                @onPill($child)
              else if $(child).hasClass('text')
                content = child.childNodes[0]
                @onText(content.textContent, content == @selNode)
              j += 1
            else
              @onText(child.textContent, child == @selNode)
              node.removeChild(child)
        else if $(node).hasClass('last-piece')
          foundLastPiece = true
          children = node.childNodes

          j = 0
          while j < children.length
            child = children[j]
            if child.nodeName == "#text"
              @onText(child.textContent, false)
              unless child.textContent.length == 1 && child.textContent.charCodeAt(160)
                child.textContent = String.fromCharCode(160)
            j += 1

    unless foundLastPiece
      span = document.createElement("span")
      span.className = "last-piece"
      span.innerText = String.fromCharCode(160)
      @element.appendChild(span)
