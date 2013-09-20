angular.module('mbuilder').controller 'PeriodicTaskController', ['$scope', '$http', ($scope, $http) ->
  $scope.allPills = ->
    $scope.pieces.concat $scope.implicitPills()

  $scope.implicitPills = ->
    [{text: $scope.from, guid:"phone_number"}]

  $scope.save = ->
    data =
      name: $scope.name
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
      window.location = "/applications/#{$scope.applicationId}/periodic_tasks"
    call.error (data, status, headers, config) =>
      alert "Error: #{data}"
]
