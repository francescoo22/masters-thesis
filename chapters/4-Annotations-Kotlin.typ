#pagebreak(to:"odd")
= Uniqueness in Kotlin<cap:annotations-kt>

This chapter introduces a uniqueness system for Kotlin that takes inspiration from the systems described in @cap:control-alias-unique. The following subsections provide an overview of this system, with formal rules defined in @cap:annotation-system.

== Overview

The uniqueness system introduces two annotations, as shown in @kt-annotations. The `Unique` annotation can be applied to class properties, as well as function receivers, parameters, and return values. In contrast, the `Borrowed` annotation can only be used on function receivers and parameters. These are the only annotations the user needs to write, annotations for local variables are inferred.

Generally, a reference annotated with `Unique` is either `null` or the sole accessible reference to an object. Conversely, if a reference is not unique, there are no guarantees about how many accessible references exist to the object. Such references are referred to as shared.

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

=== Function Annotations

The system allows annotating the receiver and parameters of a function as `Unique`. It is also possible to declare that a function's return value is unique by annotating the function itself. When a receiver or parameter is annotated with `Unique`, it imposes a restriction on the caller, that must pass a unique reference, and provides a guarantee to the callee, ensuring that it has a unique reference at the begin of its execution. Conversely, a return value annotated with `Unique` guarantees to the caller that the function will return a unique object and imposes a requirement on the callee to return a unique object.

Additionally, function parameters and receivers can be annotated as `Borrowed`. This imposes a restriction on the callee, which must ensure that no further aliases are created, and guarantees to the caller that passing a unique reference will preserve its uniqueness. On the other hand, if a unique reference is passed to a function without borrowing guarantees, the variable becomes inaccessible to the caller until it is reassigned.

#figure(
  caption: "Uniqueness annotations usage on Kotlin functions",
  ```kt
  class T()

  fun consumeUnique(@Unique t: T) { /* ... */ }

  @Unique
  fun returnUniqueError(@Unique t: T): T {
      consumeUnique(t) // uniqueness is lost
      return t // error: 'returnUniqueError' must return a unique reference
  }

  fun borrowUnique(@Unique @Borrowed t: T) { /* ... */ }
  fun borrowShared(@Borrowed t: T) { /* ... */ }

  @Unique
  fun returnUniqueCorrect(@Unique t: T): T {
      borrowUnique(t) // uniqueness is preserved
      borrowShared(t) // uniqueness is preserved
      return t // ok
  }

  fun sharedToUnique(t: T) {
      consumeUnique(t) // error: 'consumeUnique' expects a unique argument, but 't' is shared
  }
  ```
)

=== Class Annotations

Classes can have their properties annotated as `Unique`. Annotations on properties define their uniqueness at the beginning of a method. However, despite the annotation, a property marked as `Unique` may still be accessible through multiple paths. For a property to be accessible through a single path, both the property and the object owning it must be annotated as `Unique`. This principle also applies recursively to nested properties, where the uniqueness of the entire chain of ownership is necessary to ensure single-path access.
For example, in @kt-uniqueness-class, even though the property `x` of the class `A` is annotated as `Unique`, `sharedA.x` is shared because `sharedA`, the owner of property `x`, is shared.

Moreover, properties with primitive types do not need to be annotated.
This is because, unlike objects, primitive types are copied rather than referenced, meaning that each variable holds its own independent value. Therefore, the concept of uniqueness, which is designed to manage the sharing and mutation of objects in memory, does not apply to primitive types. They are always unique in the sense that each instance operates independently, and there is no risk of aliasing or unintended side effects through shared references.

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

=== Uniqueness and Assignments

The uniqueness system handles assignments similarly to Boyland's system @boyland2001alias. Specifically, once a unique reference is read, it cannot be accessed again until it has been reassigned. However, passing a reference to a function expecting a `Borrowed` argument does not count as reading, since borrowing ensures that no further aliases are created during the function's execution. This approach allows for the formulation of the following uniqueness invariant: "A unique reference is either `null` or points to an object as the only accessible reference to that object."

#figure(
  caption: "Uniqueness behavior with assignments in Kotlin",
  ```kt
  class T()
  class A(@property:Unique var t: T?)

  fun borrowUnique(@Unique @Borrowed t: T?) {}

  fun incorrectAssignment(@Unique a: A) {
      val temp = a.t // 'temp' becomes unique, but 'a.t' becomes inaccessible
      borrowUnique(a.t) // error: 'a.t' cannot be accessed
  }

  fun correctAssignment(@Unique a: A) {
      borrowUnique(a.t) // ok, 'a.t' remains accessible
      val temp = a.t // 'temp' becomes unique, but 'a.t' becomes inaccessible
      borrowUnique(temp) // ok
      a.t = null // 'a.t' is unique again
      borrowUnique(a.t) // ok
  }
  ```
)

== Benefits of Uniqueness

The uniqueness annotations that have been introduced can bring several benefits to the language.

=== Formal Verification

