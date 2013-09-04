mbuilder = angular.module('mbuilder-messages', ['ng-rails-csrf']);

mbuilder.controller 'MessagesController', ['$scope', '$http', ($scope, $http) ->
  $scope.from = ''
  $scope.body = ''
  $scope.messages = []

  $scope.send = ->
    return if $.trim($scope.from).length == 0 || $.trim($scope.body).length == 0

    data =
      from: $scope.from
      body: $scope.body

    call = $http.post "/applications/#{$scope.applicationId}/messages", JSON.stringify(data)
    call.success (data, status, headers, config) ->
      if data
        $scope.messages = data
      else
        $scope.messages = []
]
