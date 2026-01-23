module Parser.PrimitiveBlock exposing (parse)

{-| Parse a list of strings into a list of primitive blocks.

NOTE (TODO) for the moment we assume that the input ends with
a blank line.

-}

import Dict exposing (Dict)
import Parser.Line as Line exposing (Line)
import Tools.KV
import Tools.Loop exposing (Step(..), loop)
import Types exposing (BlockMeta, Heading(..), PrimitiveBlock)


verbatimNames : List String
verbatimNames =
    [ "math"
    , "chem"
    , "compute"
    , "equation"
    , "aligned"
    , "array"
    , "textarray"
    , "table"
    , "code"
    , "verse"
    , "verbatim"
    , "load"
    , "load-data"
    , "load-files"
    , "include"
    , "hide"
    , "texComment"
    , "docinfo"
    , "mathmacros"
    , "textmacros"
    , "csvtable"
    , "chart"
    , "svg"
    , "quiver"
    , "image"
    , "tikz"
    , "setup"
    , "iframe"
    , "settings"
    ]


{-| Parse a list of strings into a list of PrimitiveBlocks.
-}
parse : List String -> List PrimitiveBlock
parse lines =
    loop (init lines) nextStep



-- STATE


type alias State =
    { blocks : List PrimitiveBlock -- accumulated blocks (reversed)
    , currentBlock : Maybe PrimitiveBlock -- block being built
    , lines : List String -- remaining input lines
    , inBlock : Bool -- are we currently in a block?
    , indent : Int -- current indentation level
    , lineNumber : Int -- current line number
    , position : Int -- character position in source
    , inVerbatim : Bool -- are we in a verbatim block?
    , blocksCommitted : Int -- number of committed blocks
    }


init : List String -> State
init lines =
    { blocks = []
    , currentBlock = Nothing
    , lines = lines
    , inBlock = False
    , indent = 0
    , lineNumber = 0
    , position = 0
    , inVerbatim = False
    , blocksCommitted = 0
    }



-- MAIN LOOP


nextStep : State -> Step State (List PrimitiveBlock)
nextStep state =
    case List.head state.lines of
        Nothing ->
            -- No more lines: finalize and return
            case state.currentBlock of
                Nothing ->
                    Done (List.reverse state.blocks)

                Just block ->
                    let
                        finalBlock =
                            finalize block
                    in
                    Done (List.reverse (finalBlock :: state.blocks))

        Just rawLine ->
            let
                currentLine =
                    Line.classify state.position state.lineNumber rawLine

                isEmpty =
                    currentLine.indent == 0 && String.isEmpty (String.trim currentLine.content)

                isNonEmptyBlank =
                    currentLine.indent > 0 && String.isEmpty (String.trim (String.dropLeft currentLine.indent currentLine.content))
            in
            case ( state.inBlock, isEmpty, isNonEmptyBlank ) of
                -- State 1: Not in block, empty line -> skip
                ( False, True, _ ) ->
                    Loop (advance currentLine state)

                -- State 2: Not in block, non-empty blank line -> skip
                ( False, False, True ) ->
                    Loop (advance currentLine state)

                -- State 3: Not in block, content line -> create new block
                ( False, False, False ) ->
                    Loop (createBlock currentLine state)

                -- State 4: In block, non-empty content -> add line
                ( True, False, _ ) ->
                    Loop (addCurrentLine currentLine state)

                -- State 5: In block, empty line -> commit block
                ( True, True, _ ) ->
                    Loop (commitBlock currentLine state)



-- HELPER FUNCTIONS


{-| Advance to the next line.
-}
advance : Line -> State -> State
advance line state =
    let
        newPosition =
            state.position + String.length line.content + 1
    in
    { state
        | lines = List.drop 1 state.lines
        , lineNumber = state.lineNumber + 1
        , position = newPosition
    }


