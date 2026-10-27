module ControlSpaceTest exposing (suite)

{-| End to end: `$\ $` (a control space) in Scripta source renders and exports
without an ETeX error.
-}

import Expect
import Html
import Html.Attributes as HA
import Json.Encode as E
import Scripta
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


source : String
source =
    "[large (( W o r k] $\\ $ [large i n] $\\ $ [large P r o g r e s s ))]"


suite : Test
suite =
    describe "control space in inline math"
        [ test "renders as math containing the control space" <|
            \_ ->
                (Scripta.compile Scripta.defaultOptions source).body
                    |> Html.div []
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "math-text", Selector.attribute (HA.property "content" (E.string "\\ ")) ]
                    |> Query.count (Expect.equal 2)
        , test "LaTeX export has no ETeX error" <|
            \_ ->
                Scripta.exportRawLaTeX (Scripta.parse Scripta.defaultOptions source)
                    |> String.contains "ETeX error"
                    |> Expect.equal False
        ]
