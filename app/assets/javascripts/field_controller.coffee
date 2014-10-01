angular.module('mbuilder').controller 'FieldController', ['$scope', '$timeout', ($scope, $timeout) ->
  $scope.dragOverName = (event) ->
    return false unless window.draggedPill

    if window.draggedPill.kind == 'table_ref'
      false
    else
      event.preventDefault()
      true

  $scope.dropOverName = (event) ->
    return if window.draggedPill == null
    $scope.$emit 'pillOverFieldName', pill: window.draggedPill, field: $scope.pill, table: $scope.table
    window.draggedPill = null

  $scope.dragOverValue = (event) ->
    return false unless window.draggedPill

    if window.draggedPill.kind == 'table_ref'
      false
    else
      event.preventDefault()
      true

  $scope.dropOverValue = (event) ->
    return if window.draggedPill == null
    $scope.$emit 'pillOverFieldValue', pill: window.draggedPill, field: $scope.pill, table: $scope.table

  $scope.addNewValue = ->
    $scope.$emit 'pillOverFieldValue', pill: {kind: 'literal', guid: window.guid(), text: '', editmode: true}, field: $scope.pill, table: $scope.table
    $timeout ->
      $scope.$broadcast 'makeEditable',

  $scope.showValidValuesPopup = (field, event) ->
    $scope.hidePopups()
    $scope.validValuesPopup.field = field

    div = $('#valid-values')
    div.css left: event.originalEvent.pageX, top: event.originalEvent.pageY
    div.show()

    field.active = true

    window.setTimeout (-> $('#valid-values input').focus()), 0

    event.preventDefault()
    event.stopPropagation()
]
