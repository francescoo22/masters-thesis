#import "../formal-rules/rules/base.typ": *
#import "../formal-rules/rules/relations.typ": *
#import "../formal-rules/rules/unification.typ": *
#import "../formal-rules/rules/statements.typ": *
#import "../formal-rules/vars.typ": *
#show raw.where(block: true): frame-box
#pagebreak(to:"odd")

= Uniqueness annotations sytem formal rules

== Language

#v(1em)
#grid(
  columns: (auto, auto),
  column-gutter: 2em,
  row-gutter: 1em,
  [*Grammar*],[*Context*],
  frame-box(
    $
      CL ::= class C(overline(f\: alpha_f)) \
      af ::= unique | shared \
      beta ::= dot | borrowed \
      M ::= m(overline(af beta space x)): af {begin_m; overline(s); ret_m e} \
      p ::= x | p.f \
      e ::= null | p | m(overline(x)) \
      s ::= var x | p = e |  fi p_1 == p_2 then overline(s_1) els overline(s_2)
    $
  ),
  frame-box(
    $
      alpha ::= unique | shared | top \
      beta ::= dot | borrowed \
      Delta ::= dot | x : alpha beta, Delta
    $
  )
)

Notes:
- Primitive fields are not considered
- `this` can be seen as a parameter
- constructos can be seen as functions returning a unique value

== Annotations meaning

- Only fields, arguments, and return values have to be annotated.
- A reference annotated as `unique` may either be `null` or point to an object, and it is the sole reference to that object.
- A reference marked as `shared` can point to an object without being the exclusive reference to that object.
- `T` is an annotation that can only be inferred and means that the reference is not accessible.
- `borrowed` indicates that the function receiving the reference will not create additional aliases to it.
- Annotations on fields indicate only the default permissions, in order to understand the real permissions of a fields it is necessary to look at the context. This concept is formalized by rules in @cap:paths and shown in @field-annotations.

== Rules

=== General

#display-rules(
  M-Type, M-Args
)

=== Context

- The same variable/field cannot appear more than once in a context.
- If not present in the context, fields have a default annotation that is the one written in the class declaration

#display-rules(
  Not-In-Base, Not-In-Rec,
  Root-Base, Root-Rec,
  Ctx-Base, Ctx-Rec,
  Lookup-Base, Lookup-Rec,
  Lookup-Default, "",
  Remove-Empty, Remove-Base,
  Remove-Rec, "",
)

=== SubPaths

#display-rules(
  SubPath-Base, SubPath-Rec,
  Remove-SubPaths-Empty, Remove-SubPaths-Discard,
  Remove-SubPaths-Keep, Replace,
  Get-SubPaths-Empty, "",
  Get-SubPaths-Discard, "",
  Get-SubPaths-Keep, "",
)

=== Annotations relations

- $alpha beta rel alpha' beta'$ means that $alpha beta$ can be passed where $alpha' beta'$ is expected.

- $alpha beta ~> alpha' beta' ~> alpha'' beta''$ means that after passing a reference annotated with $alpha beta$ as argument where $alpha' beta'$ is required, the reference will be annotated with $alpha'' beta''$ right after the method call.

#display-rules(
  row-size: 3,
  A-id, A-trans, A-bor-sh,
  A-sh, A-bor-un, A-un-1,
  A-un-2, Pass-Bor, Pass-Un,
  Pass-Sh
)

#figure(image(width: 25%, "../images/lattice.svg"), caption: [Lattice obtained by annotations relations rules])<annotation-lattice>

=== Paths
<cap:paths>

- $lub{alpha_0 beta_0, ..., alpha_n beta_n}$ identifies the least upper bound of the annotations based on the lattice in @annotation-lattice.
- Note that even if $p.f$ is annotated as unique in the class declaration, $Delta(p.f)$ can be shared (or $top$) if $Delta(p) = shared$ (or $top$)
- Note that it is not possible that $Delta(p.f) = alpha borrowed$ i.e. only variables can be annotated as borrowed.
- Note that $Delta(p) = alpha beta => Delta inangle(root(p)) = alpha' beta'$ i.e. the root is present in the context.
- $Delta tr std(p, alpha)$ means that subpaths rooted in $p$ have the right permissions when passing $p$ where $alpha$ (or $alpha borrowed$) is expected. To understand better why these rules are necessary look at the example in @path-permissions.

#display-rules(
  Get-Var, Get-Path-Base,
  Std-Empty, Std-Rec-1,
  Std-Rec-2, "",
)

=== Unification

