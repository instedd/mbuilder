angular.module('mbuilder').controller 'FieldController', ['$scope', ($scope) ->
  $scope.dragOverName = (event) ->
    return false unless window.draggedPill

    if window.draggedPill.kind == 'table_ref'
      false
    else
      event.preventDefault()
      true

  $scope.dropOverName = (event) ->
    $scope.$emit 'pillOverFieldName', pill: window.draggedPill, field: $scope.pill, table: $scope.table

  $scope.dragOverValue = (event) ->
    return false unless window.draggedPill

    if window.draggedPill.kind == 'table_ref'
      false
    else
      event.preventDefault()
      true

  $scope.mouseDragOverValue = (event) ->
    console.log 'mouseDragOverValue'

  $scope.mouseDropOverValue = (event) ->
    console.log 'mouseDropOverValue'

  $scope.dropOverValue = (event) ->
    $scope.$emit 'pillOverFieldValue', pill: window.draggedPill, field: $scope.pill, table: $scope.table

  $scope.addNewValue = ->
    $scope.$emit 'pillOverFieldValue', pill: {kind: 'literal', guid: window.guid(), text: '', editmode: true}, field: $scope.pill, table: $scope.table

  $scope.showValidValuesPopup = (field, event) ->
    $scope.hidePopups()
    $scope.validValuesPopup.field = field

    div = $('#valid-values')
    div.css left: event.originalEvent.pageX, top: event.originalEvent.pageY
    div.show()

    window.setTimeout (-> $('#valid-values input').focus()), 0

    event.preventDefault()
    event.stopPropagation()
]
