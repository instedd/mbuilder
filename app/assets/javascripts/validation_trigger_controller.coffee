angular.module('mbuilder').controller 'ValidationTriggerController', ['$scope', '$http', ($scope, $http) ->
  $scope.phoneNumberDragStart = (event) ->
    window.draggedPill = {kind: "placeholder", guid: "phone_number"}
    event.dataTransfer.setData("Text", $scope.invalid_value)
    $scope.$broadcast 'dragStart'

  $scope.invalidValueDragStart = (event) ->
    window.draggedPill = {kind: "placeholder", guid: "invalid_value"}
    event.dataTransfer.setData("Text", $scope.invalid_value)
    $scope.$broadcast 'dragStart'

  $scope.allPills = ->
    $scope.implicitPills()

  $scope.implicitPills = ->
    [
      {text: $scope.from, guid: "phone_number"},
      {text: $scope.invalid_value, guid: "invalid_value"},
    ]

  $scope.save = ->
    data =
      tables: $scope.tables
      from: $scope.from
      invalid_value: $scope.invalid_value
      actions: $scope.actions
      tableAndFieldRebinds: $scope.tableAndFieldRebinds

    url = "/applications/#{$scope.applicationId}/validation_triggers/#{$scope.field_guid}"
    method = "put"

    call = $http[method](url, JSON.stringify(data))
    call.success (data, status, headers, config) =>
      window.location = "/applications/#{$scope.applicationId}/message_triggers"
    call.error (data, status, headers, config) =>
      alert "Error: #{data}"
]
