#pagebreak(to:"odd")
= Background<cap:background>

// TODO: symbols for code that compiles vs code that doesn't?

== Kotlin

Developed by JetBrains, Kotlin @Kotlin @KotlinSpec is an open-source, statically typed programming language that gained popularity in recent years especially in the Android software development ﬁeld. Kotlin shares many similarities with Java and can fully interoperate with it. Notably, Kotlin also introduces several features that are absent in Java, such as improved type inference, functional programming, null-safety, and smart-casting.

The following sections will present the features of the language that are more relevant for this work.

=== Mutable vs Immutable Variables

In programming languages, mutability refers to the capability to alter the value of a variable after it has been initialized. Variables in Kotlin are either mutable, defined using the `var` keyword, or immutable, defined using the `val` keyword. Mutable variables, once assigned, can have their value changed during the execution of the program, while immutable variables, once assigned a value, cannot be altered subsequently. For instance, `var x = 5` allows you to change the value of `x` later in the program, while `val y = 5` maintains `y` at a value of 5 throughout the program. Mutability is a fundamental principle in programming, and Kotlin's clear distinction between `val` and `var` improves code readability and helps in maintaining data consistency, especially in a multithreaded environment.

=== Functional Programming

In Kotlin, functions are considered first-class citizens. This implies that, like any other data type, they can be assigned to variables, can be incorporated into data structures, can be passed into other higher-order functions as arguments and can even be returned from such functions. Essentially, functions in Kotlin are as manipulable as any other non-functional values. 

#figure(
  caption: "Kotlin higher-order function",
  ```kt
  fun <T, R> myMap(xs: List<T>, f: (T) -> R): List<R> {
      val result = mutableListOf<R>()
      for (item in xs) {
          result.add(f(item))
      }
      return result.toList()
  }

  fun main() {
      val xs = listOf(1, 2, 3)
      val ys = myMap(xs) { y -> y * 2 } // ys = [2, 4, 6]
  }
  ```
)

=== Smart Casts

In Kotlin, smart casts refer to a feature of the language that automatically handles explicit typecasting, reducing the need for manual intervention. A smart cast occurs when the compiler tracks conditions inside conditional expressions and automatically casts types if possible, eliminating the necessity for explicit casting in many scenarios. This considerably simplifies the syntax and increases readability. For example, if we perform a type check on a variable in an `if` condition, we can use that variable in its checked type within the `if` block without the requirement to explicitly cast it. An example of smart cast can be found in @smart-cast.

#figure(
  caption: "Example of smart-cast in Kotlin",
  ```kt
  open class A()
  class B : A() {
      fun f() = println("B")
  }

  fun callIfIsB(a: A) {
      if (a is B) {
          a.f()
  //      ^^^^^
  //  Smart cast to B 
      }
  }
  ```
)<smart-cast>


=== Null Safety

Kotlin's type system has been designed with the goal of eliminating the danger of null references. In many programming languages, including Java, accessing a member of a null reference results in a null reference exception. This is more difficult to happen in Kotlin since the type system distinguishes between references that can hold `null` and those that cannot, the former are called nullable references while the latter are called non-nullable reference. @kt-null-safety shows how nullable references are declared by appending a question mark to the type name and it shows that trying to assign `null` to a non-nullable reference leads to a compilation error.

#figure(
  caption: "Kotlin null safety example",
  ```kt
  var nullableString: String?
  nullableString = "abc" // ok
  nullableString = null // ok

  var nonNullableString: String
  nonNullableString = "abc" // ok
  nonNullableString = null // compilation error
  ```
)<kt-null-safety>

Accessing members of nullable reference or calling a method with a nullable reference as receiver is only allowed if the compiler can understand that the reference will never be null when one of these actions occurs. Usually, this is done with a smart cast considering that for every type `T`, its nullable counterpart `T?` is a supertype of `T`.

#figure(
  caption: "Kotlin smart cast to non-nullable",
  ```kt
  fun f(nullableString: String?) {
      if (nullableString != null) {
          // 'nullableString' is smart-casted from 'String?' to 'String'
          println(nullableString.length) // safe
          println(nullableString.isEmpty()) // safe
      }
      val n = nullableString.length // compilation error
  }
  ```
)

However, there are some cases in which a `NullPointerException` can be raised in Kotlin:
- An explicit call to `throw NullPointerException()`.
- Unsafe (non-smart) casts.
- Java interoperation.

=== Contracts

