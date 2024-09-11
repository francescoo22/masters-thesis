#import "../config/utils.typ": *
#import "../vars/rules/base.typ": *
#import "../vars/rules/relations.typ": *
#import "../vars/rules/unification.typ": *
#import "../vars/rules/statements.typ": *
#import "../vars/kt-to-vpr-examples.typ": compare-grammar-kt

#pagebreak(to:"odd")

= Annotation System<cap:annotation-system>

This chapter formalizes the uniqueness system that was introduced in @cap:annotations-kt.
While inspired by prior works @aldrich2002alias @boyland2001alias @zimmerman2023latte, it introduces several significant improvements.
This system is designed for being as lightweight as possible and gradually integrable with already existing Kotlin code.

The main goal of the system is to improve SnaKt's verification process by adding aliasing control to Kotlin, thereby establishing a connection to separation logic in Viper.

== Grammar

In order to define the rules of this annotation system, a grammar representing a subset of the Kotlin language is used. This grammar captures the specific syntax and features that the system needs to handle. By focusing on a subset, the rules can be more clearly defined and easier to manage, while many complex features of the language can be supported through syntactic sugar.

#frame-box(
  $
    P &::= overline(CL) times overline(M) \
    CL &::= class C(overline(f\: alpha_f)) \
    M &::= m(overline(x\: af beta)): af {begin_m; s ; ret_m e} | m(overline(x\: af beta)): af \
    af &::= unique | shared \
    beta &::= dot | borrowed \
    p &::= x | p.f \
    e &::= null | p | m(overline(p)) \
    s &::= var x | p = e | s_1 ; s_2 | fi p_1 == p_2 then s_1 els s_2 | m(overline(p))
  $
)

#v(1em)

Classes are made of fields, each associated with an annotation $alpha_f$. Methods have parameters that are also associated with an annotation $alpha_f$ as well as an additional annotation $beta$, and they are further annotated with $alpha_f$ for the returned value.
The receiver of a method is not explicitly included in the grammar, as it can be treated as a parameter. Similarly, constructors are excluded from the grammar since they can be viewed as methods without a body returning a unique value. Overall, a program is simply made of a set of classes and a set of methods.

The annotations are the same that have been introduced in the previous chapter, the only difference is that `Borrowed` is represented using the symbol $borrowed$.
Finally, statements and expressions are pretty similar to Kotlin.

The runtime semantics of this grammar is not formalized in this work, as it corresponds to the expected semantics for an imperative language. Moreover, annotations do not impact the runtime behavior of the program.

#compare-grammar-kt

== General

#display-rules(
  M-Type, "",
  M-Type-2, "",
  M-Args, "",
  M-Args-2, "",
  F-Default, ""
)

Given a program $P$, M-Type rules define a function taking a method name and returning its type. Similarly, M-Args rules define a function taking a method name and returning its arguments. In order to derive these rules, the method must be contained within $P$.
For simplicity, it is assumed that in $P$, fields within the same class, as well as across different classes, have distinct names. This assumption simplifies the definition of the F-Default rule, which defines a function that returns the type of a given field.

#example[
  Given a method: $ m(x: unique borrowed, y: shared): unique $
  The type and the arguments of $m$ are the following: 
  $
  mtype(m) = unique borrowed, #h(.5em) shared -> unique \
  args(m) = x, y
  $
]

== Context

A context is a list of distinct paths associated with their annotations $alpha$ and $beta$. While $beta$ is defined in the same way of the grammar, $alpha$ is slightly different. Other than unique and shared, in a context, an annotation $alpha$ can also be $top$. As will be better explained in the following sections, the annotation $top$ can only be inferred, so it is not possible for the user to write it. A path annotated with $top$ within a context is not accessible, meaning that the path needs to be re-assigned before being read. The formal meaning of the annotation $top$ will be clearer while formalizing the statement typing rules.

#frame-box(
  $
    alpha &::= unique | shared | top \
    beta &::= dot | borrowed \
    Delta &::= dot | p : alpha beta, Delta
  $
)

#v(1em)

Apart from $top$, the rest of the annotations are similar to the annotations in the previous section.
A reference annotated as unique may either be `null` or point to an object, with no other accessible references to that object. In contrast, a reference marked as shared can point to an object without being the only reference to it. The annotation $borrowed$ (borrowed) indicates that the method receiving the reference will not create additional aliases to it, and upon returning, the fields of the object will have at least the permissions specified in the class declaration. Finally, annotations on fields only indicate the default permissions; to determine the actual permissions of a field, the context must be considered, a concept that will be formalized in the upcoming sections.

