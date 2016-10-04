port module Main exposing (..)
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode as Json exposing ((:=))
import Task


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model = 
    { distanceClusters : Clusters, taxonomicClusters : Clusters, displayedClusters : Clusters}

        
type alias Clusters =
    List Cluster


type alias Cluster =
    { id : String, data : List ClusterObject, name : Maybe String }


type alias ClusterObject =
    { name : Maybe String, id : String, count : Int }


init : ( Model, Cmd Msg )
init =
    ( Model [] [] [], Cmd.none)





-- UPDATE


type Msg
    = TaxonomicCluster Clusters
    | DistanceCluster Clusters
    | DataClusters Model
    | Draw
      
port draw : Clusters -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataClusters m ->
            (Model m.distanceClusters m.taxonomicClusters m.distanceClusters, Cmd.none)
            
        TaxonomicCluster clusters ->
            let
                newModel = Model model.distanceClusters clusters clusters
            in
                ( newModel , Cmd.none )

        DistanceCluster clusters ->
            let
                newModel = Model clusters model.taxonomicClusters clusters
            in
                ( newModel, Cmd.none )

        Draw ->
           (model, draw model.displayedClusters)


-- SUBSCRIPTIONS

port dataClusters  : (Model -> msg) -> Sub msg
                         
subscriptions : Model -> Sub Msg
subscriptions model =
    dataClusters DataClusters


        

-- VIEW


view model =
    div
    [ classList
            [ ( "row", True )
            ]
        ]
        [
         button [onClick (DistanceCluster model.distanceClusters)]   [text "Distance Clusters" ]
        ,button [onClick (TaxonomicCluster model.taxonomicClusters)] [text "Taxonomic Clusters" ]
        ,button [onClick Draw]                                       [text "Draw" ]
        ,text (toString (List.length model.displayedClusters))
        ]
