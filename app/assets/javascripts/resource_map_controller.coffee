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
      fields = _.map data, (f) -> {guid: window.guid(), id: f.id, name: f.name}

      $scope.tables.push
        guid: window.guid()
        kind: 'resource_map'
        id: collection.id
        name: collection.name
        fields: fields
        editable: false
        focus: false

]
