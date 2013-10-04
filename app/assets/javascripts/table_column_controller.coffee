angular.module('mbuilder').controller 'TableColumnController', ['$scope', ($scope) ->
  $scope.groupBy = (field) ->
    $scope.$emit 'groupByField', field: field, table: $scope.lookupTableByField(field.guid)
    $scope.hidePopups()

  $scope.showValidValuesPopup = (field, event) ->
    $scope.hidePopups()
    $scope.validValuesPopup.field = field

    tableColumnDiv = $('#table-column')
    div = $('#valid-values')
    div.css left: tableColumnDiv.css('left'), top: tableColumnDiv.css('top')
    div.show()

    window.setTimeout (-> $('#valid-values input').focus()), 0

    event.preventDefault()
    event.stopPropagation()
]
