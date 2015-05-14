angular.module('mbuilder').controller 'SendMessageController', ['$scope', ($scope) ->
  # Fix: add text piece at the end so the user can place the cursor there
  if $scope.action.message.length > 0 && $scope.action.message[$scope.action.message.length - 1].kind != 'text'
    $scope.action.message.push({kind: 'text', guid: ''})

  $scope.removePill = (pill) ->
    # the only pill that can be removed is the action.recipient
    $scope.action.recipient = {kind: 'literal', guid: window.guid(), text: ''}

  $scope.pillTemplateFor = (pill) ->
    if pill.kind == 'text'
      $scope.fieldNameFor(pill.kind)
    else
      $scope.$parent.pillTemplateFor(pill)

  $scope.dragOverRecipient = (event) ->
    return true unless window.draggedPill

    event.dataTransfer.allowedEffect = "link"
    event.dataTransfer.dropEffect = "link"
    event.preventDefault()
    false

  $scope.dropOverRecipient = (event) ->
    return if window.draggedPill == null
    console.log(window.draggedPill)
    $scope.action.recipient = window.draggedPill
    window.draggedPill = null
    true

  $scope.dragEnterRecipient = (event) ->
    $(event.target).addClass('drop-preview')

  $scope.dragLeaveRecipient = (event) ->
    $(event.target).removeClass('drop-preview')

  $scope.tryShowAggregateFunctionsPopup = (pill, actionScope, event) ->
    $scope.showAggregateFunctionsPopup pill, actionScope, event
]
