var node = document.getElementById('elm-container');
var app = Elm.MashTree.embed(node);
clusterTree = clusterTree();
console.log(window.location);
var urlA = window.location.href.split(/\//);
urlA.pop();
var url = urlA.join('/');
console.log(url);



//app.ports.clusterId.send(window.location.search);

app.ports.url.send([url, window.location.search]);

app.ports.calculateTree.subscribe(function(params){
});


app.ports.drawTree.subscribe(function(params){
    console.log(params);
    var tree = params[0];
    var rank = params[1];
    
    d3.select('g.tree')
        .datum(tree)
        .call(clusterTree, 1500, 500, rank);
    
});
