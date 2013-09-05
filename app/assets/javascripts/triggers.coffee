mbuilder = angular.module('mbuilder', ['drag-and-drop', 'focus-and-blur', 'keys', 'ng-rails-csrf']);

draggedPill = null

mbuilder.directive 'editableInput', ->
  restrict: 'E'
  scope: {
    model: '='
    editable: '='
    focus: '='
    dragover: '='
    drop: '='
  }
  link: (scope, elem, attrs) ->
    if scope.focus
      window.setTimeout (-> $('input', elem).focus()), 0

    scope.makeEditable = ->
      scope.editable = true
      window.setTimeout (-> $('input', elem).focus()), 0

    scope.makeNotEditable = ->
      scope.editable = false

    scope.checkEnter = (event) ->
      if event.originalEvent.keyCode == 13
        scope.editable = false
      true

    scope.size = ->
      len = scope.model.length
      if len == 0 then 1 else len

  templateUrl: 'editable_input'

mbuilder.controller 'EditTriggerController', ['$scope', '$http', ($scope, $http) ->
  $scope.actionTemplateFor = (kind) ->
    "#{kind}_action"

  $scope.pieceTemplateFor = (kind) ->
    "#{kind}_piece"

  $scope.bindingTemplateFor = (kind) ->
    "#{kind}_binding"

  $scope.pillTemplateFor = (pill) ->
    status = $scope.lookupPillStatus(pill)
    "#{status}_pill"

  $scope.fieldTemplateFor = (tableGuid, fieldGuid) ->
    status = $scope.lookupFieldStatus(tableGuid, fieldGuid)
    "#{status}_field"

  $scope.lookupTable = (guid) ->
    _.find $scope.tables, (table) -> table.guid == guid

  $scope.lookupTableName = (guid) ->
    $scope.lookupTable(guid)?.name

  $scope.lookupFieldName = (tableGuid, fieldGuid) ->
    table = $scope.lookupTable(tableGuid)
    return "" unless table

    field = _.find table.fields, (field) -> field.guid == fieldGuid
    field?.name

  $scope.lookupJoinedFieldName = (tableFieldGuid) ->
    [tableGuid, fieldGuid] = tableFieldGuid.split(';')
    tableName = $scope.lookupTableName(tableGuid)
    fieldName = $scope.lookupFieldName(tableGuid, fieldGuid)
    "#{tableName} #{fieldName}"

  $scope.lookupFieldAction = (tableGuid, fieldGuid) ->
    for action in $scope.actions
      if action.table == tableGuid && action.field == fieldGuid
        return action

    null

  $scope.lookupFieldStatus = (tableGuid, fieldGuid) ->
    action = $scope.lookupFieldAction(tableGuid, fieldGuid)
    if action
      return $scope.lookupPillStatus(action.pill)

    tableAction = _.find $scope.actions, (action) -> action.table == tableGuid
    if tableAction?.kind == 'select_entity'
      return 'existing'

    'new'

  $scope.lookupFieldValue = (tableGuid, fieldGuid) ->
    action = $scope.lookupFieldAction(tableGuid, fieldGuid)
    if action
      return $scope.lookupPillName(action.pill)

    null

  $scope.fieldExists = (tableGuid, fieldGuid) ->
    table = $scope.lookupTable(tableGuid)
    return false unless table

    field = _.find table.fields, (field) -> field.guid == fieldGuid
    return false unless field

    true

  $scope.tableExists = (tableGuid) ->
    table = $scope.lookupTable(tableGuid)
    return false unless table

    true

  $scope.lookupPillStatus = (pill) ->
    switch pill.kind
      when 'implicit'
        return 'bound'
      when 'field_value'
        return 'field_value'
      else
        pill = _.find $scope.pieces, (piece) -> piece.guid == pill.guid
        return 'bound' if pill

        'unbound'

  $scope.lookupPillName = (pill) ->
    switch pill.kind
      when 'implicit'
        $scope.lookupImplicitBinding(pill.guid)
      when 'field_value'
        $scope.lookupJoinedFieldName(pill.guid)
      else
        pill = $scope.lookupPill(pill.guid)
        pill?.text

  $scope.lookupPill = (guid) ->
    _.find $scope.pieces, (piece) -> piece.guid == guid

  $scope.lookupImplicitBinding = (guid) ->
    $scope.from

  $scope.fieldBindingDragStart = (tableGuid, fieldGuid) ->
    action = $scope.lookupFieldAction(tableGuid, fieldGuid)
    if action
      $scope.bindingDragStart(action.pill)
    else
      $scope.fieldValueDragStart(tableGuid, fieldGuid)

  $scope.bindingDragStart = (pill) ->
    draggedPill = pill
    event.dataTransfer.setData("Text", $scope.lookupPillName(pill))

  $scope.fieldValueDragStart = (tableGuid, fieldGuid) ->
    draggedPill = {kind: 'field_value', guid: "#{tableGuid};#{fieldGuid}"}
    event.dataTransfer.setData("Text", $scope.lookupFieldName(tableGuid, fieldGuid))

  $scope.tableDragStart = (tableGuid, event) ->
    draggedPill = {kind: 'table_ref', guid: tableGuid}
    event.dataTransfer.setData("Text", $scope.lookupTableName(tableGuid))

  $scope.dragOverUnboundPill = (pill, event) ->
    event.preventDefault()
    true

  $scope.dropOverUnboundPill = (pill, event) ->
    $scope.replacePills(pill.guid, draggedPill)

    event.stopPropagation()

  $scope.dragOverUnboundTable = (tableGuid, event) ->
    return false if draggedPill.kind != 'table_ref'

    event.preventDefault()
    true

  $scope.dropOverUnboundTable = (tableGuid, event) ->
    for action in $scope.actions
      if action.table == tableGuid
        action.table = draggedPill.guid

    event.stopPropagation()

  $scope.visitPills = (fun) ->
    for action in $scope.actions
      if action.pill
        fun(action.pill)

      if action.kind == 'send_message'
        for binding in action.message
          fun(binding)
        fun(action.recipient)

  $scope.replacePills = (guid, newPill) ->
    $scope.visitPills (otherPill) ->
      if otherPill.guid == guid
        otherPill.kind = newPill.kind
        otherPill.guid = newPill.guid

  $scope.save = ->
    data =
      name: $scope.name
      tables: $scope.tables
      message:
        from: $scope.from
        pieces: $scope.pieces
      actions: $scope.actions

    if $scope.id?
      url = "/applications/#{$scope.applicationId}/triggers/#{$scope.id}"
      method = "put"
    else
      url = "/applications/#{$scope.applicationId}/triggers"
      method = "post"

    call = $http[method](url, JSON.stringify(data))
    call.success (data, status, headers, config) =>
      window.location = "/applications/#{$scope.applicationId}/triggers"
    call.error (data, status, headers, config) =>
      alert "Error: #{data}"
]

