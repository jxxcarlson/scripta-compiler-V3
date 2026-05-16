module ScriptaDocumentTest exposing (suite)

import Expect
import Scripta
import Scripta.Document
import Test exposing (Test, describe, test)


sampleSource : String
sampleSource =
    "| title\nMy Document\n\nThis paragraph mentions primes.\n\n| theorem\nThere are infinitely many primes.\n"


suite : Test
suite =
    describe "Scripta.Document"
        [ test "title returns the title block text" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions sampleSource
                    |> Scripta.Document.title
                    |> Expect.equal "My Document"
        , test "title returns empty string when there is no title block" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions "Just a paragraph."
                    |> Scripta.Document.title
                    |> Expect.equal ""
        , test "idsContainingSource finds blocks containing the target text" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions sampleSource
                    |> Scripta.Document.idsContainingSource "infinitely many primes"
                    |> List.isEmpty
                    |> Expect.equal False
        , test "idsContainingSource returns [] for empty target" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions sampleSource
                    |> Scripta.Document.idsContainingSource "   "
                    |> Expect.equal []
        , test "idsContainingSource returns [] when no block matches" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions sampleSource
                    |> Scripta.Document.idsContainingSource "nonexistent zzz text"
                    |> Expect.equal []
        , test "sourceOfId round-trips with idsContainingSource" <|
            \_ ->
                let
                    doc =
                        Scripta.parse Scripta.defaultOptions sampleSource

                    target =
                        "infinitely many primes"
                in
                case Scripta.Document.idsContainingSource target doc of
                    firstId :: _ ->
                        Scripta.Document.sourceOfId firstId doc
                            |> Maybe.map (String.contains target)
                            |> Expect.equal (Just True)

                    [] ->
                        Expect.fail "expected at least one matching id"
        , test "sourceOfId returns Nothing for an unknown id" <|
            \_ ->
                Scripta.parse Scripta.defaultOptions sampleSource
                    |> Scripta.Document.sourceOfId "no-such-id"
                    |> Expect.equal Nothing
        ]
