port module Worker exposing (main)

import Dict
import Either exposing (Either(..))
import Parser.Forest
import Render.Export.LaTeX
import Render.Settings exposing (defaultRenderSettings)
import Render.Types exposing (DocumentKind(..), PublicationData)
import TestData


port receiveSourceText : (String -> msg) -> Sub msg


port sendLaTeX : String -> Cmd msg


type alias Model =
    ()


type Msg
    = GotSourceText String


main : Program () Model Msg
main =
    Platform.worker
        { init = \_ -> ( (), Cmd.none )
        , update = update
        , subscriptions = \_ -> receiveSourceText GotSourceText
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSourceText sourceText ->
            let
                params =
                    TestData.defaultCompilerParameters

                ( acc, forest ) =
                    Parser.Forest.parseToForestWithAccumulator params (String.lines sourceText)

                defaultPubData : PublicationData
                defaultPubData =
                    { title = "Untitled"
                    , authorList = [ "test-author" ]
                    , kind = DKArticle
                    , date = Right ""
                    }

                ( properties, resolvedPubData ) =
                    Render.Export.LaTeX.getPublicationData defaultPubData forest

                settings =
                    { defaultRenderSettings
                        | properties = properties
                    }

                latex =
                    Render.Export.LaTeX.export resolvedPubData settings forest
            in
            ( model, sendLaTeX latex )
