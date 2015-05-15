angular.module('mbuilder').controller 'HubController', ['$scope', '$http', 'HubApi', ($scope, $http, HubApi) ->

  $scope.$on 'updateCollection', (event, table) ->
    return unless table.kind == 'hub'

    $http.get("/hub/reflect/#{table.path}")
      .success (data) ->
        new_fields = $scope.build_fields(data)

        for new_field in new_fields
          existing_field = _.detect table.fields, (f) -> new_field.name == f.name
          if existing_field
            new_field.guid = existing_field.guid
            new_field.valid_values = existing_field.valid_values

        table.fields = new_fields
        table.protocol = data.protocol

  $scope.openEntitySetPicker = (path) ->
    HubApi.openPicker('entity_set')
      .then((path) ->
        $scope.$apply ->
          $scope.addNewHubData(path)
      )

  $scope.addNewHubData = (path) ->
    $scope.loading = true
    $http.get("/hub/reflect/#{path}")
      .success (data) ->
        $scope.loading = false

        fields = $scope.build_fields(data)

        $scope.tables.push
          guid: window.guid()
          kind: 'hub'
          name: data.label
          path: path
          fields: fields
          editmode: false
          focusmode: false
          readonly: true
          protocol: data.protocol

  $scope.build_fields = (data) ->
    fields = []
    for name, descriptor of data.entity_definition.properties
      fields.push {
        guid: window.guid()
        name: name
      }

    fields

]
