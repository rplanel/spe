port module MashTree exposing (..)

--import Html.Events exposing (..)
import Html exposing (..)
import Html.App as App
import Html.Attributes as Att exposing (..)
import Http
import Json.Decode as Json
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import String
import Task

main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--Model
type alias Model =
    { clusterId       : String
    , clusterDistance : (List (List (Maybe Float)))
    , clusterTaxa     : Maybe (List Taxa)
    }


type alias Taxa =
    { id : Int
    , name : String
    , taxonomy : Taxonomy
    }

type alias Rank =
    { taxid : Int
    , name  : String
    }

type alias Taxonomy =
    { species : Rank
    , genus   : Rank
    , family  : Rank
    , order   : Rank
    , class_  : Rank
    , phylum  : Rank
    }

defaultModel : Model
defaultModel = Model "" ([[Nothing]]) Nothing
    
init : ( Model, Cmd Msg )
init = (defaultModel, Cmd.none)
       


type Msg
    = ClusterId String
    | FetchSucceed (List (List String))
    | FetchTaxaSucceed (List Taxa)
    | FetchFail Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClusterId id ->
            let
                cleanId = (String.dropLeft 1 id)
                _ = Debug.log "Get id" 
            in
            ( {model | clusterId = cleanId }
            , Cmd.batch
                [ getTaxa cleanId
                , getDistance cleanId
                ]
            )
                
                
        FetchSucceed distance ->
            let
                --_ = Debug.log "distance" distance
                distanceInt =
                            List.map (\tab -> List.map (\d -> Result.toMaybe (String.toFloat d) ) tab ) distance
                                
                --_ = Debug.log "model" model
                    
                
                    
            in
                ( {model | clusterDistance = distanceInt }
                , Cmd.none
                )

        FetchFail err ->
            let
                _ = Debug.log "error : " err
             in
            (model, Cmd.none)


        FetchTaxaSucceed taxonomy ->
            let
                _ = Debug.log "model dans fetchTaxa" model
                _ = Debug.log "Taxo" taxonomy
                    
            in
                ( model
                , calculateTree (model.clusterDistance, taxonomy)
                )
                


port clusterId : (String -> msg) -> Sub msg

port calculateTree : ( List (List (Maybe Float)), List Taxa) -> Cmd msg
                 
                
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ clusterId ClusterId]
       
view : Model -> Html Msg
view model =
    div
    []
    [ --button [onClick Display ] [ text "getTree"]
    text model.clusterId
    , distanceMatrixTable model.clusterDistance
    ]

getDistance : String -> Cmd Msg
getDistance id =
    let
        url = "http://localhost:8000/results/distance-matrices/" ++ id ++ "-distance-matrix.json"
    in
        Task.perform FetchFail FetchSucceed (Http.get decodeDistanceUrl url)


getTaxa : String -> Cmd Msg          
getTaxa id =
    let
        url = "http://localhost:8000/results/distance-matrices/" ++ id ++ "-taxa.json"
        _ = Debug.log "url" url
    in
        Task.perform FetchFail FetchTaxaSucceed (Http.get decodeTaxaUrl url)



            
decodeDistanceUrl : Json.Decoder (List (List String))
decodeDistanceUrl =
    Json.list (Json.list Json.string)


decodeTaxaUrl : Json.Decoder (List Taxa)
decodeTaxaUrl =
    Json.list decodeTaxa

number : Json.Decoder Int
number =
    Json.oneOf [ Json.int, Json.customDecoder Json.string String.toInt ]
        
decodeTaxa : Json.Decoder Taxa
decodeTaxa = 
    decode Taxa
        |> Json.Decode.Pipeline.required "id"       number
        |> Json.Decode.Pipeline.required "name"     Json.string
        |> Json.Decode.Pipeline.required "taxonomy" decodeTaxonomy

           
decodeRank : Json.Decoder Rank
decodeRank =
    decode Rank
        |> Json.Decode.Pipeline.required "taxid" number
        |> Json.Decode.Pipeline.required "name" Json.string


decodeTaxonomy : Json.Decoder Taxonomy
decodeTaxonomy =
    decode Taxonomy
        |> Json.Decode.Pipeline.required "species" decodeRank
        |> Json.Decode.Pipeline.required "genus"   decodeRank
        |> Json.Decode.Pipeline.required "family"  decodeRank
        |> Json.Decode.Pipeline.required "order"   decodeRank
        |> Json.Decode.Pipeline.required "class_"  decodeRank
        |> Json.Decode.Pipeline.required "phylum"  decodeRank

        
distanceMatrixTable : List (List (Maybe a)) -> Html b
distanceMatrixTable matrix =
    let
        distanceCol distance =
            let
                dist =
                    case distance of
                        Just val ->
                            toString val
                                
                        Nothing ->
                            "NaN"
            in
            td [] [ text dist ]
                
        distanceRow distances =
            tr [] (List.map distanceCol distances)
            
    in
        table [class "ui celled table"] (List.map distanceRow matrix)
