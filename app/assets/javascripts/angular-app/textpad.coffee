angular.module('mbuilder').directive 'textpad', ->
  restrict: 'E'
  scope: {
    model: '='
  }
  templateUrl: 'textpad'
  link: (scope, elem, attrs) ->
    pillInput = new PillInput(
      $('.pillInput', elem),
      renderPill: (pill, dom) =>
        if pill.kind == 'literal'
          dom.text(pill.text).addClass('literal')
          return

        pillDesc = scope.$parent.lookupPillName(pill)

        if pillDesc
          dom.text(pillDesc).addClass('bound')
        else
          dom.text("???").addClass('unbound')

        if pill.kind == 'field_value'
          dom.append($("<span/>").addClass("arrow"))
          dom.prepend($("<span/>").addClass("aggregate").text(scope.$parent.aggregateLabel(pill.aggregate)))

      droppedObject: =>
        if window.draggedPill
          mbuilderToPillInputValue(window.draggedPill)
        else
          null
    )

    skipPillInputChange = false
    pillInput.on 'pillinput:changed', ->
      return if skipPillInputChange
      skipPillInputChange = true
      scope.$apply ->
        scope.model.splice(0, scope.model.length)
        for item in pillInput.value()
          scope.model.push(pillInputValueToMbuilder(item))
      skipPillInputChange = false

    pillInput.on 'pillinput:pilldragstart', (event, data) ->
      window.draggedPill = pillInputValueToMbuilder(data.pill)
      scope.$apply ->
        scope.$emit 'dragStart'


    updateInputDataFromScope = ->
      pillInput.value(_.map(scope.model, mbuilderToPillInputValue))

      # update labels of pills
      # for pill, i in scopeModelCopy
      #   if pill.kind == 'placeholder'
      #     textInputPill = input.getPillById(guidsByScopePillIndex[i])
      #     if not textInputPill?
      #       input.getPillById(guidsByScopePillIndex[i])
      #     textInputPill.label(scope.$parent.lookupPillName(pill))

    mbuilderToPillInputValue = (pill) ->
      if pill.kind == 'text'
        pill.guid # pills here seems to store the text in the guid property. this is why patternpad != textpad
      else
        pill

    pillInputValueToMbuilder = (value) ->
      if typeof(value) == 'string'
        {kind: 'text', guid: value}
      else
        value

    scope.$watch 'model', ->
      window.setTimeout updateInputDataFromScope, 0

    scope.$on 'onAllPillsChanged', ->
      window.setTimeout updateInputDataFromScope, 0

    scope.$on 'AggregateFuncionSelected', (e) ->
      window.setTimeout updateInputDataFromScope, 0
      e.stopPropagation()

    # context menu
    pillInput.on 'pillinput:pillclick', (e, data) ->
      pill = _.find scope.model, (elem) ->
        _.isEqual(elem, pillInputValueToMbuilder(data.pill))

      if pill.kind == 'field_value'
        popup_width = $(if scope.$parent.lookupTableByField(pill.guid).readonly
           '#aggregate-functions-error'
         else
           '#aggregate-functions').outerWidth()

        scope.$parent.tryShowAggregateFunctionsPopup pill, scope, {
          originalEvent : {
            pageX : data.dom.offset().left,
            pageY : data.dom.offset().top + data.dom.height() + 9
          },
          preventDefault : ->
          stopPropagation : ->
        }