{-| Create a new block from the current line.
-}
createBlock : Line -> State -> State
createBlock line state =
    let
        -- Commit any existing block first
        newState =
            case state.currentBlock of
                Nothing ->
                    state

                Just block ->
                    { state
                        | blocks = finalize block :: state.blocks
                        , blocksCommitted = state.blocksCommitted + 1
                    }

        newBlock =
            blockFromLine line newState

        newPosition =
            state.position + String.length line.content + 1
    in
    { newState
        | currentBlock = Just newBlock
        , lines = List.drop 1 state.lines
        , lineNumber = state.lineNumber + 1
        , position = newPosition
        , inBlock = True
        , indent = line.indent
        , inVerbatim = isVerbatimLine line.content
    }


{-| Create a PrimitiveBlock from a Line.
-}
blockFromLine : Line -> State -> PrimitiveBlock
blockFromLine line state =
    let
        headingData =
            getHeadingData line.content

        meta : BlockMeta
        meta =
            { id = ""
            , position = line.position
            , lineNumber = line.lineNumber
            , numberOfLines = 1
            , messages = []
            , sourceText = line.content
            , error = Nothing
            }
    in
    { heading = headingData.heading
    , indent = line.indent
    , args = headingData.args
    , properties = headingData.properties
    , firstLine = headingData.firstLine
    , body = []
    , meta = meta
    , style = {}
    }


{-| Add the current line to the block being built.
-}
addCurrentLine : Line -> State -> State
addCurrentLine line state =
    let
        newPosition =
            state.position + String.length line.content + 1

        updatedBlock =
            state.currentBlock
                |> Maybe.map (addLineToBlock line)
    in
    { state
        | currentBlock = updatedBlock
        , lines = List.drop 1 state.lines
        , lineNumber = state.lineNumber + 1
        , position = newPosition
    }


{-| Add a line to a block's body.
-}
addLineToBlock : Line -> PrimitiveBlock -> PrimitiveBlock
addLineToBlock line block =
    let
        -- Determine the content to add based on block type
        contentToAdd =
            if block.indent > 0 then
                -- For indented blocks, drop the indent prefix
                String.dropLeft block.indent line.content

            else
                line.content

        meta =
            block.meta
    in
    { block
        | body = contentToAdd :: block.body -- prepend (will reverse later)
        , meta = { meta | numberOfLines = meta.numberOfLines + 1 }
    }


{-| Commit the current block and reset for the next one.
-}
commitBlock : Line -> State -> State
commitBlock line state =
    let
        newPosition =
            state.position + String.length line.content + 1

        committedBlocks =
            case state.currentBlock of
                Nothing ->
                    state.blocks

                Just block ->
                    let
                        finalBlock =
                            finalize block
                                |> setBlockId state.blocksCommitted
                    in
                    finalBlock :: state.blocks
    in
    { state
        | blocks = committedBlocks
        , currentBlock = Nothing
        , lines = List.drop 1 state.lines
        , lineNumber = state.lineNumber + 1
        , position = newPosition
        , inBlock = False
        , inVerbatim = False
        , blocksCommitted = state.blocksCommitted + 1
    }


{-| Finalize a block by reversing the body and reconstructing sourceText.

For Paragraph blocks, firstLine is content (not a header), so it's prepended to body.
For Ordinary/Verbatim blocks, firstLine was the header line and body has the content.

-}
finalize : PrimitiveBlock -> PrimitiveBlock
finalize block =
    let
        reversedBody =
            List.reverse block.body

        -- For paragraphs, firstLine is content, not a header
        finalBody =
            case block.heading of
                Paragraph ->
                    if String.isEmpty block.firstLine then
                        reversedBody

                    else
                        block.firstLine :: reversedBody

                Ordinary "section" ->
                    if String.isEmpty block.firstLine then
                        reversedBody

                    else
                        block.firstLine :: reversedBody

                _ ->
                    reversedBody

        sourceText =
            if List.isEmpty reversedBody then
                block.firstLine

            else
                block.firstLine ++ "\n" ++ String.join "\n" reversedBody

        meta =
            block.meta
    in
    { block
        | body = finalBody
        , meta = { meta | sourceText = sourceText }
    }


{-| Set the block ID.
-}
setBlockId : Int -> PrimitiveBlock -> PrimitiveBlock
setBlockId index block =
    let
        meta =
            block.meta

        id =
            String.fromInt meta.lineNumber ++ "-" ++ String.fromInt index
    in
    { block | meta = { meta | id = id } }



