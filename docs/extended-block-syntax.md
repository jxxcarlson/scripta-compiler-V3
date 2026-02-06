 Currently primitive blocks have the form                                                                                          
                                                                                                                                    
  | name arg1 .. argM k1:v1 .. kN:vN                                                                                                
  BODY                                                                                                                              
                                                                                                                                    
  where arg1 .. argM are optional arguments and k1:v1 .. kN:vN are optional properties.                                             
  I would like to extend this syntax to allow                                                                                       
                                                                                                                                    
  | name <args-and-properties>                                                                                                      
  | <args-and-properties>                                                                                                           
  ..                                                                                                                                
  | <args-and-properties>                                                                                                           
  BODY                                                                                                                              
                                                                                                                                    
  In this extended syntax, all the args (no colons) come first, then come                                                           
  the properties, always of the form k:v                                                                                            
                                                                                                                                    
  Please formulate a plan for review

  Also, add to the primitive block tests, with coverage for both the old and the extended syntax.

`

---

 Goal                                                                                                                               
                                                                                                                                    
 Extend the primitive block syntax to allow arguments and properties to span multiple lines:                                        
                                                                                                                                    
 Current syntax (single line):                                                                                                      
 | name arg1 arg2 k1:v1 k2:v2                                                                                                       
 BODY                                                                                                                               
                                                                                                                                    
 Extended syntax (multi-line):                                                                                                      
 | name arg1 arg2                                                                                                                   
 | arg3 arg4                                                                                                                        
 | k1:v1 k2:v2                                                                                                                      
 | k3:v3                                                                                                                            
 BODY                                                                                                                               
                                                                                                                                    
 Rules:                                                                                                                             
 1. First line: | name followed by optional args and properties                                                                     
 2. Continuation lines: |  (pipe + space, no block name) with more args/properties                                                  
 3. All args (no colons) must come before all properties (with colons)                                                              
 4. BODY begins after the last | continuation line                                                                                  
                                                                                                                                    
 Files to Modify                                                                                                                    
                                                                                                                                    
 1. src/Parser/PrimitiveBlock.elm                                                                                                   
                                                                                                                                    
 Changes needed:                                                                                                                    
                                                                                                                                    
 1. Add continuation line detection (~line 290):                                                                                    
   - Create isContinuationLine : String -> Bool function                                                                            
   - A continuation line starts with |  where the first word after |  either:                                                       
       - Contains a colon (it's a property), OR                                                                                     
     - Is not a known block name (it's an arg or property)                                                                          
 2. Modify addCurrentLine (~line 233):                                                                                              
   - Add case for when current block is Ordinary/Verbatim and line is a continuation                                                
   - Extract args/properties from continuation line and merge with block's existing args/properties                                 
 3. Add helper function mergeContinuationLine:                                                                                      
 mergeContinuationLine : Line -> PrimitiveBlock -> PrimitiveBlock                                                                   
 mergeContinuationLine line block =                                                                                                 
     -- Parse "| arg1 arg2 k1:v1" -> extract args and properties                                                                    
     -- Append args to block.args                                                                                                   
     -- Merge properties into block.properties                                                                                      
 4. Modify state machine logic:                                                                                                     
   - When in a block and encountering a continuation line, don't treat it as body content                                           
   - Only transition to body content when a non-continuation, non-blank line is encountered                                         
                                                                                                                                    
 2. src/Tools/KV.elm                                                                                                                
                                                                                                                                    
 Changes needed:                                                                                                                    
                                                                                                                                    
 1. Add mergeArgsAndProperties function:                                                                                            
 mergeArgsAndProperties :                                                                                                           
     ( List String, Dict String String )                                                                                            
     -> ( List String, Dict String String )                                                                                         
     -> ( List String, Dict String String )                                                                                         
 mergeArgsAndProperties ( args1, props1 ) ( args2, props2 ) =                                                                       
     ( args1 ++ args2, Dict.union props2 props1 )                                                                                   
                                                                                                                                    
 3. tests/Parser/PrimitiveBlockTest.elm                                                                                             
                                                                                                                                    
 Add tests for:                                                                                                                     
                                                                                                                                    
 1. Single-line syntax (existing behavior):                                                                                         
 test "single line args and properties" <|                                                                                          
     \_ ->                                                                                                                          
         let                                                                                                                        
             input = "| image width:400 caption:Test\nhttps://example.com/img.jpg\n"                                                
             blocks = p input                                                                                                       
             block = List.head blocks                                                                                               
         in                                                                                                                         
         Expect.all                                                                                                                 
             [ \b -> Expect.equal (Just (Ordinary "image")) (Maybe.map .heading b)                                                  
             , \b -> Expect.equal (Just []) (Maybe.map .args b)                                                                     
             , \b -> Expect.equal (Just (Dict.fromList [("width","400"),("caption","Test")])) (Maybe.map .properties b)             
             ] block                                                                                                                
 2. Multi-line args only:                                                                                                           
 test "multi-line args" <|                                                                                                          
     \_ ->                                                                                                                          
         let                                                                                                                        
             input = "| block arg1 arg2\n| arg3 arg4\nBody content\n"                                                               
             blocks = p input                                                                                                       
             block = List.head blocks                                                                                               
         in                                                                                                                         
         Expect.equal (Just ["arg1", "arg2", "arg3", "arg4"]) (Maybe.map .args block)                                               
 3. Multi-line properties only:                                                                                                     
 test "multi-line properties" <|                                                                                                    
     \_ ->                                                                                                                          
         let                                                                                                                        
             input = "| image width:400\n| caption:Test Image\n| alt:Description\nhttps://example.com/img.jpg\n"                    
             blocks = p input                                                                                                       
             block = List.head blocks                                                                                               
         in                                                                                                                         
         Expect.equal                                                                                                               
             (Just (Dict.fromList [("width","400"),("caption","Test Image"),("alt","Description")]))                                
             (Maybe.map .properties block)                                                                                          
 4. Mixed args and properties across lines:                                                                                         
 test "multi-line mixed args and properties" <|                                                                                     
     \_ ->                                                                                                                          
         let                                                                                                                        
             input = "| theorem numbered\n| label:pythagoras\n| title:Pythagorean Theorem\nBody\n"                                  
             blocks = p input                                                                                                       
             block = List.head blocks                                                                                               
         in                                                                                                                         
         Expect.all                                                                                                                 
             [ \b -> Expect.equal (Just ["numbered"]) (Maybe.map .args b)                                                           
             , \b -> Expect.equal (Just (Dict.fromList [("label","pythagoras"),("title","Pythagorean Theorem")])) (Maybe.map        
 .properties b)                                                                                                                     
             ] block                                                                                                                
 5. Verbatim blocks with multi-line headers:                                                                                        
 test "verbatim block multi-line header" <|                                                                                         
     \_ ->                                                                                                                          
         let                                                                                                                        
             input = "| code lang:elm\n| highlight:1-5\nmodule Main exposing (..)\n"                                                
             blocks = p input                                                                                                       
             block = List.head blocks                                                                                               
         in                                                                                                                         
         Expect.all                                                                                                                 
             [ \b -> Expect.equal (Just (Verbatim "code")) (Maybe.map .heading b)                                                   
             , \b -> Expect.equal (Just (Dict.fromList [("lang","elm"),("highlight","1-5")])) (Maybe.map .properties b)             
             ] block                                                                                                                
 6. Backward compatibility - existing single-line blocks still work:                                                                
   - Test that | section 1 still works                                                                                              
   - Test that | equation label:eq1 still works                                                                                     
   - Test that | image width:400 caption:Foo still works                                                                            
                                                                                                                                    
 4. src/TestData.elm                                                                                                                
                                                                                                                                    
 Add test strings:                                                                                                                  
 multiLineHeader1 =                                                                                                                 
     """                                                                                                                            
 | image width:400                                                                                                                  
 | caption:A beautiful sunset                                                                                                       
 | alt:Sunset over mountains                                                                                                        
 https://example.com/sunset.jpg                                                                                                     
 """                                                                                                                                
                                                                                                                                    
 multiLineHeader2 =                                                                                                                 
     """                                                                                                                            
 | theorem numbered                                                                                                                 
 | label:main-theorem                                                                                                               
 | title:Main Result                                                                                                                
 There are infinitely many primes.                                                                                                  
 """                                                                                                                                
                                                                                                                                    
 Implementation Order                                                                                                               
                                                                                                                                    
 1. Add mergeArgsAndProperties to Tools/KV.elm                                                                                      
 2. Add isContinuationLine helper to Parser/PrimitiveBlock.elm                                                                      
 3. Add mergeContinuationLine helper to Parser/PrimitiveBlock.elm                                                                   
 4. Modify addCurrentLine to handle continuation lines                                                                              
 5. Add test data to src/TestData.elm                                                                                               
 6. Add tests to tests/Parser/PrimitiveBlockTest.elm                                                                                
 7. Run tests and iterate                                                                                                           
                                                                                                                                    
 Edge Cases to Handle                                                                                                               
                                                                                                                                    
 1. Empty continuation line: |  with nothing after → treat as end of header, start of body                                          
 2. Continuation after body started: Should be treated as body, not header                                                          
 3. Verbatim blocks: Continuation lines before the verbatim content                                                                 
 4. Section blocks: | section 2 with | label:foo continuation                                                                       
 5. List items: Should NOT support continuation (they use different syntax)                                                         
 6. Paragraph blocks: No continuation support (no | prefix)                                                                         
                                                                                                                                    
 Detecting Continuation vs New Block                                                                                                
                                                                                                                                    
 A line starting with |  is a continuation if:                                                                                      
 - We are currently inside an Ordinary or Verbatim block (not yet in body)                                                          
 - The first word after |  is NOT a known block name, OR it contains :                                                              
                                                                                                                                    
 A line starting with |  is a new block if:                                                                                         
 - We are not in a block, OR                                                                                                        
 - We are in a block's body, OR                                                                                                     
 - The first word after |  IS a known block name (and doesn't contain :)                                                            
                                                                                                                                    
 Known block names include: section, theorem, image, code, equation, math, etc.                                                     
 (The existing verbatimNames list plus ordinary block names)                                                                        
                                                                                                                                    
 Verification                                                                                                                       
                                                                                                                                    
 1. elm make src/V3/Compiler.elm --output=/dev/null                                                                                 
 2. cd Demo && elm make src/Main.elm --output=/dev/null                                                                             
 3. elm-test                                                                                                                        
 4. Manual testing in Demo app with multi-line headers 


The implementation is complete. Here's a summary of the changes made:                                                             
                                                                                                                                    
  Summary of Changes                                                                                                                
                                                                                                                                    
  1. src/Tools/KV.elm                                                                                                               
                                                                                                                                    
  - Added mergeArgsAndProperties function (lines 23-31) to merge two (List String, Dict String String) pairs, concatenating args and
   merging properties with later values taking precedence                                                                           
                                                                                                                                    
  2. src/Parser/PrimitiveBlock.elm                                                                                                  
                                                                                                                                    
  - Added inHeader : Bool field to State (line 74) to track when we're still in the extended header                                 
  - Updated init to set inHeader = False (line 89)                                                                                  
  - Updated createBlock to set inHeader = isBlockWithHeader newBlock (line 196)                                                     
  - Updated commitBlock to reset inHeader = False (line 427)                                                                        
  - Modified addCurrentLine (lines 238-308) to check for continuation lines and either merge them into the block's args/properties  
  or process as body content                                                                                                        
  - Added new helper functions:                                                                                                     
    - ordinaryNames (lines 686-719): List of known ordinary block names                                                             
    - isBlockWithHeader (lines 724-731): Checks if block has a header (not Paragraph)                                               
    - isContinuationLine (lines 739-759): Detects continuation lines (starts with |  and first word is not a known block name or    
  contains :)                                                                                                                       
    - isKnownBlockName (lines 764-766): Checks if name is in verbatim or ordinary names lists                                       
    - mergeContinuationLine (lines 771-796): Merges continuation line's args/properties into block                                  
                                                                                                                                    
  3. src/TestData.elm                                                                                                               
                                                                                                                                    
  - Added test data strings: multiLineHeader1, multiLineHeader2, multiLineHeader3, multiLineArgs, multiLineMixed                    
                                                                                                                                    
  4. tests/Parser/PrimitiveBlockTest.elm                                                                                            
                                                                                                                                    
  - Added Dict import                                                                                                               
  - Added comprehensive test suite "extended header syntax (multi-line)" with 9 tests covering:                                     
    - Backward compatibility (single-line syntax)                                                                                   
    - Multi-line properties only                                                                                                    
    - Multi-line args and properties                                                                                                
    - Verbatim blocks with multi-line headers                                                                                       
    - Multi-line args only                                                                                                          
    - Mixed args and properties                                                                                                     
    - Backward compatibility for section blocks                                                                                     
    - Backward compatibility for equation with label                                                                                
    - Verification that numberOfLines includes continuation lines                                                                   
                                                                                                                                    
  All 27 tests pass, and both the main project and Demo app compile successfully.                                                   
                                                                                 

✻ Cooked for 4m 50s
