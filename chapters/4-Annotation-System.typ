#import "../config/utils.typ": *
#import "rules/base.typ": *
#import "rules/relations.typ": *
#import "rules/unification.typ": *
#import "rules/statements.typ": *

#pagebreak(to:"odd")
// TODO: annotazioni nei commenti del codice a volte maiuscole e a volte minuscole
// TODO: tutti gli esempi in una figure con la caption
// TODO: coerenza nei nomi delle regole (nel modo in cui abbrevio unique, shared e borrowed)
// TODO: decidere cosa fare con gli esempi scritti anche con la notazione della grammatica (da rivedere tutti in ogni caso (nomi classi T vs C)). Anche capire se ha senso dare un nome al subset del linguaggio
// decidere se call, if ecc. in corsivo
// decidere se unique, shared, borrowed in corsivo
// decidere se nomi delle regole in corsivo

= Annotation System

This chapter describes an annotation system for controlling aliasing within a subset of the Kotlin language.
The system takes inspiration from some previous works @boyland2001alias @zimmerman2023latte @aldrich2002alias  but it also introduces significant modifications.

One distinguishing trait of this system is that it is designed exclusively for Kotlin, while the majority of previous works are made for Java and other languages.
It is also specifically made for being as lightweight as possible and gradually integrable with already existing code.
// TODO: borrowed unique / borrowed shared distinction here?

A unique design goal of this system is to improve the verification process with Viper by establishing a link between separation logic and the absence of aliasing control in Kotlin.

== Grammar

In order to define the rules of this annotation system, a grammar representing a substet of the Kotlin language is used.

#figure(
  caption: "TODO",
  frame-box(
    $
      CL &::= class C(overline(f\: alpha_f)) \
      M &::= m(overline(x\: af beta)): af {begin_m; overline(s); ret_m e} \
      af &::= unique | shared \
      beta &::= dot | borrowed \
      p &::= x | p.f \
      e &::= null | p | m(overline(p)) \
      s &::= var x | p = e |  fi p_1 == p_2 then overline(s_1) els overline(s_2) | m(overline(p))
      // \ &| loop p_1 == p_2 do overline(s)
    $
))

=== Class and Method declaration
- Primitive fields are not considered
- `this` can be seen as a parameter
- constructors can be seen as functions returning a `unique` value
=== Annotations
// TODO: create a definition function??
- Only *fields*, *method parameters*, and *return values* have to be annotated.
- A reference annotated as `unique` may either be `null` or point to an object, and it is the sole *accessible* reference pointing to that object.
- A reference marked as `shared` can point to an object without being the exclusive reference to that object.
- `T` is an annotation that can only be inferred and means that the reference is *not accessible*.
- $borrowed$ (borrowed) indicates that the function receiving the reference won't create extra aliases to it, and on return, its fields will maintain at least the permissions stated in the class declaration.
- Annotations on fields indicate only the default permissions, in order to understand the real permissions of a fields it is necessary to look at the context. This concept is formalized by rules in /*@cap:paths*/ and shown in /*@field-annotations.*/

#let grammar_annotations = ```
class C(
  f1: unique,
  f2: shared
)

m1() : unique { 
  ... 
}


m2(this: unique) : shared {
  ... 
}

m3(
  x1: unique,
  x2: unique borrowed,
  x3: shared,
  x4: shared borrowed
) {
  ...
}
```

#let kt_annotations = ```kt
class C(
    @Unique var f1: Any,
    var f2: Any
)

@Unique
fun m1(): Any {
    /* ... */
}

fun @receiver:Unique Any.m2() {
    /* ... */
}

