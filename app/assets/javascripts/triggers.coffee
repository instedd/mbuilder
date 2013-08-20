mbuilder = angular.module('mbuilder', ['drag-and-drop']);

mbuilder.controller 'EditTriggerController', ['$scope', ($scope) ->
  $scope.actionTemplateFor = (kind) ->
    "#{kind}_action"

  $scope.lookupTable = (guid) ->
    _.find $scope.tables, (table) -> table.guid == guid

  $scope.lookupTableName = (guid) ->
    $scope.lookupTable(guid).name

  $scope.lookupFieldName = (tableGuid, fieldGuid) ->
    table = $scope.lookupTable(tableGuid)
    field = _.find table.fields, (field) -> field.guid == fieldGuid
    field.name
]

mbuilder.controller 'TriggerController', ['$scope', ($scope) ->
  $scope.phoneNumberDragStart = (event) ->
    event.dataTransfer.setData("pill", "phone number")
]

mbuilder.controller 'TablesController', ['$scope', ($scope) ->
  $scope.newTable = ->
    $scope.tables.push
      guid: window.guid()
      name: "Table #{$scope.tables.length + 1}"
      fields: []
]

mbuilder.controller 'TableController', ['$scope', ($scope) ->
  $scope.newField = ->
    $scope.table.fields.push
      guid: window.guid()
      name: "Field #{$scope.table.fields.length + 1}"
]

mbuilder.controller 'FieldController', ['$scope', ($scope) ->
  $scope.dragOverName = (event) ->
    event.preventDefault()
    true

  $scope.dropOverName = (event) ->
    pillName = event.dataTransfer.getData("pill")

    $scope.$emit 'pillNameOverFieldName', pill: pillName, field: $scope.field, table: $scope.table
]

mbuilder.controller 'ActionsController', ['$scope', '$rootScope', ($scope, $rootScope) ->
  $rootScope.$on 'pillNameOverFieldName', (event, args) ->
    $scope.actions.push
      kind: 'select_or_create'
      pill: args.pill
      table: args.table.guid
      field: args.field.guid
]
