 All 150 tests pass.                  
                                                                                                                                                        
  Summary                                                                                                                                               
   
  Added a partial inverse inverseTransformETeX : MathMacroDict -> String -> String to src/ETeX/Transform.elm. The four examples you mentioned now work  
  as specified:                                             

  inverseTransformETeX Dict.empty "\\sin{x^2}"   == "sin(x^2)"
  inverseTransformETeX Dict.empty "\\frac{1}{2}" == "frac(1,2)"
  inverseTransformETeX Dict.empty "\\alpha"      == "alpha"                                                                                             
   
  What was added (src/ETeX/Transform.elm):                                                                                                              
  - inverseTransformETeX entry point at Transform.elm:65 — re-uses the existing parseManyWithDict parser (which already accepts LaTeX-flavored input)
  and runs the result through a new ETeX-form printer                                                                                                   
  - printETeX / printETeXList / printETeXDeco at Transform.elm:1745 — mirrors the existing print function but renders Macro nodes with parens/commas
  - printETeXMacro at Transform.elm:1853 — the core rewrite: Macro name [] → name; Macro name [Arg a1, Arg a2, …] → name(a1,a2,…); falls back to LaTeX  
  form if the body contains anything that isn't an Arg                                                                                                  
  - printETeXArgInner, isArgNode, printETeXArgList helpers                                                                                              
                                                                                                                                                        
  What it does not do yet (deliberately out of scope for this first pass):                                                                              
  - \begin{…}\end{…} environments — currently pass through as raw AlphaNum chunks, so they round-trip unchanged but verbatim as LaTeX                   
  - User-defined macro expansion in the inverse                                                                                                         
  - \text{…} text-mode commands                                                                                                                         
  - LET … IN … reduction                                                                                                                                
                                                                                                                                                        
  Tests (tests/ETeX/TransformTest.elm): added a new describe "inverseTransformETeX — simple cases" block with 6 tests covering the three user examples, 
  a nested subscript case, and two round-trip tests (ETeX → LaTeX → ETeX). All 150 tests in the suite pass.                                             
                                                                                                                                                        
  Say the word if you'd like me to extend to environments, \text{…}, user-macro re-expression, or anything else.
