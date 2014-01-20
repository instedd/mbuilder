angular.module('mbuilder').controller 'IfAggregatesController', ['$scope', ($scope) ->
  $scope.select = (operator) ->
    action = $scope.ifAggregatesPopup.action
    action.all = operator.id
    $scope.hidePopups()
]
