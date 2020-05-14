# Rational Markup Languages

We collect here  a series of experiments intended 
for the design of rational markup languages. 

## Goals

Some of the goals:

- Simplicity

- Consistency

- Compile to Html and LaTeX

There are two series of examples, **M** and **R**. For
now, the **M** series addresses block structure only 
and the **R** series addreses inline elements only.
For a version which includes rendering to LaTeX, see 
language **R2**. See [Rational Markup](https://github.com/jxxcarlson/rational-markup/blob/master/rationalMarkup.md)
for an overview.

## Languages

- **M1** has very simple blocks, nothing more.  Blocks start with `|`
- **R1** has simple inline elements like `[i ....]` for italic. 
Can be nested, e.g `[i [b ...]]` for italicized bold text.
- **R2** treats inline elements as functions which can be composed.
Then one can say `[i.b ...]` for italicized bold text.
- **R3** introduces two additional kinds of functions, hence
the necessity of a rudimentary type system so that function 
composition will work.  Here function composition is partially defined
in that only functions of the same type can be composed. In this
approach, it is necessary to introduce identity elements for 
composition for each function type.

See [Arith: parsing](https://medium.com/@jxxcarlson/implementing-the-mini-language-arith-in-elm-a522f9a7101),
[Arith: type checking](https://medium.com/@jxxcarlson/type-checking-the-mini-language-arith-in-elm-c752e3e77a97), 
and [this repo](https://github.com/jxxcarlson/arith) for simple
examples of parsing and type-checking using Elm.

All this is a work in progress.  

## M1

The language **M1** defines a very simple block element and nothing
more.  Here is an example:

``` 
|h Intro

Trying out a new
language here

|s Basics

There are three elements:
headings, subheadings, and
paragraphs.
```

Blocks are either *plain* or *marked*. 
Marked blocks begin 
with the leading character |. In the 
example above, the headings and 
subheadings  are marked blocks, indicated
by `|h` and `|s`, respectively, while
ordinary paragraphs are unmarked blocks. 
The type
of a block is given by the word following
the pipe character.  The remaining 
words of the block header are viewed 
as arguments to the block header.  See
[Rational Markup](https://github.com/jxxcarlson/rational-markup/blob/master/rationalMarkup.md)
for more details.

### AST

Here is the type of the AST for **M1**:

```elm
type Element
    = Heading String
    | Subheading String
    | Paragraph (List String)
```

### Repl

There is a repl for working with **M1**. To run 
it, do this:

```bash
$ cd .M1/
$ sh make.sh
> h
```

The `h` command brings up a help screen.
For subsequent runs, just do `node repl.js`



## R1

The language 
**R1** is the simplest of the **R** series, admitting constructs such as 

```
    This is a test: [b [i whatever!]]
```

where `b` stands for "bold" and `i` for "italic".

**Note.** It would be nice to use the pipe character
instead of brackets for inline elements so as to have
a more uniform and non-noisy syntax.  But as far
as I can see, this can only work if inline elements
cannot be nested. (???) Also in favor of brackets is that the
shift key does not have to be used.  In all of these cases
the inline delimiters become reserved characters, so we would
need a means of escape, e.g, `\[`, etc. Yuuk!

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
    > import R1.Interpreter.String exposing(evalResult)
    > parse "a b [f [g y]]" |> evalResult
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

### LaTeX

```

      > import R2.Parse exposing(parse)
      > import R2.LaTeX.Interpreter exposing(evalResult)

      > parse "This is a [b.i real] test" |> evalResult
      "This  is  a \\textbf{\\textit{real}} test"

```

Note that the implementations of `Func` in `R3.Html` and `R3.LaTeX` are
quite different.

## R3

The language **R3** builds on the notion
of function, of which there are now three types:

```elm
type Func
    = FAttr AttributeList
    | FTag TagName
    | F (String -> String)
```

Example:

```elm
code : Func
code =
    FTag "code"
```

The meaning of `code` is defined by `Func.apply`:

```elm
apply : Func -> String -> String
apply func str =
    case func of
        FAttr attributes ->
            applyAttributes attributes str

        FTag tagName ->
            tag tagName str

        F f ->
            f str
```

Then we have

``` 
    > import R2.Parse exposing(parse)
    > import R2.Html.Interpreter exposing(evalResult)

    > parse "This is geek stuff: [code x = x + 1]" |> evalResult
    "<div>This  is  geek  stuff: \n<code>x  =  x  +  1</code></div>"

    > parse "[math a^2 + b^2 = c^2]" |> evalResult
    "<div>$a^2  +  b^2  =  c^2$</div>"
```

In order to make function composition work, we
need to introduce a rudimentary type system,
where

```elm
type FuncType
    = TAttr
    | TTag
    | TF
```
with functions 

```elm
typeOfFunc : Func -> FuncType

typeOfFuncList : List Func -> Maybe FuncType
```

and companion identity elements, where `idFattr` is as before and
where the new elements are

```elm
idFTag : Func
idFTag =
    FTag "*"

idF : Func
idF =
    F identity
```

With these in hand, one modifies `compose` and
`composeList` accordingly:

-  `compose` treats the two identity
functions `idFTag` and `idF` as *right* identities under composition, while
`idF` is a *bona fide* identity element.


- `composeList` checks the type of its function list and 
selects the corresponding identity element, with
`idFTag` as the default (?? is this a sound approach ??).
A function list has "type" `Just T` if all of its elements have
type `T`.  Otherwise it has type 'Nothing'





