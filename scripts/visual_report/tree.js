var node = document.getElementById('main')
var app = Elm.MashTree.embed(node);


app.ports.clusterId.send(window.location.search);

app.ports.calculateTree.subscribe(function(params){
    console.log(params);

    var RNJ = new RapidNeighborJoining(params[0], params[1]);
    RNJ.run();

    
});
