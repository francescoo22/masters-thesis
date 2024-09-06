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

Furthermore, the plugin extends the predicate's body by incorporating Kotlin type information using domain functions. Unlike other assertions within the predicate, these domain functions are not resource assertions but rather logical assertions about the Kotlin type of a reference.
For example, instead of directly mapping Kotlin `Int` and other primitive types to their corresponding built-in Viper types, the plugin maps them to Viper `Ref` type, each associated with a domain function that asserts the specific Kotlin type of the reference. This approach ensures that the type information is logically represented within the verification process. Similarly, when dealing with classes, the plugin pairs them with domain functions to maintain consistent type information throughout the verification.
This representation, while crucial for accurate type tracking, is omitted in the examples provided here, as it is not central to the primary focus of this work.
For a complete view, @complete-encoding shows how the shared predicate of the classes in @class-comp-1 appears in the plugin. 

#code-compare("Shared predicate encoding", 0.8fr, classes-kt, classes-vpr)<class-comp-1>

#figure(
  caption: "Shared predicate non-simplified encoding",
  full-encoding
)<complete-encoding>

=== Unique Predicate

The unique predicate of a class grants access to all its fields with either `write` or `wildcard` permission, depending on whether the field is declared as `var` or `val`. If a field is marked as unique, the unique predicate also includes access to that field’s unique predicate. Additionally, the predicate contains access assertions to the shared predicates of the fields since, as explained in the previous section, accessing immutable resources is always safe.

It is worth mentioning that some overlap might exist between the assertions in the shared predicate and those in the unique predicate. However, this overlap cannot lead to contradictions in Viper, such as requiring access with a total amount greater than 1, because the only assertions that can overlap are accessed with `wildcard` permission.

#code-compare("Unique predicate encoding", 0.65fr, classes-unique-kt, classes-unique-vpr)


== Functions Encoding

Access information provided by Kotlin's type system and by the uniqueness annotations is encoded using the predicates described in @cap:class-encoding within the conditions of a method.
On the one hand, shared predicates can always be accessed with `wildcard` permission without causing issues. Therefore, they can always be included in the conditions of a method for its parameters, receiver, and return value.
On the other hand, unique predicates can only be included in a method's conditions in accordance with the annotation system.

=== Return object

Since accessing immutable data is not a problem even if it is shared, every Kotlin function, in its encoding can ensure access to the shared predicate of the type of the returned object.
In addition, a Kotlin function annotated to return a unique object will also ensure access to its unique predicate. @return-comp illustrates the differences in the encoding between a function that returns a unique object and a function that returns a shared one.

#code-compare("Function return object encoding", 0.7fr, return-kt, return-vpr)<return-comp>

=== Parameters

Annotations on parameters are encoded by adding preconditions and postconditions to the method. Access to the shared predicate of any parameter can always be required in preconditions and ensured in postconditions. Conversely, access to the unique predicate can be required in preconditions only for parameters annotated as unique, and it can be ensured in postconditions only for parameters annotated as both unique and borrowed. @param-comp shows how function parameters are encoded, while @param-table summarizes the assertions contained within preconditions and postconditions based on the parameter annotations.

In Kotlin, when passing a unique reference to a function that expects a shared borrowed argument, fields included in the unique predicate can still be modified. The current encoding does not fully capture this behavior. However, as shown in @cap:vpr-calls-enc, this limitation can be addressed by adding additional statements when such functions are called.

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

== Accessing Properties<cap:unfolding>

While encoding the body of a function using predicates to represent classes, multiple `unfold`, `fold`, `inhale`, and `exhale` statements may be necessary to access the properties of a class. If a property is part of a shared predicate, it is accessed through that predicate. If no shared predicate contains the property, the plugin attempts to access it through a unique predicate, if available. If the property is not even contained within any unique predicate, the access is inhaled.

=== Accessing Properties within Shared Predicate

Accessing properties contained within a shared predicate is straightforward. This is because shared predicates are always accessed with `wildcard` permission, meaning that after unfolding, the predicate remains valid, so there is no need to fold it back. In @unfold-shared-example, it is possible to note that the encoding of the function `f` does not require folding any predicate after accessing `b.a.n` to satisfy its postconditions.

#code-compare("Immutable property access encoding", .7fr, unfold-shared-kt, unfold-shared-vpr)<unfold-shared-example>

=== Accessing Properties within Unique Predicate

When accessing a property through a unique predicate, the predicate must be unfolded with `write` permission. Unlike shared predicates, which remain valid after unfolding with `wildcard` permission, a unique predicate does not hold after it has been unfolded. If the unique predicate is needed again, it must be folded back. This is necessary when satisfying the postconditions of the method or the preconditions of a called method.

#code-compare("Unique mutable property access encoding", .7fr, unfold-unique-kt, unfold-unique-vpr)<unfold-unique-example>

=== Accessing Properties not Contained within a Predicate

When no predicates contain the access to a property that needs to be accessed, it must be inhaled. After the property is used, its access is immediately exhaled. It is important to note that once the access to a property is exhaled, all information about it is lost. This is coherent with the idea that a property not contained within a predicate is mutable and shared, making it impossible to reason about it. In fact, such a property could be accessed and modified by other functions running concurrently.

#code-compare("Shared mutable property access encoding", .7fr, inhale-shared-kt, inhale-shared-vpr)<unfold-unique-example>

== Function Calls Encoding<cap:vpr-calls-enc>

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

#v(1em)

#code-compare("Function call with shared parameter encoding", .8fr, shared-call-kt, shared-call-vpr)

== Stack Example

Finally, @stack-vpr shows how the example from @cap:kt-stack is encoded in Viper. In this example, shared predicates are omitted for readability, as they would be empty. Moreover, the `UniqueAny` predicate does not add additional value to the encoding. However, it can be replaced with any class predicate without affecting the correctness of the encoding.

#figure(
  caption: "Stack encoding in Viper",
  ```vpr
  field value: Ref, next: Ref, root: Ref

  predicate UniqueAny(this: Ref)

  predicate UniqueNode(this: Ref) {
      acc(this.value) && (this.value != null ==> UniqueAny(this.value)) &&
      acc(this.next) && (this.next != null ==> UniqueNode(this.next))
  }

  predicate UniqueStack(this: Ref) {
      acc(this.root) && (this.root != null ==> UniqueNode(this.root))
  }

  method constructorNode(val: Ref, nxt: Ref) returns (res: Ref)
  requires val != null ==> UniqueAny(val)
  requires nxt != null ==> UniqueNode(nxt)
  ensures UniqueNode(res)
  ensures unfolding UniqueNode(res) in res.value == val && res.next == nxt

  method push(this: Ref, val: Ref)
  requires UniqueStack(this)
  requires val != null ==> UniqueAny(val)
  ensures UniqueStack(this) {
      var r: Ref
      unfold UniqueStack(this)
      r := this.root
      this.root := constructorNode(val, r)
      fold UniqueStack(this)
  }

  method pop(this: Ref) returns (res: Ref)
  requires UniqueStack(this)
  ensures UniqueStack(this)
  ensures res != null ==> UniqueAny(res) {
      var val: Ref
      unfold UniqueStack(this)
      if(this.root == null) { val := null }
      else {
          unfold UniqueNode(this.root)
          val := this.root.value
          this.root := this.root.next
      }
      fold UniqueStack(this)
      res := val
  }
  ```
)<stack-vpr>