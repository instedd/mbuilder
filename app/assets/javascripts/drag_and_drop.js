module = window.angular.module('drag-and-drop', []);
['dragstart', 'dragenter', 'dragover', 'dragleave', 'drop', 'dragend'].forEach(function(event_name) {
  module.directive(event_name, function($parse) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        var attrHandler = $parse(attrs[event_name]);
        var handler = function(e) {
          scope.$apply(function() {
            attrHandler(scope, { $event: e });
          });
        };
        element[0].addEventListener(event_name, handler, false);
      }
    };
  });
});
