#import "../config/utils.typ": *
#import "rules/base.typ": *
#import "rules/relations.typ": *
#import "rules/unification.typ": *
#import "rules/statements.typ": *

#pagebreak(to:"odd")
= Annotation System

This chapter describes an annotation system for controlling aliasing within a subset of the Kotlin language.
The system takes inspiration from some previous works @boyland2001alias @zimmerman2023latte @aldrich2002alias  but it also introduces significant modifications.

One distinguishing trait of this system is that it is designed exclusively for Kotlin, while the majority of previous works are made for Java and other languages.
It is also specifically made for being as lightweight as possible and gradually integrable with already existing code.
// TODO: borrowed unique / borrowed shared distinction here?

A unique design goal of this system is to improve the verification process with Viper by establishing a link between separation logic and the absence of aliasing control in Kotlin.

== Grammar

In order to define the rules of this annotation system, a grammar representing a substet of the Kotlin language is used. The grammar uses a notation similar to Featherweight Java @Featherweight-Java.

#frame-box(
  $
    CL &::= class C(overline(f\: alpha_f)) \
    M &::= m(overline(af beta space x)): af {begin_m; overline(s); ret_m e} \
    af &::= unique | shared \
    beta &::= dot | borrowed \
    p &::= x | p.f \
    e &::= null | p | m(overline(p)) \
    s &::= var x | p = e |  fi p_1 == p_2 then overline(s_1) els overline(s_2) | m(overline(p))
    // \ &| loop p_1 == p_2 do overline(s)
  $
)

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
=== Expressions
=== Statements

== Context

#frame-box(
  $
    alpha &::= unique | shared | top \
    beta &::= dot | borrowed \
    Delta &::= dot | p : alpha beta, Delta
  $
)

== General

#display-rules(
  M-Type, "",
  M-Args, "",
)

== Context

- The same variable/field cannot appear more than once in a context.
- Contexts are always *finite*
- If not present in the context, fields have a default annotation that is the one written in the class declaration

#display-rules(
  Not-In-Base, Not-In-Rec,
  Ctx-Base, Ctx-Rec,
  Root-Base, Root-Rec,
  Lookup-Base, Lookup-Rec,
  Lookup-Default, "",
  Remove-Empty, Remove-Base,
  Remove-Rec, "",
)

== SubPaths

If $p_1 subset.sq p_2$ holds, we say that 
- $p_1$ is a *sub*-path of $p_2$
- $p_2$ is a *sup*-path of $p_1$

#display-rules(
  SubPath-Base, SubPath-Rec,
  SubPath-Eq-1, SubPath-Eq-2,
  Remove-SupPathsEq-Empty, Remove-SupPathsEq-Discard,
  Remove-SupPathsEq-Keep, Replace,
  Get-SupPaths-Empty, "",
  Get-SupPaths-Discard, "",
  Get-SupPaths-Keep, "",
)

== Annotations relations

- $alpha beta rel alpha' beta'$ means that $alpha beta$ can be passed where $alpha' beta'$ is expected.

- $alpha beta ~> alpha' beta' ~> alpha'' beta''$ means that after passing a reference annotated with $alpha beta$ as argument where $alpha' beta'$ is expected, the reference will be annotated with $alpha'' beta''$ right after the method call.

#display-rules(
  row-size: 3,
  A-id, A-trans, A-bor-sh,
  A-sh, A-bor-un, A-un-1,
  A-un-2, Pass-Bor, Pass-Un,
  Pass-Sh
)

#figure(image(width: 25%, "../images/lattice.svg"), caption: [Lattice obtained by annotations relations rules])<annotation-lattice>

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

=== Begin

#display-rules(Begin, "")

This rule is used to initialize the context at the beginning of a method. The initial context will contain only the method's arguments with the declared uniqueness annotations.

// TODO: scrivere da qualche parte che i tipi sono a cazzo
```kt
fun @receiver:Unique T.f(
    @Unique @Borrowed x: T,
    @Borrowed y: T,
    z: T
) {
    // Δ = this: unique, x: unique ♭, y: shared ♭, z: shared
    // ...
}
```

// TODO: derivation?

$ f(unique this, unique borrowed space x, shared borrowed space y, shared z){begin_f; ...} $

=== Variable Declaration

#display-rules(Decl, "")

After declaring a variable, it is unaccessible until its initialization and so the varaible will be in the context with $top$ annotation.
Note that this rule only allows to declare variables if they are not in the context while Kotlin allows to shadow variables declared in outer scopes. Kotlin code using shadowing is not currently supported by this system.

```kt
fun f(){
    // Δ = ∅
    var x: C
    // Δ = x: T
    // ...
}
```
$ f(){begin_f; var x; ...} $

=== Assigning null

#display-rules(Assign-Null, "")

The definition of unique tells us that a reference is unique when it is `null` or is the sole accessible reference pointing to the object that is pointing. Given that, we can safely consider unique a path $p$ after assigning `null` to it. Moreover, all sup-paths of $p$ are removed from the context after the assignment.

```kt
class B(@property:Unique var t: T)

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

#line(length: 100%)

#display-rules(
  Begin, "",
  Decl, Assign-Null,
  Seq-Base, Seq-Rec,
  If, "",
  Assign-Unique, "",
  Assign-Shared, "",
  Assign-Borrowed-Field, "",
  Assign-Call, "",
  Call, "",
  Return-p, "",
)

*Note:* Since they can be easily desugared, there are no rules for returnning `null` or a method call.
- `return null` $equiv$ `var fresh ; fresh = null ; return fresh`
- `return m(...)` $equiv$ `var fresh ; fresh = m(...) ; return fresh`

The same can be done for the guard of if statements:
- `if (p1 == null) ...` $equiv$ `var p2 ; p2 = null ; if(p1 == p2) ...`
- `if (p1 == m(...)) ...` $equiv$ `var p2 ; p2 = m(...) ; if(p1 == p2) ...`

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