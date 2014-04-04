angular.module('mbuilder').directive 'patternpad', ->
  restrict: 'E'
  templateUrl: 'patternpad'
  link: (scope, elem, attrs) ->
    svgInput = $('.svgInput', elem)

    scope.textselection = ''

    input = new TextInput(svgInput[0]);
    input.GUIDgenerator = window.guid;
    input.autoExpand(true);
    input.addEventListener Event.SELECT, (e) ->
      scope.$apply ->
        scope.textselection = input.selectionText(e.info.start, e.info.end)

    scope.createPill = ->
      # in order to exit angular event loop.
      # because the Event.SELECT uses $apply
      window.setTimeout ->
        input.createPill()
        ensureSpacesAroundPills()
        updateScopeFromInputData()
      , 0

    updateInputDataFromScope = ->
      inputData = []
      for pill in scope.pieces
        if pill.kind == 'text'
          inputData.push pill.text
        else if pill.kind == 'placeholder'
          inputData.push {
            id: pill.guid
            text: pill.text
            hasMenu : false
          }
      input.data(inputData)

    ensureSpacesAroundPills = ->
      data = []
      originalData = input.data()
      moveCarretToEnd = false
      for item, i in originalData
        if typeof(item) == 'string'
          # space before a pill
          if !/\s/.test(_.last(item)) && i < originalData.length - 1
            item = item + ' '
          # space after a pill
          if !/\s/.test(_.first(item)) && i > 0
            item = ' ' + item
            if i == originalData.length - 1
              moveCarretToEnd = true
        else
          # two pills together
          if data.length > 0 && typeof(_.last(data)) != 'string'
            data.push ' '
        unless i == originalData.length - 1 && i == ' '
          data.push item

      if !_.isEqual(input.data(), data)
        input.data(data)
        input.render()
        if moveCarretToEnd
          window.setTimeout ->
            input.caret(Number.MAX_VALUE, false)
          , 0

    updateScopeFromInputData = ->
      scope.$apply ->
        newPieces = []
        for item in input.data()
          newPieces.push(inputDataToMbuilderPill(item))

        args = [0, scope.pieces.length].concat(newPieces)
        Array.prototype.splice.apply(scope.pieces, args)
      scope.$emit 'onPatternpadPicesChanged'

    inputDataToMbuilderPill = (item) ->
      if typeof(item) == 'string'
        { kind: 'text', text: item, guid: window.guid() }
      else
        { kind: 'placeholder', text: item.text, guid: item.id }

    updateInputDataFromScope()
    ensureSpacesAroundPills()
    input.render();

    skipInputChange = false
    input.addEventListener Event.CHANGE, (e) ->
      return if skipInputChange
      skipInputChange = true
      ensureSpacesAroundPills()
      updateScopeFromInputData()
      skipInputChange = false

    phantom = null

    mouseHandler = (e) ->
      mouse = mousePosition(e)
      phantom.style.left = mouse.x + "px"
      phantom.style.top = mouse.y + "px"

    input.addEventListener Event.DRAG, (e) ->
      window.draggedPill = inputDataToMbuilderPill(e.info.pill)
      phantom = document.body.appendChild(e.info.phantom)
      phantom.style.position = "absolute"
      phantom.style.opacity = 0.5
      phantom.style.left = e.info.mouseX + "px"
      phantom.style.top = e.info.mouseY + "px"
      window.addEventListener("mousemove", mouseHandler)

    input.addEventListener Event.DROP, (e) ->
      if phantom != null && phantom.parentNode
        phantom.parentNode.removeChild(phantom)
      window.removeEventListener("mousemove", mouseHandler)
      ensureSpacesAroundPills()

    # svgInput.mouseup ->
    #   window.draggedPill = null