== Well-Formed Context

#display-rules(
  Not-In-Base, Not-In-Rec,
  Ctx-Base, Ctx-Rec,
)

This first set of rules defines how a well-formed context is structured. The judgment $p in.not Delta$ is derivable when $p$ is not present in the context. If the judgment $Delta ctx$ is derivable, the context is well-formed. In order to be well-formed, a context must not contain duplicate paths and must be finite.

#example[
  Given a context: $ Delta = x: unique, space x.y: shared $
  The following judgments are derivable: $ y &in.not Delta \ x.f &in.not Delta \ x.y.z &in.not Delta $
]

#example[
  Given the following contexts: 
  $
  Delta_1 &= x: unique, space x.y: shared \
  Delta_2 &= x: unique, space x.y: shared, space x: shared \
  Delta_3 &= x: unique, space x.y: shared, space x.y: top
  $
  The judgment "$Delta_1 ctx$" is derivable meaning that $Delta_1$ is a well-formed context. However, the judgments "$Delta_2 ctx$" and "$Delta_3 ctx$" are not derivable meaning that $Delta_2$ and $Delta_3$ are not well-formed contexts. Indeed, they are not well-formed because $x$ appears twice in $Delta_2$ and $x.f$ appears twice in $Delta_3$.
]

== Sub-Paths and Super-Paths

=== Definition

#display-rules(
  SubPath-Base, SubPath-Rec,
  SubPath-Eq-1, SubPath-Eq-2,
)

This set of rules is used to formally define sub-paths and super-paths.

#example[
  Given two paths $x.y$ and $x.y.z$, the following judgment is derivable: $ x.y subset.sq x.y.z $
  We say that:
  - $x.y$ is a sub-path of $x.y.z$
  - $x.y.z$ is a super-path of $x.y$
]

=== Remove

#display-rules(
  Remove-Empty, Remove-Base,
  Remove-Rec, "",
)

Remove rules are used to define a function taking a context and a path and returning a context.

$ \_without\_ : Delta -> p -> Delta $

Basically, the function will return the context without the specified path if the path is within the context, and it will return the original context if the path is not contained.

#example[
  Given a context: $ Delta = x: shared, space x.f: shared $
  Remove has the following results: $ Delta without x.f = x: shared \ Delta without x = x.f: shared \ Delta without y = x: shared, space x.f: shared $
]

=== Deep Remove

#display-rules(
  Remove-SuperPathsEq-Empty, "",
  Remove-SuperPathsEq-Discard, "",
  Remove-SuperPathsEq-Keep, "",
)

Deep-Remove rules define a function similar to Remove ($without$) that in addiction to removing the given path from the context, also removes all the super-paths of that path.

$ \_minus.circle\_: Delta -> p -> Delta $

#example[
  Given a context: $ Delta = x: unique, space x.y: unique, space x.f: unique, space x.y.z: unique $
  Deep Remove has the following result: $ Delta minus.circle x.y = x: unique, space x.f: unique $
]

=== Replace

#display-rules(
  Replace, "",
)

This rule gives the definition of a function that will be fundamental for typing statements. The function takes a context, a path $p$ and a set of annotations $alpha beta$ and returns a context in which all the super-paths of $p$ have been removed and the annotation of $p$ becomes $alpha beta$.

$ \_[\_|->\_] : Delta -> p -> alpha beta -> Delta $

#example[
  Given a context: $ Delta = x: unique, space x.y: unique, space x.y.z: unique $
  Replace has the following result: $ Delta[x.y |-> top] = x: unique, space x.y: top $
]

=== Get Super-Paths

#display-rules(
  Get-SuperPaths-Empty, "",
  Get-SuperPaths-Discard, "",
  Get-SuperPaths-Keep, "",
)

Finally, Get-Super-Paths rules are used to define a function that returns all the super-paths of a give path within a context. Also this function will be used for statements typing rules.

$ \_ tr sp(\_) : Delta -> p -> overline(p : alpha beta) $

#example[
  Given a context: $ Delta = x: unique, space x.y: unique, space x.y.z: unique $
  Getting super-paths has the following result: $ sp(x.y) = x.y.z: unique $
]

