angular.module('mbuilder').controller 'ValidValuesController', ['$scope', ($scope) ->
  $scope.groupBy = (field) ->
    $scope.$emit 'groupByField', field: field, table: $scope.lookupTableByField(field.guid)
    $scope.hidePopups()

  $scope.keydown = (event) ->
    if event.keyCode == 13 # Enter
      $scope.hidePopups()

  $scope.defineValidationTrigger = ->
    window.open "/applications/#{$scope.applicationId}/validation_triggers/#{$scope.validValuesPopup.field.guid}"
    $scope.hidePopups()

  $scope.hideGroupByOption = () ->
    $scope.validValuesPopup.field && $scope.lookupTableByField($scope.validValuesPopup.field.guid).readonly
]
