                                                                                                                                                                      
⏺ The approach has two parts:                                                                                                                                          
                                                                                                                                                                       
  1. Shared sync attributes in Render.Utility                                                                                                                          
                                                                                                                                                                       
  rlSync (for expressions) attaches data-begin, data-end, and an onClick SendMeta handler using ExprMeta:                                                              
                                                                                                                                                                       
  rlSync : ExprMeta -> List (Attribute Msg)                                                                                                                            
                                                                                                                                                                       
  rlBlockSync (for verbatim blocks) does the same but takes a BlockMeta. Since blocks don't have an ExprMeta, it synthesizes one — constructing an expression-style id 
  "e-{lineNumber}.0" so that mapV3Msg in Demo/src/Main.elm can parse out the line number for editor navigation.                                                        
                                                                                                                                                                       
  2. Applied to math, equation, and aligned blocks in Render.VerbatimBlock                                                                                             
                                                                                                                                                                       
  For each of renderMath, renderEquation, and renderAligned, three changes were made to the outer container div:                                                       
                                                                                                                                                                       
  - Added ++ Render.Utility.rlBlockSync (.meta block) to the attribute list, so clicking sends SendMeta with the synthesized expression meta                           
  - Added HA.style "cursor" "pointer" to signal clickability                                                                                                           
  - Wrapped the inner mathText call in Html.div [ HA.style "pointer-events" "none" ] [...] so click events pass through to the outer container rather than being       
  consumed by the MathJax-rendered content
