angular.module('mbuilder-messages').controller 'LogsController', ['$scope', ($scope) ->
  $scope.loadMessageInPopup = (message) ->
    $scope.$broadcast 'load-message', message

  $scope.$on 'message-sent', () ->
    refreshListing('logs')
]