== Relations between Annotations

=== Partial Ordering<cap:PO>

#display-rules(
  A-id, A-trans,
  A-bor-sh, A-sh,
  A-bor-un, A-un-1,
  A-un-2, "",
)

This set of rules is used to define a partial order between the annotations. This partial order can be represented by the lattice shown in @annotation-lattice. The meaning of these relations is that if $alpha beta rel alpha' beta'$, then $alpha beta$ can be used where $alpha' beta'$ is expected, for example for method calls. Thanks to these rules, it will be correct to pass a unique reference to a method expecting a shared argument, but not vice versa. Moreover, the relations are consistent with the definition of $top$ since it will not be possible to pass an inaccessible reference to any method.

#v(1em)
#figure(image(width: 35%, "../images/lattice.svg"), caption: [Lattice obtained by Rel rules])<annotation-lattice>

=== Passing<cap:passing>

#display-rules(
  Pass-Bor, Pass-Un,
  Pass-Sh, ""
)

Pass rules define what happens to the annotations of a reference after passing it to a method.
If derivable, a judgment $alpha beta ~> alpha' beta' ~> alpha'' beta''$ indicates that after passing a reference annotated with $alpha beta$ to a method expecting an argument annotated with $alpha' beta'$, the reference will be annotated with $alpha'' beta''$ after the call.
However, these rules are not sufficient to type a method call statement since passing the same reference more than once to the same method call is a situation that has to be handled carefully. Nonetheless, the rules are fundamental to express the logic of the annotation system and will be used for typing method calls in subsequent sections.

== Paths
<cap:paths>

=== Root

#display-rules(
  Root-Base, Root-Rec,
)

This simple function takes a path and returns its root. The function can simplify the preconditions of more complex rules. For example $root(x.y.z) = x$

$ root : p -> p $

#example[
  $ root(x.y.z) = x \ root(y.z) = y \ root(z) = z $
]

=== Lookup<cap:lookup>

#display-rules(
  Lookup-Base, Lookup-Rec,
  Lookup-Default, "",
)

Lookup rules define a (partial) function that, given a well-formed context, returns the annotations associated with a given path

When the path is explicitly contained within the context, the function returns the corresponding annotation. If a field access ($p.f$) is not explicitly present in the context, the function returns the annotations specified in the class declaration containing $f$. This concept, formalized by Lookup-Default, is crucial as it ensures that contexts remain finite, even when handling recursive classes. However, if a variable ($x$) is not present in the context, its lookup cannot be derived.

It is important to note that the lookup function returns the annotations associated with a path based on the context or the class declaration, rather than determining the actual ownership status of that path.

$ \_inangle(\_): Delta -> p -> alpha beta $

#example[
  Given a context: $ Delta = x : shared, space x.f : unique $ 
  The result of the lookup for $x.f$ is the following: $ Delta inangle(x.f) = unique $
  However, since $x$ is shared, there can be multiple references accessing $x$. This implies there can be multiple references accessing $x.f$, meaning that $x.f$ is also shared.
  A scenario like this can occur when, starting from a context containing only $x : shared$, a unique value is assigned to the field $x.f$.
  A function able to determine the actual ownership of a path is defined in the subsequent section.
  
]

#example[
  Given class $C$, context $Delta$ and variable $x$ such that: $ class C(f: shared) in P \ Delta = x : unique \ type(x.f) = shared $
  The result of the lookup for $x.f$ is the following: $ Delta inangle(x.f) = shared $
  Since $x.f in.not Delta$, the lookup returns the default annotation, which is the one declared in the class signature.
]

=== Get

#display-rules(
  Get-Var, Get-Path,
)

As described in the previous subsection, the lookup function might not return the correct annotation for a given path. The task of returning the right annotation for a path within a context is left to the (partial) function described in this chapter.

$ \_(\_) : Delta -> p -> alpha beta $

In the case that the given path is a variable, the function will return the same annotation returned by the lookup function. If the given path is not a variable, the function will return the least upper bound ($lub$) between the lookup of the given path and all its sub-paths. The LUB between a set of annotations can be easily obtained by using the partial order described in @cap:PO. 

It is important to note that if $Delta(p) = alpha beta$ is derivable for some $alpha beta$ then the root of $p$ is contained inside $Delta$. This is important because many rules in the subsequent sections will use the judgment $Delta(p) = alpha beta$ as a precondition and it also helps to guarantee that the root of $p$ is contained inside $Delta$.