fun m3(
    @Unique x1: Any,
    @Unique @Borrowed x2: Any,
    x3: Any,
    @Borrowed x4: Any
) {
    /* ... */
}
```
#align(
  center,
  grid(
    columns: (auto, auto),
    column-gutter: 2em,
    row-gutter: .5em,
    [*Grammar*],[*Kotlin*],
    grammar_annotations, kt_annotations
  )
)

=== Expressions
=== Statements
- Since it is not too relevant for the purposes of the system, the guard of an if statement is kept as simple as possible.

== General

#display-rules(
  M-Type, "",
  M-Args, "",
)

== Context

#frame-box(
  $
    alpha &::= unique | shared | top \
    beta &::= dot | borrowed \
    Delta &::= dot | p : alpha beta, Delta
  $
)

#v(1em)

A context is a list of paths associated with their annotations $alpha$ and $beta$. While $beta$ is defined in the same way of the grammar, $alpha$ is slightly different. Other than _unique_ and _shared_, in a context, an annotation $alpha$ can also be $top$. As will be better explained in the following sections, the annotation $top$ can only be inferred, so it is not possible for the user to write it. A path annotated with $top$ within a context is not accessible, meaning that the path needs to be re-assigned before beign read. The formal meaning of the annotation $top$ will be clearer while formilizing the statement typing rules.

=== Well-formed context

#display-rules(
  Not-In-Base, Not-In-Rec,
  Ctx-Base, Ctx-Rec,
)

This first set of rules defines how a well-formed context is structured. The judgement $p in.not Delta$ is derivable when $p$ is not present in the context. If the judgement $Delta ctx$ is derivable, the context is well-formed. In order to be well-formed, a context must not contain duplicate paths and must be finite.

=== Lookup

#display-rules(
  Lookup-Base, Lookup-Rec,
  Lookup-Default, "",
)

Lookup rules are used to define a (partial) function that returns the annotations of a path in a well-formed context.

$ \_inangle(\_): Delta -> p -> alpha beta $

The function will return the annotations declared in the class declaration in the case in which a path that is not a variable ($p.f$) is not explicitly contained inside the context. This concept, formalized by Lookup-Default, is fundamental because it allows contexts to be finite also when dealing with recursive classes. On the other hand, the lookup for variables ($x$) not contained in a context cannot be derived.

It is also important to note that this function does not necessarily return the correct ownership of a path, but just the annotations contained within the context or those written in the class declaration. 
Consider an example where the context is given as $ Delta = x : shared, x.f : unique $ In this case, the lookup is the following $ Delta inangle(x.f) = unique $ However, since $x$ is shared, there can be multiple references accessing $x$. This implies there can be multiple references accessing $x.f$, meaning that $x.f$ is also shared.
This behaviour is intended and a function able to provide the correct ownership of a reference will be defined in the next sections.

=== Remove

#display-rules(
  Remove-Empty, Remove-Base,
  Remove-Rec, "",
)

Remove rules are used to define a function taking a context and a path and returning a context.

$ \_without\_ : Delta -> p -> Delta $

Basically, the function will return the context without the specified path if the path is within the context, and it will return the original context if the path is not contained.

== Sub-Paths and Sup-Paths

=== Definition

#display-rules(
  SubPath-Base, SubPath-Rec,
  SubPath-Eq-1, SubPath-Eq-2,
)

The first set of rules is used to formally define sub-paths and sup-paths. 
In particular, if $p_1 subset.sq p_2$ is derivable, we say that:
- $p_1$ is a *sub*-path of $p_2$
- $p_2$ is a *sup*-path of $p_1$

=== Deep Remove

#display-rules(
  Remove-SupPathsEq-Empty, "",
  Remove-SupPathsEq-Discard, "",
  Remove-SupPathsEq-Keep, "",
)

Deep-Remove rules define a function similar to Remove ($without$) that in addiction to removing the given path from the context, also removes all the sup-paths of that path.

$ \_minus.circle\_: Delta -> p -> Delta $

=== Replace

#display-rules(
  Replace, "",
)

This rule gives the definition of a funtion that will be fundamental for typing statements. The function takes a context, a path $p$ and a set of annotations $alpha beta$ and returns a context in which all the sup-paths of $p$ have been removed and the annotation of $p$ becomes $alpha beta$.

$ \_[\_|->\_] : Delta -> p -> alpha beta -> Delta $

=== Get Sup-Paths

#display-rules(
  Get-SupPaths-Empty, "",
  Get-SupPaths-Discard, "",
  Get-SupPaths-Keep, "",
)

Finally, Get-Sup-Paths rules are used to define a function that returns all the sup-paths of a give path within a context. Also this function will be used for statements typing rules.

$ \_ tr sp(\_) : Delta -> p -> "List"(p : alpha beta) $

== Annotations relations

=== Partial ordering

#display-rules(
  A-id, A-trans,
  A-bor-sh, A-sh,
  A-bor-un, A-un-1,
  A-un-2, "",
)

This set of rules is used to define a partial order between the annotations. This partial order can be represented by the lattice shown in @annotation-lattice. The meaning of these relations is that if $alpha beta rel alpha' beta'$, then $alpha beta$ can be used where $alpha' beta'$ is expected, for example for function calls. Thanks to these rules, it will be correct to pass a unique reference to a function expecting a shared argument, but not vice versa. Moreover, the relations are consistent with the definition of $top$ since it will not be possible to pass an inaccessible reference to any function.

#v(1em)
#figure(image(width: 35%, "../images/lattice.svg"), caption: [Lattice obtained by Rel rules])<annotation-lattice>

=== Passing

#display-rules(
  Pass-Bor, Pass-Un,
  Pass-Sh, ""
)

Pass rules define what happens to the annotations of a reference after passing it to a method.
If derivable, a judgement $alpha beta ~> alpha' beta' ~> alpha'' beta''$ indicates that after passing a reference annotated with $alpha beta$ to a method expecting an argument annotated with $alpha' beta'$, the reference will be annotated with $alpha'' beta''$ after the call.
However, these rules are not sufficient to type a method call statement since passing the same reference more than once to the same method call is a situation that has to be handled carefully. Nonetheless, the rules are fundamental to express the logic of the annotation system and will be used for typing method calls in subsequent sections.

== Paths
<cap:paths>

- $Lub{alpha_0 beta_0, ..., alpha_n beta_n}$ identifies the least upper bound of the annotations based on the lattice in @annotation-lattice.
- Note that even if $p.f$ is annotated as unique in the class declaration, $Delta(p.f)$ can be shared (or $top$) if $Delta(p) = shared$ (or $top$)
- Note that fields of a borrowed parameter are borrowed too and they need to be treated carefully in order to avoid unsoundness. Specifically, borrowed fields:
  - Can be passed as arguments to other functions (if relation rules are respected).
  - Have to become `T` after being read (even if shared).
  - Can only be reassigned with a `unique`.
- Note that $(Delta(p) = alpha beta) => (Delta inangle(root(p)) = alpha' beta')$ i.e. the root is present in the context.
- $Delta tr std(p, alpha beta)$ means that paths rooted in $p$ have the right permissions when passing $p$ where $alpha beta$ is expected. To understand better why these rules are necessary look at the example in /*@path-permissions*/.
- Note that in the rule "Std-Rec-2" the premise $(x : alpha beta) (p') = alpha'' beta''$ means that the evaluation of $p'$ in a context in which there is only $x : alpha beta$ is $alpha'' beta''$

#display-rules(
  Root-Base, Root-Rec,
  Get-Var, Get-Path,
  Std-Empty, Std-Rec-1,
  Std-Rec-2, "",
)

== Unification

- $Delta_1 lub Delta_2$ is the pointwise lub of $Delta_1$ and $Delta_2$.
  - If a variable $x$ is present in only one context, it will be annotated with $top$ in $Delta_1 lub Delta_2$.
  - If a path $p.f$ is missing in one of the two contexts, we can just consider the annotation in the class declaration.
- $Delta triangle.filled.small.l Delta_1$ is used to maintain the correct context when exiting a scope.
  - $Delta$ represents the resulting context of the inner scope.
  - $Delta_1$ represents the context at the beginning of the scope.
  - The result of the operation is a context where paths rooted in variable locally declared inside the scope are removed.
- $unify(Delta, Delta_1, Delta_2)$ means that we want to unify $Delta_1$ and $Delta_2$ starting from a parent environment $Delta$.
  - A path $p$ contained in $Delta_1$ or $Delta_2$ such that $root(p) = x$ is not contained $Delta$ will not be included in the unfication.
  - The annotation of variables contained in the unfication is the least upper bound of the annotation in $Delta_1$ and $Delta_2$.

#display-rules(
  Ctx-Lub-Empty, Ctx-Lub-Sym,
  Ctx-Lub-1, "",
  Ctx-Lub-2, "",
  Ctx-Lub-3, "",
  Remove-Locals-Base, Remove-Locals-Keep,
  Remove-Locals-Discard, "",
  Unify, ""
)

== Normalization

- Normalization takes a list of annotated $p$ and retruns a list in which duplicates are substituted with the least upper bound.
- Normalization is required for method calls in which the same variable is passed more than once.

```kt
fun f(x: ♭ shared, y: shared)
fun use_f(x: unique) {
  // Δ = x: unique
  f(x, x)
  // Δ = normalize(x: unique, x:shared) = x: shared
}
```

#display-rules(
  N-Empty, "",
  N-Rec, ""
)

== Statements Typing

TODO: How to read typing rules

$"Program" ::= overline(CL) times overline(M)$
where:
- $overline(CL) in 2^CL$
- $overline(M) in 2^M$

A program is well-typed iff $forall m equiv m(...){overline(s)} in overline(M) . space dot tr overline(s) tr dot$ is derivable.

=== Begin

#display-rules(Begin, "")

This rule is used to initialize the context at the beginning of a method. The initial context will contain only the method's arguments with the declared uniqueness annotations.

```kt
class C

