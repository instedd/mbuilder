angular.module('mbuilder')

.controller('ExternalServiceActionController', ['$scope', ($scope) ->
  external_service = $scope.findExternalService($scope.action.guid)

  $scope.name = external_service?.display_name ? '???'
  $scope.pills = $scope.action.pills
  $scope.results = $scope.action.results

  $scope.allPills = ->
    $scope.results

  $scope.variables = _.map external_service?.variables, (v) -> {
    name: v.name,
    display_name: v.display_name
  }

  $scope.outputPillName = (pill) ->
    output = _.find external_service?.response_variables, (v) -> v.name == pill.name
    output?.display_name
])

.controller('ExternalServiceActionVariableController', ['$scope', ($scope) ->
  $scope.pill = $scope.$parent.pills[$scope.variable.name]

  $scope.dragOverVariable = (event) ->
    return true unless window.draggedPill

    if _.findWhere($scope.results, {guid: window.draggedPill.guid})
      # cannot bind a result from self to a parameter
      true
    else
      event.preventDefault()
      false

  $scope.dropOverVariable = (event) ->
    $scope.pill = window.draggedPill
    $scope.$parent.pills[$scope.variable.name] = $scope.pill
])

.controller('AddExternalServiceController', ['$scope', ($scope) ->
  $scope.select = (step) ->
    $scope.addExternalServiceAction(step)
    $scope.hidePopups()
])

