angular.module('mbuilder').controller 'TableController', ['$scope', ($scope) ->
  $scope.newField = ->
    $scope.table.fields.push
      guid: window.guid()
      name: "Field #{$scope.table.fields.length + 1}"
      editable: true
      focus: true

  $scope.deleteField = (index) ->
    $scope.table.fields.splice(index, 1)

  $scope.pillTemplateFor = (field) ->
    # This is repeated here because of the "self problem". The controllers scope are built with composition, not inheritance
    status = $scope.lookupPillStatus(field)
    $scope.fieldNameFor(status)

  $scope.lookupPillStatus = (field) ->
    action = $scope.lookupFieldAction(field.guid)
    if action
      return $scope.$parent.lookupPillStatus(action.pill)

    tableGuid = $scope.lookupTableByField(field.guid).guid

    tableAction = _.find $scope.actions, (action) -> action.table == tableGuid
    if tableAction?.kind == 'select_entity'
      return 'field_value'

    'new'

  $scope.lookupPillName = (field) ->
    action = $scope.lookupFieldAction(field.guid)
    if action
      return $scope.$parent.lookupPillName(action.pill)
    else
      $scope.lookupJoinedFieldName(field.guid)

  $scope.lookupPill = (pill) ->
    action = $scope.lookupFieldAction(pill.guid)
    if action
      return action.pill
    else
      pill

  $scope.dragPill = (pill) ->
    action = $scope.lookupFieldAction(pill.guid)
    if action
      $scope.$parent.dragPill(action.pill)
    else
      $scope.fieldValueDragStart(pill.guid)

  $scope.dropOverUnboundPill = (pill, event) ->
    action = $scope.lookupFieldAction(pill.guid)
    if action
      $scope.$parent.dropOverUnboundPill(action.pill, event)
    else
      debugger # wtf!
]