fun @receiver:Unique C.f(
    @Unique @Borrowed x: C,
    @Borrowed y: C,
    z: C
) {
    // Δ = this: unique, x: unique ♭, y: shared ♭, z: shared
    // ...
}
```

// TODO: derivation?

$ f(this: unique, x: unique borrowed, y: shared borrowed, z: shared){begin_f; ...} $

=== Variable Declaration

#display-rules(Decl, "")

After declaring a variable, it is inaccessible until its initialization and so the varaible will be in the context with $top$ annotation.
Note that this rule only allows to declare variables if they are not in the context while Kotlin allows to shadow variables declared in outer scopes. Kotlin code using shadowing is not currently supported by this system.

```kt
class C

fun f(){
    // Δ = ∅
    var x: C
    // Δ = x: T
    // ...
}
```
$ f(){begin_f; var x; ...} $

=== Assigning null

// TODO: precondizione per p in context???
// basta essere coerenti, o sempre o mai

#display-rules(Assign-Null, "")

The definition of unique tells us that a reference is unique when it is `null` or is the sole accessible reference pointing to the object that is pointing. Given that, we can safely consider unique a path $p$ after assigning `null` to it. Moreover, all sup-paths of $p$ are removed from the context after the assignment.

It is also important to note the presence of the premise "$Delta(p) = alpha beta$" ensuring that the root of the path $p$ is inside the context $Delta$.

```kt
class C
class B(@property:Unique var t: C)

