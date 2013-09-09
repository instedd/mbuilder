angular.module('mbuilder').controller 'EditTriggerController', ['$scope', '$http', ($scope, $http) ->
  $scope.tableAndFieldRebinds = []

  $scope.actionTemplateFor = (kind) ->
    "#{kind}_action"

  $scope.pieceTemplateFor = (kind) ->
    "#{kind}_piece"

  $scope.bindingTemplateFor = (kind) ->
    "#{kind}_binding"

  $scope.pillTemplateFor = (pill) ->
    status = $scope.lookupPillStatus(pill)
    "#{status}_pill"

  $scope.fieldTemplateFor = (tableGuid, fieldGuid) ->
    status = $scope.lookupFieldStatus(tableGuid, fieldGuid)
    "#{status}_field"

  $scope.lookupTable = (guid) ->
    _.find $scope.tables, (table) -> table.guid == guid

  $scope.lookupTableName = (guid) ->
    $scope.lookupTable(guid)?.name

  $scope.lookupFieldName = (tableGuid, fieldGuid) ->
    table = $scope.lookupTable(tableGuid)
    return "" unless table

    field = _.find table.fields, (field) -> field.guid == fieldGuid
    field?.name

  $scope.lookupJoinedFieldName = (tableFieldGuid) ->
    [tableGuid, fieldGuid] = tableFieldGuid.split(';')
    tableName = $scope.lookupTableName(tableGuid)
    fieldName = $scope.lookupFieldName(tableGuid, fieldGuid)
    "#{tableName} #{fieldName}"

  $scope.lookupFieldAction = (tableGuid, fieldGuid) ->
    for action in $scope.actions
      if action.table == tableGuid && action.field == fieldGuid
        return action

    null

  $scope.lookupFieldStatus = (tableGuid, fieldGuid) ->
    action = $scope.lookupFieldAction(tableGuid, fieldGuid)
    if action
      return $scope.lookupPillStatus(action.pill)

    tableAction = _.find $scope.actions, (action) -> action.table == tableGuid
    if tableAction?.kind == 'select_entity'
      return 'existing'

    'new'

  $scope.lookupFieldValue = (tableGuid, fieldGuid) ->
    action = $scope.lookupFieldAction(tableGuid, fieldGuid)
    if action
      return $scope.lookupPillName(action.pill)

    null

  $scope.fieldExists = (tableGuid, fieldGuid) ->
    table = $scope.lookupTable(tableGuid)
    return false unless table

    field = _.find table.fields, (field) -> field.guid == fieldGuid
    return false unless field

    true

  $scope.tableExists = (tableGuid) ->
    table = $scope.lookupTable(tableGuid)
    return false unless table

    true

  $scope.lookupPillStatus = (pill) ->
    switch pill.kind
      when 'implicit'
        return 'bound'
      when 'field_value'
        return 'field_value'
      else
        pill = _.find $scope.pieces, (piece) -> piece.guid == pill.guid
        return 'bound' if pill

        'unbound'

  $scope.lookupPillName = (pill) ->
    switch pill.kind
      when 'implicit'
        $scope.lookupImplicitBinding(pill.guid)
      when 'field_value'
        $scope.lookupJoinedFieldName(pill.guid)
      else
        pill = $scope.lookupPill(pill.guid)
        pill?.text

  $scope.lookupPill = (guid) ->
    _.find $scope.pieces, (piece) -> piece.guid == guid

  $scope.lookupImplicitBinding = (guid) ->
    $scope.from

  $scope.fieldBindingDragStart = (tableGuid, fieldGuid) ->
    action = $scope.lookupFieldAction(tableGuid, fieldGuid)
    if action
      $scope.bindingDragStart(action.pill)
    else
      $scope.fieldValueDragStart(tableGuid, fieldGuid)

  $scope.bindingDragStart = (pill) ->
    window.draggedPill = pill
    event.dataTransfer.setData("Text", $scope.lookupPillName(pill))

  $scope.fieldValueDragStart = (tableGuid, fieldGuid) ->
    window.draggedPill = {kind: 'field_value', guid: "#{tableGuid};#{fieldGuid}"}
    event.dataTransfer.setData("Text", $scope.lookupFieldName(tableGuid, fieldGuid))

  $scope.tableDragStart = (tableGuid, event) ->
    window.draggedPill = {kind: 'table_ref', guid: tableGuid}
    event.dataTransfer.setData("Text", $scope.lookupTableName(tableGuid))

  $scope.fieldDragStart = (tableGuid, fieldGuid, event) ->
    window.draggedPill = {kind: 'field_ref', guid: "#{tableGuid};#{fieldGuid}"}
    event.dataTransfer.setData("Text", $scope.lookupFieldName(tableGuid, fieldGuid))

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


  $scope.dragOverUnboundField = (tableGuid, fieldGuid, event) ->
    return false if window.draggedPill.kind != 'field_ref'

    event.preventDefault()
    true

  $scope.dropOverUnboundField = (tableGuid, fieldGuid, event) ->
    [pillTable, pillField] = window.draggedPill.guid.split ';'

    $scope.tableAndFieldRebinds.push kind: 'field', fromTable: tableGuid, toTable: pillTable, fromField: fieldGuid, toField: pillField

    for action in $scope.actions
      if action.table == tableGuid
        action.table = pillTable
        if action.field == fieldGuid
          action.field = pillField

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