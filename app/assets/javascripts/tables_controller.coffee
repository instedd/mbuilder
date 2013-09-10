angular.module('mbuilder').controller 'TablesController', ['$scope', ($scope) ->
  $scope.newTable = ->
    $scope.tables.push
      guid: window.guid()
      name: "Table #{$scope.tables.length + 1}"
      fields: []
      editable: true
      focus: true

  $scope.deleteTable = (index) ->
    $scope.tables.splice(index, 1)
]