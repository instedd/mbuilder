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

  $scope.isFirstFilter = (action) ->
    (_.select $scope.actions, (a) ->
      return a.kind == "select_entity"
    )[0] == action
]
