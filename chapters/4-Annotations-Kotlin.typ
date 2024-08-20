#pagebreak(to:"odd")
= Uniqueness in Kotlin<cap:annotations-kt>

This chapter introduces a uniqueness system for Kotlin that takes inspiration from the systems described in @cap:control-alias-unique. The following subsections provide an overview of this system, with formal rules defined in @cap:annotation-system.

== Overview

The uniqueness system introduces two annotations, as shown in @kt-annotations. The `Unique` annotation can be applied to class properties, as well as function receivers, parameters, and return values. In contrast, the `Borrowed` annotation can only be used on function receivers and parameters.

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

The system allows annotating the receiver and parameters of a function as `Unique`. It is also possible to declare that a function's return value is unique by annotating the function itself. When a receiver or parameter is annotated with `Unique`, it imposes a restriction on the caller, that must pass a unique reference, and provides a guarantee to the callee, ensuring that it has a unique reference at the start of its execution. Conversely, a return value annotated with `Unique` guarantees to the caller that the function will return a unique object and imposes a requirement on the callee to return a unique object.

Additionally, function parameters and receivers can be annotated as `Borrowed`. This imposes a restriction on the callee, which must ensure that no further aliases are created, and guarantees to the caller that passing a unique reference will preserve its uniqueness.

// TODO: better example? or in the body section
#figure(
  caption: "Uniqueness annotations for a function in Kotlin",
  ```kt
  @Unique // the returned value is unique
  fun @receiver:Unique T.f(
      @Borrowed x: T,
      @Unique @Borrowed y: T,
      z: T,
  ): T {
      // ...
  }
  ```
)

=== Class annotations

Classes can have their properties annotated as `Unique`. Annotations on properties define their uniqueness at the beginning of a method. However, a property annotated as `Unique` might not be unique in practice. In fact, for a property to be truly unique, it’s necessary that both the property itself is annotated as `Unique` and that the object owning the property is also unique. This concept applies recursively to nested properties.

For example, in @kt-uniqueness-class, even though the property `x` of the class `A` is annotated as `Unique`, `a1.x` is shared because `a1`, the owner of property `x`, is shared.

It is important to note that properties with primitive types do not need to be annotated.

#figure(
  caption: "Uniqueness annotations for a class in Kotlin",
  ```kt
  class T()

  class A(
      @property:Unique var x: T,
      var y: T,
  )

  fun f(a1: A, @Unique a2: A) {
      // a1.x is shared
      // a1.y is shared
      // a2.x is unique
      // a2.y is shared
  }
  ```
)<kt-uniqueness-class>

=== Annotatations on the Body

- context
- tutto inferito (correttezza non parte di questo lavoro)
- uniqueness si puo perdere

== Examples of Aliasing control in Kotlin

// TODOs

// - Stack example, dire che e' esempio noto in letteratura (poi sarebbe da fare anche nel capitolo dopo)

// since it's popular to have this example (latte, aliasJava)
// maybe it's better to have this in the end of chapter 5

// TODO here and in chapter 5 (maybe also 6) the axample can be simplified. There are some assignments that are useless.

#figure(
  caption: "TODO",
  ```kt
  class Node(
      @property:Unique var value: Any?,
      @property:Unique var next: Node?,
  )

  class Stack(@property:Unique var root: Node?)

  fun @receiver:Borrowed @receiver:Unique Stack.push(@Unique value: Any?) {
      val r = this.root
      val n = Node(value, r)
      this.root = n
  }

  @Unique
  fun @receiver:Borrowed @receiver:Unique Stack.pop(): Any? {
      val value: Any?
      if (this.root == null) {
          value = null
      } else {
      // Note: here is possible to smart cast 'this.root' from Node? to Node
          value = this.root.value
      // Note: here is possible to smart cast 'this.root' from Node? to Node
          val next = this.root.next
          this.root = next
      }
      return value
  }
  ```
)

== Improvents to the language

=== Contracts verification


// example of contracts usage

// example of improvement in verification of contracts

=== Smart cast
=== Function optimiztion (modify lists implace)
=== Garbage collection in Kotlin native