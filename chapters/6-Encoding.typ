#pagebreak(to:"odd")
= Encoding in Viper<cap:encoding>

Brief introduciton on the plugin @FormVerPlugin
- what has been done
- aliasing problem
- solution --> annotation system

== Classes Encoding

- classes can be seen as trees (potentially unbounded)
- classes are encoded as predicates
- point out that overlapping of predicates with wildcard permission is not a problem.

=== shared predicate

- immutable part of the class
- interesting because can be used by shared stuff
- nullables
- supertype
- type information

- EXAMPLES

=== unique predicare

- unique part of the class
- nullables
- supertype
- type information

- EXAMPLES

== Functions Encoding

// TODO: decidere se la spiegazione delle annotazioni va fatta qui o nel capitolo 4 (ad esempio che annotiamo la funzione per il return value) 

- unique
- borrowed unique
- shared
- borrowed shared

- this
- return value
- constructors

- EXAMPLES

// Mostrare come ogni tipo di parametro viene tradotto in Viper

// *************************************************

Within a method, the following elements are annotated as follows:

- The arguments have to be either `unique` or `shared`, in addition they can also be `borrowed`.
- The receiver has to be either `unique` or `shared`, in addition it can also be `borrowed`.
- The return value has to be either `unique` or `shared`.

=== Return

- All the methods have to ensure access to the immutable predicate of the returned reference.
- In addition, a method returning a `unique` reference in Kotlin will also ensure access to the mutable predicate of the returned reference.

#let return-kt = ```kt
class T()

@Unique
fun return_unique(): T {
    // ...
}

fun return_shared(): T {
    // ...
}
```

// TODO: write that predicate body is not relevant, same for the function's body

#let return-vpr = ```java
predicate SharedT(this: Ref)
predicate UniqueT(this: Ref)

method return_unique()
returns(ret: Ref)
ensures acc(SharedT(ret), wildcard)
ensures UniqueT(ret)

method return_shared()
returns(ret: Ref)
ensures acc(SharedT(ret), wildcard)
```

#align(
  center,
  figure(
    caption: "TODO",
    grid(
      columns: (1.4fr, 2fr),
      column-gutter: 2em,
      row-gutter: .5em,
      return-kt, return-vpr
    )
  )
)

=== Parameters

#figure(
  caption: "TODO",
  table(
    columns: (auto, auto, auto, auto, auto),
    inset: 8pt,
    align: center,
    table.header(
      [* *], [*Unique*], [*Unique Borrowed*], [*Shared*], [*Shared Borrowed*],
    ),
    "Requires Read", $checkmark$, $checkmark$, $checkmark$, $checkmark$,
    "Ensures Read", $checkmark$, $checkmark$, $checkmark$, $checkmark$,
    "Requires Write", $checkmark$, $checkmark$, "✗", "✗",
    "Ensures Write", "✗", $checkmark$, "✗", "✗",
  )
)

#let param-kt = ```kt
fun arg_unique(
    @Unique t: T
) {
}

fun arg_shared(
    t: T
) {
}

fun arg_unique_b(
    @Unique @Borrowed t: T
) {
}

fun arg_shared_b(
    @Borrowed t: T
) {
}
```

#let param-vpr = ```java
method arg_unique(t: Ref)
requires acc(UniqueT(t))
requires acc(SharedT(t), wildcard)
ensures acc(SharedT(t), wildcard)

method arg_shared(t: Ref)
requires acc(SharedT(t), wildcard)
ensures acc(SharedT(t), wildcard)

method arg_unique_b(t: Ref)
requires acc(UniqueT(t))
requires acc(SharedT(t), wildcard)
ensures acc(UniqueT(t))
ensures acc(SharedT(t), wildcard)

method arg_shared_b(t: Ref)
requires acc(SharedT(t), wildcard)
ensures acc(SharedT(t), wildcard)
```

#align(
  center,
  figure(
    caption: "TODO",
    grid(
      columns: (1.4fr, 2fr),
      column-gutter: 2em,
      row-gutter: .5em,
      param-kt, param-vpr
    )
  )
)

=== Receiver

- easy to encode, just consider it as a parameter
- example

== Function Calls Encoding

// Interessante mostrare il grafo delle chiamate

#figure(
  caption: "TODO",
  image("../images/calls-graph.svg", width: 80%)
)

- explain the call graph

- EXAMPLES



// Esempi

== Predicates Unfolding

- easy for shared
- inhaling -> only if there are no way to access the predicate
- design choices for unique
- EXAMPLES