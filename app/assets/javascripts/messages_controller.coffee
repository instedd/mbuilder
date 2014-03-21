angular.module('mbuilder-messages').controller 'MessagesController', ['$scope', '$http', ($scope, $http) ->
  $scope.from = ''
  $scope.body = ''
  $scope.messages = []
  $scope.actions = []
  $scope.loading = false

  $scope.send = ->
    return if $.trim($scope.from).length == 0 || $.trim($scope.body).length == 0

    data =
      from: $scope.from
      body: $scope.body

    $scope.loading = true
    $scope.actions = []

    call = $http.post "/applications/#{$scope.applicationId}/messages", JSON.stringify(data)
    call.success (data, status, headers, config) ->
      if data
        $scope.$emit 'message-sent'
        $scope.actions = data.actions
        $scope.messages = data.messages
      else
        $scope.actions = []
        $scope.messages = []
      $scope.loading = false

  $scope.$on 'load-message', (e, message) ->
    $scope.from = message.from
    $scope.body = message.body
    $scope.actions = message.actions
    $scope.loading = false
]
