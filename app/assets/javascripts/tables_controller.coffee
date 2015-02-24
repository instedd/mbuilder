angular.module('mbuilder').controller 'TablesController', ['$scope', ($scope) ->
  $scope.newTable = ->
    $scope.tables.push
      guid: window.guid()
      name: "Table #{$scope.tables.length + 1}"
      fields: []
      editmode: true
      focusmode: true
      kind: 'local'
      protocol: ['query', 'update', 'insert']

  $scope.deleteTable = (index) ->
    $scope.tables.splice(index, 1)
]
