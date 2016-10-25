var NJ         = require('neighbor-joining');
var fs         = require('fs');
const util     = require('util')
var taxa       = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
var distance   = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
var out   = process.argv[4];

var distanceFloat = distance.map(function(col) {
    return col.map(function(cell){
        return parseFloat(cell);
    });
});


var famSize = taxa.length;
if (famSize > 1) {
    var RNJ = new NJ.RapidNeighborJoining(distanceFloat, taxa);
    RNJ.run();
    var treeObject = RNJ.getAsObject();
    var json = JSON.stringify(treeObject);
    fs.writeFile(out,json);
}
else {
    fs.writeFile(out,'{}');
}
