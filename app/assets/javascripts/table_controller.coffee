angular.module('mbuilder').controller 'TableController', ['$scope', ($scope) ->
  $scope.newField = ->
    $scope.table.fields.push
      guid: window.guid()
      name: "Field #{$scope.table.fields.length + 1}"
      editable: true
      focus: true

  $scope.deleteField = (index) ->
    $scope.table.fields.splice(index, 1)

  $scope.fieldTemplateFor = (fieldGuid) ->
    status = $scope.lookupFieldStatus(fieldGuid)
    "#{status}_field"

  $scope.lookupFieldStatus = (fieldGuid) ->
    action = $scope.lookupFieldAction(fieldGuid)
    if action
      return $scope.lookupPillStatus(action.pill)


    tableGuid = $scope.lookupTableByField(fieldGuid).guid

    tableAction = _.find $scope.actions, (action) -> action.table == tableGuid
    if tableAction?.kind == 'select_entity'
      return 'existing'

    'new'

  $scope.lookupFieldValue = (fieldGuid) ->
    action = $scope.lookupFieldAction(fieldGuid)
    if action
      unless action.pill
        console.log action
      return $scope.lookupPillName(action.pill)

    null

  $scope.fieldBindingDragStart = (fieldGuid) ->
    action = $scope.lookupFieldAction(fieldGuid)
    if action
      $scope.dragPill(action.pill)
    else
      $scope.fieldValueDragStart(fieldGuid)
]