Furthermore, in the rule Get-Path, the premise $Delta inangle(p.f) = alpha'$ does not pair a $beta'$ annotation to $alpha'$. This omission is intentional because, by the design of the subsequent typing rules, a field access lookup should never result in a borrowed annotation. Regardless, the $beta$ annotation for a field access should be determined solely by its root.

#example[
  Given a context: $ Delta = x: unique, space x.y: top, space x.y.z: shared $

  The annotation that is returned for the variable $x$ is the same as the one returned by the lookup.

  $ Delta(x) = Delta inangle(x) = unique $

  The annotation returned for the path $x.y$ is the LUB between the lookup of $x.y$ and that of all its sub-paths.

  $
  Delta(x.y) &= Lub{Delta inangle(x), Delta inangle(x.y)} \
  &= Lub{unique, top} \
  &= top
  $

  Finally, the annotation returned for the path $x.y.z$ is the LUB between the lookup of $x.y.z$ and that of all its sub-paths.

  $
  Delta(x.y.z) &= Lub{Delta inangle(x), Delta inangle(x.y), Delta inangle(x.y.z)} \
  &= Lub{unique, top, shared} \
  &= top
  $
]

=== Standard Form

#display-rules(
  Std-Empty, Std-Rec-1,
  Std-Rec-2, "",
)

If the judgment $Delta tr std(p, alpha beta)$ is derivable,  inside the context $Delta$, all the super-paths of $p$ carry the right annotations when $p$ is passed to a method expecting an argument annotated with $alpha beta$. This type of judgment is necessary verify the correctness of the annotations in a method-modular fashion.

Since a called method does not have information about $Delta$ when verified, all the super-paths of $p$ must have an annotation in $Delta$ that is lower or equal ($rel$) to the annotation that they have in a context containing just their root annotated with $alpha beta$.

#example[
  Given the following program:
  $
  class C(y: unique) \
  m_1(x: unique) : shared \
  m_2(x: shared) : shared \
  $

  Within the context $ Delta = x: unique, space x.y : shared $

  - $Delta tr std(x, unique)$ is not derivable, meaning that $x$ cannot be passed to the method $m_1$. The judgment is not derivable because $Delta(x.y) = shared$ while in a context $Delta' = x: unique$, $Delta'(x.y) = unique$, but $shared lt.eq.curly.not unique$.

  - $Delta tr std(x, shared)$ is derivable, meaning that $x$ can be passed to the method $m_2$ if all the preconditions, which would be formalized by statement's typing rules, are also satisfied.
]

== Unification

This section introduces several functions essential for managing contexts in control flow constructs such as branching and scope transitions.

=== Pointwise LUB

#display-rules(
  Ctx-Lub-Empty, Ctx-Lub-Sym,
  Ctx-Lub-1, "",
  Ctx-Lub-2, "",
)

The rules in this section describe a function that takes two contexts and returns the LUB between each pair of paths in the given contexts. If a variable $x$ is present in only one of the two contexts, it will be annotated with $top$ in the resulting context.

$ \_ lub \_ : Delta -> Delta -> Delta $

#example[
  $
  Delta_1 &= x: shared, space y: shared \
  Delta_2 &= x: unique \
  Delta_1 lub Delta_2 &= x: Lub {shared, unique}, space y: top \ 
  &= x: shared, space y: top
  $
]
=== Removal of Local Declarations

#display-rules(
  Remove-Locals-Base, "",
  Remove-Locals-Keep, "",
  Remove-Locals-Discard, "",
)

The function formalized by these rules is used to obtain the correct context when exiting a scope. When writing $Delta_1 triangle.filled.small.l Delta_2$, $Delta_1$ represents the resulting context of a scope, while $Delta_2$ represents the context at the beginning of that scope.
The result of the operation is a context where paths rooted in variables that have been locally declared inside the scope are removed.

$ \_ triangle.filled.small.l \_ : Delta -> Delta -> Delta $

#example[
  $
  Delta_1 &= x: unique, space y: unique, space x.f: unique, space y.f: shared \
  Delta_2 &= x: shared \
  Delta_1 triangle.filled.small.l Delta_2 &= x: unique, space x.f: unique \
  $
]

=== Unify

#display-rules(
  Unify, ""
)

