angular.module('mbuilder').directive 'pilltextarea', ->
  restrict: 'E'
  scope: {
    model: '='
  }
  templateUrl: 'pilltextarea'
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
        updateScopeFromInputData()
      , 0

    updateInputDataFromScope = ->
      inputData = []
      for pill in scope.model
        if pill.kind == 'text'
          inputData.push pill.text
        else if pill.kind == 'placeholder'
          inputData.push {
            id: pill.guid
            text: pill.text
          }
      input.data(inputData)
      # input.data(["Hola mundo", {id:"116afaa1-89a5-c86c-e03d-83dd5fab97be", text:"this is a pill far too wide", operator:undefined},"! new line"]);

    updateScopeFromInputData = ->
      scope.$apply ->
        scope.model.splice(0, scope.model.length)
        for item in input.data()
          if typeof(item) == 'string'
            scope.model.push { kind: 'text', text: item, guid: window.guid() }
          else
            scope.model.push { kind: 'placeholder', text: item.text, guid: item.id }

    updateInputDataFromScope()
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

    input.addEventListener Event.CHANGE, (e) ->
      updateScopeFromInputData()
    input.addEventListener Event.CONTEXT_MENU, contextMenuHandler

