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
      $scope.deleteAction $scope.actions.indexOf actionOfTable args.table.guid
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
    $scope.actions.splice(index, 1)

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

      console.log $scope.actions

      return false

    action =
      kind: 'foreach'
      table: window.draggedPill.guid
      actions: []

    $scope.actions.splice index, 0, action

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
