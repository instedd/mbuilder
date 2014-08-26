angular.module('mbuilder').directive 'textpad', ->
  restrict: 'E'
  scope: {
    model: '='
  }
  templateUrl: 'textpad'
  link: (scope, elem, attrs) ->
    svgInput = $('.svgInput', elem)

    scope.textselection = ''

    input = new TextInput(svgInput[0]);
    input.autoExpand(true);
    input.isForeignObjectDragged = ->
      return window.draggedPill != null

    updateInputDataFromScope = ->
      inputData = []
      scopeModelCopy = scope.model.slice(0)
      for pill in scopeModelCopy
        inputData.push(mbuilderToInputDataPill(pill))
      input.data(inputData)
      input.render()

      # update labels of pills
      # for pill, i in scopeModelCopy
      #   if pill.kind == 'placeholder'
      #     textInputPill = input.getPillById(guidsByScopePillIndex[i])
      #     if not textInputPill?
      #       input.getPillById(guidsByScopePillIndex[i])
      #     textInputPill.label(scope.$parent.lookupPillName(pill))

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
        scope.model.splice(0, scope.model.length)
        for item in input.data()
          scope.model.push(inputDataToMbuilderPill(item))

    inputDataToMbuilderPill = (item) ->
      if typeof(item) == 'string'
        { kind: 'text', guid: item }
      else
        item.data.mbuilder_pill

    mbuilderToInputDataPill = (pill) ->
      if pill.kind == 'text'
        pill.guid # pills here seems to store the text in the guid property. this is why patternpad != textpad
      else if pill.kind == 'placeholder' || pill.kind == 'field_value'
        {
          id: window.guid() # pill guid refers to field id. no identity :-(
          text: pill.guid
          label: labelForMbuilderPill(pill)
          hasMenu: pill.kind == 'field_value'
          data: {
            mbuilder_pill: pill
          }
        }

    labelForMbuilderPill = (pill) ->
      aggDesc = scope.$parent.aggregateLabel(pill.aggregate)
      pillDesc = scope.$parent.lookupPillName(pill)
      pillDesc = "???" unless pillDesc

      label = document.createElementNS("http://www.w3.org/2000/svg", "text")
      if aggDesc
        aggregate = document.createElementNS("http://www.w3.org/2000/svg", "tspan")
        aggregate.setAttribute("class", "aggregate")
        aggregate.textContent = aggDesc + ' '
        label.appendChild(aggregate)
      label.appendChild(document.createTextNode(pillDesc))

      label

    # updateInputDataFromScope()
    scope.$watch 'model', ->
      window.setTimeout updateInputDataFromScope, 0

    scope.$on 'onAllPillsChanged', ->
      window.setTimeout updateInputDataFromScope, 0

    scope.$on 'AggregateFuncionSelected', (e) ->
      window.setTimeout updateInputDataFromScope, 0
      e.stopPropagation()

    ensureSpacesAroundPills()
    input.render();

    # begin context menu
    pillContextMenu = false

    svgInput.click (e) ->
      if pillContextMenu
        e.stopPropagation()
        e.preventDefault()
      else
        scope.$parent.hidePopups()
      pillContextMenu = false

    contextMenuHandler = (e) ->
      pill = e.info.pill.data().mbuilder_pill
      if pill.kind == 'field_value'

        popup_width = $(if scope.$parent.lookupTableByField(pill.guid).readonly
           '#aggregate-functions-error'
         else
           '#aggregate-functions').outerWidth()

        scope.$parent.tryShowAggregateFunctionsPopup pill, scope, {
          originalEvent : {
            pageX : e.info.mouseX - popup_width + 1,
            pageY : e.info.mouseY + 2
          }
          preventDefault : ->
            pillContextMenu = true
            return
          stopPropagation : ->
            pillContextMenu = true
            return
        }
      else
        console.log 'no popup to show for ', e

    skipInputChange = false
    input.addEventListener Event.CHANGE, (e) ->
      return if skipInputChange
      skipInputChange = true
      ensureSpacesAroundPills()
      updateScopeFromInputData()
      skipInputChange = false

    input.addEventListener Event.CONTEXT_MENU, contextMenuHandler

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
      if e.info.pill != null
        # drag&drop inside pill
        if phantom != null && phantom.parentNode
          phantom.parentNode.removeChild(phantom)
        window.removeEventListener("mousemove", mouseHandler)
        ensureSpacesAroundPills()
      else
        if window.draggedPill
          pill = mbuilderToInputDataPill(window.draggedPill)
          input.insertPillAtCaret(pill.id, pill.label, pill.text, pill.hasMenu, pill.data)
      window.draggedPill = null

