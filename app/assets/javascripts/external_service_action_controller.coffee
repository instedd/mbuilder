angular.module('mbuilder')

.controller('ExternalServiceActionController', ['$scope', ($scope) ->
  debugger
  # TODO lookup external service and setup variables
  $scope.pills = $scope.action.pills
  $scope.parameters = $scope.action.parameters

  $scope.variables = [
    {name: 'var1', display_name: 'Variable 1'},
    {name: 'var2', display_name: 'Variable 2'}
  ]
])

.controller('ExternalServiceActionVariableController', ['$scope', ($scope) ->
  $scope.pill = $scope.$parent.pills[$scope.variable.name]

  $scope.dragOverVariable = (event) ->
    if window.draggedPill
      event.preventDefault()
      true
    else
      false

  $scope.dropOverVariable = (event) ->
    $scope.pill = window.draggedPill
    $scope.$parent.pills[$scope.variable.name] = $scope.pill
])
