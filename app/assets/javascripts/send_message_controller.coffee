angular.module('mbuilder').controller 'SendMessageController', ['$scope', ($scope) ->
  addBinding = (bindings, kind, guid, text) ->
    guid = $.trim(guid)
    return if guid.length == 0

    bindings.push kind: kind, guid: guid, text: text

  $scope.pillTemplateFor = (pill) ->
    if pill.kind == 'text'
      $scope.fieldNameFor(pill.kind)
    else
      $scope.$parent.pillTemplateFor(pill)

  $scope.parseMessage = (event) ->
    bindings = []
    parser = new MessageParser(event.originalEvent.currentTarget)
    parser.onText (text) ->
      console.log(text)
      addBinding bindings, 'text', text
    parser.onPill (node) ->
      console.log(node)
      addBinding bindings, node.data('kind'), node.data('guid'), node.data('text')
    parser.lastPieceNeeded ->
      bindings.length > 0 && bindings[bindings.length - 1].kind != 'text'
    parser.parse()

    # Replace $scope.message' contents
    args = [0, $scope.action.message.length].concat(bindings)
    Array.prototype.splice.apply($scope.action.message, args)

  $scope.makeMessageNotEditable = (event) ->
    $scope.parseMessage(event)
    $scope.action.messageEditable = 'false'

  $scope.makeMessageEditable = (event) ->
    unless $(event.originalEvent.target).hasClass('pill')
      $scope.action.messageEditable = 'true'

  $scope.dragOverMessage = (event) ->
    event.preventDefault()
    true

  $scope.dropOverMessage = (event) ->
    $scope.action.message.push window.draggedPill
    MessageParser.appendLastPieceTo(event.target)
    true

  $scope.handleMessageKey = (event) ->
    if event.keyCode == 8 # delete
      if $.trim(event.originalEvent.target.innerText).length == 0
        event.preventDefault()
        return false

      sel = window.getSelection()
      if sel.rangeCount > 0
        range = sel.getRangeAt(0)
        if range.startOffset == 0
          event.preventDefault()
          return false

    true

  $scope.parseRecipient = (event) ->
    parser = new MessageParser(event.originalEvent.currentTarget)
    parser.onText (text) ->
      text = $.trim(text)
      if text.length > 0
        $scope.action.recipient = {kind: 'text', guid: text}
    parser.onPill (node) ->
      $scope.action.recipient = {kind: node.data('kind'), guid: node.data('guid')}
    parser.lastPieceNeeded ->
      $scope.action.recipient.kind != 'text'
    parser.parse()

  $scope.makeRecipientNotEditable = (event) ->
    $scope.parseRecipient(event)
    $scope.action.recipientEditable = 'false'

  $scope.makeRecipientEditable = (event) ->
    $scope.action.recipientEditable = 'true'

  $scope.dragOverRecipient = (event) ->
    event.preventDefault()
    true

  $scope.dropOverRecipient = (event) ->
    $scope.action.recipient = window.draggedPill
    MessageParser.appendLastPieceTo(event.target)
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
]
