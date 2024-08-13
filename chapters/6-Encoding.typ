#import "../vars/kt-to-vpr-examples.typ": *
#import "../config/utils.typ": code-compare

#pagebreak(to:"odd")
= Encoding in Viper<cap:encoding>

The annotation system for aliasing control introduced in @cap:annotations-kt and formalized in @cap:annotation-system aims to improve the verification process performed by a plugin @FormVerPlugin for the Kotlin compiler. This plugin verifies Kotlin code by encoding it to Viper and supports a substantial subset of the Kotlin language. However, as described in @cap:aliasing, the lack of guarantees about aliasing presents a significant limitation for the plugin.

== Classes Encoding

- classes can be seen as trees (potentially unbounded)
- classes are encoded as predicates
- point out that overlapping of predicates with wildcard permission is not a problem.

=== Shared Predicate

- immutable part of the class
- interesting because can be used by shared stuff
- nullables
- supertype
- type information

The shared predicate of a class includes the read access to all the fields that are guaranteed by the language to be immutable.

#code-compare("TODO", 0.8fr, classes-kt, classes-vpr)

- EXAMPLES
- Note that Int are not represented in this way in our plugin.

=== Unique Predicate

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
- constructors (unique in most of the cases)

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

// TODO: write that predicate body is not relevant, same for the function's body

#code-compare("TODO", 0.7fr, return-kt, return-vpr)

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

#code-compare("TODO", 0.7fr, param-kt, param-vpr)

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