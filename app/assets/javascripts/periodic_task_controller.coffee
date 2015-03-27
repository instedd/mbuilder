angular.module('mbuilder').controller 'PeriodicTaskController', ['$scope', '$http', ($scope, $http) ->
  $scope.allPills = ->
    $scope.implicitPills()

  $scope.implicitPills = ->
    [{text: 'yyyymmdd', guid:"received_at"}]

  $scope.receivedAtDragStart = (event) ->
    window.draggedPill = {kind: "placeholder", guid: "received_at"}
    event.dataTransfer.setData("Text", 'yyyymmdd')
    $scope.$broadcast 'dragStart'

  $scope.save = ->
    data =
      name: $scope.name
      enabled: $scope.enabled
      tables: $scope.tables
      schedule: $('#scheduleRule').val()
      scheduleTime: $scope.scheduleTime

      actions: $scope.actions
      tableAndFieldRebinds: $scope.tableAndFieldRebinds

    if $scope.id?
      url = "/applications/#{$scope.applicationId}/periodic_tasks/#{$scope.id}"
      method = "put"
    else
      url = "/applications/#{$scope.applicationId}/periodic_tasks"
      method = "post"

    call = $http[method](url, JSON.stringify(data))
    call.success (data, status, headers, config) =>
      window.location = "/applications/#{$scope.applicationId}/message_triggers"
    call.error (data, status, headers, config) =>
      alert "Error: #{data}"
]
