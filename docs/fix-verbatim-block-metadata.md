 Summary of the change:                                                                                                                                    
                                                                                                                                                            
  - src/V3/Types.elm — BlockMeta grew begin : Int, end : Int.                                                                                               
  - src/Parser/PrimitiveBlock.elm:                                                                                                                          
    - Initial constructor: begin = line.position, end = line.position + String.length line.content.                                                         
    - finalizeBody: recomputes end = meta.begin + String.length sourceText when the final sourceText is written — a single authoritative sync point, so     
  line-append operations don't need to touch end.                                                                                                           
  - src/Render/Export/LaTeX.elm — emptyExpressionBlock gets begin = 0, end = 0.                                                                             
  - tests/Parser/PipelineTest.elm — 4 fixtures gain begin = 0, end = String.length sourceText.                                                              
  - src/Render/Utility.elm — rlBlockSync now reads blockMeta.begin / blockMeta.end instead of hardcoded "0".                                                
  - src/Render/VerbatimBlock.elm — 5 mathText call sites now pass block.meta.begin / block.meta.end instead of hardcoded 0.                                 
                                                                                                                                                            
  For the | equation / \frac{1}{2 case you reported, the outer block div should now render data-begin="P" data-end="P+L" data-lines="2" where P is the      
  block's character offset in the source and L is the length of its sourceText; the inner math span receives the same begin/end through mathText → rlSync.  
                                                                                                                                                            
  You should test this in the browser to confirm the DOM numbers match what you expect.                                                    
