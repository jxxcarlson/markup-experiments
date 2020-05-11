# Language R1

This is a first in a series of experiments in 
designing a rational markup language.

Here is an example:

```
This is a test: [strong [italic whatever!]]
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

Note that `evalResult` is a left inverse of `parse`.  At 
least it is supposed to be. 