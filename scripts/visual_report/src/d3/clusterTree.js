function clusterTree () {
    function exports(_selection, width, height, rank) {
	_selection.each(function(data, i) {

            
            
            var tree = d3.tree()
                .size([500, 500]);
            var lineHeight = 25;
            var colors = d3.scaleOrdinal(d3.schemeCategory10); //schemeCategory20b
            var root = d3.hierarchy(data);
            tree(root);
            var leaves = root.leaves();
            d3
                .select('svg')
                .attr('height', leaves.length * lineHeight + 50);
            
            /**
             * Functions
             */
            function getlength (node) {
                if (node.data.length != null) {
                    return parseFloat(node.data.length);
                }
                else {
                    return 0;
                }
            }


            function addTreeHeight (node) {
                if (node.children == undefined ) {
                    node.left = 0;
                    node.right = 0;
                    return 1
                }
                else {
                    node.children[0].isRight = true;
                    node.right = addTreeHeight(node.children[0]);
                    node.children[1].isRight = false;
                    node.left = addTreeHeight(node.children[1]);
                    return node.left + node.right + 1
                }
            }

            function addYposition(node) {
                if (node.children == undefined ) {
                    return node.x;
                }
                else {
                    
                    var tot = node.children.reduce(function(prev,cur){
                        return prev + addYposition(cur);
                    },0);
                    node.x = tot / node.children.length;
                    return node.x;
                }
            }
            
            
            
            root
                .descendants()
                .forEach(function(d){
                    var totalL = getlength(d);
                    var parent = d.parent;
                    while (parent) {
                        var l = getlength(parent);
                        totalL += l;
                        parent = parent.parent;
                    }
                    d.data.depth = totalL;
                });

            
            leaves.forEach(function(node,i){
                node.x = (i * lineHeight) + 10;
            });

            
            
            var maxDepth = leaves.reduce(function(prev,curr){
                var depth = curr.data.depth;
                return (prev < depth) ? depth : prev;
            },0);

            
            
            var x = d3.scaleLinear()
                .domain([0, maxDepth])
                .range([0, tree.size()[0]]);

            root
                .descendants()
                .forEach(function(d){
                    d.y = x(d.data.depth);
                });

            
            addYposition(root);
            //addTreeHeight(root);

            
            var container = d3.select(this)
            var link = container.selectAll(".link")
                .data(root.descendants().slice(1))
                .enter()
                .append("path")
                .attr("class", "link")
                .attr("d", function(d) {
                    return "M" + d.y + " " + d.x
                        + " H" + d.parent.y 
                        + " V" + d.parent.x;
                    

                });


            var dataSelection = container
                .selectAll(".node")
                .data(root.descendants());
            
            var nodeEnter = dataSelection
                .enter();
            
            var node = nodeEnter
                .append("g")
                .attr("class", function(d) {
                    return "node" + (d.children ? " node--internal" : " node--leaf");
                })
                .attr("transform", function(d) {
                    return "translate(" + d.y + "," + d.x + ")";
                })

            node.append("circle")
                .attr("r", 2.5);
            
            node.append("text")
                .attr("dy", 3)
                .attr("x", 8);


            var update = nodeEnter
                .merge(dataSelection)
                .selectAll("text")
                .style("text-anchor", function(d) {
                    return d.children ? "end" : "start";
                })
                .style('fill',function(d){
                    var c = ''
                    if (d.data.taxon && d.data.taxon.taxonomy[rank]) {
                        c = colors(d.data.taxon.taxonomy[rank].name);
                    }
		    return c;
                })
                .text(function(d) {
                    var text;
                    if (d.data.taxon && d.data.taxon.taxonomy[rank]) {
                        text = d.data.taxon.taxonomy[rank].name;
                    }
                    else {
                        
                        text = '';
                    }
                    return text;
                });
        });
   } 
    return exports;
}