Finally, the unify function groups the two functions described before. This function will be fundamental to type `if` statements.
In particular, $unify(Delta, Delta_1, Delta_2)$ can be used to type an `if` statement: when $Delta$ is the context at the beginning of the statement while $Delta_1$ and $Delta_2$ are the resulting contexts of the two branches of the statement.

$ "unify" : Delta -> Delta -> Delta -> Delta $

#example[
  Given the following contexts:
  $
  Delta &= x: unique \
  Delta_1 &= x: shared, space x.f : shared, space y: unique \ 
  Delta_2 &= x: unique, space x.f : top, space y: unique \
  $
  Unification has the following result:
  $
  unify(Delta, Delta_1, Delta_2) &= (Delta_1 lub Delta_2) triangle.filled.small.l Delta \
  &= (x: shared, space x.f: top, space y: unique) triangle.filled.small.l Delta \
  &= x: shared, space x.f: top
  $
]

== Normalization

#display-rules(
  N-Empty, "",
  N-Rec, ""
)

Normalize is a function that takes and returns a list of annotated paths. In the returned list, duplicate paths from the given list are substituted with a single path annotated with the LUB of the annotations from the duplicate paths.
As already mentioned, rules in @cap:passing are not sufficient to type a method call because the same path might be passed more than once to the same method.
Normalization is the missing piece that will enable the formalization of typing rules for method calls.

$ norm : overline(p : alpha beta) -> overline(p : alpha beta) $

#example[
  $ norm(x\: top, space x\: shared, space y\: unique) &= x: Lub{shared, top}, space y: unique \ &=  x: top, space y: unique $
]

== Statements Typing

Typing rules are structured as follows: $ Delta tr s tl Delta' $
This judgment means that typing a statement $s$ in a context $Delta$ leads to a context $Delta'$.
It is important to note that this refers only to the types involved and is not related to the operational semantics of the program.

A program $P$ is well-typed if and only if the following judgment is derivable:

$ forall m(overline(x\: af beta)): af {begin_m; s; ret_m e} in P . space dot tr begin_m; s; ret_m e tl dot $

This means that a program is well-typed if and only if, for every method in that program, executing the body of the method within an empty context leads to an empty context. Methods without a body are excluded from this judgment, as they can be safely assumed to be well-typed without further analysis.

=== Begin

#display-rules(Begin, "")

This rule is used to initialize the context at the beginning of a method. The initial context will contain only the method's parameters with the declared uniqueness annotations. The example below demonstrates how the rule works in practice. In this and subsequent examples, the resulting context after typing a statement is shown on the next line.

#figure(
  caption: "Typing example for Begin statement",
```
f(this: unique, x: unique ♭, y: shared ♭, z: shared): unique {
  begin_f;
    ⊣ Δ = this: unique, x: unique ♭, y: shared ♭, z: shared
  ...
}
```
)

=== Sequence

#display-rules(Seq-New, "")

This rule is straightforward, but necessary to define how to type a sequence of statements. In a sequence, statements are typed in the order that they appear. After a statement is typed, the resulting context is used to type the following one.

=== Variable Declaration

#display-rules(Decl, "")

After declaring a variable, it is inaccessible until its initialization and so the variable will be in the context with $top$ annotation.
Note that this rule only allows to declare variables if they are not in the context while Kotlin allows to shadow variables declared in outer scopes. Kotlin code using shadowing is not currently supported by this system.

#figure(
  caption: "Typing example for variable declaration",
```
f(): unique {
  begin_f;
    ⊣ Δ = ∅
  var x;
    ⊣ Δ = x: T
  ...
}
```
)

=== Call

#display-rules(Call, "")

Typing a method call follows the logic presented in the rules of @cap:passing ($~>$) while taking care of what can happen with method accepting multiple parameters.
- All the roots of the paths passed to a method must be in the context (also guaranteed by the language).
- All the paths passed to a method must be in standard form of the expected annotation.
- It is allowed to pass the same path twice to the same method, but only if it passed where a shared argument is expected.
- It is allowed to pass two paths $p_i$ and $p_j$ such that $p_i subset.sq p_j$ when one of the following conditions is satisfied:
  - $p_j$ is shared.
  - The method that has been called expects shared (possibly borrowed) arguments in positions $i$ and $j$.
- The resulting context is constructed in the following way:
  - Paths passed to the method and their super-paths are removed from the initial context.
  - A list of annotated paths (in which a the same path may appear twice) in constructed by mapping passed paths according to the "passing" ($~>$) rules.
  - The obtained list is normalized and added to the context.