- Basically $unify(Delta, Delta_1, Delta_2)$ means that we want to unify $Delta_1$ and $Delta_2$ starting from a parent environment $Delta$.
  - Variables and paths $x, p.f$ contained in $Delta_1$ or $Delta_2$ such that $x$ is not contained $Delta$ will not be included in the unfication.
  - The annotation of variables contained in the unfication is the least upper bound of the annotation in $Delta_1$ and $Delta_2$.
- Rules are a bit complicated because it is necessary to take care of default annotation for fields.

#display-rules(
  U-Empty-1, U-Empty-2,
  U-Field-1, "",
  U-Field-2, "",
  U-Var-1, "",
  U-Var-2, "",
  U-Field-3, "",
  U-Field-4, ""
)

=== Normalization

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

=== Statements

#display-rules(
  Begin, "",
  Decl, Assign-Null,
  Seq-Base, Seq-Rec,
  If, "",
  Assign-Var-Unique, "",
  Assign-Var-Shared, "",
  Assign-Call, "",
  Call, "",
)

#pagebreak()

== Examples

=== Paths-permissions:

#figure(
```kt
class C()
class A(var f: @Unique C)

fun use_a(a: @Unique A)

fun f1(a: @Shared A){
  //  Δ = a: Shared 
  // ==>  Δ(a.f) = shared even if `f` is annotated ad unique
}

fun f2(a: @Unique A){
  //  Δ = a: Unique 
  // ==>  Δ(a.f) = Unique
  use_a(a)
  // after passing `a` to `use_a` it can no longer be accessed
  // Δ = a: T
  // Δ(a.f) = T even if `f` is annotated ad unique
}
```
)<field-annotations>

#figure(
```kt
class C()
class A(var f: @Unique C)

fun f(a: @Unique A)
fun use_f(x: @Unique A, y: @Unique A){
  // Δ = x: Unique, y: Unique
  y.f = x.f
  // Δ = x: Unique, y: Unique, x.f: T
  f(x) // error: 'x.f' does not have standard permissions when 'x' is passed
}
```
)<path-permissions>


=== Call premises explaination:

- $forall 0 <= i <= n : Delta tr std(p_i)$ : \ We need that all the arguments to have at least standard permissions for their fields. This is necessary for making the annotations method modular.


- $forall 0 <= i, j <= n : (i != j and p_i = p_j) => alpha_i^m = shared$ : \ If the same variable/field is passed more than once, it can only be passed where shared is expected. This us necessary since the called function expects unique parameters not to be aliased.
```kt
class C()
class A(var f: @Unique C)

fun f1(x: @Unique A, y: @Borrowed @Shared A)
fun f2(x: @Borrowed @Shared A, y: @Borrowed @Shared A)
fun f3(x: @Shared A, y: @Borrowed @Shared A)

fun use_f1(x: @Unique A){
  // Δ = x: Unique
  f1(x, x) // error: 'x' is passed more than once and but is also expected to be unique
}

fun use_f2_f3(x: @Unique A){
  // Δ = x: Unique
  f2(x, x) // ok, uniqueness is also preserved since both the args are borrowed
  // Δ = x: Unique
  f3(x, x) // ok, but uniqueness is lost since one of the args is not borrowed
  // Δ = x: Shared
}
```

- $forall 0 <= i, j <= n : p_i supset p_j => (Delta(p_j) = shared or a_i^m = a_j^m = shared)$ : \ Fields of an object that has been passed to a method can be passed too, but only if the nested one is shared or they are both expected to be shared.

```kt
class C()
class A(var f: @Shared C)
class B(var f: @Unique B)

fun f1(x: @Unique A, y: @Shared C)
fun use_f1(x: @Unique A){
  // Δ = x: Unique
  f1(x, x.f) // ok
  // Δ = x: T, x.f: Shared
  // Note that even if x.f is marked shared in the context,
  // it is not accessible since Δ(x.f) = T
}

fun f2(x: @Unique B, y: @Shared C)
fun use_f2(b: @Unique B){
  // Δ = b: Unique
  f2(b, b.f) // error: 'b.f' cannot be passed since 'b' is passed as Unique and Δ(b.f) = Unique
  // It is correct to raise an error since f2 expects x.f to be unique
}

fun f3(x: @Shared B, y: @Shared C)
fun use_f3(x: @Unique B){
  // Δ = x: Unique
  f3(x, x.f) // ok
  // Δ = x: Shared, x.f: Shared
}
```

#pagebreak()
=== Next steps

- probably unification can be simplified
- keep track of local aliases (similarly to how it is done in LATTE) in order to increase the set of valid annotated code
- while loops
- if statements with non-pure guard
- lambdas
- ...