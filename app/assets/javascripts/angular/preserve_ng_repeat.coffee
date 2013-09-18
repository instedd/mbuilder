# This directive preserve the "<!-- ngRepeat: ... -->" dom element put by AngularJS.
# Inside a .message-are we are repeating the pieces. Because the message area
# is contenteditable, the user can delete everything inside it, including that
# comment which, apparently, makes the ngRepeat work.
# So, the idea is to keep the ngRepeat comment when the user presses a key,
# and when it releases it check if that comment is still there. If not,
# we put it back.
module = window.angular.module('preserve-ng-repeat', []);
module.directive 'preserveNgRepeat', ->
  restrict: 'A'
  link: (scope, elem, attrs) ->
    ngRepeatComment = null

    findNgRepeatComment = (element) ->
      children = element.childNodes
      for child in children
        if child.nodeName == '#comment'
          return child
      null

    $(elem).keydown (event) ->
      ngRepeatComment ?= findNgRepeatComment event.originalEvent.target
      true

    $(elem).keyup (event) ->
      target = event.originalEvent.target
      comment = findNgRepeatComment target
      unless comment
        child = target.childNodes[0]
        if child
          target.insertBefore ngRepeatComment, child
        else
          target.appendChild ngRepeatComment
      true
