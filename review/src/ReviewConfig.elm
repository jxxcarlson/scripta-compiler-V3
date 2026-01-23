module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import NoDebug.Log
import NoDebug.TodoOrToString
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule exposing (Rule)
import Simplify


config : List Rule
config =
    [ -- Debug rules
      NoDebug.Log.rule
    , NoDebug.TodoOrToString.rule

    -- Unused code rules
    --, NoUnused.Variables.rule
    --, NoUnused.Parameters.rule
    --, NoUnused.Patterns.rule
    --, NoUnused.CustomTypeConstructors.rule []
    --, NoUnused.CustomTypeConstructorArgs.rule
    , NoUnused.Dependencies.rule
    , NoUnused.Exports.rule

    -- Simplification rules
    , Simplify.rule Simplify.defaults
    ]
