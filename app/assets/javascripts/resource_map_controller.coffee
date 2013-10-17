angular.module('mbuilder').controller 'ResourceMapController', ['$scope', '$http', ($scope, $http) ->
  $scope.listCollections = (event) ->
    $scope.loading = true
    $scope.showPopup '#add-resource-map-collection', event

    call = $http.get("/resource_map/collections.json")
    call.success (data, status, headers, config) ->
      $scope.loading = false
      $scope.collections = data

  $scope.addCollection = (collection) ->
    $scope.hidePopups()

    call = $http.get("/resource_map/collections/#{collection.id}/fields.json")
    call.success (data, status, headers, config) ->
      fields = []
      fields.push guid: window.guid(), id: "name", name: "Name"
      fields.push guid: window.guid(), id: "lat", name: "Latitude"
      fields.push guid: window.guid(), id: "lng", name: "Longitude"
      for field in data
        fields.push guid: window.guid(), id: field.id, name: field.name

      $scope.tables.push
        guid: window.guid()
        kind: 'resource_map'
        id: collection.id
        name: collection.name
        fields: fields
        editmode: false
        focusmode: false
        readonly: true

  $scope.$on 'updateCollection', (event, table) ->
    table = table
    call = $http.get("/resource_map/collections/#{table.id}/fields.json")
    call.success (data, status, headers, config) ->
      fields = []

      fields.push( _.detect table.fields, (field) -> field.id == "name")
      fields.push( _.detect table.fields, (field) -> field.id == "lat")
      fields.push( _.detect table.fields, (field) -> field.id == "lng")

      for field in data
        f = _.detect table.fields, (f) -> f.id == field.id
        guid = if f
          f.guid
        else
          window.guid()

        fields.push guid: guid, id: field.id, name: field.name

      table.fields = fields
]
