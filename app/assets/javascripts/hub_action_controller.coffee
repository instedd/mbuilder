angular.module('mbuilder')

.controller('HubActionController', ['$scope', 'HubApi', ($scope, HubApi) ->
  $scope.reflect = HubApi.reflectResult($scope.action.reflect)
  $scope.pills = $scope.action.pills

  $scope.fieldViewFor = (field) ->
    if field.isStruct()
      'hub_action_struct_field'
    else
      'hub_action_value_field'

  $scope.$on 'updateActionReflect', (e) ->
    $scope.action.reflect = $scope.reflect.toJson()
    e.stopPropagation()
])

.controller('HubActionArgController', ['$scope', '$timeout', ($scope, $timeout) ->
  if $scope.field.canBeRemoved()
    $scope.name = {
      model: $scope.field.label(),
      editmode: false,
      focusmode: false
    }

    $scope.$watch 'name.model', (new_value, old_value) ->
      if new_value != old_value
        $scope.field.setName(new_value)
        $scope.pills[new_value] = $scope.pills[old_value]
        delete $scope.pills[old_value]
        $scope.$emit 'updateActionReflect'

  if $scope.field.isStruct()
    $scope.pills = $scope.$parent.pills[$scope.field.name()]
    $scope.new_field = { name : '' }
  else
    $scope.pill = $scope.$parent.pills[$scope.field.name()]

  $scope.dragOverHubOperand = (event) ->
    if window.draggedPill
      event.dataTransfer.allowedEffect = "link"
      event.dataTransfer.dropEffect = "link"
      event.preventDefault()
      false
    else
      true

  # Support for Hub's enum type parameters
  $scope.pillTemplateFor = (pill) ->
    if pill.kind == 'literal' and !$scope.field.isStruct() and $scope.field.isEnum()
      'enum_literal_pill'
    else
      $scope.$parent.pillTemplateFor(pill)

  $scope.enumOptions = ->
    [{value: null, label: '(empty)'}].concat $scope.field.enumOptions()

  $scope.dropOverHubOperand = (event) ->
    $scope.pill = window.draggedPill
    $scope.$parent.pills[$scope.field.name()] = $scope.pill

  $scope.addField = (type) ->
    return unless $scope.new_field.name and !$scope.pills[$scope.new_field.name]
    f = $scope.field.addOpenField($scope.new_field.name, type)
    if f.isStruct()
      $scope.pills[$scope.new_field.name] = {}
    else
      $scope.pills[$scope.new_field.name] = $scope.newPill()
    $scope.$emit 'updateActionReflect'
    $scope.new_field.name = ''

  $scope.removeField = ->
    $scope.field.remove()
    $scope.$emit 'updateActionReflect'

  $scope.addNewValue = ->
    $scope.pill = $scope.$parent.pills[$scope.field.name()] = $scope.newFocusedEmptyLiteralPill()

    $timeout ->
      $scope.$broadcast 'makeEditable'

  $scope.removePill = (pill) ->
    $scope.pill = $scope.$parent.pills[$scope.field.name()] = $scope.defaultPillForHubField($scope.field)

])