The main goal of introducing the concept of uniqueness in Kotlin is to enable the verification of interesting functional properties. For example, it might be interesting to prove the absence of `IndexOutOfBoundsException` in a function. However, the lack of aliasing guarantees within a concurrent context in Kotlin can complicate such proofs @KotlinDocsConcurrency, even for relatively simple functions like the one shown in @out-of-bound.  In this example, the following scenario could potentially lead to an `IndexOutOfBoundsException`:
- The function executes `xs.add(x)`, adding an element to the list `xs`.
- Concurrently, another function with access to an alias of `xs` invokes the `clear` method, emptying the list.
- Subsequently, `xs[0]` is called on the now-empty list, raising an `IndexOutOfBoundsException`.
Uniqueness, however, offers a solution by providing stronger guarantees. If `xs` is unique, there are no other accessible references to the same object, which simplifies proving the absence of `IndexOutOfBoundsException`.

#figure(
  caption: "Function using a mutable list",
  ```kt
fun <T> f(xs: MutableList<T>, x: T) : T {
    xs.add(x)
    return xs[0]
}
  ```
)<out-of-bound>

Moreover, the concept of uniqueness can significantly facilitate the process of encoding Kotlin programs into Viper. Uniqueness guarantees that a reference to an object is exclusive, meaning there are no other accessible references to it.
This characteristic aligns well with Viper's notion of write access. In Viper, write access refers to a situation where a reference is guaranteed to be inaccessible to any other part of the program outside the method performing the write operation. This guarantee allows Viper to perform rigorous formal verification since it can assume that no external factors will alter the reference while it is being used.

=== Smart Casts

As introduced in @cap:smart-cast, smart casts are an important feature in Kotlin that allow developers to avoid using explicit cast operators under certain conditions. However, the compiler can only perform a smart cast if it can guarantee that the cast will always be safe @KotlinSpec. 
This guarantee relies on the concept of stability: a variable is considered stable if it cannot change after being checked, allowing the compiler to safely assume its type throughout a block of code.
Since Kotlin allows for concurrent execution, the compiler cannot perform smart casts when dealing with mutable properties. The reason is that after checking the type of a mutable property, another function running concurrently may access the same reference and change its value. @smart-cast-error, shows that after checking that `a.valProperty` is not `null`, the compiler can smart cast it from `Int?` to `Int`. However, the same operation is not possible for `a.varProperty` because, immediately after checking that it is not `null`, another function running concurrently might set it to `null`.
Guarantees on the uniqueness of references can enable the compiler to perform more exhaustive analysis for smart casts. When a reference is unique, the uniqueness system ensures that there are no accessible aliases to that reference, meaning it is impossible for a concurrently running function to modify its value. @smart-cast-unique shows the same example as before, but with the function parameter being unique. Since `a` is unique, it is completely safe to smart cast `a.varProperty` from `Int?` to `Int` after verifying that it is not null.

#figure(
  caption: "Smart cast error caused by mutability",
  ```kt
class A(var varProperty: Int?, val valProperty: Int?)

fun useSharedA(a: A): Int {
    return when {
        a.valProperty != null -> a.valProperty // smart cast
        a.varProperty != null -> a.varProperty // compilation error
        else -> 0
    }
}
  ```
)<smart-cast-error>

#figure(
  caption: "Smart cast enabled thanks to uniqueness",
  ```kt
class A(var varProperty: Int?, val valProperty: Int?)

fun useUniqueA(@Unique @Borrowed a: A): Int {
    return when {
        a.valProperty != null -> a.valProperty // smart cast to Int
        a.varProperty != null -> a.varProperty // smart cast to Int
        else -> 0
    }
}
  ```
)<smart-cast-unique>

=== Optimizations

Uniqueness can also optimize functions in certain circumstances, particularly when working with data structures like lists. In the Kotlin standard library, functions that manipulate lists, such as `filter`, `map`, and `reversed`, typically create a new list to store the results of the operation. For instance, as shown in @manipulate-list, the `filter` function traverses the original list, selects the elements that meet the criteria, and stores these elements in a newly created list. Similarly, `map` generates a new list by applying a transformation to each element, and `reversed` produces a new list with the elements in reverse order.

While this approach ensures that the original list remains unchanged, it also incurs additional memory and processing overhead due to the creation of new lists. However, when the uniqueness of a reference to the list is guaranteed, these standard library functions could be optimized to safely manipulate the list in place. This means that instead of creating a new list, the function would modify the original list directly, significantly improving performance by reducing memory usage and execution time.

#figure(
  caption: "List manipulation example",
  ```kt
fun manipulateList(xs: List<Int>): List<Int> {
    return xs.filter { it % 2 == 0 }
        .map { it + 1 }
        .reversed()
}
  ```
)<manipulate-list>

== Stack Example<cap:kt-stack>

To conclude the overview of the uniqueness system, a more complex example is provided in @kt-stack. The example shows the implementation of an alias-free stack, a common illustration in the literature for showcasing uniqueness systems in action @aldrich2002alias @zimmerman2023latte. 
It is interesting to note that having a unique receiver for the `pop` function allows to safely smart cast `this.root` from `Node?` to `Node` (Lines 19-20); this would not be allowed without uniqueness guarantees since `root` is a mutable property.

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
          value = this.root.value
          this.root = this.root.next
      }
      return value
  }
  ```
)<kt-stack>