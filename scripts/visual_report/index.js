
// Graphical
var piechart = piechart();
var parameters = parameters();
var histogram = histogram();
var slider = document.getElementById('slider-degre');


// DATA
var currentData = rawClusterData;
var range = getRange(currentData);
var currentRange = range;
var histogramData = [];

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

updateClusterData(currentData);
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
	updateClusterData(currentData);
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
    d3.select('text#count-cluster').text(fdata.length);


    var piechartRadius = 80;
    d3.select('svg').attr('height',function(d){
	return (fdata.length * (piechartRadius+50)) + 400;
    });
    
    d3.select('.clusters').datum(fdata).call(piechart,piechartRadius,piechartRadius);
}

function getRange(data) {
    return data.reduce(function(prev,curr){
	var categoryCount = curr.data.length;
	return [Math.min(prev[0],categoryCount),Math.max(prev[1],categoryCount)];
    },[0,0]);
}

function updateHistogramData(data) {
    return data.reduce(function(prev,curr){
	var num = curr.data.length;
	if (prev[num] == undefined ) {
	    prev[num] = 0;
	}
	prev[num]++;
	return prev;
    },[]).map(function(e){
	if (e == undefined) {
	    return 0;
	}
	else {
	    return e;
	}
    });
}

function updateClusterData(data) {
    var newRange = getRange(data);
    updateSliderRange(newRange[0],newRange[1]);
    histogramData = updateHistogramData(data);
    d3.select('svg').datum(histogramData).call(histogram,500,500);
    console.log(histogramData);
    draw(data,newRange);

}


