angular.module('mbuilder').controller 'SendMessageController', ['$scope', ($scope) ->
  # Fix: add text piece at the end so the user can place the cursor there
  if $scope.action.message.length > 0 && $scope.action.message[$scope.action.message.length - 1].kind != 'text'
    $scope.action.message.push({kind: 'text', guid: ''})

  addBinding = (bindings, properties) ->
    guid = $.trim(properties.guid)
    return if guid.length == 0

    properties.guid = guid

    bindings.push properties

  $scope.pillTemplateFor = (pill) ->
    if pill.kind == 'text'
      $scope.fieldNameFor(pill.kind)
    else
      $scope.$parent.pillTemplateFor(pill)

  $scope.parseMessage = (event) ->
    bindings = []
    pills = _.select $scope.action.message, (m) -> m.kind != 'text'
    pillIndex = 0

    parser = new MessageParser(event.originalEvent.currentTarget)
    parser.onText (text) ->
      addBinding bindings, kind: 'text', guid: text
    parser.onPill (node) ->
      pill = pills[pillIndex]
      if pill
        bindings.push pill
      else
        addBinding bindings, $scope.data(node)
      pillIndex += 1
    parser.lastPieceNeeded ->
      bindings.length > 0 && bindings[bindings.length - 1].kind != 'text'
    parser.parse()

    # Replace $scope.message' contents
    args = [0, $scope.action.message.length].concat(bindings)
    Array.prototype.splice.apply($scope.action.message, args)

  $scope.parseRecipient = (event) ->
    parser = new MessageParser(event.originalEvent.currentTarget)
    parser.onText (text) ->
      text = $.trim(text)
      if text.length > 0
        $scope.action.recipient = {kind: 'text', guid: text}
    parser.onPill (node) ->
      unless $scope.action.recipient?.guid == node.data('guid')
        $scope.action.recipient = $scope.data(node)
    parser.lastPieceNeeded ->
      $scope.action.recipient.kind != 'text'
    parser.parse()

  $scope.makeRecipientNotEditable = (event) ->
    $scope.parseRecipient(event)
    $scope.action.recipientEditable = 'false'

  $scope.makeRecipientEditable = (event) ->
    $scope.action.recipientEditable = 'true'

  $scope.dragOverRecipient = (event) ->
    return true unless window.draggedPill

    event.dataTransfer.allowedEffect = "link"
    event.dataTransfer.dropEffect = "link"
    event.preventDefault()
    false

  $scope.dropOverRecipient = (event) ->
    return if window.draggedPill == null
    $scope.action.recipient = window.draggedPill
    MessageParser.appendLastPieceTo(event.target)
    window.draggedPill = null
    true

  $scope.handleRecipientKey = (event) ->
    hasPill = $scope.action.recipient.kind != 'text'

    if event.keyCode == 8 # delete
      if hasPill
        $scope.action.recipient = {kind: 'text', guid: ''}
        event.preventDefault()
        return false

      if $.trim(event.originalEvent.target.innerText).length == 0
        event.preventDefault()
        return false
    else if hasPill
      event.preventDefault()
      return false

    true

  $scope.tryShowAggregateFunctionsPopup = (pill, actionScope, event) ->
    $scope.showAggregateFunctionsPopup pill, actionScope, event
]