-- HEADING DATA


type alias HeadingData =
    { heading : Heading
    , args : List String
    , properties : Dict String String
    , firstLine : String
    }


{-| Extract heading data from a line.
-}
getHeadingData : String -> HeadingData
getHeadingData line =
    let
        trimmed =
            String.trim line
    in
    if String.startsWith "|| " trimmed then
        -- Verbatim block: || blockname -- LEGACY, eventually phase out?
        getVerbatimHeading trimmed

    else if String.startsWith "| " trimmed then
        -- Ordinary block: | blockname
        getHeading trimmed

    else if String.startsWith "```" trimmed then
        -- Code fence
        { heading = Verbatim "code"
        , args = []
        , properties = Dict.empty
        , firstLine = ""
        }

    else if String.startsWith "$$" trimmed then
        -- Math block
        { heading = Verbatim "math"
        , args = []
        , properties = Dict.empty
        , firstLine = ""
        }

    else if String.startsWith "# " trimmed then
        -- Markdown heading level 1
        { heading = Ordinary "section"
        , args = [ "1" ]
        , properties = Dict.singleton "level" "1"
        , firstLine = String.dropLeft 2 trimmed
        }

    else if String.startsWith "## " trimmed then
        -- Markdown heading level 2
        { heading = Ordinary "section"
        , args = [ "2" ]
        , properties = Dict.singleton "level" "2"
        , firstLine = String.dropLeft 3 trimmed
        }

    else if String.startsWith "### " trimmed then
        -- Markdown heading level 3
        { heading = Ordinary "section"
        , args = [ "3" ]
        , properties = Dict.singleton "level" "3"
        , firstLine = String.dropLeft 4 trimmed
        }

    else if String.startsWith "- " trimmed then
        -- List item
        { heading = Ordinary "item"
        , args = []
        , properties = Dict.empty
        , firstLine = String.dropLeft 2 trimmed
        }

    else if String.startsWith ". " trimmed then
        -- Numbered item
        { heading = Ordinary "numbered"
        , args = []
        , properties = Dict.empty
        , firstLine = String.dropLeft 2 trimmed
        }

    else
        -- Paragraph
        { heading = Paragraph
        , args = []
        , properties = Dict.empty
        , firstLine = line
        }


{-| Parse verbatim heading: || blockname arg1 arg2 ...
-}
getVerbatimHeading : String -> HeadingData
getVerbatimHeading line =
    let
        afterPrefix =
            String.dropLeft 3 line

        parts =
            String.words afterPrefix

        name =
            List.head parts |> Maybe.withDefault "code"

        ( args, properties ) =
            Tools.KV.argsAndPropertiesFromList (List.drop 1 parts)
    in
    { heading = Verbatim name
    , args = args
    , properties = properties
    , firstLine = ""
    }


{-| Parse ordinary heading: | blockname arg1 arg2 ...
-}
getHeading : String -> HeadingData
getHeading line =
    let
        afterPrefix : String
        afterPrefix =
            String.dropLeft 2 line

        parts =
            String.words afterPrefix

        name =
            List.head parts |> Maybe.withDefault "block"

        ( args, properties_ ) =
            Tools.KV.argsAndPropertiesFromList (List.drop 1 parts)

        properties =
            if name /= "section" then
                properties_

            else
                case List.head args of
                    Nothing ->
                        Dict.insert "level" "1" properties_

                    Just str ->
                        case String.toInt str of
                            Nothing ->
                                Dict.insert "level" "1" properties_

                            Just _ ->
                                Dict.insert "level" str properties_
    in
    { heading =
        if isVerbatimName name then
            Verbatim name

        else
            Ordinary name
    , args = args
    , properties = properties
    , firstLine = ""
    }


isVerbatimName : String -> Bool
isVerbatimName str =
    List.member str verbatimNames



-- VERBATIM DETECTION


{-| Check if a line starts a verbatim block.
-}
isVerbatimLine : String -> Bool
isVerbatimLine line =
    let
        trimmed =
            String.trim line
    in
    String.startsWith "|| " trimmed
        || String.startsWith "```" trimmed
        || String.startsWith "$$" trimmed
