#import "../vars/kt-to-vpr-examples.typ": *
#import "../config/utils.typ": code-compare

#pagebreak(to:"odd")
= Encoding in Viper<cap:encoding>

The annotation system for aliasing control introduced in @cap:annotations-kt and formalized in @cap:annotation-system aims to improve the verification process performed by a plugin @FormVerPlugin for the Kotlin compiler. This plugin verifies Kotlin code by encoding it to Viper and supports a substantial subset of the Kotlin language. However, as described in @cap:aliasing, the lack of guarantees about aliasing presents a significant limitation for the plugin.

== Classes Encoding

In Kotlin, as in most programming languages, classes can represent potentially unbounded structures on the heap, such as linked lists or trees. This characteristic was a key factor in the decision to encode Kotlin classes into Viper predicates. Viper predicates, in fact, are specifically designed to represent potentially unbounded data structures.

=== Shared Predicate

The shared predicate of a class includes read access to all fields that the language guarantees as immutable. Having access to these predicates allows the verification of certain functional properties of a program, even without uniqueness guarantees. The reason is that immutability is a stronger condition than uniqueness from a verification point of view. Indeed, while uniqueness ensures that an object is only accessible through a single reference, immutability guarantees that the object's state cannot change after its creation, eliminating the need to track or control access patterns for verifying correctness.

As shown in @class-comp-1, the encoding process involves including access to all fields declared as `val`, along with their shared predicate if they have one.

@class-comp-2 shows how inheritance is encoded by including access to the shared predicates of the supertypes (Line 2). Additionally, the example illustrates how Kotlin's nullable types are encoded by accessing the predicate when the reference is not `null` through a logical implication (Lines 3-5).

All the encoding examples that follow are simplified to improve readability and focus on the aspects pertinent to this work. In the plugin, avoiding name clashes is a crucial concern. As a result, names in the plugin are typically more complex than those shown in the examples.
Furthermore, the plugin extends the predicate's body by adding Kotlin type information through domain functions. Instead of mapping Kotlin `Int` and other primitive types directly to their corresponding built-in Viper types, the plugin maps them to Viper `Ref` paired with a domain function. Similarly, classes are also paired with domain functions to ensure that their type information is consistently represented. However, this representation is omitted since it is not relevant to the focus of this work.

For a complete view, @complete-encoding shows how the shared predicate of the class in @class-comp-2 appears in the plugin. 

#code-compare("Shared predicate encoding: basic classes", 0.8fr, classes-kt, classes-vpr)<class-comp-1>

#code-compare("Shared predicate encoding: supertypes and nullables", 0.8fr, classes-2-kt, classes-2-vpr)<class-comp-2>

#figure(
  caption: "TODO",
  ```java
  field bf$a1: Ref
  field bf$a2: Ref
  field bf$b: Ref
  field bf$x: Ref
  field bf$y: Ref

  predicate p$c$A$shared(this: Ref) {
    acc(this.bf$x, wildcard) &&
    df$rt$isSubtype(df$rt$typeOf(this.bf$x), df$rt$intType())
  }

  predicate p$c$B$shared(this: Ref) {
    acc(this.bf$a1, wildcard) && 
    acc(p$c$A$shared(this.bf$a1), wildcard) &&
    df$rt$isSubtype(df$rt$typeOf(this.bf$a1), df$rt$T$c$A())
  }

  predicate p$c$C$shared(this: Ref) {
    acc(this.bf$b, wildcard) &&
    (this.bf$b != df$rt$nullValue() ==>
    acc(p$c$B$shared(this.bf$b), wildcard)) &&
    acc(p$c$A$shared(this), wildcard) &&
    df$rt$isSubtype(df$rt$typeOf(this.bf$b), df$rt$nullable(df$rt$T$c$B()))
  }
  ```
)<complete-encoding>

=== Unique Predicate

- unique part of the class
- nullables
- supertype
- type information
- point out that overlapping of predicates with wildcard permission is not a problem.


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