mbuilder = angular.module('mbuilder', ['drag-and-drop', 'focus-and-blur']);

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
]

mbuilder.controller 'TriggerController', ['$scope', ($scope) ->
  $scope.contenteditable = 'false'
  $scope.pieces = []

  $scope.phoneNumberDragStart = (event) ->
    event.dataTransfer.setData("pill", "phone number")

  $scope.makeContentEditable = (event) ->
    $scope.contenteditable = 'true'

  addPiece = (pieces, kind, value) ->
    return if $.trim(value).length == 0

    pieces.push {kind: kind, value: value, index: pieces.length}

  addSelection = (pieces, text, range) ->
    if range.startOffset > 0
      addPiece pieces, 'text', text.substring(0, range.startOffset)

    addPiece pieces, 'pill', text.substring(range.startOffset, range.endOffset)

    if range.endOffset < text.length
      addPiece pieces, 'text', text.substring(range.endOffset)

  samePieces = (pieces1, pieces2) ->
    return false if pieces1.length != pieces2.length

    i = 0
    while i < pieces1.length
      piece1 = pieces1[i]
      piece2 = pieces2[i]
      return false if piece1.kind != piece2.kind || piece1.value != piece2.value
      i += 1

    true

  $scope.parseMessage = (event) ->
    sel = window.getSelection()
    if sel.rangeCount > 0
      range = sel.getRangeAt(0)
      if range.startOffset != range.endOffset
        selNode = sel.baseNode

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
          for child in children
            if child.localName == "div"
              if $(child).hasClass('pill')
                addPiece pieces, 'pill', child.innerText
              else if $(child).hasClass('text')
                content = child.childNodes[0]
                if content == selNode
                  addSelection pieces, content.textContent, range
                else
                  addPiece pieces, 'text', content.textContent
            else if child == selNode
              addSelection pieces, child.textContent, range
            else
              addPiece pieces, 'text', child.textContent

    unless samePieces($scope.pieces, pieces)
      $scope.pieces = pieces

    if selNode
      $scope.contenteditable = 'false'
    else
      $scope.contenteditable = 'true'

    true

  $scope.makeNotEditable = (event) ->
    $scope.contenteditable = 'false'

  $scope.dragPill = (event) ->
    event.dataTransfer.setData("piece", 1)
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

  $scope.dragOverValue = (event) ->
    event.preventDefault()
    true

  $scope.dropOverValue = (event) ->
    pillName = event.dataTransfer.getData("pill")
    $scope.$emit 'pillNameOverFieldValue', pill: pillName, field: $scope.field, table: $scope.table
]

mbuilder.controller 'ActionsController', ['$scope', '$rootScope', ($scope, $rootScope) ->
  $rootScope.$on 'pillNameOverFieldName', (event, args) ->
    $scope.actions.push
      kind: 'select_or_create_table'
      pill: args.pill
      table: args.table.guid
      field: args.field.guid

  $rootScope.$on 'pillNameOverFieldValue', (event, args) ->
    $scope.actions.push
      kind: 'store_value'
      pill: args.pill
      table: args.table.guid
      field: args.field.guid
]
