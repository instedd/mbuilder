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

    updateInputDataFromScope = ->
      inputData = []
      guidsByScopePillIndex = {}
      scopeModelCopy = scope.model.slice(0)
      for pill, i in scopeModelCopy
        if pill.kind == 'text'
          inputData.push pill.guid # pills here seems to store the text in the guid property. this is why pilltextarea != textpad
        else if pill.kind == 'placeholder'
          guidsByScopePillIndex[i] = window.guid()
          inputData.push {
            id: guidsByScopePillIndex[i] # pill guid refers to field id. no identity :-(
            text: pill.guid
          }
        else
          console.error('Unsupported pill kind: ' + pill.kind)

      input.data(inputData)
      input.render()

      # update labels of pills
      for pill, i in scopeModelCopy
        if pill.kind == 'placeholder'
          textInputPill = input.getPillById(guidsByScopePillIndex[i])
          if not textInputPill?
            input.getPillById(guidsByScopePillIndex[i])
          textInputPill.label(scope.$parent.lookupPillName(pill))

      console.log(scope.model)


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
        { kind: 'placeholder', guid: item.text }

    # updateInputDataFromScope()
    scope.$watch 'model', ->
      window.setTimeout updateInputDataFromScope, 0

    ensureSpacesAroundPills()
    input.render();

    _contextMenu = null
    contextMenuHandler = (e) ->
      console.log "CONTEXT_MENU"
      if(_contextMenu != null && _contextMenu.parentNode)
        _contextMenu.parentNode.removeChild(_contextMenu)

      _contextMenu = document.body.appendChild(document.createElement("div"))
      _contextMenu.style.position = "absolute"
      _contextMenu.style.backgroundColor = "#cccccc"
      _contextMenu.style.border = "1px solid #999999"
      addOption "Break", null, _contextMenu, e.info, ->
        input.breakPill(e.info.pill)
        _contextMenu.parentNode.removeChild(_contextMenu)
        _contextMenu = null
        input.render()

      x = e.info.mouseX || e.info.pill.x();
      y = e.info.mouseY || e.info.pill.y();
      if(e.info.eventAt == "arrow")
        x -= _contextMenu.getBoundingClientRect().width;
        y += 5;

      _contextMenu.style.left = x + "px";
      _contextMenu.style.top = y + "px";
      document.addEventListener "mousedown", (e) ->
        if(!_contextMenu.contains(e.target) && _contextMenu.parentNode)
          _contextMenu.parentNode.removeChild(_contextMenu)

    addOption = (label, option, menu, info, customHandler) ->
      button = menu.appendChild(document.createElement("button"))
      button.innerHTML = label
      button.style.display = "block"
      button.style.width = "100%"
      button.onclick = customHandler || (e) ->
        info.pill.operator(option);

        label = document.createElementNS("http://www.w3.org/2000/svg", "text")
        if option != null
          operator = document.createElementNS("http://www.w3.org/2000/svg", "tspan")
          operator.setAttribute("class", "operator")
          operator.textContent = option + " of "
          label.appendChild(operator);

        label.appendChild(document.createTextNode(info.pill.text()))
        info.pill.label(label)
        menu.parentNode.removeChild(menu)
        input.render()

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
      if phantom.parentNode
        phantom.parentNode.removeChild(phantom)
      window.removeEventListener("mousemove", mouseHandler)
      ensureSpacesAroundPills()

