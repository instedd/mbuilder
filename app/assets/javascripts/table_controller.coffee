angular.module('mbuilder').controller 'TableController', ['$scope', ($scope) ->
  $scope.newField = ->
    $scope.table.fields.push
      guid: window.guid()
      name: "Field #{$scope.table.fields.length + 1}"
      editable: true
      focus: true

  $scope.deleteField = (index) ->
    $scope.table.fields.splice(index, 1)
]