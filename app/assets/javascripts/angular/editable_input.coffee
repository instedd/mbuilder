window.draggedPill = null

angular.module('mbuilder').directive 'editableInput', ->
  restrict: 'E'
  scope: {
    model: '='
    editmode: '='
    focusmode: '='
    dragover: '='
    drop: '='
  }
  link: (scope, elem, attrs) ->
    if scope.focusmode
      window.setTimeout (-> $('input', elem).focus()), 0

    scope.makeEditable = (event) ->
      return unless event.originalEvent.button == 0

      scope.editmode = true
      window.setTimeout (-> $('input', elem).focus()), 0

    scope.makeNotEditable = ->
      scope.editmode = false

    scope.checkEnter = (event) ->
      if event.originalEvent.keyCode == 13
        scope.editmode = false
      true

    scope.size = ->
      len = scope.model?.length
      if len == 0 then 1 else len

  templateUrl: 'editable_input'
