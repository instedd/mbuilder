angular.module('mbuilder').controller 'MessageTriggerController', ['$scope', '$http', ($scope, $http) ->
  $scope.allPills = ->
    $scope.pieces.concat $scope.implicitPills()

  $scope.implicitPills = ->
    [{text: $scope.from, guid:"phone_number"}, {text: 'yyyymmdd', guid:"received_at"}]

  $scope.contenteditable = 'false'

  $scope.phoneNumberDragStart = (event) ->
    window.draggedPill = {kind: "placeholder", guid: "phone_number"}
    event.dataTransfer.setData("Text", $scope.from)
    $scope.$broadcast 'dragStart'

  $scope.receivedAtDragStart = (event) ->
    window.draggedPill = {kind: "placeholder", guid: "received_at"}
    event.dataTransfer.setData("Text", 'yyyymmdd')
    $scope.$broadcast 'dragStart'

  $scope.$on 'onPatternpadPicesChanged', ->
    $scope.$broadcast 'onAllPillsChanged'

  $scope.save = ->
    data =
      name: $scope.name
      enabled: $scope.enabled
      tables: $scope.tables
      message:
        from: $scope.from
        pieces: $scope.pieces
      actions: $scope.actions
      tableAndFieldRebinds: $scope.tableAndFieldRebinds

    if $scope.id?
      url = "/applications/#{$scope.applicationId}/message_triggers/#{$scope.id}"
      method = "put"
    else
      url = "/applications/#{$scope.applicationId}/message_triggers"
      method = "post"

    call = $http[method](url, JSON.stringify(data))
    call.success (data, status, headers, config) =>
      window.location = "/applications/#{$scope.applicationId}/message_triggers"
    call.error (data, status, headers, config) =>
      alert "Error: #{data}"
]
