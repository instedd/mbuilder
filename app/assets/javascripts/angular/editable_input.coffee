mbuilder = angular.module('mbuilder', ['drag-and-drop', 'focus-and-blur', 'keys', 'right-click', 'ng-rails-csrf', 'preserve-ng-repeat']);

window.draggedPill = null

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

    scope.makeEditable = (event) ->
      return unless event.originalEvent.button == 0

      scope.editable = true
      window.setTimeout (-> $('input', elem).focus()), 0

    scope.makeNotEditable = ->
      scope.editable = false

    scope.checkEnter = (event) ->
      if event.originalEvent.keyCode == 13
        scope.editable = false
      true

    scope.size = ->
      len = scope.model?.length
      if len == 0 then 1 else len

  templateUrl: 'editable_input'
