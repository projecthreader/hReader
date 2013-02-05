angular.directive('bs:popover', function(expression, compiledElement){
    return function(linkElement) {
        linkElement.popover();
    };
});