fun f() {
    var b: B?
    // Δ = b: T
    // ...
    // Δ = b: shared, b.t: T
    b = null
    // Δ = b: unique
    // ...
}
```

$ 
class B(t:unique) \
f(){begin_f; var b; ...; b = null; ...}
$

=== Sequence of statements

#display-rules(Seq-Base, Seq-Rec)

// TODO: anche begin e return dovrebbero essere statement. Sarebbe da creare una entry nella grammatica che li includa.

These rules are straightforward, but necessary to define how to type a sequence of statements. In a sequence, statements are typed in the order that they appear. After a statement is typed, the resulting context is used to type the following one.

=== Call


#display-rules(Call, "")

Typing a function call follows the logic presented in the "passing" ($~>$) rules while taking care of what can happen with function accepting multiple parameters.
- All the roots of the paths passed to a function must be in the context (also guranteed by the language).
- All the paths passed to a function must be in standard form of the expected annotation.
- It is allowed to pass the same path twice to the same function, but only if it passed where a shared argument is expected.
- It is allowed to pass two paths $p_i$ and $p_j$ such that $p_i subset.sq p_j$ when one of the following conditions is satisfied:
  - $p_j$ is _shared_.
  - The function that has been called expects _shared_ (possibly _borrowed_) arguments in positions $i$ and $j$.
- The resulting context is constructed in the following way:
  - Paths passed to the function and their sup-paths are removed from the initial context.
  - A list of annotated paths (in which a the same path may appear twice) in constructed by mapping passed paths according to the "passing" ($~>$) rules.
  - The obtained list is normalized and added to the context.

@call-arg-twice shows the cases where it is possible to pass the same reference more than once.
In @call-sup-ok-1 it is possible to call `f` by passing `x` and `x.f` since $Delta(x.f) = shared$.
In @call-sup-wrong is not possible to call `g` by passing `b` and `b.f`, this is because `g`, in its body, expects `x.f` to be _unique_, but it would not be the case by passing `b` and `b.f`.
Finally @call-sup-ok-2 shows that it is possible to call `h` by passing `x` and `x.f` since the function expects both of the arguments to be _shared_.


#figure(
  caption: "TODO",
  ```kt
  class C

  fun f(@Unique x: C, @Borrowed y: C) {}

  fun g(@Borrowed x: C, @Borrowed y: C) {}

  fun h(x: C, @Borrowed y: C) {}

  fun use_f(@Unique x: C) {
      // Δ = x: Unique
      f(x, x) // error: 'x' is passed more than once but is also expected to be unique
  }

  fun use_g_h(@Unique x: C) {
      // Δ = x: Unique
      g(x, x) // ok, uniqueness is also preserved since both the args are borrowed
      // Δ = x: Unique
      h(x, x) // ok, but uniqueness is lost since one of the args is not borrowed
      // Δ = x: Shared
  }
  ```
)<call-arg-twice>

#figure(
  caption: "TODO",
  ```kt
  class C
  class A(var f: C)

  fun f(@Unique x: A, y: C) {}

  fun use_f(@Unique x: A) {
      // Δ = x: Unique
      f(x, x.f) // ok
      // Δ = x: T, x.f: Shared
      // Note that even if x.f is marked shared in the context,
      // it is not accessible since Δ(x.f) = T
  }
  ```
)<call-sup-ok-1>

#figure(
  caption: "TODO",
  ```kt
  class C
  class B(@Unique var f: C)

  fun g(@Unique x: B, y: C) {}

  fun use_g(@Unique b: B) {
      // Δ = b: Unique
      g(b, b.f) // error: 'b.f' cannot be passed since 'b' is passed as Unique and Δ(b.f) = Unique
      // It is correct to raise an error since 'g' expects x.f to be unique
  }
  ```
)<call-sup-wrong>

#figure(
  caption: "TODO",
  ```kt
  class C
  class B(@Unique var f: C)

  fun h(x: B, y: C) {}

  fun use_h(@Unique x: B) {
      // Δ = x: Unique
      h(x, x.f) // ok
      // Δ = x: Shared, x.f: Shared
  }
  ```
)<call-sup-ok-2>

=== Assign call

#display-rules(Assign-Call, "")

After defining how to type a _call_, it is easy to formilize the typing of a _call_ assignment. Like all the other assignment rules, the root of the path on the left side of the assignment must be in the context. First of all, the _call_ is typed obtaining a new context $Delta_1$. Then, the annotation of the path on the left side of the assignment is replaced ($|->$) in $Delta_1$ with the annotation of the return value of the function.

```kt
class C

