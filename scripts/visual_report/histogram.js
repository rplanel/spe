function histogram () {
    function exports(_selection, width, height) {
	_selection.each(function(data, i) {
	    var formatCount = d3.format("d");
	    
	    var margin = {top: 10, right: 30, bottom: 30, left: 30},
		width = 960 - margin.left - margin.right,
		height = 250 - margin.top - margin.bottom;

            var domain = [0,d3.max(data)];
            console.log(data);
            console.log(domain);
	    var x = d3.scaleLinear()
                .domain(domain)
		.range([0, width]);

            
	    var bins = d3.histogram()
		.domain(domain)
                .thresholds(x.ticks(domain[1]+1))
	    (data);

            
            
            console.log('bins');
	    console.log(bins);
	    
	    var y = d3.scaleLinear()
		.domain([0, d3.max(bins, function(d) { return d.length; })])
		.range([height, 0]);
	    
	    var container = d3.select(this)
            
            
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");


            container.select('g.axis').remove();
            
            var axis = container
                .append("g")
	        .attr("class", "axis axis--x")
	        .attr("transform", "translate(0," + height + ")")
                .call(d3.axisBottom(x).ticks(domain[1]));

            
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
		.attr("dy", ".75em")
            	.attr("text-anchor", "middle")
		.attr("y", 6);
            
            //EXIT

            
            // UPDATE
            var update = barE
                .merge(bar);


            update
		.attr("transform", function(d) { return "translate(" + x(d.x0) + "," + y(d.length) + ")"; });
            
            update
                .select('rect')
		.attr("width", x(bins[0].x1) - x(bins[0].x0) - 1)
		.attr("height", function(d) { return height - y(d.length); });
            
            update
                .select('text')
		.attr("x", (x(bins[0].x1) - x(bins[0].x0)) / 2)
		.text(function(d) { return formatCount(d.length); });
            // update
            //     .select('g.axis')
            //     .call(d3.axisBottom(x));
            
	});
    }
    return exports;
}
