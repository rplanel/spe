module Cluster exposing (..)

import Taxonomy.Rank as Rank exposing (..)


type alias ClustersByRank =
    { --oid : Clusters
      strain : Clusters
    , species : Clusters
    , genus : Clusters
    , family : Clusters
    , order : Clusters
    , class : Clusters
    , phylum : Clusters
    }


type alias Clusters =
    List Cluster


type alias Cluster =
    { id : String, data : List ClusterObject, name : Maybe String }


type alias ClusterObject =
    { name : Maybe String, id : String, count : Int }


getClustersByRank : Rank -> Maybe ClustersByRank -> Maybe Clusters
getClustersByRank rank clustersByRank =
    case clustersByRank of
        Nothing ->
            Nothing

        Just clusters ->
            case rank of
                Oid rankInfo ->
                    Just clusters.strain

                Strain rankInfo ->
                    Just clusters.strain

                Species rankInfo ->
                    Just clusters.species

                Genus rankInfo ->
                    Just clusters.genus

                Family rankInfo ->
                    Just clusters.family

                Order rankInfo ->
                    Just clusters.order

                Class rankInfo ->
                    Just clusters.class

                Phylum rankInfo ->
                    Just clusters.phylum
