angular.module('mbuilder').controller 'EditTriggerController', ['$scope', '$http', ($scope, $http) ->
  $scope.tableAndFieldRebinds = []

  $scope.pieceTemplateFor = (kind) ->
    "#{kind}_piece"

  $scope.pillTemplateFor = (pill) ->
    status = $scope.lookupPillStatus(pill)
    "#{status}_pill"

  $scope.tableExists = (tableGuid) ->
    table = $scope.lookupTable(tableGuid)
    return false unless table

    true

  $scope.lookupPillName = (pill) ->
    switch pill.kind
      when 'field_value'
        $scope.lookupJoinedFieldName(pill.guid)
      else
        pill = $scope.lookupPill(pill.guid)
        pill?.text

  $scope.lookupJoinedFieldName = (fieldGuid) ->
    "#{$scope.lookupTableByField(fieldGuid)?.name} #{$scope.lookupFieldName(fieldGuid)}"

  $scope.lookupPill = (guid) ->
    _.find $scope.allPills(), (piece) -> piece.guid == guid

  $scope.allPills = ->
    $scope.pieces.concat $scope.implicitPills()

  $scope.implicitPills = ->
    [{text: $scope.from, guid:"phone number"}]

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



  $scope.lookupFieldAction = (fieldGuid) ->
    for action in $scope.actions
      if action.field == fieldGuid
        return action
    null

  $scope.lookupPillStatus = (pill) ->
    pill = if pill.kind == 'field_value'
      $scope.fieldExists(pill.guid)
    else
      $scope.lookupPill(pill.guid)

    if pill
      'bound'
    else
      'unbound'

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
    window.draggedPill = {kind: 'field_ref', guid: fieldGuid}
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

    destinationTableGuid = $scope.lookupTableByField(destinationPillGuid).guid
    draggedPillTableGuid = $scope.lookupTableByField(draggedPillGuid).guid

    $scope.tableAndFieldRebinds.push kind: 'field', fromTable: destinationTableGuid, toTable: draggedPillTableGuid, fromField: destinationPillGuid, toField: draggedPillGuid

    for action in $scope.actions
      if action.table == destinationTableGuid
        action.table = draggedPillTableGuid
        if action.field == destinationPillGuid
          action.field = draggedPillGuid

    event.stopPropagation()

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
      message:
        from: $scope.from
        pieces: $scope.pieces
      actions: $scope.actions
      tableAndFieldRebinds: $scope.tableAndFieldRebinds

    if $scope.id?
      url = "/applications/#{$scope.applicationId}/triggers/#{$scope.id}"
      method = "put"
    else
      url = "/applications/#{$scope.applicationId}/triggers"
      method = "post"

    call = $http[method](url, JSON.stringify(data))
    call.success (data, status, headers, config) =>
      window.location = "/applications/#{$scope.applicationId}/triggers"
    call.error (data, status, headers, config) =>
      alert "Error: #{data}"
]