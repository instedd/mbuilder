angular.module('mbuilder').controller 'ExternalTriggerController', ['$scope', '$http', ($scope, $http) ->
  $scope.allPills = ->
    $scope.parameters.concat $scope.implicitPills()

  $scope.implicitPills = ->
    [{text: 'yyyymmdd', guid:"received_at"}]

  $scope.addParameter = ->
    $scope.parameters.push kind: 'parameter', name: '', guid: window.guid()

  $scope.deleteParameter = (index) ->
    $scope.parameters.splice(index, 1)

  $scope.makeNotEditable = (event) ->
    $scope.contenteditable = 'false'

  $scope.makeEditable = (event) ->
    unless $(event.originalEvent.target).hasClass('pill')
      $scope.contenteditable = 'true'

  $scope.receivedAtDragStart = (event) ->
    window.draggedPill = {kind: "placeholder", guid: "received_at"}
    event.dataTransfer.setData("Text", 'yyyymmdd')
    $scope.$broadcast 'dragStart'

  $scope.save = ->
    data =
      name: $scope.name
      tables: $scope.tables
      parameters: $scope.parameters
      actions: $scope.actions
      tableAndFieldRebinds: $scope.tableAndFieldRebinds

    if $scope.id?
      url = "/applications/#{$scope.applicationId}/external_triggers/#{$scope.id}"
      method = "put"
    else
      url = "/applications/#{$scope.applicationId}/external_triggers"
      method = "post"

    call = $http[method](url, JSON.stringify(data))
    call.success (data, status, headers, config) =>
      window.location = "/applications/#{$scope.applicationId}/message_triggers"
    call.error (data, status, headers, config) =>
      alert "Error: #{data}"
]