@Unique
fun get_unique(): C { /* ... */ }

fun get_shared(): C { /* ... */ }

fun f() {
    // Δ = ∅
    val x = get_unique()
    // Δ = x: Unique
    val y = get_shared()
    // Δ = x: Unique, y: Shared
}
```

=== Assign unique

#display-rules(Assign-Unique, "")

In order to type an assignment $p = p'$ in which $p'$ is _unique_, the following conditions must hold:
- The root of $p$ must be in context.
- $p'$ must be _unique_ in the context.
- Assignments in which $p' subset.eq.sq p$, like $p.f = p$, are not allowed.

The resulting context is built in the following way:
- Starting from the initial context $Delta$, a context $Delta_1$ is obtained by replacing ($|->$) the annotation of $p'$ with $top$.
- The context $Delta_1$ is used to obtain a context $Delta'$ by replacing ($|->$) the annotation of $p$ with _unique_.
- Finally, to obtain the resulting context, all the paths that were originally rooted in $p'$ are rooted in $p$ with the same annotation and added to $Delta'$.

```kt
class C
class B(@property:Unique var t: C)
class A(@property:Unique var b: B)

fun f(@Unique x: A, @Unique y: B){
    // Δ = x: Unique, y: Unique
    y.t = x.b.t
    // Δ = x: Unique, y: Unique, x.b.t: T, y.t: Unique
    x.b = y
    // Δ = x: Unique, y: T, x.b: Unique
}
```

=== Assign shared

#display-rules(Assign-Shared, "")

Typing an assignment $p = p'$ in which $p'$ is _shared_ is similar to the case where $p'$ is _unique_, but with some differences:
- $p$ cannot be _borrowed_. This is necessary to guarantee the soundness of the system when a _unique_ variable is passed to a function expecting a _shared borrowed_ argument.
- Obviously $p'$ must be _shared_ in the context.

Also the resulting context is constructed in a similar way to the previous case. The only difference is that in this case it is not needed to replace ($|->$) the annotation of $p'$.

```kt
class C
class B(@property:Unique var t: C)