@call-arg-twice shows the cases where it is possible to pass the same reference more than once and how normalization is applied.
In @call-sup-ok-1 it is possible to call `f` by passing `x` and `x.f` since $Delta(x.f) = shared$.
In @call-sup-wrong is not possible to call `g` by passing `b` and `b.f`, this is because `g`, in its body, expects `x.f` to be unique, but it would not be the case by passing `b` and `b.f`.
Finally @call-sup-ok-2 shows that it is possible to call `h` by passing `x` and `x.f` since the method expects both of the arguments to be shared.

#figure(
  caption: "Typing example for method call with same reference",
  ```
  f(x: unique, y: shared ♭): unique

  g(x: shared ♭, y: shared ♭): unique

  h(x: shared, y: shared ♭): unique

  use_f(x: unique) {
    begin_use_f;
      ⊣ Δ = x: unique
    f(x, x);
    // not derivable: 'x' is passed more than once but is also expected to be unique
    ...
  }

  use_g_h(x: unique) {
    begin_use_g_h;
        ⊣ Δ = x: unique
    g(x, x); // ok, uniqueness is also preserved since both the args are borrowed
        ⊣ Δ = x: unique
    h(x, x); // ok, but uniqueness is lost after normalization
        ⊣ Δ = x: shared
  }
  ```
)<call-arg-twice>

#figure(
  caption: "Typing example for correct method call with super-paths",
  ```
  class A(f: shared)

  f(x: unique, y: shared): unique

  fun use_f(x: unique) {
    begin_use_f;
      ⊣ Δ = x: unique
    f(x, x.f); // ok
      ⊣ Δ = x: T, x.f: shared
    // Note that even if x.f is marked shared in the context, it is not accessible since Δ(x.f) = T
    ...
  }
  ```
)<call-sup-ok-1>

#figure(
  caption: "Typing example for incorrect method call with super-paths",
  ```
  class B(f: unique)

  g(x: unique, y: shared): unique

  use_g(b: unique) {
    begin_use_g;
      ⊣ Δ = b: unique
    g(b, b.f);
    // error: 'b.f' cannot be passed since 'b' is passed as unique and Δ(b.f) = unique
    // It is correct to raise an error since 'g' expects x.f to be unique
  }
  ```
)<call-sup-wrong>

#figure(
  caption: "Typing example for correct method call with super-paths",
  ```
  class B(f: unique)

  h(x: shared, y: shared) {}

  use_h(x: unique) {
    begin_use_h;
      ⊣ Δ = x: unique
    h(x, x.f); // ok
      ⊣ Δ = x: shared, x.f: shared
    ...
  }
  ```
)<call-sup-ok-2>

=== Assignments

All rules for typing assignments have a path $p$ on the left-hand side and vary based on the expression on the right-hand side. The common trait of these rules is that they require the root of $p$ to be contained within the initial context using the premise "$Delta(p) = alpha beta$". Additionally, in the resulting context, the annotation of $p$ is always updated according to the expression on the right-hand side of the assignment.

==== Assign null

#display-rules(Assign-Null, "")

The definition of unique tells us that a reference is unique when it is `null` or is the sole accessible reference pointing to the object that is pointing. Given that, we can safely consider unique a path $p$ after assigning `null` to it. Moreover, all super-paths of $p$ are removed from the context after the assignment.

#figure(
  caption: "Typing example for assigning null",
```
class C(t: unique)

f() {
  begin_f;
    ⊣ Δ = ∅
  var b;
    ⊣ Δ = b: T
  ...
    ⊣ Δ = b: shared, b.t: T
  b = null
    ⊣ Δ = b: unique
  ...
}
```
)

==== Assign Call

#display-rules(Assign-Call, "")

After defining how to type a method call, it is easy to formalize the typing of a call assignment. Like all the other assignment rules, the root of the path on the left side of the assignment must be in the context. First of all, the method call is typed obtaining a new context $Delta_1$. Then, the annotation of the path on the left side of the assignment is replaced ($|->$) in $Delta_1$ with the annotation of the return value of the method.

