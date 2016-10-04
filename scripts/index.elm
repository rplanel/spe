import Html exposing (..)
    import Html.App as App
        import Html.Attributes exposing (..)
            import Html.Events exposing (onInput)
                import Json.Decode as Decode exposing (Decoder, (:=))
                



-- StartApp plumbing


type alias TaxonomicCount = {name : String, id : Int, count : Int }

type alias TaxonomicCounts = List TaxonomicCount
