angular.module('mbuilder').controller 'HubController', ['$scope', '$http', ($scope, $http) ->

  $scope.new_hub_data_path = "connectors/1d5fc682-a580-6337-dfd9-f2361238b76f/indices/hub_unicef/types/patients"

  $scope.$on 'updateCollection', (event, table) ->
    return unless table.kind == 'hub'
    console.error('not implemented')

  $scope.addNewHubData = (path) ->

    $http.get("/hub/reflect/#{path}")
      .success (data) ->
        # TODO would be nice to allow fields no be updated after the table was pushed

        fields = []
        for name, descriptor of data.entity_definition.properties
          fields.push {
            guid: window.guid()
            name: name
          }

        $scope.tables.push
          guid: window.guid()
          kind: 'hub'
          name: data.label
          path: path
          fields: fields
          editmode: false
          focusmode: false
          readonly: true

]
