angular.module('mbuilder').factory 'HubApi', ['$window', ($window) ->
  new HubApi($window.hub_url, '/hub')
]
