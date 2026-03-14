Lets' change subject. I want to talk about 
a possible addition to ETeX, namely let-expressions.

# Example

| equation
LET 
  A = e1
  B = e2
  p = A + B
  q = A - B
IN
  pq
  
Then

  pq = (A + B)(A-B)
     = (e1 + e2)(e1 - e2)
     
is computed by repated substitution.     

The idea is that it is easier to reliably build up 
complicated expressions this way.  Here e1 and e2
are some LaTeX expressions, possibly quite complicated.

# Parsing and reducing

Ideally a let expression as above can be parsed into something like
the folowing.

We begin with an atomic notion of LaTeXExpr

  - A LetBlock consists of a LetHead and a LetBody.
  - the LetHead is a list of definitions
  - the LetBody is a LaTeX (or ETeX) expression
  - a definition is of the form "TemporaryVar = LetExpr"
  - a LetExpr is either a LaTeX (or Katex) expr or else one
    a generalized LaTeX or KaTeX expr, namely a LaTeX expr
    where some parts have been replaced by TemporaryVars
    (call these LetExprs)
  - the body is a LaTeX (or generalized LaTeX expr)
  
A LetBlock is also a generalized LaTeX expr  We hope to have a function 

   reduce: LetBlock -> LateXExp
  

  
  
 