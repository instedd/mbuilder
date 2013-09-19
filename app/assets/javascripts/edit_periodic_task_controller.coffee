angular.module('mbuilder').controller 'EditPeriodicTaskController', ['$scope', '$http', ($scope, $http) ->
  $scope.tableAndFieldRebinds = []
  $scope.aggregateFunctionPopup = { pill: null }

  $scope.aggregates = [
    {id: null, name: 'List of values', ''},
    {id: 'count', name: 'Count of values', desc: 'count of'},
    {id: 'sum', name: 'Sum of values', desc: 'sum of'},
    {id: 'avg', name: 'Average of values', desc: 'average of'},
    {id: 'max', name: 'Maximum of values', desc: 'maximum of'},
    {id: 'min', name: 'Minimum of values', desc: 'minimum of'},
  ]

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
      else
        pill = $scope.lookupPillByGuid(pill.guid)
        pill?.text

  $scope.lookupJoinedFieldName = (fieldGuid) ->
    "#{$scope.lookupTableByField(fieldGuid)?.name} #{$scope.lookupFieldName(fieldGuid)}"

  $scope.lookupPillByGuid = (guid) ->
    _.find $scope.allPills(), (pill) -> pill.guid == guid

  $scope.lookupPill = (pill) ->
    pill

  $scope.allPills = ->
    $scope.pieces.concat $scope.implicitPills()

  $scope.implicitPills = ->
    [{text: $scope.from, guid:"phone_number"}]

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
      if action.table == tableGuid
        return action
    null

  $scope.lookupFieldAction = (fieldGuid) ->
    for action in $scope.actions
      if action.field == fieldGuid
        return action
    null

  $scope.lookupPillStatus = (pill) ->
    switch pill.kind
      when 'literal'
        return 'literal'
      when 'field_value'
        return 'field_value' if $scope.fieldExists(pill.guid)
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

  $scope.fieldValueDragStart = (fieldGuid) ->
    window.draggedPill = {kind: 'field_value', guid: fieldGuid}
    event.dataTransfer.setData("Text", $scope.lookupFieldName(fieldGuid))

  $scope.tableDragStart = (tableGuid, event) ->
    window.draggedPill = {kind: 'table_ref', guid: tableGuid}
    event.dataTransfer.setData("Text", $scope.lookupTableName(tableGuid))

  $scope.fieldDragStart = (fieldGuid, event) ->
    window.draggedPill = {kind: 'field_value', guid: fieldGuid}
    event.dataTransfer.setData("Text", $scope.lookupFieldName(fieldGuid))

  $scope.dragOverUnboundPill = (pill, event) ->
    event.preventDefault()
    true

  $scope.dropOverUnboundPill = (pill, event) ->
    $scope.replacePills(pill.guid, window.draggedPill)
    event.stopPropagation()

  $scope.dragOverUnboundTable = (tableGuid, event) ->
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

  $scope.hidePopupus = ->
    $('.popup').hide()

  $(window.document).click $scope.hidePopupus
  $(window.document).keydown (event) ->
    if event.keyCode = 27 # Esc
      $scope.hidePopupus()

  $scope.visitPills = (fun) ->
    for action in $scope.actions
      if action.pill
        fun(action.pill)

      if action.kind == 'send_message'
        for binding in action.message
          fun(binding)
        fun(action.recipient)

  $scope.replacePills = (guid, newPill) ->
    $scope.visitPills (otherPill) ->
      if otherPill.guid == guid
        otherPill.kind = newPill.kind
        otherPill.guid = newPill.guid

  $scope.save = ->
    data =
      name: $scope.name
      tables: $scope.tables
      schedule: $('#schedule_rule').val()

      actions: $scope.actions
      tableAndFieldRebinds: $scope.tableAndFieldRebinds

    if $scope.id?
      url = "/applications/#{$scope.applicationId}/periodic_tasks/#{$scope.id}"
      method = "put"
    else
      url = "/applications/#{$scope.applicationId}/periodic_tasks"
      method = "post"

    call = $http[method](url, JSON.stringify(data))
    call.success (data, status, headers, config) =>
      window.location = "/applications/#{$scope.applicationId}/periodic_tasks"
    call.error (data, status, headers, config) =>
      alert "Error: #{data}"
]
