#import "../vars/kt-to-vpr-examples.typ": *
#import "../config/utils.typ": code-compare

#pagebreak(to:"odd")
= Encoding in Viper<cap:encoding>

The annotation system for aliasing control introduced in @cap:annotations-kt and formalized in @cap:annotation-system aims to improve the verification process performed by a plugin @FormVerPlugin for the Kotlin compiler. This plugin verifies Kotlin code by encoding it to Viper and supports a substantial subset of the Kotlin language. However, as described in @cap:aliasing, the lack of guarantees about aliasing presents a significant limitation for the plugin.

== Classes Encoding<cap:class-encoding>

In Kotlin, as in most programming languages, classes can represent potentially unbounded structures on the heap, such as linked lists or trees. This characteristic was a key factor in the decision to encode Kotlin classes into Viper predicates. Viper predicates, in fact, are specifically designed to represent potentially unbounded data structures.

=== Shared Predicate

The shared predicate of a class includes read access to all fields that the language guarantees as immutable. Having access to these predicates allows the verification of certain functional properties of a program, even without uniqueness guarantees. The reason is that immutability is a stronger condition than uniqueness from a verification point of view. Indeed, while uniqueness ensures that an object is only accessible through a single reference, immutability guarantees that the object's state cannot change after its creation, eliminating the need to track or control access patterns for verifying correctness.

As shown in @class-comp-1, the encoding process involves including access to all fields declared as `val`, along with their shared predicate if they have one. Inheritance is encoded by including access to the shared predicates of the supertypes (Line 18). Additionally, the example illustrates how Kotlin's nullable types are encoded by accessing the predicate when the reference is not `null` through a logical implication (Lines 19-21).

All the encoding examples that follow are simplified to improve readability and focus on the aspects pertinent to this work. In the plugin, avoiding name clashes is a crucial concern. As a result, names in the plugin are typically more complex than those shown in the examples.
Furthermore, the plugin extends the predicate's body by adding Kotlin type information through domain functions. Instead of mapping Kotlin `Int` and other primitive types directly to their corresponding built-in Viper types, the plugin maps them to Viper `Ref` paired with a domain function. Similarly, classes are also paired with domain functions to ensure that their type information is consistently represented. However, this representation is omitted since it is not relevant to the focus of this work.

For a complete view, @complete-encoding shows how the shared predicate of the classes in @class-comp-1 appears in the plugin. 

#code-compare("Shared predicate encoding", 0.8fr, classes-kt, classes-vpr)<class-comp-1>

#figure(
  caption: "Shared predicate non-simplified encoding",
  full-encoding
)<complete-encoding>

=== Unique Predicate

The unique predicate of a class represents all the resources that the annotation system guarantees will not be aliased for a unique object. This includes access to all the fields of a class with `write` or `wildcard` permission, depending on whether the field is `var` or `val`. If a field is declared unique, it also includes access to its unique predicate. Additionally, this predicate contains access assertions to the shared predicate of the fields because, as explained in the previous section, accessing immutable resources is always safe.

It is worth mentioning that some overlap might exist between the assertions in the shared predicate and those in the unique predicate. However, this overlap cannot lead to contradictions in Viper, such as requiring access with a total amount greater than 1, because the only assertions that can overlap are accessed with `wildcard` permission.

#code-compare("Unique predicate encoding", 0.65fr, classes-unique-kt, classes-unique-vpr)


== Functions Encoding

Access information provided by Kotlin's type system and by the uniqueness annotations is encoded using the predicates described in @cap:class-encoding within the conditions of a method.
On the one hand, shared predicates can always be accessed with `wildcard` permission without causing issues. Therefore, they can always be included in the conditions of a method for its parameters, receiver, and return value.
On the other hand, unique predicates can only be included in a method's conditions in accordance with the annotation system.

// TODO: decidere se la spiegazione delle annotazioni va fatta qui o nel capitolo 4 (ad esempio che annotiamo la funzione per il return value) 

=== Return object

Since accessing immutable data is not a problem even if it is shared, every Kotlin function, in its encoding can ensure access to the shared predicate of the type of the returned object.
In addition, a Kotlin function annotated to return a unique object will also ensure access to its unique predicate. @return-comp illustrates the differences in the encoding between a function that returns a unique object and a function that returns a shared one.

#code-compare("Function return object encoding", 0.7fr, return-kt, return-vpr)<return-comp>

=== Parameters

Annotations on parameters are encoded by adding preconditions and postconditions to the method. Access to the shared predicate of any parameter can always be required in preconditions and ensured in postconditions. Conversely, access to the unique predicate can be required in preconditions only for parameters annotated as unique, and it can be ensured in postconditions only for parameters annotated as both unique and borrowed. @param-comp shows how function parameters are encoded, while @param-table summarizes the assertions contained within preconditions and postconditions based on the parameter annotations.

#code-compare("Function parameters encoding", 0.8fr, param-kt, param-vpr)<param-comp>

#figure(
  caption: "Conditions for annotated parameters",
  param-table
)<param-table>

=== Receiver

Encoding the receiver of a method is straightforward since the receiver is considered as a normal parameter.

#code-compare("Function receiver encoding", 1fr, receiver-kt, receiver-vpr, same-row: false)

=== Constructor

Constructors are encoded as black-box methods returning a unique object. The encoding of a constructor requires access to the shared predicates for every property that is not of a primitive type. In addition, the unique predicate is also required for properties that are unique in the class declaration.
Currently, the plugin only supports class properties declared as parameters. Properties declared within the body of a class and initializing blocks are not supported yet, as they may construct objects that are not necessarily unique.

#code-compare("Constructor encoding", .8fr, constructor-kt, constructor-vpr, same-row: false)

== Predicates Unfolding<cap:unfolding>

- easy for shared
- inhaling -> only if there are no way to access the predicate
- design choices for unique
- EXAMPLES

== Function Calls Encoding

Encoding method calls is straightforward for some cases, but requires attention for some others.

=== Functions with unique parameters

Functions with a unique parameter, when called, do not need the inclusion of additional statements for their encoding, except for folding or unfolding statements, as detailed in @cap:unfolding.

#code-compare("Function call with unique parameter encoding", .8fr, unique-call-kt, unique-call-vpr)

=== Functions with shared parameters

When functions with a shared parameter are called, their encoding may require the addition of `inhale` and `exhale` statements. The annotation system allows functions with shared parameters to be called by passing unique references. However, the function's conditions alone are not sufficient to properly encode these calls.

For example, passing a unique reference to a function expecting a shared (non-borrowed) parameter will result in the loss of uniqueness for that reference, which is encoded by exhaling the unique predicate. Similarly, when a unique reference is passed to a function expecting a borrowed-shared parameter, the uniqueness is preserved, but any field of that reference can be modified. This is encoded by exhaling and then re-inhaling the unique predicate of that reference.

@call-graph summarizes the `inhale` and `exhale` statements added during the encoding of a function call.

#figure(
  caption: "Extra statements added for functions call encoding",
  image("../images/calls-graph.svg", width: 60%)
)<call-graph>

#code-compare("Function call with shared parameter encoding", .8fr, shared-call-kt, shared-call-vpr)
