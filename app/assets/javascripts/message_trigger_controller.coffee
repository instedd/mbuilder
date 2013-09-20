angular.module('mbuilder').controller 'MessageTriggerController', ['$scope', '$http', ($scope, $http) ->
  $scope.allPills = ->
    $scope.pieces.concat $scope.implicitPills()

  $scope.implicitPills = ->
    [{text: $scope.from, guid:"phone_number"}]

  $scope.contenteditable = 'false'

  $scope.phoneNumberDragStart = (event) ->
    window.draggedPill = {kind: "placeholder", guid: "phone_number"}
    event.dataTransfer.setData("Text", $scope.from)

  addPiece = (pieces, kind, text, guid = window.guid()) ->
    text = $.trim(text)
    return if text.length == 0

    pieces.push kind: kind, text: text, guid: guid

  addSelection = (pieces, text, range) ->
    start = range.startOffset
    end = range.endOffset
    if start > end
      tmp = start
      start = end
      end = tmp

    while start > 0 && text[start] != ' '
      start -= 1

    while end < text.length && text[end] != ' '
      end += 1

    if start > 0
      addPiece pieces, 'text', text.substring(0, start)

    addPiece pieces, 'placeholder', text.substring(start, end)

    if end < text.length
      addPiece pieces, 'text', text.substring(end)

  samePieces = (pieces1, pieces2) ->
    return false if pieces1.length != pieces2.length

    i = 0
    while i < pieces1.length
      piece1 = pieces1[i]
      piece2 = pieces2[i]
      return false if piece1.kind != piece2.kind || piece1.text != piece2.text
      i += 1

    true

  $scope.parseMessage = (event) ->
    pieces = []

    parser = new MessageParser(event.originalEvent.currentTarget)
    parser.onText (text, hasSelection) ->
      if hasSelection && parser.range.startContainer == parser.range.endContainer
        addSelection pieces, text, parser.range
      else
        addPiece pieces, 'text', text
    parser.onPill (node) ->
      addPiece pieces, 'placeholder', node.text(), node.data('guid')
    parser.lastPieceNeeded ->
      pieces.length > 0 && pieces[pieces.length - 1].kind != 'text'
    parser.parse()

    # Replace $scope.pieces' contents only if it changed
    unless samePieces($scope.pieces, pieces)
      args = [0, $scope.pieces.length].concat(pieces)
      Array.prototype.splice.apply($scope.pieces, args)

    if parser.selNode
      $scope.contenteditable = 'false'
    else
      $scope.contenteditable = 'true'

    true

  $scope.makeNotEditable = (event) ->
    $scope.parseMessage(event)
    $scope.contenteditable = 'false'

  $scope.makeEditable = (event) ->
    unless $(event.originalEvent.target).hasClass('pill')
      $scope.contenteditable = 'true'

  $scope.save = ->
    data =
      name: $scope.name
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