Kotlin contracts are an experimental feature introduced in Kotlin 1.3 designed to provide additional guarantees about code behavior, helping the compiler in performing more precise analysis and optimizations. Contracts are defined using a special contract block within a function, describing the relationship between input parameters and the function's effects. This can include conditions such as whether a lambda is invoked or if a function returns under certain conditions. By specifying these relationships, contracts help the compiler understand the function's logic more deeply, enabling advanced features like smart casting and better null-safety checks.

It is important to point out that currently contracts correctness is not statically verified. The compiler trusts contracts unconditionally meaning that the programmer is responsible for writing correct and sound contracts.

In @contract-1 it is possible to see how contracts allow the initialization of immutable variables within the body of a lambda, doing this is not possible without using a contract (@contract-2).

#figure(
  caption: "Example of contract declaration and usage",
  ```kt
  public inline fun <R> run(block: () -> R): R {
      contract {
          callsInPlace(block, InvocationKind.EXACTLY_ONCE)
      }
      return block()
  }

  fun main() {
    val b: Boolean
    run {
        b = true
    }
    println(b)
  }
  ```
)<contract-1>

#figure(
  caption: "Compilation error caused by the absence of contracts",
  ```kt
  fun <R> runWithoutContract(block: () -> R): R {
      return block()
  }

  fun main() {
      val b: Boolean
      runWithoutContract { b = true }
  /*                       ^^^^^^^^
      Captured values initialization is forbidden 
      due to possible reassignment       
  */
  }  
  ```
)<contract-2>

=== Annotations?

TODO: decide if it is worth to have a paragraph about kotlin's annotations.

== Aliasing

Aliasing refers to the situation where a data location in memory can be accessed through different symbolic names in the program. Thus, changing the data through one name inherently leads to a change when accessed through the other name as well. This can happen due to several reasons such as pointers, references, multiple arrays pointing to the same memory location etc.

In contrast, uniqueness ensures that a particular data location is accessed through only one symbolic name at any point in time. This means that no two variables or references point to the same memory location, thus preventing unintended side effects when data is modified. Uniqueness is particularly important in concurrent programming and in functional programming paradigms, where the goal is often to avoid mutable shared state to ensure predictability and maintainability of the code. By enforcing uniqueness, programmers can guarantee that data modifications are localized and do not inadvertently affect other parts of the program, making reasoning about program behavior and correctness more straightforward.

@aliasing shows the concept of aliasing and uniqueness practically with a Kotlin example.
The function starts by declaring and initializing variable `y` with `x`, resulting in `x` and `y` being aliased.
Following that, variable `z` is initialized with a newly-created object in the function's second line. Therefore, at this stage in the program, `z` can be referred to as "unique", signifying that it is the only reference pointing to that particular object.

#figure(
  caption: "Aliasing, an example",
  ```kt
  class T()

  fun f(x: T) {
      val y = x // 'x' and 'y' are now aliased
      val z = T() // here 'z' is unique
  }
  ```
)<aliasing>

=== Problems Caused by Aliasing

Aliasing is a topic that has been studied for decades in Computer Science @Aliasing-OOP.
Although aliasing is essential in object-oriented programming as it allows programmers to implement designs involving sharing, as described in The Geneva Convention @GenevaConvention, aliasing can be a problem in both formal veriﬁcation and practical programming.

The example in @alias-verification illustrates how aliasing between references can complicate the formal verification process. In the given example, a class `A` is declared with a boolean field `x`, followed by the function `f` which accepts two arguments `a1` and `a2` of type `A`. The function assigns `true` to `a1.x`, `false` to `a2.x`, and finally returns `a1.x`. Despite the function being straightforward, we cannot assert that the function will always return `true`. The reason for this uncertainty is the potential aliasing of `a1` and `a2`, as the second assignment might change the value of `a1.x` as well.

Modern programming languages frequently utilize a high degree of concurrency, which can further complicate the verification process. As showed in @alias-verification-concurrent, even a simpler function than its counterpart in @alias-verification does not permit to assert that it will always return `true`. In this instance, the function only takes a single argument `a` of type `A`, assigns `true` to `a.x` and eventually retruns it. However, within a concurrent context there may exist another thread with access to a variable aliasing `a` that can modify `a.x` to `false` prior to the function's return, thus challenging the verification process.

Finally, @alias-bug presents a contrived example to illustrate how aliasing can lead to mysterious bugs. Function `f` takes two lists `xs` and `ys` as arguments.If both lists are not empty, the function removes the last element from each. One might assume this function will never raise an `IndexOutOfBoundsException`. However, if `xs` and `ys` are aliased and have a size of one, this exception will occur.

// TODO: decide whether to write in the caption that the examples are written in Kotlin

