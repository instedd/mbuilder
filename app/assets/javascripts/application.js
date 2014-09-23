// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require recurring_select
//= require underscore
//= require listings
//= require bootstrap
//= require instedd-bootstrap
//= require angular
//= require_directory ./angular-app/
//= require ng-rails-csrf
//= require guid
//= require pigeon
//= require message_parser
//= require_directory ./pill-input/
//= require_directory ./pill_editor/
//= require_directory .

$(function(){

  $(".sandbox-header").click(function(){
    $(".sandbox-container").toggleClass("show");
    $('input:first', this).focus();
    return false;
  });

  $(".add-trigger").click(function(){
    $(this).addClass("hide");
    $(".triggers-menu").addClass("show");
    return false;
  });

  var changeHoverAction = function(action) {
    if (action.length == 0) {
      $('.action.hover').removeClass('hover');
    } else if (!action.hasClass('.action')) {
      $('.action.hover').removeClass('hover');
      action.addClass('hover');
    }
  }

  // $(window).on('click', function(e){
  //   var a = $(e.target).closest('a.delete');
  //   var action = $(e.target).closest('.action');
  //   if (action.length > 0 && a.length > 0) {
  //     var elementAtMouse = document.elementFromPoint(e.pageX - window.pageXOffset, e.pageY - window.pageYOffset);
  //     var nextAction = $(elementAtMouse).closest('.action');
  //     changeHoverAction(nextAction);
  //   }
  // });

  // $(window).mousemove(function(e){
  //   var action = $(e.target).closest('.action');
  //   changeHoverAction(action);
  // });
});