mbuilder.controller 'TriggerController', ['$scope', ($scope) ->
  $scope.contenteditable = 'false'

  $scope.phoneNumberDragStart = (event) ->
    draggedPill = {kind: "implicit", guid: "phone number"}
    event.dataTransfer.setData("Text", $scope.lookupImplicitBinding(draggedPill.guid))

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

  $scope.parseMessage = (event) ->
    pieces = []

    parser = new MessageParser(event.originalEvent.currentTarget)
    parser.onText (text, hasSelection) ->
      if hasSelection
        addSelection pieces, text, parser.range
      else
        addPiece pieces, 'text', text
    parser.onPill (node) ->
      addPiece pieces, 'pill', node.text(), node.data('guid')
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

  $scope.dragPill = (piece, event) ->
    draggedPill = {kind: "piece", guid: piece.guid}
    event.dataTransfer.setData("Text", piece.text)
    true
]

mbuilder.controller 'TablesController', ['$scope', ($scope) ->
  $scope.newTable = ->
    $scope.tables.push
      guid: window.guid()
      name: "Table #{$scope.tables.length + 1}"
      fields: []
      editable: true
      focus: true

  $scope.deleteTable = (index) ->
    $scope.tables.splice(index, 1)
]

mbuilder.controller 'TableController', ['$scope', ($scope) ->
  $scope.newField = ->
    $scope.table.fields.push
      guid: window.guid()
      name: "Field #{$scope.table.fields.length + 1}"
      editable: true
      focus: true

  $scope.deleteField = (index) ->
    $scope.table.fields.splice(index, 1)
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
      status = $scope.lookupPillStatus(action.pill)
      if status == "unbound"
        actionGuid = action.pill.guid
        $scope.replacePills(actionGuid, args.pill)
      else
        action.pill = args.pill
    else
      newAction =
        kind: kind
        pill: args.pill
        table: args.table.guid
        field: args.field.guid

      # Put the action before the first "send message" action, if any
      i = $scope.actions.length - 1
      while i >= 0
        action = $scope.actions[i]
        if action.kind != 'send_message'
          $scope.actions.splice(i + 1, 0, newAction)
          return
        i -= 1

      $scope.actions.splice(0, 0, newAction)

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
      message: []
      recipient: {kind: 'text', guid: ''}
      messageEditable: 'false'
      recipientEditable: 'false'

  $scope.deleteAction = (index) ->
    $scope.actions.splice(index, 1)
]

mbuilder.controller 'SendMessageController', ['$scope', ($scope) ->
  addBinding = (bindings, kind, guid) ->
    guid = $.trim(guid)
    return if guid.length == 0

    bindings.push kind: kind, guid: guid

  $scope.parseMessage = (event) ->
    bindings = []
    parser = new MessageParser(event.originalEvent.currentTarget)
    parser.onText (text) ->
      addBinding bindings, 'text', text
    parser.onPill (node) ->
      addBinding bindings, node.data('kind'), node.data('guid')
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
    $scope.action.messageEditable = 'true'

  $scope.dragOverMessage = (event) ->
    event.preventDefault()
    true

  $scope.dropOverMessage = (event) ->
    $scope.action.message.push draggedPill
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
    $scope.action.recipient = draggedPill
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
