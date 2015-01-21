angular.module('mbuilder-import').controller 'TableImportController', ['$scope', '$http', ($scope, $http) ->
  $scope.initialize = (data) ->
    $scope.applicationId = data.applicationId
    $scope.tableGuid = data.tableGuid
    $scope.fields = data.fields
    $scope.actions = [{action: 'ignore', label: 'Ignore column'},
                      {action: 'new_field', label: 'New field'}]
    if data.tableGuid
      $scope.actions.push {action: 'existing_field', label: 'Existing field'}
      $scope.actions.push {action: 'existing_identifier', label: 'Existing field as identifier'}

    $scope.columnSpecs = _.map data.columnSpecs, (col) ->
      col.action = _.find $scope.actions, (v) -> v.action == col.action
      col.field = _.find $scope.fields, (v) -> v.guid == col.field
      col

  $scope.actionTypeChanged = (column) ->
    # ensure only one column is used as identifier
    if column.action.action == 'existing_identifier'
      _.each $scope.columnSpecs, (col) ->
        if col isnt column and col.action is column.action
          col.action = _.find $scope.actions, (v) -> v.action == 'existing_field'

  $scope.import = ->
    columnSpecs = _.map $scope.columnSpecs, (col) ->
      action: col.action.action
      field: col.field?.guid
      name: col.name
    data =
      table_guid: $scope.tableGuid
      name: $scope.tableName
      column_specs: columnSpecs

    url = "/applications/#{$scope.applicationId}/tables/import"

    $scope.busy = true
    call = $http.post(url, JSON.stringify(data))
    call.success (data, status, headers, config) =>
      window.location = "/applications/#{$scope.applicationId}/data"
    call.error (data, status, headers, config) =>
      $scope.busy = false
      alert "Error: #{data}"
]