#figure(
  caption: "Problems caused by aliasing in formal verification",
  ```kt
  class A(var x: Boolean)

  fun f(a1: A, a2: A): Boolean {
    a1.x = true
    a2.x = false
    return a1.x
  }
  ```
)<alias-verification>

#figure(
  caption: "Problems caused by aliasing in formal verification within a concurrent context",
  ```kt
  class A(var x: Boolean)

  fun f(a: A): Boolean {
    a.x = true
    return a.x
  }
  ```
)<alias-verification-concurrent>

#figure(
  caption: "Problems caused by aliasing in practical programming",
  ```kt
  fun f(xs: MutableList<Int>, ys: MutableList<Int>) {
      if (xs.isNotEmpty() && ys.isNotEmpty()) {
          xs.removeLast()
          ys.removeLast()
      }
  }

  fun main() {
      val xs = mutableListOf(1)
      f(xs, xs)
  }
  ```
)<alias-bug>

== Separation Logic

Separation logic @separationLogic1 @separationLogic2 @separationLogic3 is an extension of Hoare logic that allows to reason about low-level imperative programs that use shared mutable data structure.

Separation logic significantly simplifies reasoning about programs that manipulate pointer data structures. It also helps in managing principles related to the "transfer of ownership," as well as offering a virtual separation that enables modular reasoning between concurrent modules. 

$
angle.l "assert" angle.r &::= \
&| "emp" &&& "empty heap" \
&| angle.l "exp" angle.r |-> angle.l "exp" angle.r &&& "singleton heap" \
&| angle.l "assert" angle.r * angle.l "assert" angle.r &&& "separating conjunction" \
&| angle.l "assert" angle.r "−∗" angle.l "assert" angle.r #h(5em) &&& "separating implication" \
$

In particular, `emp` is an assertion used to express that the heap is empty, $e_1 |-> e_2$ states that the heap contains one cell at address $e$ containing $e_2$.
$a_1 * a_2$ asserts that it is possible to split the heap into two disjoint parts in which $a_1$ and $a_2$ hold respectively.
Finally, $a_1 "−∗" a_2$ states that, extending the current heap with a disjoint part where $a_1$ holds, will lead to a heap where $a_2$ holds.
The following example shows a derivable formula in separation logic.

$ {(x |-> -) * ((x |-> 1) "−∗" P)} space x := 1 {P} $

== Viper

Viper @ViperWebSite @Viper (Verification Infrastructure for Permission-based Reasoning) is a language and suite of tools developed by ETH Zurich that can be used for developing new verification tools.

The whole Viper infrastructure is shown in @vpr-infrastructure and is made of the Viper intermediate language and two back-ends, the first based on symbolic execution and the second based on verifcation condition generation.

The verification process using the Viper toolchain happens as follows. An higher-level language is first encoded into the Viper intermediate language which provides support to permissions natively and uses them to express ownership of heap locations in a style similar to separation logic. 
This is convenient for reasoning about programs that manipulate the heap and concurrent thread interactions. 
Viper conditions are then verified using one of the two back-ends and an SMT Solver (Z3). 
Viper back-ends aim to achieve extensive automation with the intention to avoid circumstances where tool developers and users need to comprehend the inner behaviour of the back-ends to carry out the verification process. 

// TODO: is it okay to have just the reference to the website for the image?

#figure(
  caption: "The Viper verification infrastructure",
  image("../images/viper.png", width: 80%)
)<vpr-infrastructure>

=== Language Overview

The Viper intermediate language is an object-oriented, sequential programming language. Despite being designed as an intermediary language, Viper offers high-level features that are beneficial in manually expressing verification issues, along with potent low-level features useful for automatic encoding of source languages.

In Viper, methods can be seen as an abstraction over an operation sequence, which may involve executing an unlimited number of statements. The caller of a method observes its behaviour solely through the method's signature and its preconditions and postconditions. This allows Viper to perform a method-modular verifcation, avoiding all the complexities associated with interprocedural analysis.

#figure(
  caption: "Viper method example",
  ```java
  method multiply(x: Int, y: Int) returns (res: Int)
  requires x >= 0 && y >= 0
  ensures res == x * y
  {
    res := 0
    var i: Int := 0
    while (i < x)
      invariant i <= x
      invariant res == i * y
    {
      res := res + y
      i := i + 1
    }
  }
  ```
)<ViperMultiply>

@ViperMultiply shows an example of method in Viper. It is possible to notice that the signature of the method (Line 1) declares the returned values as a list of variables. Preconditions (Line 2), postconditions (Line 3) and invariants (Lines 8-9) are the assertions subject to verification. The remaining statements are similar to most of the existing programming languages. The language is statically typed and several built-in types like `Ref`, `Bool`, `Int`, `Seq`, `Set` and others are provided.

