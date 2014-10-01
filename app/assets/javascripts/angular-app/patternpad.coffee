angular.module('mbuilder').directive 'patternpad', ->
  restrict: 'E'
  templateUrl: 'patternpad'
  link: (scope, elem, attrs) ->
    # TODO add allowDrop: false option to PillInput
    pillInput = new PillInput(
      $('.pillInput', elem),
      renderPill: (pill, dom) =>
        dom.text(pill.text).addClass('placeholder')
    )

    skipPillInputChange = false
    pillInput.on 'pillinput:changed', ->
      return if skipPillInputChange
      skipPillInputChange = true
      scope.$apply ->
        scope.pieces.splice(0, scope.pieces.length)
        for item in pillInput.value()
          scope.pieces.push(pillInputValueToMbuilder(item))
        scope.$emit 'onPatternpadPicesChanged'
      skipPillInputChange = false

    pillInput.on 'pillinput:pilldragstart', (event, data) ->
      window.draggedPill = pillInputValueToMbuilder(data.pill)
      scope.$apply ->
        scope.$emit 'dragStart'

    pillInput.on 'pillinput:selection', (event, data) ->
      pillInput.replaceSelectedTextWith({
        kind:'placeholder',
        text: pillInput.selectedText(),
        guid: window.guid()
      })

    updateInputDataFromScope = ->
      pillInput.value(_.map(scope.pieces, mbuilderToPillInputValue))

    mbuilderToPillInputValue = (pill) ->
      if pill.kind == 'text'
        pill.text # pills here seems to store the text in the guid property. this is why patternpad != textpad
      else
        pill

    pillInputValueToMbuilder = (value) ->
      if typeof(value) == 'string'
        {kind: 'text', text: value, guid: window.guid()}
      else
        value

    scope.$watch 'pieces', ->
      window.setTimeout updateInputDataFromScope, 0
