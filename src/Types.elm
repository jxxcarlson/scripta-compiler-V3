module Types exposing (..)

{-| The Scripta Language consists of blocks and expressions.

  - GenericBlocks
  - PrimitiveBlocks
  - ExpressionBlocks

-}

import Dict exposing (Dict)
import Either exposing (Either)
import Generic.Vector exposing (Vector)
import Html exposing (Html)



-- BLOCKS


{-| GenericBlock: a parameterized block, i.e., a type constructor

  - PrimitiveBlocks: content = List String
  - ExpressionBlocks: content = Either String (List Expression)

-}
type alias GenericBlock content metaData style =
    { heading : Heading
    , indent : Int
    , args : List String
    , properties : Dict String String
    , firstLine : String
    , body : content
    , meta : metaData
    , style : style
    }


type Heading
    = Paragraph
    | Ordinary String -- block name
    | Verbatim String -- block name


{-| A block whose content is a list of strings.
-}
type alias PrimitiveBlock =
    GenericBlock (List String) BlockMeta NullStyle


{-| A block whose content is a list of expressions.
-}
type alias ExpressionBlock =
    GenericBlock (Either String (List Expression)) BlockMeta NullStyle



-- EXPRESSIONS


type alias Expression =
    Expr ExprMeta


type Expr metaData
    = Text String metaData
    | Fun String (List (Expr metaData)) metaData
    | VFun String String metaData
    | ExprList Int (List (Expr metaData)) metaData -- the Int parameter is the indentation of the expression list in the source



-- METADATA


type alias BlockMeta =
    { id : String
    , position : Int
    , lineNumber : Int
    , numberOfLines : Int
    , messages : List String
    , sourceText : String
    , error : Maybe String
    }


type alias ExprMeta =
    { begin : Int, end : Int, index : Int, id : String }



-- STYLE


type alias NullStyle =
    {}



-- ACCUMULATOR


type alias Accumulator =
    { headingIndex : Vector
    , documentIndex : Vector
    , counter : Dict String Int
    , blockCounter : Int
    , itemVector : Vector -- Used for section numbering
    , deltaLevel : Int
    , numberedItemDict : Dict String { level : Int, index : Int }
    , numberedBlockNames : List String
    , inListState : InListState
    , reference : Dict String { id : String, numRef : String }
    , terms : Dict String TermLoc
    , footnotes : Dict String TermLoc2
    , footnoteNumbers : Dict String Int
    , mathMacroDict : MathMacroDict
    , textMacroDict : Dict String Macro
    , keyValueDict : Dict String String
    , qAndAList : List ( String, String )
    , qAndADict : Dict String String
    }


{-| Tracks whether we're currently inside a numbered list.
-}
type InListState
    = InList
    | NotInList


{-| Location of a term in the source.
-}
type alias TermLoc =
    { begin : Int, end : Int, id : String }


{-| Location of a footnote with optional source reference.
-}
type alias TermLoc2 =
    { begin : Int, end : Int, id : String, mSourceId : Maybe String }


{-| A text macro with name and body.
-}
type alias Macro =
    { name : String, body : String }


{-| Dictionary of math macros (name -> expansion).
-}
type alias MathMacroDict =
    Dict String String



-- COMPILER PARAMETERS


{-| Parameters for the compiler.
-}
type alias CompilerParameters =
    { filter : Filter
    , windowWidth : Int
    , selectedId : String
    , theme : Theme
    , editCount : Int
    }



{-| Filter for the forest of expression blocks.
-}
type Filter
    = NoFilter
    | SuppressDocumentBlocks



-- COMPILER OUTPUT


{-| Output from the compiler containing rendered HTML.
-}
type alias CompilerOutput msg =
    { body : List (Html msg)
    , banner : Maybe (Html msg)
    , toc : List (Html msg)
    , title : Html msg
    }



-- MSG TYPE


{-| Messages for interactive rendering.
-}
type Msg
    = SendMeta ExprMeta
    | SelectId String
    | HighlightId String
    | NoOp



-- RENDER SETTINGS


{-| Settings for rendering.
-}
type alias RenderSettings =
    { width : Int
    , selectedId : String
    , theme : Theme
    , showTOC : Bool
    , paragraphSpacing : Int
    , editCount : Int
    }



-- THEME


{-| Light or dark theme.
-}
type Theme
    = Light
    | Dark
