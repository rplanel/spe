// var noUiSlider = require('nouislider');
// var d3 = require('d3');
// var NJ = require('neighbor-joining');
// Setup Elm app
var node = document.getElementById('cluster-form')
var app = Elm.Main.embed(node);

// Initialize D3 component
var piechart = piechart();
var parameters = parameters();
var histogram = histogram();

// Set parameters
var piechartRadius = 80;
var numColumn = 4;
var href = window.location.href;
var url = href.replace(/index.html/,'');

console.log(url);


// Get the data

var dataCluster = rawClusterData;
var taxoCluster = rawRankData;

// Create the slider
var slider = document.getElementById('slider-degre');
noUiSlider.create(slider, {
    start: [1,2],
    step: 1,
    tooltips: [ true, true],
    range: {
	'min': [0],
	'max': [10]
    },
});

slider.noUiSlider.on('change', function(range){
    app.ports.sliderChange.send({
        'min' : parseInt(range[0]),
        'max' : parseInt(range[1])
    });
    
});


app.ports.dataClusters.send({
    "distanceClusters" : dataCluster,
    "taxonomicClusters": taxoCluster,
    "displayedClusters" : undefined,
    "parameters"       : [ parametersData ],
});

app.ports.sliderRange.subscribe(function(range){
    slider.noUiSlider.updateOptions({
	range: {
	    'min': range[0],
	    'max': range[1]
	}
    });
});

app.ports.sliderValue.subscribe(function(range){
    slider.noUiSlider.set(range);
});


app.ports.deletePies.subscribe(function(params){
    d3.selectAll('g.piecharts').remove()
});

app.ports.draw.subscribe(function(params) {
    var data = params[0];
    var histoData = params[1];
    d3
        .select('svg')
        .attr('width',function(d){
            return (numColumn * (piechartRadius+200)) + 100;
        })
        .attr('height',function(d){
            return ((data.length/numColumn) * (piechartRadius+150)) + 700;
        });

    d3.select('g.histogram').datum(histoData).call(histogram,500,500);
    
    d3.select('g.clusters')
        .attr('transform', "translate(0,400)")
        .datum(data)
        .call(piechart,piechartRadius,piechartRadius,numColumn, url);
});


// For the MashTree
