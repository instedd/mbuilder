angular.module('mbuilder').controller 'ScheduleController', ['$scope', ($scope) ->
  $scope.scheduleTemplate = () ->
    "#{$scope.scheduleGranularity.id}_schedule"
]
