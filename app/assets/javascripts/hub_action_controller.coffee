angular.module('mbuilder')

.controller('HubActionController', ['$scope', 'HubApi', ($scope, HubApi) ->
  $scope.reflect = HubApi.reflectResult($scope.action.reflect)
  $scope.pills = $scope.action.pills

  $scope.fieldViewFor = (field) ->
    if field.isStruct()
      'hub_action_struct_field'
    else
      'hub_action_value_field'


  $scope.referenced_pill = ->
    navigate = (obj, path) ->
      for key in path
        obj = obj[key]
      obj

    $scope.reflect.visitArgs (f) =>
      navigate($scope.pills, f.path())

  $scope.$on 'updateActionReflect', (e) ->
    $scope.action.reflect = $scope.reflect.toJson()

    # keep only pills defined in the reflect.
    # in case pill are removed
    $scope.pills = $scope.action.pills = $scope.referenced_pill()
    $scope.$broadcast 'reflectUpdated'

    e.stopPropagation()
])

.controller('HubActionArgController', ['$scope', '$timeout', ($scope, $timeout) ->
  if $scope.field.canBeRemoved()
    $scope.name = {
      model: $scope.field.name(),
      editmode: false,
      focusmode: false
    }

    initial_name = $scope.field.name()

    $scope.$watch 'name.editmode', (new_value, old_value) ->
      if new_value != old_value && new_value == false
        $scope.field.setName($scope.name.model)
        target_pills = if $scope.field.isStruct()
          $scope.$parent.pills
        else
          $scope.pills
        target_pills[$scope.name.model] = target_pills[initial_name]
        initial_name = $scope.name.model
        $scope.$emit 'updateActionReflect'

    $scope.$on 'edit-field-name', (e, field_name) ->
      if $scope.name.model == field_name
        $scope.$broadcast('makeEditable')
        e.preventDefault();

  get_pill_from_parent = ->
    return unless $scope.$parent.pills
    if $scope.field.isStruct()
      $scope.pills = $scope.$parent.pills[$scope.field.name()]
    else
      $scope.pill = $scope.$parent.pills[$scope.field.name()]

  get_pill_from_parent()
  $scope.$on 'reflectUpdated', get_pill_from_parent

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
    field_exists = (name) ->
      for f in $scope.field.fields()
        return true if f.name() == name
      return false

    next_field_name = () ->
      new_field_name_prefix = 'new_field_'
      new_field_name_counter = 1
      while field_exists("#{new_field_name_prefix}#{new_field_name_counter}")
        new_field_name_counter += 1
      return "#{new_field_name_prefix}#{new_field_name_counter}"

    new_field_name = next_field_name()

    f = $scope.field.addOpenField(new_field_name, type)
    if f.isStruct()
      $scope.pills[new_field_name] = {}
    else
      $scope.pills[new_field_name] = $scope.newPill()


    $scope.$emit 'updateActionReflect'
    $timeout ->
      $scope.$broadcast 'edit-field-name', new_field_name
    , 0

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
