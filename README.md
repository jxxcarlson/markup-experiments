# Rational Markup Languages

We collect here  a series of experiments in 
designing a rational markup language. 

## Goals

Some of the goals for the languages **Rn**:

- Simplicity

- Consistency

- Compile to Html and LaTeX


## R1

The language 
**R1** is the simplest, admitting constructs such as 

```
    This is a test: [b [i whatever!]]
```

where `b` stands for "bold" and `i` for "italic".


### AST

The type of the abstract syntax
for **R1** captures the notion of word, function,
and function application, as well as the notion 
of a list of expressions.

```elm
type Expr
    = Word String
    | ExprList (List Expr)
    | Function String
    | FunctionApplication Expr Expr
```

Example:

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

At the moment, there are two interpreters,
housed in modules `R1.Interpreter.String` and 
`R1.Interpreter.Html`, each with its own 
`eval` function.  Here is an example:



```
    > import R1.Parse exposing(parse)
    > import R1.Interpreter.String as S
    > parse "a b [f [g y]]" |> S.evalResult
    "a b [f [g y]]"
```

We would like for `evalResult` to be a left inverse of `parse`.  A parser with a left inverse is said to be *injective*. 
For injective parser, the source text is recoverable fromm the AST.  As a convenience for testing such parsers,
we have the following code:

```
A round-trip test of the
validity of the parser.

    > check "Try [i [b this]]"
    (True,True) 
    
    > check "Try [i [b this]] and that"
    (False,True)
```

 The second example shows that the evalResult is not a left inverse of parse, but may be a left inverse modulo whitespace.



## R2

In language **R2** one can say `This is a test: [b [i whatever!]]`, but
one can also say 

```
    This is a test: [b.i whatever!]
```

The expression `b.i` is the composition of the functions
`b` and `i`.  To make function composition work,
we introduce


```elm
type Func
    = FAttr AttributeList
```

A typical function looks like this:

```elm
red : Func
red =
    FAttr [ ( "color", "red" ) ]
```

It is just a piece of data whose meaning as 
a function is defined by 

```elm
apply : Func -> String -> String
apply func str =
    case func of
        FAttr attributes ->
            applyAttributes attributes str
```

Composition is defined like this:

```elm
compose : Func -> Func -> Func
compose f g =
    case ( f, g ) of
        ( FAttr ff, FAttr gg ) ->
            FAttr (ff ++ gg)


composeList : List Func -> Func
composeList funcs =
    List.foldl (\f acc -> compose f acc) id funcs
```

where

```elm
idFAttr : Func
idFAttr =
    FAttr [ ( "*", "*" ) ]
```

At this point, `id` is a fake identity function.
We will do better in language **R3**.


## R3

The language **R3** builds on the notion
of function, of which there are now two types:

```elm
type Func
    = FAttr AttributeList
    | FTag TagName
```
In order to make function composition work, we
need to introduce a rudimentary type system,
where

```elm
type FuncType
    = TAttr
    | TTag
```
with functions 

```elm
typeOfFunc : Func -> FuncType

typeOfFuncList : List Func -> Maybe FuncType
```

and companion identity elements, where `idFattr` is as before and
where the new element is

```elm
idFTag : Func
idFTag =
    FTag "*"
```

With these in hand, one modifies `compose` and
`composeList` accordingly:

-  `compose` treats the two identity
functions as *right* identities under composition.


- `composeList` checks the type of its function list and 
selects the corresponding identity element, with
`idFTag` as the default (?? is this a sound approach ??).
A function list has "type" `Just T` if all of its elements have
type `T`.  Otherwise it has type 'Nothing'





