angular.module('mbuilder').controller 'ResourceMapController', ['$scope', '$http', ($scope, $http) ->
  $scope.listCollections = (event) ->
    $scope.loading = true
    $scope.showPopup '#add-resource-map-collection', event

    call = $http.get("/resource_map/collections.json")
    call.success (data, status, headers, config) ->
      $scope.loading = false
      $scope.collections = data

  $scope._resmapTableFields = (data) ->
    fields = []
    fields.push id: "name", name: "Name"
    fields.push id: "lat", name: "Latitude"
    fields.push id: "lng", name: "Longitude"
    for field in data
      if $scope.isMultipleOptionsField field
        fields.push id: field.id, name: "#{field.name} (label)", kind: field.kind, value: "label"
        fields.push id: field.id, name: "#{field.name} (code)", kind: field.kind, value: "code"
      else
        fields.push id: field.id, name: field.name, kind: field.kind

      if $scope.isHierarchyOptionsField field
        fields.push id: field.id, name: "#{field.name} (under id)", kind: field.kind, modifier: "under"

    return fields

  $scope.addCollection = (collection) ->
    $scope.hidePopups()

    call = $http.get("/resource_map/collections/#{collection.id}/fields.json")
    call.success (data, status, headers, config) ->
      fields = $scope._resmapTableFields(data)
      for f in fields
        f.guid = window.guid()

      $scope.tables.push
        guid: window.guid()
        kind: 'resource_map'
        id: collection.id
        name: collection.name
        fields: fields
        editmode: false
        focusmode: false
        readonly: true
        protocol: ['query', 'update', 'insert']

  $scope.$on 'updateCollection', (event, table) ->
    return unless table.kind == 'resource_map'
    table = table
    call = $http.get("/resource_map/collections/#{table.id}/fields.json")
    call.success (data, status, headers, config) ->
      new_fields = $scope._resmapTableFields(data)
      eqp = (a, b, p) ->
        if a[p]?
          if b[p]?
            return a[p] == b[p]
        else
          if b[p]?
            return false
          else
            return true
        return false

      for new_field in new_fields
        existing_field = _.detect table.fields, (f) -> eqp(f, new_field, 'id') and eqp(f, new_field, 'value') and eqp(f, new_field, 'modifier')
        console.log new_field, existing_field
        if existing_field
          new_field.guid = existing_field.guid
        else
          new_field.guid = window.guid()

      table.fields = new_fields

  $scope.isMultipleOptionsField = (field) ->
    _.include ["select_one", "select_many", "hierarchy"], field.kind

  $scope.isHierarchyOptionsField = (field) ->
    _.include ["hierarchy"], field.kind

]