fun f(@Unique x: B, y: C){
    // Δ = x: Unique, y: Shared
    x.t = y
    // Δ = x: Unique, y: Shared, x.t: Shared
}
```

=== Assign boorowed field

#display-rules(Assign-Borrowed-Field, "")

// TODO: spiegazione
// TODO: esempio

=== If

#display-rules(If, "")

Once the unification function is defined, typing an _if_ statement is straightforward. First it is necessary to be sure that paths appearing in the guard are accessible in the initial context. The _then_ and the _else_ branches are typed separately and their resulting contexts are unified to get the resulting context of the whole statement.

Note that the system does not allow to have _null_ or a _method call_ in the guard of an _if_ statement because they are easy to be desugared, as it is shown in the following examples:
$ fi (p == null) ... equiv var "fresh" ; "fresh" = null ; fi(p == "fresh") ... $
$ fi (p == m(...)) ... equiv var "fresh" ; "fresh" = m(...) ; fi(p == "fresh") ... $

```kt
class C
class A(@property:Unique var c: C)

fun consumeUnique(@Unique c: C) {}

fun consumeShared(a: A) {}

fun f(@Unique a: A, @Borrowed c: C) {
    // Δ = a: unique, t: shared borrowed
    if (a.c == c) {
        consumeUnique(a.c)
        // Δ1 = a: unique, a.f: T, t: shared borrowed
    } else {
        consumeShared(a)
        // Δ2 = a: shared, t: shared borrowed
    }
    // unify(Δ; Δ1; Δ2) = a: LUB{ unique, shared }, a.f: LUB{ T, shared }, t: shared borrowed
    // Δ = a: shared, a.f: T, t: shared borrowed
}
```
$
class A(c: unique) \
"consumeUnique"(c: unique){} \
"consumeShared"(a: shared){} \
f(a: unique, c: shared borrowed){
  fi(a.c == c) 
    "consumeUnique"(a.c)
   els 
    "consumeShared"(a)
}
$

=== Return

#display-rules(Return-p, "")

By construction of the grammar, a _return_ statement will always be the last statement to execute. Therefore, it is not relevant to have a resulting context after typing the return statement. In order to be well-typed, a _return_ statement must satisfy the following conditions:
- The annotation of the returned path must be lower or equal ($rel$) than the annotation of the return value of the method.
- The returned path must be in the standard form of the returned type
- All the parameters that are not unique must be in the standard form of their original.
These conditions are essential for having a method modular system. // TODO: elaborate more?

Note that the system does not allow to return _null_ or a _method call_ because they are easy to be desugared, as it is shown in the following examples:
$ {...; ret null} equiv {...; var "fresh" ; "fresh" = null ; ret "fresh"} $
$ {...; ret m(...)} equiv {...; var "fresh" ; "fresh" = m(...) ; ret "fresh"} $
Where _fresh_ is a variable that has not been declared before.

// TODO: examples

#line(length: 100%)

#display-rules(
  Begin, "",
  Decl, Assign-Null,
  Seq-Base, Seq-Rec,
  Assign-Unique, "",
  Assign-Shared, "",
  Assign-Borrowed-Field, "",
  Assign-Call, "",
  Call, "",
  If, "",
  Return-p, "",
)

// TODO: Stack example + DERIVATION

// TODO: put this in a separate chapter

// == Aliasing control in Kotlin

// === Verify  contracts


// // example of contracts usage

// // example of improvement in verification of contracts

// // quote something??

// === Static analysis (IntelliJ)
// === Smart cast
// === Function optimiztion (modify lists implace)
// === Garbage collection in Kotlin native

// == The system