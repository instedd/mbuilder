angular.module('mbuilder-messages').controller 'LogsController', ['$scope', ($scope) ->
  $scope.loadMessageInPopup = (message) ->
    $scope.$broadcast 'load-message', message
    $('#messagesModal').modal()

  $scope.$on 'message-sent', () ->
    refreshListing('logs')
]
