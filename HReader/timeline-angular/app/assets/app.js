angular.module('bootstrapDemoApp', ['ui.directives', 'ui.bootstrap']);

function MainCtrl($scope, $http, orderByFilter) {
  var url = "http://50.116.42.77:3001";
  $scope.selectedModules = [];
  //iFrame for downloading
  var $iframe = $("<iframe>").css('display','none').appendTo(document.body);
}
