#pagebreak(to:"odd")
= Uniqueness in Kotlin<cap:annotations-kt>

This chapter introduces a uniqueness system for Kotlin that takes inspiration from the systems described in @cap:control-alias-unique. The following subsections provide an overview of this system, with formal rules defined in @cap:annotation-system.

== Overview

The uniqueness system introduces two annotations, as shown in @kt-annotations. The `Unique` annotation can be applied to class properties, as well as function receivers, parameters, and return values. In contrast, the `Borrowed` annotation can only be used on function receivers and parameters. These are the only annotations the user needs to write, annotations for local variables are inferred.

Generally, a reference annotated with `Unique` is either `null` or the sole reference to an object. Conversely, if a reference is not unique, there are no guarantees about how many references exist to the object. Such references are referred to as shared.

The `Borrowed` annotation is similar to the one described by Boyland @boyland2001alias and also to the `Owned` annotation discussed by Zimmerman et al. @zimmerman2023latte. In this system, every function must ensure that no additional aliases are created for parameters annotated with `Borrowed`. Moreover, a distinguishing feature of this system is that borrowed parameters can either be unique or shared.

#figure(
  caption: "Annotations for the Kotlin uniqueness system",
  ```kt
  @Target(
      AnnotationTarget.VALUE_PARAMETER,
      AnnotationTarget.FUNCTION,
      AnnotationTarget.PROPERTY
  )
  annotation class Unique

  @Target(AnnotationTarget.VALUE_PARAMETER)
  annotation class Borrowed
  ```
)<kt-annotations>

=== Function annotations

The system allows annotating the receiver and parameters of a function as `Unique`. It is also possible to declare that a function's return value is unique by annotating the function itself. When a receiver or parameter is annotated with `Unique`, it imposes a restriction on the caller, that must pass a unique reference, and provides a guarantee to the callee, ensuring that it has a unique reference at the begin of its execution. Conversely, a return value annotated with `Unique` guarantees to the caller that the function will return a unique object and imposes a requirement on the callee to return a unique object.

Additionally, function parameters and receivers can be annotated as `Borrowed`. This imposes a restriction on the callee, which must ensure that no further aliases are created, and guarantees to the caller that passing a unique reference will preserve its uniqueness. On the other hand, if a unique reference is passed to a function without borrowing guarantees, the variable becomes inaccessible to the caller until it is reassigned.

#figure(
  caption: "Uniqueness annotations usage on Kotlin fucntions",
  ```kt
  class T()

  fun consumeUnique(@Unique t: T) { /* ... */ }

  @Unique
  fun returnUniqueError(@Unique t: T): T {
      consumeUnique(t) // uniqueness is lost
      return t // error: 'returnUniqueError' must return a unique reference
  }

  fun borrowUnique(@Unique @Borrowed t: T) { /* ... */ }

  @Unique
  fun @receiver:Unique T.returnUniqueCorrect(): T {
      borrowUnique(this) // uniqueness is preserved
      return this // ok
  }

  fun sharedToUnique(t: T) {
      consumeUnique(t) // error: 'consumeUnique' expects a unique argument, but 't' is shared
  }
  ```
)

=== Class annotations

Classes can have their properties annotated as `Unique`. Annotations on properties define their uniqueness at the beginning of a method. However, a property annotated as `Unique` might not be unique in practice. In fact, for a property to be truly unique, it’s necessary that both the property itself is annotated as `Unique` and that the object owning the property is also unique. This concept applies recursively to nested properties.

For example, in @kt-uniqueness-class, even though the property `x` of the class `A` is annotated as `Unique`, `a1.x` is shared because `a1`, the owner of property `x`, is shared.

It is important to note that properties with primitive types do not need to be annotated.

#figure(
  caption: "Uniqueness annotations usage on Kotlin classes",
  ```kt
  class T()

  class A(
      @property:Unique var x: T,
      var y: T,
  )

  fun borrowUnique(@Unique @Borrowed t: T) {}

  fun f(@Unique uniqueA: A, sharedA: A) {
      borrowUnique(uniqueA.x) // ok: both 'uniqueA' and property 'x' are unique
      borrowUnique(uniqueA.y) // error: 'uniqueA.y' is not unique since property 'y' is shared
      borrowUnique(sharedA.x) // error: 'sharedA.x' is not unique since 'sharedA' is shared
  }
  ```
)<kt-uniqueness-class>

=== Uniqueness and assignments

The uniqueness system handles assignments similarly to Alias Burying @boyland2001alias. Specifically, once a unique reference is read, it cannot be accessed again until it has been reassigned. This approach allows for the formulation of the following uniqueness invariant: "A unique reference is either `null` or points to an object as the only accessible reference to that object."

#figure(
  caption: "Uniqueness behaviour with assignments in Kotlin",
  ```kt
  class T()
  class A(@property:Unique var t: T?)

  fun borrowUnique(@Unique @Borrowed t: T?) {}

  fun incorrectAssignment(@Unique a: A) {
      val temp = a.t // 'temp' becomes unique, but 'a.t' becomes inaccessible
      borrowUnique(a.t) // error: 'a.t' cannot be accessed
  }

  fun correctAssignment(@Unique a: A) {
      val temp = a.t // 'temp' becomes unique, but 'a.t' becomes inaccessible
      borrowUnique(temp) // ok
      a.t = null // 'a.t' is unique again
      borrowUnique(a.t) // ok
  }
  ```
)

=== Stack example

To conclude the overview of the uniqueness system, a more complex example is provided in @kt-stack. This example shows the implementation of an alias-free stack, a common illustration in the literature for showcasing uniqueness systems in action @aldrich2002alias @zimmerman2023latte. The next chapter will formally prove the correctness of this example.

#figure(
  caption: "Stack implementation with uniqueness annotations",
  ```kt
  class Node(
      @property:Unique var value: Any?,
      @property:Unique var next: Node?,
  )

  class Stack(@property:Unique var root: Node?)

  fun @receiver:Borrowed @receiver:Unique Stack.push(@Unique value: Any?) {
      val r = this.root
      this.root = Node(value, r)
  }

  @Unique
  fun @receiver:Borrowed @receiver:Unique Stack.pop(): Any? {
      val value: Any?
      if (this.root == null) {
          value = null
      } else {
          value = this.root!!.value
          this.root = this.root!!.next
      }
      return value
  }
  ```
)<kt-stack>

== Improvents to the language

=== Contracts verification


// example of contracts usage

// example of improvement in verification of contracts

=== Smart cast

// In the stack example, unsafe cast can be smart cast

=== Function optimiztion (modify lists implace)
=== Garbage collection in Kotlin native