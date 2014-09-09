angular.module('mbuilder').controller 'AggregateFunctionsController', ['$scope', ($scope) ->
  $scope.select = (aggregate) ->
    $scope.aggregateFunctionPopup.pill.aggregate = aggregate.id
    $scope.hidePopups()
    $scope.aggregateFunctionPopup.actionScope.$emit 'AggregateFuncionSelected'
]
