angular.module('mbuilder').controller 'ValidValuesController', ['$scope', ($scope) ->
  $scope.keydown = (event) ->
    if event.keyCode == 13 # Enter
      $scope.hidePopups()

  $scope.defineValidationTrigger = ->
    window.open "/applications/#{$scope.applicationId}/validation_triggers/#{$scope.validValuesPopup.field.guid}"
    $scope.hidePopups()
]
