port module SpanCheck exposing (main)

{-| Invariant check: for every primitive block, `String.slice begin end source`
is exactly the block's lines as written (lines lineNumber .. lineNumber + numberOfLines - 1).
Reports one line per violation.
-}

import Parser.PrimitiveBlock
import V3.Types exposing (Heading(..))


port out : List String -> Cmd msg


main : Program (List ( String, String )) () ()
main =
    Platform.worker
        { init = \docs -> ( (), out (List.concatMap check docs) )
        , update = \_ m -> ( m, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


check : ( String, String ) -> List String
check ( name, source ) =
    let
        lines =
            String.lines source

        blocks =
            Parser.PrimitiveBlock.parse lines
    in
    ("checked " ++ String.fromInt (List.length blocks))
        :: List.filterMap
            (\b ->
                let
                    raw =
                        lines |> List.drop b.meta.lineNumber |> List.take b.meta.numberOfLines |> String.join "\n"
                in
                if String.slice b.meta.begin b.meta.end source == raw then
                    Nothing

                else
                    Just ("SPAN MISMATCH " ++ name ++ ":" ++ String.fromInt (b.meta.lineNumber + 1) ++ " " ++ headingName b.heading ++ " indent=" ++ String.fromInt b.indent)
            )
            blocks


headingName : Heading -> String
headingName heading =
    case heading of
        Paragraph ->
            "paragraph"

        Ordinary n ->
            n

        Verbatim n ->
            n
