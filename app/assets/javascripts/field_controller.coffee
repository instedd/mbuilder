angular.module('mbuilder').controller 'FieldController', ['$scope', ($scope) ->
  $scope.dragOverName = (event) ->
    if window.draggedPill.kind == 'field_ref' || window.draggedPill.kind == 'table_ref'
      false
    else
      event.preventDefault()
      true

  $scope.dropOverName = (event) ->
    $scope.$emit 'pillOverFieldName', pill: window.draggedPill, field: $scope.field, table: $scope.table

  $scope.dragOverValue = (event) ->
    if window.draggedPill.kind == 'field_ref' || window.draggedPill.kind == 'table_ref'
      false
    else
      event.preventDefault()
      true

  $scope.dropOverValue = (event) ->
    $scope.$emit 'pillOverFieldValue', pill: window.draggedPill, field: $scope.field, table: $scope.table
]