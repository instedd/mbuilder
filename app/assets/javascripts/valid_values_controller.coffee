angular.module('mbuilder').controller 'ValidValuesController', ['$scope', ($scope) ->
  $scope.keydown = (event) ->
    if event.keyCode == 13 # Enter
      $scope.hidePopups()
]
