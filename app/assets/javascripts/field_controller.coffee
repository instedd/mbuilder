angular.module('mbuilder').controller 'FieldController', ['$scope', ($scope) ->
  $scope.dragOverName = (event) ->
    if window.draggedPill.kind == 'table_ref'
      false
    else
      event.preventDefault()
      true

  $scope.dropOverName = (event) ->
    $scope.$emit 'pillOverFieldName', pill: window.draggedPill, field: $scope.pill, table: $scope.table

  $scope.dragOverValue = (event) ->
    if window.draggedPill.kind == 'table_ref'
      false
    else
      event.preventDefault()
      true

  $scope.dropOverValue = (event) ->
    $scope.$emit 'pillOverFieldValue', pill: window.draggedPill, field: $scope.pill, table: $scope.table

  $scope.addNewValue = ->
    $scope.$emit 'pillOverFieldValue', pill: {kind: 'literal', guid: window.guid(), text: '', editable: true}, field: $scope.pill, table: $scope.table

  $scope.showTableColumnPopup = (field, event) ->
    $scope.tableColumnPopup.field = field

    div = $('#table-column')
    div.css left: event.originalEvent.pageX, top: event.originalEvent.pageY
    div.show()

    event.preventDefault()
    event.stopPropagation()
]
