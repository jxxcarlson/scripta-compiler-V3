module Render.Settings exposing (fromParams)

{-| Convert CompilerParameters to RenderSettings.
-}

import Types exposing (CompilerParameters, RenderSettings, Theme(..))


{-| Create RenderSettings from CompilerParameters.
-}
fromParams : CompilerParameters -> RenderSettings
fromParams params =
    { width = params.windowWidth
    , selectedId = params.selectedId
    , theme = params.theme
    , showTOC = False
    , paragraphSpacing = 18
    , editCount = params.editCount
    }


{-| Make settings with explicit width.
-}
makeSettings : Int -> String -> Theme -> Int -> RenderSettings
makeSettings width selectedId theme editCount =
    { width = width
    , selectedId = selectedId
    , theme = theme
    , showTOC = False
    , paragraphSpacing = 18
    , editCount = editCount
    }
