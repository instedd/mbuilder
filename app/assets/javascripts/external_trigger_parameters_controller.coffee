angular.module('mbuilder').controller 'ExternalTriggerParametersController', ['$scope', ($scope) ->
  $scope.removePill = (pill) ->
    $scope.removeParameter(pill)
]
