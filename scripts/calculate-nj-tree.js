var NJ         = require('neighbor-joining');
var fs         = require('fs');
const util     = require('util');

var distanceFS;
try {
    distanceFS = fs.readFileSync(process.argv[2], 'utf8');
} catch (err) {
    console.log('File "'+process.argv[2]+'" is size too big');
    process.exit(0);
}

var taxa       = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
var distance   = JSON.parse(distanceFS);
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
    const treeNewick = RNJ.getAsNewick();
    var json = JSON.stringify(treeObject);
    fs.writeFile(out + '.json',json);
    fs.writeFile(out + '.nwk',treeNewick);
}
else {
    fs.writeFile(out + '.json','{}');
    fs.writeFile(out + '.nwk', ';');
}

