angular.module('mbuilder').controller 'AggregateFunctionsController', ['$scope', ($scope) ->
  $scope.select = (fun) ->
    $scope.aggregateFunctionPopup.pill.fun = fun.id
    $scope.hidePopupus()
]

