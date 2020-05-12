# Rational Markup Languages

We collect here  a series of experiments in 
designing a rational markup language. The language 
**R1** is the simplest, admitting constructs such 
as 

```
    This is a test: [b [i whatever!]]
```

where `b` stands for "bold" and `i` for "italic".
In language **R2** one can say this as well, but
one cal also say 

```
    This is a test: [b.i whatever!]
```

The expression `b.i` is the composition of the functions
`b` and `i`.  

Some of the goals for the languages **Rn**:

- Simplicity

- Consistency

- Compile to Html and LaTeX

## Language R1


Here is an example of a piece of text in the langauge
R1:

```
This is a test: [bold [italic whatever!]]
```

or perhaps just 

```
This is a test: [b [i whatever!]]
```

There is only one construct:

```
[FUNCTION_NAME ARGLIST]
```

### AST

```elm
type Expr
    = Word String
    | ExprList (List Expr)
    | Function String
    | FunctionApplication Expr Expr
```

### Parse 

```elm
    parse "a b [f [g y]]"
    --> Ok [
        ExprList [Word ("a "),Word ("b ")]
        ,FunctionApplication (Function ("f ")) (ExprList [Word "x"])
        ,ExprList [Word ("c "),Word ("d ")]
        ,FunctionApplication (Function ("f ")) (ExprList [Word "y"])
       ]
```

### Eval

For now, just evaluate to a string:

```
    > parse "a b [f [g y]]" |> evalResult
    "a b [f [g y]]"
```

We would like for `evalResult` to be a left inverse of `parse`.  
A parser with a left inverse is said to be *injective*. 
For injective parser, the source text is recoverable 
fromm the AST.  As a convenience for testing such parsers,
we have the following code:

```
A round-trip test of the
validity of the parser.

    > check "Try [i [b this]]"
    (True,True) 
    
    > check "Try [i [b this]] and that"
    (False,True)
    
 The second example shows that the evalResult
 is not a left inverse of parse, but may be
 a left inverse modulo whitespace.
```

At the moment, our parser 'seems to be"
 injective up to white space.



### Eval as Html

Using module `InterpretAsHtml`, we have

```
      > parse "This is a [b [i real]] test" |> H.evalResult
      "<div>This  is  a
      <span style=font-weight:bold ><span style=font-style:italic >real</span></span>
      test</div>"
```

## Language R2

The R2 makes it possible to write text like

> "This is a [b.i real] test"

 
where `b` means `bold` and `i` means `italic`.
This is more compact than

> "This is a [b [i real]] test"

The idea is that the function with name
 `b.i` is the composition of the functions  with names
 `b` and `i`.