#figure(
  caption: "Typing example for assigning a method call",
  ```
  get_unique(): unique
  get_shared(): shared

  f(): unique {
    begin_f; 
      ⊣ Δ = ∅
    var x; 
      ⊣ Δ = x: T
    var y; 
      ⊣ Δ = x: T, y: T
    x = get_unique(); 
      ⊣ Δ = x: unique, y: T
    y = get_shared(); 
      ⊣ Δ = x: unique, y: shared
    ...
  }
  ```
)

==== Assign Unique

#display-rules(Assign-Unique, "")

In order to type an assignment $p = p'$ in which $p'$ is unique, the following conditions must hold:
- The root of $p$ must be in context.
- $p'$ must be unique in the context.
- Assignments in which $p' subset.eq.sq p$, like $p.f = p$, are not allowed.

The resulting context is built in the following way:
- Starting from the initial context $Delta$, a context $Delta_1$ is obtained by replacing ($|->$) the annotation of $p'$ with $top$.
- The context $Delta_1$ is used to obtain a context $Delta'$ by replacing ($|->$) the annotation of $p$ with unique.
- Finally, to obtain the resulting context, all the paths that were originally rooted in $p'$ are rooted in $p$ with the same annotation and added to $Delta'$.

#figure(
  caption: "Typing example for assigning a unique reference",
  ```
  class B(t: unique)
  class A(b: unique)

  f(x: unique, y: unique): unique {
    begin_f; 
      ⊣ (Δ = x: unique, y: unique)
    y.t = x.b.t;
      ⊣ (Δ = x: unique, y: unique, x.b.t: T, y.t: unique)
    x.b = y;
      ⊣ Δ = x: unique, y: T, x.b: unique
    ...
  }
  ```
)

==== Assign Shared

#display-rules(Assign-Shared, "")

Typing an assignment $p = p'$ in which $p'$ is shared is similar to the case where $p'$ is unique, but with some differences:
- $p$ cannot be borrowed. This is necessary to guarantee the soundness of the system when a unique variable is passed to a method expecting a shared borrowed argument.
- Obviously $p'$ must be shared in the context.

Also the resulting context is constructed in a similar way to the previous case. The only difference is that in this case it is not needed to replace ($|->$) the annotation of $p'$.

#figure(
  caption: "Typing example for assigning a shared reference",
  ```
  class B(t: unique)

  f(x: unique, y: shared): unique {
    begin_f;
      ⊣ Δ = x: unique, y: shared
    x.t = y;
      ⊣ Δ = x: unique, y: shared, x.t: shared
    ...
  }
  ```
)

==== Assign Borrowed Field

#display-rules(Assign-Borrowed-Field, "")

Fields of a borrowed parameter must be treated with caution to avoid unsoundness. Borrowed fields can be passed as arguments to other methods if the preconditions for typing the method call are respected. In addition, they can be used on the right-hand side of an assignment with certain limitations. After being read, a borrowed field will inaccessible even if shared. Finally, borrowed fields can be used on the left-hand side of an assignment when a unique reference is on the right-hand side.

Ensuring inaccessibility after reading borrowed fields and restricting their reassignment to unique references, along with respecting the preconditions for typing a return statement stated in @type-ret, is essential for maintaining soundness when unique references are passed to methods that accept a borrowed-shared parameter.

#figure(
  caption: "Typing example for assigning a borrowed field",
  ```
  class B(t: unique)

  f(x: shared ♭): unique {
    begin_f;
      ⊣ Δ = x: shared ♭,
    var z;
      ⊣ Δ = x: shared ♭, z: T
    z = x.t;
      ⊣ Δ = x: shared ♭, z: shared, x.t: T
    ...
  }
  ```
)

=== If

#display-rules(If, "")

Once the unification function is defined, typing an `if` statement is straightforward. First it is necessary to be sure that paths appearing in the guard are accessible in the initial context. The `then` and the `else` branches are typed separately and their resulting contexts are unified to get the resulting context of the whole statement.

The system does not allow to have `null` or a method call in the guard of an `if` statement, as these constructs can be easily desugared.

#example[
  Desugaring for `if` statements containing expressions different from paths within the guard.
  $ fi (p == null) ... equiv var "fresh" ; "fresh" = null ; fi(p == "fresh") ... $
  $ fi (p == m(...)) ... equiv var "fresh" ; "fresh" = m(...) ; fi(p == "fresh") ... $
]

#figure(
  caption: "Typing example for if statement",