=== Permissions

In Viper, fields are top-level declarations and, since classes do not exist in Viper, every object has all the declared fields.
Field permissions, which define the heap areas that an expression, a statement, or an assertion can access, control the reasoning of a Viper program's heap. Heap locations are only accessible if the relevant permission is under the control of the method currently being verified.
@vpr-permissions-1 shows how a method can require field permissions in its precondtions (Line 4) and ensure that these permissions will still be valid when returning to the caller (Line 5).

#figure(
  caption: "Viper permissions example",
  ```java
  field b: Bool

  method nagation(this: Ref)
  requires acc(this.b)
  ensures acc(this.b)
  {
    this.b := !this.b
  }
  ```
)<vpr-permissions-1>

As well as being declared in preconditions and postconditions, field permissions can also be obtained within a method's body. The operation that allows to gain permissions is called inhaling and can be seen in @vpr-permissions-2 (Line 3). The opposite operation is called exhaling and enables to drop permissions.
@vpr-permissions-2 also allows to notice how access permissions that has been seen until now are exclusive. In fact, the assertion `acc(x.b) && acc(y.b)` is similar to a separating conjunction in separation logic and so inhaling that assertion implies that `x != y`. This is confermed by the fact that the statement at Line 6 can be verified.

#figure(
  caption: "Viper exclusivity example",
  ```java
  method conjuntion(x: Ref, y: Ref)
  {
    inhale acc(x.b) && acc(y.b)
    x.b := true
    y.b := true
    assert x != y
  }
  ```
)<vpr-permissions-2>

Sometimes, exclusive permissions can be too restrictive. Viper also allows to have fractional permissions for heap locations that can be shared but only read. Fractional permissions are declared with a permission amount between 0 and 1 or with the `wildcard` keyword.
The value represented by a `wildcard` is not constant, instead it is reselected each time an expression involving a `wildcard` is identified. 
The wildcard permission amount provides a convenient way to implement duplicable read-only resources, which is often suitable for the representation of immutable data. The example in @vpr-fractional shows how fractional permissions can be combined to gain full permissions (Line 6-7). In the same example it is also possible to see that Viper does not allow to have a permission amount greater than 1, in fact, since `wildcard` is an amount grater than 0, a situation in which `x == y == z` is not possible and so the assertion on Line 9 can be verified.

#figure(
  caption: "Viper fractional permissions example",
  ```java
  method fractional(x: Ref, y: Ref, z: Ref)
  requires acc(x.b, 1/2)
  requires acc(y.b, 1/2)
  requires acc(z.b, wildcard)
  {
    if (x == y) {
      x.b := true
      if (x == z) {
        assert false
      }
    }
  }
  ```
)<vpr-fractional>

=== Predicates and Functions

Predicates can be seen as an abstraction tool over assertions, which can include resources like field permissions. The body of a predicate is an assertion. However, predicates are not automatically inlined. In fact, in order to substitute the predicate resource with the assertions defined by its body, it is necessary to perform an unfold operation. The opposite operation is called a fold: folding a predicate substitutes the resources determined by its core content with an instance of the predicate. Having predicates that are not automatically inlined is fundamental since it allows to represent potentially unbounded data structure as shown in @vpr-predicate (Lines 4-8) where the predicate `List` can represent a linked-list. The same example shows how unfold and fold operations can be performed to access the value of the second element of a list (Lines 22-26).

Similarly to predicates, functions are used to define parametrised and pontentially-recursive assertions.
Functions body must be an immutable expression and differently from methods, Viper reasons about function applications in terms of the function bodies, meaning that it is not always necessary to provide postconditions. In @vpr-predicate (Lines 11-15) a function is used to represent the size of a `List` and due to the immutability of its body, the function can be used in the preconditions of the method `second` (Line 19).

#figure(
  caption: "Viper predicate example",
  ```java
  field value: Int
  field next: Ref

  predicate List(this: Ref)
  {
    acc(this.value) &&
    acc(this.next) &&
    (this.next != null ==> List(this.next))
  }

  function size(xs: Ref): Int
  requires List(xs)
  {
    unfolding List(xs) in xs.next == null ? 1 : 1 + size(xs.next) 
  }


  method second(xs: Ref) returns(res: Int)
  requires List(xs) && size(xs) > 1
  ensures List(xs)
  {
    unfold List(xs)
    unfold List(xs.next)
    res := xs.next.value
    fold List(xs.next)
    fold List(xs)
  }
  ```
)<vpr-predicate>

=== TODO: Domains
Since predicates include subtype domain assertions, probably it's worth to have this paragraph.