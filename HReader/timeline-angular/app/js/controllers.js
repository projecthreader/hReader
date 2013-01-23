'use strict';

function loadScope(scope, data, attributes) {
  for (var index in attributes) {
    var attribute = attributes[index];
    scope[attribute] = data[attribute];
  }
}

function DayListCtrl($scope, $http) {
  $http.get('http://hreader.local/timeline.json?page=day', {cache:false}).success(function(data) {
    loadScope($scope, data, ['vitals', 'results', 'symptoms', 'pain', 'mood', 'energy', 'conditions', 'levels']);
    $scope.medications = data.timeline_medications
    $scope.format = 'yyyy/d/MM';
  });
};

function WeekListCtrl($scope, $http) {
  $http.get('http://hreader.local/timeline.json?page=week', {cache:false}).success(function(data) {
    loadScope($scope, data, ['vitals', 'symptoms', 'levels', 'conditions', 'observations', 'start_date', 'end_date']);
  });
};

function MonthListCtrl($scope, $http) {
  $http.get('http://hreader.local/timeline.json?page=month', {cache:false}).success(function(data) {
    loadScope($scope, data, ['vitals', 'symptoms', 'medications', 'conditions', 'encounters', 'start_date', 'end_date']);
  });
};

function YearListCtrl($scope, $http) { 
  $http.get('http://hreader.local/timeline.json?page=year', {cache:false}).success(function(data) {
    loadScope($scope, data, ['vitals', 'symptoms', 'conditions', 'treatments', 'start_date', 'end_date']);
  });
};

function DecadeListCtrl($scope, $http) {
  $http.get('http://hreader.local/timeline.json?page=decade', {cache:false}).success(function(data) {
    loadScope($scope, data, ['vitals', 'symptoms', 'conditions', 'levels', 'start_date', 'end_date']);
    $scope.Math = window.Math;
  });

  $scope.DecadeOffset = function(entry) {
    var offset = (entry.date*1000-(1.01e+12))/(315569259747/460);
    return { 'left' : offset + 'px' }
  }
};