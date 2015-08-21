// https://github.com/bcardiff/angular-elastic-input
/**
 * angular-elastic-input
 * A directive for AngularJS which automatically resizes the width of input field according to the content, while typing.
 * @author: Jacek Pulit <jacek.pulit@gmail.com>
 * @license: MIT License
 */

'use strict';

angular.module('puElasticInput', []).directive('puElasticInput', function(){
    return {
        restrict: 'A',
        link: function postLink(scope, element, attrs) {

            var wrapper = angular.element('#pu-elastic-input-wrapper');
            if (!wrapper.length) {
              wrapper = angular.element('<div id="pu-elastic-input-wrapper" style="position:fixed; top:-999px; left:0;"></div>');
              angular.element('body').append(wrapper);
            }

            var mirror = angular.element('<span style="white-space:pre;"></span>');

            var defaultMaxwidth = element.css('maxWidth') === 'none' ? element.parent().innerWidth() : element.css('maxWidth');
            element.css('minWidth', attrs.puElasticInputMinwidth || element.css('minWidth'));
            element.css('maxWidth', attrs.puElasticInputMaxwidth || defaultMaxwidth);

            angular.forEach(['fontFamily', 'fontSize', 'fontWeight', 'fontStyle',
                'letterSpacing', 'textTransform', 'wordSpacing', 'textIndent',
                'boxSizing', 'borderRightWidth', 'borderLeftWidth', 'borderLeftStyle', 'borderRightStyle',
                'paddingLeft', 'paddingRight', 'marginLeft', 'marginRight'], function(value) {
                mirror.css(value, element.css(value));
            });

            wrapper.append(mirror);

            function update() {
                mirror.text(element.val() || attrs.placeholder);
                element.css('width', mirror.outerWidth() + 1);
            }

            update();

            if (attrs.ngModel) {
                scope.$watch(attrs.ngModel, function(){ update(); });
            } else {
                element.on('keydown keyup focus input propertychange change', function(){ update(); });
            }

            scope.$on('$destroy', function() {
                mirror.remove();
            });
        }
    };
});
