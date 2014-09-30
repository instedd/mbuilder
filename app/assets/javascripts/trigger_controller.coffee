angular.module('mbuilder').controller 'TriggerController', ['$scope', '$http', '$document', '$timeout', ($scope, $http, $document, $timeout) ->
  $scope.tableAndFieldRebinds = []

  $scope.aggregateFunctionPopup = { pill: null }
  $scope.aggregates = [
    {id: null, name: 'List of values', ''},
    {id: 'count', name: 'Count of values', desc: 'count of'},
    {id: 'total', name: 'Sum of values', desc: 'sum of'},
    {id: 'mean', name: 'Average of values', desc: 'average of'},
    {id: 'max', name: 'Maximum of values', desc: 'maximum of'},
    {id: 'min', name: 'Minimum of values', desc: 'minimum of'},
  ]

  $scope.ifOperatorsPopup = { action: null }

  $scope.ifOperatorsPlural = [
    {id: '==', desc: 'equals'},
    {id: '!=', desc: 'does not equal'},
    {id: 'contains', desc: 'contains'},
    {id: '<', desc: 'is less than'},
    {id: '>', desc: 'is greater than'},
    {id: 'between', desc: 'is between'},
    {id: 'not between', desc: 'is not between'},
  ]

  $scope.ifOperatorsSingular = [
    {id: '==', desc: 'equal'},
    {id: '!=', desc: 'do not equal'},
    {id: 'contains', desc: 'contain'},
    {id: '<', desc: 'are less than'},
    {id: '>', desc: 'are greater than'},
    {id: 'between', desc: 'are between'},
    {id: 'not between', desc: 'are not between'},
  ]

  $scope.ifAggregatesPopup = { action : null }
  $scope.ifAggregates = [
    {id: true, desc: 'all of'},
    {id: false, desc: 'any of'},
  ]

  $scope.validValuesPopup = { field: null }
  $scope.tableColumnPopup = { field: null }

  $scope.selectedAction = null

  for name in ['pillOverFieldName', 'pillOverFieldValue']
    do(name) ->
      $scope.$on name, (event, args) ->
        unless event.targetScope == event.currentScope
          $scope.$broadcast name, args

  $scope.$on 'addSendMessageActionUp', (event, args) ->
    $scope.$broadcast 'addSendMessageActionDown', args

  $scope.$watch 'actions', ->
    # deep watch on actions
    $scope._checkActionState()
  , true

  $scope._checkActionState = ->
    $scope.visitActions $scope.actions, (pill) ->
      null
    , (action) ->
      # ensure all non first store_entity_value had create_or_update flag in false
      # not required by backend, but cleaner
      if action.kind == 'store_entity_value' && !$scope.isFirstStoreAfterSelect(action)
        action.create_or_update = false

  $scope.data = (node) ->
    newData = {}
    for key, value of node.data()
      newData[key] = value unless key[0] == '$'
    newData

  $scope.tableExists = (tableGuid) ->
    table = $scope.lookupTable(tableGuid)
    return false unless table

    true

  $scope.lookupPillName = (pill) ->
    switch pill.kind
      when 'field_value'
        $scope.lookupJoinedFieldName(pill.guid)
      when 'parameter'
        pill = $scope.lookupPillByGuid(pill.guid)
        pill?.name
      else
        pill = $scope.lookupPillByGuid(pill.guid)
        pill?.text

  $scope.lookupJoinedFieldName = (fieldGuid) ->
    "#{$scope.lookupTableByField(fieldGuid)?.name} #{$scope.lookupFieldName(fieldGuid)}"

  $scope.lookupPillByGuid = (guid) ->
    _.find $scope.allPills(), (pill) -> pill.guid == guid

  $scope.lookupPill = (pill) ->
    pill

  # $scope.allPills = -> subclass responsibility
  # $scope.implicitPills = -> subclass responsibility

  $scope.lookupTable = (guid) ->
    _.find $scope.tables, (table) -> table.guid == guid

  $scope.lookupTableName = (guid) ->
    $scope.lookupTable(guid)?.name

  $scope.lookupTableByField = (fieldGuid) ->
    _.find($scope.tables, (table) -> _.any(table.fields, (field) -> field.guid == fieldGuid))

  $scope.lookupFieldName = (fieldGuid) ->
    table = $scope.lookupTableByField(fieldGuid)
    return "" unless table

    field = _.find table.fields, (field) -> field.guid == fieldGuid
    field?.name

  $scope.lookupTableAction = (tableGuid) ->
    for action in $scope.actions
      if action.table == tableGuid && action.kind != 'group_by'
        return action
    null

  $scope.lookupFieldAction = (fieldGuid) ->
    for action in $scope.actions
      if action.field == fieldGuid && action.kind != 'group_by'
        return action
    null

  $scope.lookupPillStatus = (pill) ->
    switch pill.kind
      when 'literal'
        return 'literal'
      when 'field_value'
        return 'field_value' if $scope.fieldExists(pill.guid)
      when 'parameter'
        return 'parameter' if $scope.lookupPillByGuid(pill.guid)
      else
        return 'placeholder' if $scope.lookupPillByGuid(pill.guid)
    'unbound'

  $scope.pillTemplateFor = (field) ->
    status = $scope.lookupPillStatus(field)
    $scope.fieldNameFor(status)

  $scope.pieceTemplateFor = (kind) ->
    "#{kind}_piece"

  $scope.fieldNameFor = (status) ->
    "#{status}_pill"

  $scope.fieldExists = (fieldGuid) ->
    !!$scope.lookupTableByField(fieldGuid)

  $scope.dragPill = (pill) ->
    window.draggedPill = pill
    event.dataTransfer.setData("Text", $scope.lookupPillName(pill))
    event.stopPropagation()
    $scope.$emit 'dragStart'

  $scope.fieldValueDragStart = (fieldGuid) ->
    window.draggedPill = {kind: 'field_value', guid: fieldGuid}
    event.dataTransfer.setData("Text", $scope.lookupFieldName(fieldGuid))
    $scope.$emit 'dragStart'

  $scope.tableDragStart = (tableGuid, event) ->
    window.draggedPill = {kind: 'table_ref', guid: tableGuid}
    event.dataTransfer.setData("Text", $scope.lookupTableName(tableGuid))
    $scope.$emit 'dragStart'

  $scope.fieldDragStart = (fieldGuid, event) ->
    window.draggedPill = {kind: 'field_value', guid: fieldGuid}
    event.dataTransfer.setData("Text", $scope.lookupFieldName(fieldGuid))
    $scope.$emit 'dragStart'

  body = $document.find('body')
  $scope.$on 'dragStart', (event) ->
    if window.draggedPill?
      if window.draggedPill.kind == 'table_ref'
        $timeout( ->
          body.addClass 'dragging-table'
        , 200)
      else
        $timeout( ->
          body.addClass 'dragging-pill'
        , 200)

    if window.draggedAction?
      $timeout( ->
        body.addClass 'dragging-action'
      , 200)

  $scope.$on 'dragEnd', (event) ->
    body.removeClass('dragging-table').removeClass('dragging-pill').removeClass('dragging-action')

  $scope.dragOverUnboundPill = (pill, event) ->
    event.preventDefault()
    true

  $scope.dropOverUnboundPill = (pill, event) ->
    $scope.replacePills(pill.guid, window.draggedPill)
    event.stopPropagation()

  $scope.dragOverUnboundTable = (tableGuid, event) ->
    return false unless window.draggedPill
    return false if window.draggedPill.kind != 'table_ref'

    event.preventDefault()
    true

  $scope.dropOverUnboundTable = (tableGuid, event) ->
    $scope.tableAndFieldRebinds.push kind: 'table', from: tableGuid, to: window.draggedPill.guid

    for action in $scope.actions
      if action.table == tableGuid
        action.table = window.draggedPill.guid

    event.stopPropagation()

  $scope.dragOverUnboundField = (fieldGuid, event) ->
    return false unless window.draggedPill
    return false if window.draggedPill.kind != 'field_ref'

    event.preventDefault()
    true

  $scope.dropOverUnboundField = (destinationPillGuid, event) ->
    draggedPillGuid = window.draggedPill.guid

    draggedPillTableGuid = $scope.lookupTableByField(draggedPillGuid).guid

    $scope.tableAndFieldRebinds.push kind: 'field', fromField: destinationPillGuid, toField: draggedPillGuid

    for action in $scope.actions
        if action.field == destinationPillGuid
          action.field = draggedPillGuid
          action.table = draggedPillTableGuid

    event.stopPropagation()

  $scope.dragOverBoard = (event) ->
    false

  $scope.mouseEnterOverBoard = (event) ->
    $scope.dragOverBoard(event)

  $scope.dropOverBoard = (event) ->
    console.log 'dropOverBoard'
    window.draggedPill = null
    event.stopPropagation()
    event.preventDefault()
    $scope.$emit 'dragEnd'
    false

  $scope.mouseDropOverBoard = (event) ->
    console.log 'mouseDropOverBoard'
    $scope.dropOverBoard(event)

  $scope.hidePopups = ->
    if $scope.validValuesPopup.field
      $scope.validValuesPopup.field.active = false
    $('.popup').hide()

  $(window.document).click (event) ->
    unless $(event.target).closest($('.popup')).length > 0
      $scope.hidePopups()

  $(window.document).keydown (event) ->
    if event.keyCode == 27 # Esc
      $scope.hidePopups()

  $scope.visitPills = (fun) ->
    $scope.visitActions $scope.actions, fun

  $scope.visitActions = (actions, fun, actionsFun) ->
    for action in actions
      actionsFun(action) if actionsFun?

      if action.pill
        fun(action.pill)

      switch action.kind
        when 'send_message'
          for binding in action.message
            fun(binding)
          fun(action.recipient)
        when 'foreach'
          $scope.visitActions action.actions, fun, actionsFun
        when 'if'
          for right in action.right
            fun(right)
          $scope.visitActions action.actions, fun, actionsFun

  $scope.firstActionThat = (filter) ->
    first_action = null

    $scope.visitActions $scope.actions, (pill) ->
      null
    , (action) ->
      if filter(action) && first_action == null
        first_action = action

    first_action

  $scope.tableIsUsedInASelectAction = (tableGuid) ->
    ($scope.firstActionThat (action) ->
      return action.kind == "select_entity" and action.table == tableGuid
    ) != null

  $scope.isFirstFilter = (action) ->
    ($scope.firstActionThat (a) ->
      return a.kind == "select_entity" and a.table == action.table
    ) == action

  $scope.isFirstStoreAfterSelect = (action) ->
    $scope.tableIsUsedInASelectAction(action.table) and ($scope.firstActionThat (a) ->
      return a.kind == "store_entity_value" and a.table == action.table
    ) == action

  $scope.replacePills = (guid, newPill) ->
    $scope.visitPills (otherPill) ->
      if otherPill.guid == guid
        otherPill.kind = newPill.kind
        otherPill.guid = newPill.guid

  $scope.showPopup = (id, event) ->
    $scope.hidePopups()

    div = $(id)
    div.css left: event.originalEvent.pageX, top: event.originalEvent.pageY
    div.show()
    event.preventDefault()
    event.stopPropagation()

  $scope.selectAction = (action, event) ->
    $scope.hidePopups()
    if $scope.selectedAction == action
      $scope.unselectAction()
    else
      $scope.selectedAction = action
    event.stopPropagation()

  $scope.actionIsSelected = (action) ->
    $scope.selectedAction == action

  $scope.unselectAction = ->
    $scope.selectedAction = null

  $scope.showAggregateFunctionsPopup = (pill, actionScope, event) ->
    $scope.aggregateFunctionPopup.pill = pill
    $scope.aggregateFunctionPopup.actionScope = actionScope
    id = if $scope.lookupTableByField(pill.guid).readonly
           '#aggregate-functions-error'
         else
           '#aggregate-functions'
    $scope.showPopup id, event

  $scope.aggregateLabel = (aggregate) ->
    aggregate = null unless aggregate
    _.find($scope.aggregates, (a) -> a.id == aggregate).desc

  $scope.showIfOperatorsPopup = (action, event) ->
    $scope.ifOperatorsPopup.action = action
    selectedValue = !! action.all
    gramaticalNumber = if selectedValue then 'singular' else 'plural'
    $scope.showPopup ("#if-operators-" + gramaticalNumber), event

  $scope.ifOperatorDescription = (op, ifAggregator) ->
    ifAggregator = !!ifAggregator
    operators = if ifAggregator then $scope.ifOperatorsSingular else $scope.ifOperatorsPlural
    _.find(operators, (a) -> a.id == op).desc

  $scope.showIfAggregatesPopup = (action, event) ->
    $scope.ifAggregatesPopup.action = action
    $scope.showPopup '#if-aggregates', event

  $scope.ifAggregateDescription = (aggregate) ->
    aggregate = !!aggregate
    _.find($scope.ifAggregates, (a) -> a.id == aggregate).desc
]
