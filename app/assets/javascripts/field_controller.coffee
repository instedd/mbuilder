angular.module('mbuilder').controller 'FieldController', ['$scope', '$timeout', ($scope, $timeout) ->
  $scope.dragOverName = (event) ->
    return true unless window.draggedPill

    if window.draggedPill.kind == 'table_ref'
      true
    else
      event.dataTransfer.allowedEffect = "link"
      event.dataTransfer.dropEffect = "link"
      event.preventDefault()
      false

  $scope.dropOverName = (event) ->
    return if window.draggedPill == null
    $scope.$emit 'pillOverFieldName', pill: window.draggedPill, field: $scope.pill, table: $scope.table
    window.draggedPill = null

  $scope.dragOverValue = (event) ->
    return true unless window.draggedPill

    if window.draggedPill.kind == 'table_ref'
      true
    else
      event.dataTransfer.allowedEffect = "link"
      event.dataTransfer.dropEffect = "link"
      event.preventDefault()
      false

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
    closest_th = $(event.originalEvent.currentTarget).closest('th')
    closest_th_positon = closest_th.offset()
    div.css left: closest_th_positon.left, top: closest_th_positon.top + $(closest_th).height()
    div.show()

    field.active = true

    window.setTimeout (-> $('#valid-values input').focus()), 0

    event.preventDefault()
    event.stopPropagation()
]
