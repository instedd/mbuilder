module = window.angular.module('keys', []);
module.directive('ngKeydown', ['$parse', function($parse) {
  return function(scope, element, attr) {
    var fn = $parse(attr['ngKeydown']);
    element.bind('keydown', function(event) {
      scope.$apply(function() {
        fn(scope, {$event:event});
      });
    });
  }
}]);

module.directive('ngKeyup', ['$parse', function($parse) {
  return function(scope, element, attr) {
    var fn = $parse(attr['ngKeyup']);
    element.bind('keyup', function(event) {
      scope.$apply(function() {
        fn(scope, {$event:event});
      });
    });
  }
}]);
