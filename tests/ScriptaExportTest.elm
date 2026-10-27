module ScriptaExportTest exposing (suite)

{-| Tests for the LaTeX export and pretty-print functions in the public `Scripta`
API. Each must give exactly what the internal call it replaces gives, so apps can
switch to the API without any change in output.
-}

import Dict
import Either
import Expect
import Render.Export.LaTeX
import Render.Pretty
import Render.Types
import Scripta
import Scripta.Internal as Internal
import Test exposing (Test, describe, test)


source : String
source =
    String.join "\n"
        [ "| title"
        , "Test Document"
        , ""
        , "# Introduction"
        , ""
        , "Some [b bold] text and math $a^2 + b^2 = c^2$."
        , ""
        , "| equation"
        , "\\int_0^1 x\\, dx = \\frac{1}{2}"
        , ""
        , "## Details"
        , ""
        , "- one"
        , "- two"
        ]


document : Scripta.Document
document =
    Scripta.parse Scripta.defaultOptions source


forest (Internal.Document data) =
    data.forest


renderSettings =
    { windowWidth = 600
    , properties = Dict.empty
    , isStandaloneDocument = True
    }


suite : Test
suite =
    describe "Scripta export API"
        [ test "exportLaTeX gives what Render.Export.LaTeX.export gives" <|
            \_ ->
                Scripta.exportLaTeX { title = "My Title", authors = [ "A. Author", "B. Author" ] } document
                    |> Expect.equal
                        (Render.Export.LaTeX.export
                            { title = "My Title"
                            , authorList = [ "A. Author", "B. Author" ]
                            , kind = Render.Types.DKArticle
                            , date = Either.Right ""
                            }
                            renderSettings
                            (forest document)
                        )
        , test "exportLaTeX is a complete LaTeX document" <|
            \_ ->
                Scripta.exportLaTeX { title = "My Title", authors = [] } document
                    |> String.contains "\\begin{document}"
                    |> Expect.equal True
        , test "exportRawLaTeX gives what Render.Export.LaTeX.rawExport gives" <|
            \_ ->
                Scripta.exportRawLaTeX document
                    |> Expect.equal (Render.Export.LaTeX.rawExport renderSettings (forest document))
        , test "exportRawLaTeX has no preamble" <|
            \_ ->
                Scripta.exportRawLaTeX document
                    |> String.contains "\\documentclass"
                    |> Expect.equal False
        , test "prettyPrint gives what Render.Pretty.print gives" <|
            \_ ->
                Scripta.prettyPrint source
                    |> Expect.equal (Render.Pretty.print source)
        ]
