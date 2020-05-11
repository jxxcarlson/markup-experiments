# Language R1

This is a first in a series of experiments in 
designing a rational markup language.

Here is an example:

```
This is a test: [strong [italic whatever!]]
```

or perhaps just 

```
This is a test: [s [i whatever!]]
```

There is only one construct:

```
[FUNCTION_NAME ARGLIST]
```

## AST

```elm
type Expr
    = Word String
    | ExprList (List Expr)
    | Function String
    | FunctionApplication Expr Expr
```

## Parse 

```elm
    parse "a b [f [g y]]"
    --> Ok [
        ExprList [Word ("a "),Word ("b ")]
        ,FunctionApplication (Function ("f ")) (ExprList [Word "x"])
        ,ExprList [Word ("c "),Word ("d ")]
        ,FunctionApplication (Function ("f ")) (ExprList [Word "y"])
       ]
```

## Eval

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

```elm
{-| A round-trip test of the
validity of the parser.
-}
check : String -> Status
check str =
    case evalResult (parse str) == str of
        True ->
            Pass

        False ->
            Fail
```

At the moment, our parser is "injective" up to white space.

(Ha ha! proof needed for this assertion)

## Coming soon

A function

```
evalHtml : Expr -> Html
```