using DataFrames;
using Clustering;

vectors_file = ARGS[1];
num_cluster_col_1 = parse(Int64, ARGS[2]);
num_cluster_col_2 = parse(Int64, ARGS[3]);
distance = ARGS[4];


df = readtable(vectors_file, separator= ' ', header=false);
b1 = convert(Array, df[1]);
b2 = convert(Array, df[2]);
variation_information = varinfo(num_cluster_col_1, b1, num_cluster_col_2, b2);
println("$distance $variation_information");