```
class A(c: unique)

consume_unique(c: unique): shared

consume_shared(a: shared): shared

fun f(a: unique, c: shared ♭) {
  begin_f;
    ⊣ Δ = a: unique, t: shared ♭
  if (a.c == c) {
      consume_unique(a.c);
        ⊣ Δ1 = a: unique, a.f: T, t: shared ♭
  } else {
      consume_shared(a);
        ⊣ Δ2 = a: shared, t: shared ♭
  };
    ⊣ Δ = a: shared, a.f: T, t: shared ♭
  // unify(Δ; Δ1; Δ2) = a: LUB{ unique, shared }, a.f: LUB{ T, shared }, t: shared ♭
  ...
}
```
)

=== Return<type-ret>

#display-rules(Return-p, "")

By the construction of the grammar, a `return` statement is designed to be the final statement executed within a method. As such, there is no need to maintain a resulting context after the return statement has been typed. However, several important conditions must be satisfied when returning.

First, the annotation of the path being returned must be lower than or equal to ($rel$) the annotation of the return value of the method. This ensures that a method cannot return a value with greater aliasing than what was specified in the method’s signature, effectively preventing borrowed values from being returned (@ret-bor).

Second, the path being returned must be in the standard form of the return type (@ret-std).

Finally, all parameters that are shared or borrowed (or both) must remain in the standard form of their original annotations by the time the method returns.

These conditions are essential for maintaining the modularity, allowing each method to be typed without knowing the implementation of the other methods.

The system does not allow returning `null` or a method call, since these cases can be easily desugared, as shown in @ret-desugar. Similarly, functions that do not return a value can be represented by having them return a call to the `Unit` constructor.

#example[
  Given the following program:
  $
  class C(f: unique) \
  m(x: unique borrowed): unique {begin_m ; ...; ret_m space x.f }
  $
  The following judgment is not derivable: $ x: unique borrowed = Delta tr ret_m space x.f tl dot $
  This happens because the function returns a borrowed field, which is prohibited by the third precondition of the rule.
  Specifically: $ mtype(m) = unique borrowed -> unique \ Delta(x.f) = unique borrowed $ 
  However, the third precondition is not derivable since: $ unique borrowed lt.eq.curly.not unique $
]<ret-bor>

#example[
  Given the following program:
  $
  class C(f: unique) \
  m(x: unique): unique {begin_m ; ...; ret_m space x }
  $
  The following judgment is not derivable: $ x: unique, space x.f: shared = Delta tr ret_m space x tl dot $
  This occurs because the fourth precondition, $Delta tr std(x, unique)$, is not derivable.
  
]<ret-std>

#example[
  Desugaring for return statements that do not return a path.
  $ {...; ret null} equiv {...; var "fresh" ; "fresh" = null ; ret "fresh"} $
  $ {...; ret m(...)} equiv {...; var "fresh" ; "fresh" = m(...) ; ret "fresh"} $
  Where $"fresh"$ refers to a variable that does not exist in the context prior to its declaration.
]<ret-desugar>

== Stack Example

@stack-grammar illustrates how the context evolves in the example presented in @cap:kt-stack when it is encoded using the grammar described in this chapter.

#figure(
  caption: "Typing for a Stack implementation",
  ```
  class Node(value: unique, next: unique)

  class Stack(root: unique)

  fun Node(value: unique, next: unique): unique

  fun push(this: unique ♭, value: unique): shared {
    begin_push;
      ⊣ Δ = this: unique ♭, value: unique
    var r;
      ⊣ Δ = this: unique ♭, value: unique, r: T
    r = this.root;
      ⊣ Δ = this: unique ♭, value: unique, r: unique, this.root: T
    this.root = Node(value, r);
      ⊣ Δ = this: unique ♭, value: T, r: T, this.root: unique
    return Unit();
  }

  fun pop(this: unique ♭): unique {
    begin_pop;
      ⊣ Δ = this: unique ♭
    var value;
      ⊣ Δ = this: unique ♭, value: T
    if (this.root == null) {
        value = null;
          ⊣ Δ = this: unique ♭, value: unique
    } else {
        value = this.root.value;
          ⊣ Δ = this: unique ♭, value: unique, this.root.value: T
        this.root = this.root.next;
          ⊣ Δ = this: unique ♭, value: unique, this.root: unique
    }
    // Unification...
      ⊣ Δ = this: unique ♭, value: unique, this.root: unique
    return value;
  }
  ```
)<stack-grammar>