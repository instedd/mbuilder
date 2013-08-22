mbuilder = angular.module('mbuilder', ['drag-and-drop', 'focus-and-blur', 'keys']);

draggedPill = null

mbuilder.controller 'EditTriggerController', ['$scope', ($scope) ->
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

  $scope.lookupPillName = (pill) ->
    if pill.kind == 'implicit'
      pill.name
    else
      pill = _.find $scope.pieces, (piece) -> piece.guid == pill.guid
      pill.value
]

mbuilder.controller 'TriggerController', ['$scope', ($scope) ->
  $scope.contenteditable = 'false'

  $scope.phoneNumberDragStart = (event) ->
    draggedPill = {kind: "implicit", name: "phone number"}
    event.dataTransfer.setData("Text", "phone number")

  addPiece = (pieces, kind, value) ->
    return if $.trim(value).length == 0

    pieces.push {kind: kind, value: value, index: pieces.length, guid: guid()}

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
      return false if piece1.kind != piece2.kind || piece1.value != piece2.value
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

        if $(node).hasClass('pill-container')
          children = node.childNodes

          j = 0
          while j < children.length
            child = children[j]
            if child.localName == "div"
              if $(child).hasClass('pill')
                # Here we found an existing pill, so we reuse it
                currentPill = currentPills[currentPillIndex]
                currentPill.index = pieces.length
                currentPillIndex += 1
                pieces.push currentPill
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
    $scope.contenteditable = 'false'

  $scope.handleMessageKey = (event) ->
    if event.keyCode == 8 # delete
      sel = window.getSelection()
      if sel.rangeCount > 0
        range = sel.getRangeAt(0)
        if range.startOffset == 0 || range.commonAncestorContainer.nodeName != "#text"
          event.preventDefault()
          return false

    true

  $scope.dragPill = (piece, event) ->
    draggedPill = {kind: "piece", guid: piece.guid}
    event.dataTransfer.setData("Text", piece.value)
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
  $rootScope.$on 'pillOverFieldName', (event, args) ->
    $scope.actions.push
      kind: 'select_or_create_table'
      pill: args.pill
      table: args.table.guid
      field: args.field.guid

  $rootScope.$on 'pillOverFieldValue', (event, args) ->
    $scope.actions.push
      kind: 'store_value'
      pill: args.pill
      table: args.table.guid
      field: args.field.guid
]
