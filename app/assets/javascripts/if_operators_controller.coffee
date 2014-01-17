angular.module('mbuilder').controller 'IfOperatorsController', ['$scope', ($scope) ->
  $scope.select = (operator) ->
    action = $scope.ifOperatorsPopup.action
    action.op = operator.id

    switch operator.id
      when 'between', 'not between'
        if action.right.length == 1
          action.right.push(kind: 'literal', guid: window.guid(), text: '')
      else
        if action.right.length == 2
          action.right.pop()

    $scope.hidePopups()
]
