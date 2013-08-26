mbuilder = angular.module('mbuilder', ['drag-and-drop', 'focus-and-blur', 'keys', 'ng-rails-csrf']);

draggedPill = null

mbuilder.controller 'EditTriggerController', ['$scope', '$http', ($scope, $http) ->
  $scope.actionTemplateFor = (kind) ->
    "#{kind}_action"

  $scope.pieceTemplateFor = (kind) ->
    "#{kind}_piece"

  $scope.lookupTable = (guid) ->
    _.find $scope.tables, (table) -> table.guid == guid

  $scope.lookupTableName = (guid) ->
    $scope.lookupTable(guid).name

  $scope.lookupFieldName = (tableGuid, fieldGuid) ->
    table = $scope.lookupTable(tableGuid)
    field = _.find table.fields, (field) -> field.guid == fieldGuid
    field.name

  $scope.lookupFieldAction = (tableGuid, fieldGuid) ->
    for action in $scope.actions
      if action.table == tableGuid && action.field == fieldGuid
        return action

    null

  $scope.lookupFieldValue = (tableGuid, fieldGuid) ->
    action = $scope.lookupFieldAction(tableGuid, fieldGuid)
    if action
      return $scope.lookupPillName(action.pill)

    null

  $scope.lookupPillName = (pill) ->
    if pill.kind == 'implicit'
      pill.guid
    else
      pill = _.find $scope.pieces, (piece) -> piece.guid == pill.guid
      pill.text

  $scope.save = ->
    data =
      name: $scope.name
      tables: $scope.tables
      message:
        pieces: $scope.pieces
      actions: $scope.actions

    if $scope.id?
      url = "/applications/#{$scope.applicationId}/triggers/#{$scope.id}"
      method = "put"
    else
      url = "/applications/#{$scope.applicationId}/triggers"
      method = "post"

    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')

    $http[method](url, JSON.stringify(data)).success (data, status, headers, config) =>
      window.location = "/applications/#{$scope.applicationId}/triggers"
]

mbuilder.controller 'TriggerController', ['$scope', ($scope) ->
  $scope.contenteditable = 'false'

  $scope.phoneNumberDragStart = (event) ->
    draggedPill = {kind: "implicit", guid: "phone number"}
    event.dataTransfer.setData("Text", "phone number")

  addPiece = (pieces, kind, text) ->
    text = $.trim(text)
    return if text.length == 0

    pieces.push {kind: kind, text: text, guid: guid()}

  addSelection = (pieces, text, range) ->
    start = range.startOffset
    end = range.endOffset

    while start > 0 && text[start] != ' '
      start -= 1

    while end < text.length && text[end] != ' '
      end += 1

    if start > 0
      addPiece pieces, 'text', text.substring(0, start)

    addPiece pieces, 'pill', text.substring(start, end)

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

  # Parse message pieces from html
  $scope.parseMessage = (event) ->
    sel = window.getSelection()
    if sel.rangeCount > 0
      range = sel.getRangeAt(0)
      if range.startOffset != range.endOffset
        selNode = sel.baseNode

    # We need to keep the current pill's guids.
    # This assumes no pieces are removed after text editions.
    currentPills = _.select $scope.pieces, (piece) -> piece.kind == 'pill'
    currentPillIndex = 0

    pieces = []
    target = event.originalEvent.currentTarget
    foundLastPiece = false

    i = 0
    while i < target.childNodes.length
      node = target.childNodes[i]
      if node.nodeName == "#text"
        if node == selNode
          addSelection pieces, node.textContent, range
        else
          addPiece pieces, 'text', node.textContent
        target.removeChild(node)
      else
        i += 1

        if $(node).hasClass('piece-container')
          children = node.childNodes

          j = 0
          while j < children.length
            child = children[j]
            if child.localName == "div"
              if $(child).hasClass('pill')
                # Here we found an existing pill, so we reuse it
                currentPill = currentPills[currentPillIndex]
                currentPill.text = child.innerText
                pieces.push currentPill
                currentPillIndex += 1
              else if $(child).hasClass('text')
                content = child.childNodes[0]
                if content == selNode
                  addSelection pieces, content.textContent, range
                else
                  addPiece pieces, 'text', content.textContent
              j += 1
            else if child == selNode
              addSelection pieces, child.textContent, range
              node.removeChild(child)
            else
              addPiece pieces, 'text', child.textContent
              node.removeChild(child)
        else if $(node).hasClass('last-piece')
          foundLastPiece = true
          children = node.childNodes

          j = 0
          while j < children.length
            child = children[j]
            if child.nodeName == "#text"
              addPiece pieces, 'text', child.textContent
              unless child.textContent.length == 1 && child.textContent.charCodeAt(160)
                child.textContent = String.fromCharCode(160)
            j += 1

    unless foundLastPiece
      span = document.createElement("span")
      span.className = "last-piece"
      span.innerText = String.fromCharCode(160)
      target.appendChild(span)

    # Replace $scope.pieces' contents only if it changed
    unless samePieces($scope.pieces, pieces)
      args = [0, $scope.pieces.length].concat(pieces)
      Array.prototype.splice.apply($scope.pieces, args)

    if selNode
      $scope.contenteditable = 'false'
    else
      $scope.contenteditable = 'true'

    true

  $scope.makeNotEditable = (event) ->
    $scope.parseMessage(event)
    $scope.contenteditable = 'false'

  $scope.handleMessageKey = (event) ->
    if event.keyCode == 8 # delete
      sel = window.getSelection()
      if sel.rangeCount > 0
        range = sel.getRangeAt(0)
        if range.startOffset == 0
          event.preventDefault()
          return false
        else
          parent = $(sel.extentNode.parentNode)
          if parent.hasClass('pill') && parent.text().length == 1
            event.preventDefault()
            return false

    true

  $scope.dragPill = (piece, event) ->
    draggedPill = {kind: "message_piece", guid: piece.guid}
    event.dataTransfer.setData("Text", piece.text)
    true
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
    $scope.$emit 'pillOverFieldName', pill: draggedPill, field: $scope.field, table: $scope.table

  $scope.dragOverValue = (event) ->
    event.preventDefault()
    true

  $scope.dropOverValue = (event) ->
    $scope.$emit 'pillOverFieldValue', pill: draggedPill, field: $scope.field, table: $scope.table
]

mbuilder.controller 'ActionsController', ['$scope', '$rootScope', ($scope, $rootScope) ->
  tableIsSelected = (tableGuid) ->
    _.any $scope.actions, (action) ->
      (action.kind == 'select_entity' || action.kind == 'create_entity') && action.table == tableGuid

  createTableFieldAction = (kind, args) ->
    action = $scope.lookupFieldAction(args.table.guid, args.field.guid)
    if action
      action.pill = args.pill
    else
      $scope.actions.push
        kind: kind
        pill: args.pill
        table: args.table.guid
        field: args.field.guid

  $rootScope.$on 'pillOverFieldName', (event, args) ->
    createTableFieldAction 'select_entity', args

  $rootScope.$on 'pillOverFieldValue', (event, args) ->
    if tableIsSelected(args.table.guid)
      createTableFieldAction 'store_entity_value', args
    else
      createTableFieldAction 'create_entity', args

  $scope.addSendMessageAction = ->
    $scope.actions.push
      kind: 'send_message'
]
