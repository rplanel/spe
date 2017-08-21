function parameters () {
    function exports(_selection, width, height) {
	_selection.each(function(d, i) {
	    console.log(d);
	});
    }
    return exports;
}
