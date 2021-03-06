angular.module('mbuilder').controller 'ActionsController', ['$scope', '$rootScope', 'HubApi', ($scope, $rootScope, HubApi) ->

  $scope.addNewValuePlaceholder = 'define value'

  tableIsUsedInAnCreateOrSelectAction = (tableGuid) ->
    _.any $scope.actions, (action) ->
      (action.kind == 'select_entity' || action.kind == 'create_entity') && action.table == tableGuid

  tableIsUsedInAGroupByAction = (tableGuid) ->
    _.any $scope.actions, (action) ->
      action.kind == 'group_by' && action.table == tableGuid

  actionOfTable = (tableGuid) ->
    _.find $scope.actions, (action) ->
      action.kind == 'group_by' && action.table == tableGuid

  createTableFieldAction = (kind, args) ->
    action = $scope.lookupFieldAction(args.field.guid)
    if action
      status = $scope.lookupPillStatus(action.pill)
      if status == "unbound"
        actionGuid = action.pill.guid
        $scope.replacePills(actionGuid, args.pill)
      else
        action.pill = args.pill
      null
    else
      if args.table.protocol
        if (kind == 'store_entity_value' and 'update' not in args.table.protocol) or \
           (kind == 'create_entity' and 'insert' not in args.table.protocol)
          return

      newAction =
        kind: kind
        pill: args.pill
        table: args.table.guid
        field: args.field.guid

      newAction.create_or_update = false if kind == 'store_entity_value'

      newAction

  addToActions = (actions, newAction, index = -1) ->
    # Put the action before the first "send message" action, if any
    i = index
    i = actions.length - 1 if i == -1

    if i == -1 || newAction.kind == 'send_message'
      actions.push(newAction)
    else
      if newAction.kind != 'send_message'
        while i >= 0
          action = actions[i]
          if action.kind != 'send_message'
            actions.splice(i + 1, 0, newAction)
            return
          i -= 1

      actions.splice(0, 0, newAction)

  $scope.onActionTarget = (callback) ->
    mustCreate = false
    actions = $scope.actions
    index = -1
    if !$scope.action
      mustCreate = true

    if mustCreate
      callback(actions, index)

  $scope.$on 'pillOverFieldName', (event, args) ->
    $scope.onActionTarget (actions, index) ->
      action = createTableFieldAction 'select_entity', args
      if action
        addToActions(actions, action, index)

  $scope.$on 'pillOverFieldValue', (event, args) ->
    $scope.onActionTarget (actions, index) ->
      action = null
      actionKind = if tableIsUsedInAnCreateOrSelectAction(args.table.guid) then 'store_entity_value' else 'create_entity'
      action = createTableFieldAction actionKind, args
      if action
        addToActions(actions, action, index)

  $rootScope.$on 'groupByField', (event, args) ->
    unless $scope.action
      if tableIsUsedInAGroupByAction(args.table.guid)
        $scope.deleteActionWithoutConfirmation $scope.actions.indexOf actionOfTable args.table.guid
        addGroupByAction args
      else
        addGroupByAction args

  $rootScope.$on 'refreshCollection', (event, args) ->
    unless $scope.action
      $rootScope.$broadcast 'updateCollection', args

  $scope.addSendMessageAction = ->
    action =
      kind: 'send_message'
      message: []
      recipient: $scope.newPill()
      messageeditable: 'false'
      recipienteditable: 'false'

    $scope.actions.push(action)

  $scope.addLoopAction = ->
    action =
      kind: 'foreach'
      table: null
      actions: []

    $scope.actions.push(action)

  $scope.addIfAction = ->
    action =
      kind: 'if'
      all: true,
      left: $scope.newPill() # TODO should define how to write literal probaly
      op: '=='
      right: [
        $scope.newEmptyLiteralPill() # TODO migrate to newPill
      ]
      actions: []

    $scope.actions.push(action)

  $scope.addHubAction = ->
    HubApi.openPicker('action')
      .then((path, selection) ->
        HubApi.reflect(path)
          .then (result) ->
            $scope.$apply ->
              action =
                kind: 'hub'
                path: path
                selection: selection
                reflect: result.toJson()
                pills: result.visitArgs (field) ->
                  $scope.defaultPillForHubField(field)

              $scope.actions.push(action)
      )

  $scope.defaultPillForHubField = (field) ->
    if !field.isStruct() and field.isEnum()
      $scope.newEmptyLiteralPill()
    else
      $scope.newPill()

  $scope.showAddExternalServicePopup = (event) ->
    li = $(event.target).closest('li')
    offset = li.offset();
    $scope.showPopup '#add-external-service', event, {top: offset.top, left: offset.left + li.outerWidth()}

  $scope.deleteAction = (index) ->
    action = $scope.actions[index]
    if action.kind == 'foreach'
      if action.actions.length == 0
        $scope.deleteActionWithoutConfirmation(index)
      else
        $rootScope.modalScope = $scope
        $rootScope.modalActionIndex = index
        $('#actions-modal-delete').modal()
    else
      $scope.deleteActionWithoutConfirmation(index)

  $scope.deleteActionWithoutConfirmation = (index) ->
    action = $scope.actions[index]

    $scope.actions.splice(index, 1)

    # change the first store_entity_value in the table to a create_entity
    if action.kind == 'create_entity'
      new_create_entity = ($scope.firstActionThat (a) ->
        return a.kind == 'store_entity_value' and a.table == action.table
      )
      if new_create_entity != null
        delete new_create_entity.create_or_update
        new_create_entity.kind = 'create_entity'


  $scope.modalDeleteForeachAndActions = ->
    $rootScope.modalScope.deleteActionWithoutConfirmation($rootScope.modalActionIndex)
    $('#actions-modal-delete').modal('hide')

  $scope.modalDeleteForeachKeepActions = ->
    scope = $rootScope.modalScope
    action = scope.actions[$rootScope.modalActionIndex]
    scope.actions.splice($rootScope.modalActionIndex, 1, action.actions...)
    $('#actions-modal-delete').modal('hide')

  $scope.actionTemplateFor = (kind) ->
    "#{kind}_action"

  addGroupByAction = (args) ->
    addToActions $scope.actions,
      kind: 'group_by'
      field: args.field.guid
      table: args.table.guid

  $scope.dragOverSpaceBetweenActions = (event) ->
    if window.draggedAction
      # We must prevent dropping an action inside itself
      scope = window.draggedAction.scope
      me = $scope
      while me
        if me == scope
          return true
        me = me.$parent

      event.dataTransfer.effectAllowed = "move"
      event.dataTransfer.dropEffect = "move"
      event.preventDefault()
      return false

    if window.draggedPill
      event.dataTransfer.effectAllowed = "copy"
      event.dataTransfer.dropEffect = "copy"
      event.preventDefault()
      return false

    true

  $scope.dragEnterPlaceholder = (event) ->
    $(event.target).addClass('drop-preview')

  $scope.dragLeavePlaceholder = (event) ->
    $(event.target).removeClass('drop-preview')

  $scope.dropOverSpaceBetweenActions = (index, event) ->
    if window.draggedAction
      window.draggedAction.scope.actions.splice window.draggedAction.index, 1
      $scope.actions.splice index, 0, window.draggedAction.action
      return false

    if window.draggedPill == null
      return false

    if window.draggedPill.kind == 'table_ref'
      table = $scope.lookupTable window.draggedPill.guid

      # Automatically include following actions in the foreach
      # if the mention some of the table's fields.
      actions = []

      i = index
      while i < $scope.actions.length
        next_action = $scope.actions[i]
        if $scope.actionMentionsTable(next_action, table)
          actions.push next_action
          i += 1
        else
          break

      action =
        kind: 'foreach'
        table: window.draggedPill.guid
        actions: actions

      $scope.actions.splice index, actions.length, action

      return false

    action =
      kind: 'if'
      all: true,
      left: window.draggedPill
      op: '=='
      right: [
        {kind: 'literal', guid: window.guid(), text: ''},
      ]
      actions: []

    $scope.actions.splice index, 0, action

    false

  $scope.actionMentionsTable = (action, table) ->
    switch action.kind
      when 'create_entity', 'select_entity', 'store_entity_value'
        _.any table.fields, (field) -> action.field == field.guid
      when 'send_message'
        _.any table.fields, (field) ->
          (action.recipient.kind != 'text' && action.recipient.guid == field.guid) ||
            _.any action.message, (msg) -> msg.guid == field.guid
      when 'if'
        $scope.pillMentionsTable(action.left, table) || _.any(action.right, (a) -> $scope.pillMentionsTable(a, table))
      else
        false

  $scope.pillMentionsTable = (pill, table) ->
    if pill.kind == 'field_value'
      targetTable = $scope.lookupTableByField(pill.guid)
      return targetTable?.guid == table.guid
    else
      false

  $scope.actionDragStart = (scope, action, index, event) ->
    window.draggedAction = {scope: scope, action: action, index: index}
    window.draggedPill = null
    $scope.$emit 'dragStart'

    event.stopPropagation()

    # set the opacity of the drag and drop ghost
    original = $(event.target).closest('.action')
    original.css('opacity', '0.4')
    event.dataTransfer.setDragImage(original[0], 0, 0);
    window.setTimeout ->
      original.css('opacity', '')
    , 0
    #

    false

  $scope.actionDragEnd = (event) ->
    window.draggedAction = null

    false

  $scope.tryShowAggregateFunctionsPopup = (pill, actionScope, event) ->
    if $scope.action?.kind == 'if'
      return $scope.showAggregateFunctionsPopup pill, actionScope, event

    false

  $scope.dragOverIfOperand = (event) ->
    if window.draggedPill
      event.dataTransfer.allowedEffect = "link"
      event.dataTransfer.dropEffect = "link"
      event.preventDefault()
      false
    else
      true

  $scope.dropOverIfLeft = (event) ->
    $scope.action.left = window.draggedPill

  $scope.dropOverIfRight = (index, event) ->
    $scope.action.right[index] = window.draggedPill

  $scope.convertIfRightToLiteral = (index, event) ->
    if window.draggedPill
      $scope.dropOverIfRight(index, event)
      return
    action = $scope.action.right[index]
    if action.kind != 'literal'
      $scope.action.right[index] = {kind: 'literal', guid: window.guid(), text: '', editmode: true, focusmode: true}

  $scope.mustShowIfAggregate = (action) ->
    switch action.left.kind
      when 'placeholder'
        false
      when 'field_value'
        table = $scope.lookupTableByField(action.left.guid)
        if table && $scope.tableIsUsedAsForeach(table.guid)
          false
        else
          true
      else
        true

  $scope.tableIsUsedAsForeach = (table_guid) ->
    scope = $scope.$parent
    while scope
      if scope.action?.kind == 'foreach' && scope.action.table == table_guid
        return true
      scope = scope.$parent
    false

  $scope.tryShowAggregateFunctionsPopup = (pill, event) ->
    $scope.showAggregateFunctionsPopup pill, $scope, event

]
