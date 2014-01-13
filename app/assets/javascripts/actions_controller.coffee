angular.module('mbuilder').controller 'ActionsController', ['$scope', '$rootScope', ($scope, $rootScope) ->
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
    else
      newAction =
        kind: kind
        pill: args.pill
        table: args.table.guid
        field: args.field.guid

      addToActions(newAction)

  addToActions = (newAction) ->
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

  $rootScope.$on 'groupByField', (event, args) ->
    if tableIsUsedInAGroupByAction(args.table.guid)
      $scope.deleteActionWithoutConfirmation $scope.actions.indexOf actionOfTable args.table.guid
      addGroupByAction args
    else
      addGroupByAction args

  $rootScope.$on 'refreshCollection', (event, args) ->
    $rootScope.$broadcast 'updateCollection', args

  $rootScope.$on 'pillOverFieldValue', (event, args) ->
    if tableIsUsedInAnCreateOrSelectAction(args.table.guid)
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
    $scope.actions.splice(index, 1)

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
    addToActions
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
          return false
        me = me.$parent

      event.preventDefault()
      true
    else if window.draggedPill.kind == 'table_ref'
      event.preventDefault()
      true
    else
      false

  $scope.dropOverSpaceBetweenActions = (index, event) ->
    if window.draggedAction
      window.draggedAction.scope.actions.splice window.draggedAction.index, 1
      $scope.actions.splice index, 0, window.draggedAction.action
      return false

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

    false

  $scope.actionMentionsTable = (action, table) ->
    switch action.kind
      when 'create_entity', 'select_entity', 'store_entity_value'
        _.any table.fields, (field) -> action.field == field.guid
      when 'send_message'
        _.any table.fields, (field) ->
          (action.recipient.kind != 'text' && action.recipient.guid == field.guid) ||
            _.any action.message, (msg) -> msg.guid == field.guid
      else
        false

  $scope.actionDragStart = (scope, action, index, event) ->
    window.draggedAction = {scope: scope, action: action, index: index}
    window.draggedPill = null

    event.stopPropagation()

    false

  $scope.actionDragEnd = (event) ->
    window.draggedAction = null

    false

  $scope.isFirstFilter = (action) ->
    (_.select $scope.actions, (a) ->
      return a.kind == "select_entity" and a.table == action.table
    )[0] == action
]
