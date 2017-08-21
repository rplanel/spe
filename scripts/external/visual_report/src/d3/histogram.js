function histogram () {
    function exports(_selection, width, height) {
	_selection.each(function(data, i) {
	    var formatCount = d3.format("d");
            var formatStat = d3.format(".6f");
            
	    
	    var margin = {top: 10, right: 30, bottom: 30, left: 130},
		width = 960 - margin.left - margin.right,
		height = 250 - margin.top - margin.bottom;

            var domain = [0,d3.max(data) || 0];
	    var x = d3.scaleLinear()
                .domain(domain)
		.range([0, width]);

            var mean     = d3.mean(data);
            var median   = d3.median(data);
            var variance = d3.variance(data);
            var deviation = d3.deviation(data);
            
	    var bins = d3.histogram()
		.domain(domain)
                .thresholds(x.ticks(domain[1]+1))
	    (data);

            var y = d3.scaleLinear()
		.domain([0, d3.max(bins, function(d) { return d.length; })])
		.range([height, 0]);
	    
	    var container = d3.select(this)
            	.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");



            // mean

            container.select('g.stat').remove();

            var stat = container
                .append('g')
                .attr('transform','translate(-130,0)')
                .classed('stat',true);
            
            
            stat
                .append('text')
                .attr('transform','translate(0,20)')
                .text('Mean = '+formatStat(mean));
            stat
                .append('text')
                .attr('transform','translate(0,40)')
                .text('Median = '+formatStat(median));
            stat
                .append('text')
                .attr('transform','translate(0,60)')
                .text('Variance = '+formatStat(variance));
            stat
                .append('text')
                .attr('transform','translate(0,80)')
                .text('Deviation = '+formatStat(deviation));
            
            
            container.select('g.axis').remove();
            var thicks = (domain[1] > 30 ) ? 30 : domain[1];
            if (bins.length > 0) {
                container
                    .append("g")
	            .attr("class", "axis axis-x")
	            .attr("transform", "translate(0," + height + ")")
                    .call(d3.axisBottom(x).ticks(thicks));
            }
            
	    var bar = container.selectAll("g.bar")
		.data(bins);

	    
            
            bar
                .exit()
                .remove();
            
            var barE = bar
	        .enter()
                .append("g")
		.attr("class", "bar");

            barE
                .append("rect")
		.attr("x", 1);
            
            barE
                .append("text")
		.attr("dy", "-.75em")
                .style("fill","brown")
            	.attr("text-anchor", "middle")
		.attr("y", 6);
            
            //EXIT

            
            // UPDATE

            
            var update = barE
                .merge(bar);
            
            update
		.attr("transform", function(d) {
                    var x0;
                    if (d.x0 != undefined) {
                        x0 = d.x0;
                    }
                    else {
                        x0 = 0;
                    }
                    return "translate(" + x(x0) + "," + y(d.length) + ")";
                });
            
            update
                .select('rect')
		.attr("width", function(d) {
                    var xVal = x(bins[0].x1) - x(bins[0].x0);
                    if (xVal <= 1) {
                        xVal = 1
                    }
                    return xVal - 1;
                })
		.attr("height", function(d) { return height - y(d.length); });
            
            update
                .select('text')
		.attr("x", (x(bins[0].x1) - x(bins[0].x0)) / 2)
		.text(function(d) { return (formatCount(d.length) > 0) ? formatCount(d.length):''; });
            // update
            //     .select('g.axis')
            //     .call(d3.axisBottom(x));
            
	});
    }
    return exports;
}
