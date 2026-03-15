❯ Tell me about diffing optimizations for the AST                                                                                                       

⏺ Let me explore the codebase for AST diffing-related code.

⏺ Explore(Find AST diffing optimizations)
  ⎿  Done (30 tool uses · 67.9k tokens · 57s)
  (ctrl+o to expand)                           

⏺ Here's an overview of the AST diffing optimizations:                                                                                                  
   
  Two-Tier Compilation Strategy                                                                                                                         
                                                            
  The system chooses between two paths in src/Frontend/Document.elm:279-300:                                                                            
                                                            
  - Full re-initialization — used when the document is small (< 5000 chars, configured in src/Config.elm:398) or every 400th edit cycle to prevent drift
  - Differential update — used for large documents on most edits, reusing the existing EditRecord and only reprocessing changed blocks

  Core Diffing Algorithm

  The differ in vendor/compilerV2/src/Differential/Differ.elm:37-72 implements a longest common prefix/suffix approach:

  old_blocks = prefix + changed_old + suffix
  new_blocks = prefix + changed_new + suffix

  It compares blocks with == to find the minimum changed region, then only that middle segment gets re-parsed.

  Three-Layer Pipeline

  1. Chunking (DifferentialCompiler.elm:328-342) — source text is split into primitive blocks (language-specific: MiniLaTeX, L0, or SMarkdown)
  2. AST-level diffing (AbstractDifferentialParser.elm:84-133) — runs DifferForest.diff to find common prefix/suffix, then splices: unchangedPrefix ++
  reparsedMiddle ++ adjustedSuffix
  3. Tree reconstruction — converts parsed blocks back to a forest, rebuilds the accumulator (cross-references, metadata), and extracts error messages

  The EditRecord

  The central data structure (AbstractDifferentialParser.elm:10-18):

  type alias EditRecord chunk parsedChunk accumulator =
      { chunks : List chunk
      , parsed : List parsedChunk
      , tree : List (Tree parsedChunk)
      , accumulator : accumulator
      , lang : Language
      , messages : List String
      , initialData : InitialData
      }

  This is stored in LoadedModel (src/Types.elm:420) and updated on every keystroke.

  Periodic Full Recompilation

  A counter tracks edit count (Types.elm:454). Every 400 edits (Config.modulusForFastRendering), a full recompilation is forced to prevent the
  differential AST from drifting from ground truth.