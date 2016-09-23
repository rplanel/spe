var piechart = piechart();
var parameters = parameters();
var currentData = rawClusterData;


var slider = document.getElementById('slider-degre');
var range = getRange(currentData);
console.log(range);
var currentRange = range;


noUiSlider.create(slider, {
    start: [1,2],
    step: 1,
    tooltips: [ true, true],
    range: {
	'min': [range[0]],
	'max': [range [1]]
    },
});

slider.noUiSlider.on('change', function(curRange){
    currentRange = curRange;
    draw(currentData,currentRange);
});


d3.select('div.control-cluster')
    .selectAll('button.btn.btn-default')
    .data(['cluster','taxonomy'])
    .enter()
    .append('button')
    .classed('btn btn-default',true)
    .text(function(d){return d;})
    .on('click',function(d){
	if (d == 'cluster') {
	    currentData = rawClusterData;

	}
	else {
	    currentData = rawRankData;
	}
	var newRange = getRange(currentData);
	updateSliderRange(newRange[0],newRange[1])
	draw(currentData,newRange);
    });


function updateSliderRange ( min, max ) {
    slider.noUiSlider.updateOptions({
	range: {
	    'min': min,
	    'max': max
	}
    });
}

function draw (data,range) {
    var fdata = data.filter(function(d){
	return d.data.length >= range[0] && d.data.length <= range[1];
    });
    d3.select('svg').datum(fdata).call(piechart,80,80);
}

function getRange(data) {
    console.log(data);
    return data.reduce(function(prev,curr){
	var categoryCount = curr.data.length;
	console.log(categoryCount);
	return [Math.min(prev[0],categoryCount),Math.max(prev[1],categoryCount)];
    },[0,0]);
}

draw(currentData,range);

