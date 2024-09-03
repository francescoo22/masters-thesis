#import "../config/utils.typ": *
#pagebreak(to:"odd")
= Background<cap:background>

// IMPROVE: symbols for code that compiles vs code that doesn't?

== Kotlin

Developed by JetBrains, Kotlin @KotlinSpec @Kotlin is an open-source, statically typed programming language that gained popularity in recent years, particularly in the field of Android software development. It shares many similarities with Java and it can fully interoperate with it. Additionally, Kotlin introduces a range of modern features, including improved type inference, support for functional programming, null-safety, and smart-casting, making it an attractive option for developers.

The following sections will present the features of the language that are more relevant for this work.

=== Mutability vs Immutability

In programming languages, mutability refers to the capability to alter the value of a variable after it has been initialized. In Kotlin, variables and fields can be either mutable or immutable. Mutable elements are defined using the `var` keyword, while immutable elements are defined using the `val` keyword. Mutable variables or fields, once assigned, can have their values changed during the execution of the program. In contrast, immutable elements, once assigned a value, cannot be altered subsequently. For instance, `var x = 5` allows to change the value of `x` later in the program, while `val y = 5` keeps `y` consistently at the value of `5` throughout the program's execution. This clear distinction between `val` and `var` is particularly useful in a multithreaded environment since it helps to prevent race conditions and data inconsistencies.

=== Smart Casts<cap:smart-cast>

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

However, there are instances in which a `NullPointerException` can be raised in Kotlin. These include explicit calls to `throw NullPointerException()`, performing unsafe (non-smart) casts, and during Java interoperation.

=== Properties

As mentioned before, properties in Kotlin can be declared as either mutable or read-only. While the initializer, getter, and setter for a property are optional, the property's type can also be omitted if it can be inferred from the initializer or the getter's return type.
Kotlin does not allow direct declaration of fields. Instead, fields are implicitly created as part of properties to store their values in memory. When a property requires a backing field, Kotlin automatically provides one. This backing field can be accessed within the property's accessors using the `field` identifier.
A backing field is generated under two conditions: if the property relies on the default implementation of at least one accessor, or if a custom accessor explicitly references the backing field via the `field` identifier.

#figure(
  caption: "Kotlin properties",
  ```kt
  class Square {
      var width = 1 // initializer
          set(value) { // setter
              if (value > 0) field = value // accessing backing field
              else throw IllegalArgumentException(
                  "Square size must be greater than 0"
              )
          }
      val area
          get() = width * width // getter
  }
  ```
)

=== Contracts

Kotlin contracts are an experimental feature introduced in Kotlin 1.3 designed to provide additional guarantees about code behavior, helping the compiler in performing more precise analysis and optimizations. Contracts are defined using a special contract block within a function, describing the relationship between input parameters and the function's effects. This can include conditions such as whether a lambda is invoked or if a function returns under certain conditions. By specifying these relationships, contracts provide guarantees to the caller of a function, offering the compiler additional information that enable more advanced code analysis.

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

=== Annotations

Annotations provide a way to associate metadata with the code. To declare annotations, the `annotation` modifier should be placed before a class declaration.
It is also possible to specify additional attributes by using meta-annotations on the annotation class. For instance, `@Target` specifies the types of elements that can be annotated.

@kt-annotations-example illustrates how to declare and use a custom annotation (Lines 1-13) alongside existing annotations such as `@Deprecated` and `@SinceKotlin`.

#figure(
  caption: "Example of annotations usage",
  ```kt
  @Target(
      AnnotationTarget.CLASS,
      AnnotationTarget.FUNCTION,
      AnnotationTarget.VALUE_PARAMETER
  )
  annotation class MyAnnotation

  @MyAnnotation
  class MyClass {
      @MyAnnotation
      fun myFun(@MyAnnotation foo: Int) {
      }
  }

  @Deprecated(
      message = "Use newFunction() instead",
      replaceWith = ReplaceWith("newFunction()"),
  )
  fun oldFunction() { /* ... */ }

  @SinceKotlin(version = "1.3")
  fun newFunction() { /* ... */ }
  ```
)<kt-annotations-example>

== Aliasing and Uniqueness<cap:aliasing>

Aliasing refers to the situation where a data location in memory can be accessed through different symbolic names in the program. Thus, changing the data through one name inherently leads to a change when accessed through the other name as well. This can happen due to several reasons such as pointers, references, multiple arrays pointing to the same memory location etc.

In contrast, uniqueness @uniqueness-logic @An-Entente-Cordiale ensures that a particular data location is accessible through only one symbolic name at any point in time. This means that no two variables or references point to the same memory location, thus preventing unintended side effects when data is modified. A data location that is accessible by exactly one reference is said to be unique;  similarly, the reference pointing to that data location is also termed unique.

Uniqueness can be particularly important in concurrent programming paradigms, where the goal is often to avoid mutable shared state to ensure predictability and maintainability of the code @bocchino2013alias. By enforcing uniqueness, programmers can guarantee that data modifications are localized and do not inadvertently affect other parts of the program, making reasoning about program behavior and correctness more straightforward.

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

Although aliasing is essential in object-oriented programming as it allows programmers to implement designs involving sharing, as described in The Geneva Convention @GenevaConvention, aliasing can be a problem in both formal verification and practical programming.

The example in @alias-verification illustrates how aliasing between references can complicate the formal verification process. In the given example, a class `A` is declared with a boolean field `x`, followed by the function `f` which accepts two arguments `a1` and `a2` of type `A`. The function assigns `true` to `a1.x`, `false` to `a2.x`, and finally returns `a1.x`. Despite the function being straightforward, we cannot assert that the function will always return `true`. The reason for this uncertainty is the potential aliasing of `a1` and `a2`, as the second assignment might change the value of `a1.x` as well.

Modern programming languages frequently utilize a high degree of concurrency, which can further complicate the verification process. As shown in @alias-verification-concurrent, even a simpler function than its counterpart in @alias-verification does not permit to assert that it will always return `true`. In this instance, the function only takes a single argument `a` of type `A`, assigns `true` to `a.x` and eventually returns it. However, within a concurrent context there may exist another thread with access to a variable aliasing `a` that can modify `a.x` to `false` prior to the function's return, thus challenging the verification process.

@alias-bug presents a contrived example to illustrate how aliasing can lead to mysterious bugs. Function `f` takes two lists `xs` and `ys` as arguments. If both lists are not empty, the function removes the last element from each. One might assume this function will never raise an `IndexOutOfBoundsException`. However, if `xs` and `ys` are aliased and have a size of one, this exception will occur.

Moving to a more realistic example, @alias-custom-assign shows a reasonable C++ implementation of the assignment operator overloading for a vector. 
Since C++ does not have built-in mechanisms to control aliasing statically, in this implementation, the assignment operator must explicitly address the possibility of aliasing between the `this` pointer and the `&other` pointer (Lines 9-11). If these two pointers are found to be identical, indicating that the object is being assigned to itself, the operation is immediately terminated to prevent any unnecessary operations. Failing to properly manage this aliasing could lead to significant issues, such as data corruption or unintended behavior, because the operator might inadvertently delete the data before copying, thereby causing the object to lose its original state. 

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

#figure(
  caption: "Aliasing handling in vector assignment operator overloading",
  ```cpp
  class Vector {
  private:
      int* data;
      size_t size;
  public:
      // other code here...

      Vector& operator=(const Vector& other) {
          if (this == &other) {
              return *this;
          }
          
          delete[] data;
          size = other.size;
          data = new int[size];
          std::memcpy(data, other.data, size * sizeof(int));
          return *this;
      }

      // other code here...
  }
  ```
)<alias-custom-assign>

== Separation Logic

$
angle.l "assert" angle.r &::= \
&| "emp" &&& "empty heap" \
&| angle.l "exp" angle.r |-> angle.l "exp" angle.r &&& "singleton heap" \
&| angle.l "assert" angle.r * angle.l "assert" angle.r &&& "separating conjunction" \
&| angle.l "assert" angle.r "−∗" angle.l "assert" angle.r #h(5em) &&& "separating implication" \
$

Separation logic @separationLogic1 @separationLogic2 @separationLogic3 is an extension of first-order logic that can be used to reason about low-level imperative programs that manipulate pointer data structures by integrating it in Hoare's triples.

The core concept of separation logic is the separating conjunction $P ∗ Q$, which asserts that $P$ and $Q$ hold for different, non-overlapping parts of the heap. For instance, if a change to a single heap cell affects $P$ in $P ∗ Q$, it is guaranteed that it will not impact $Q$. This feature eliminates the need to check for possible aliases in $Q$. On a broader scale, the specification ${P} space C space {Q}$ for a heap modification can be expanded using a rule that allows to derive ${P ∗ R} space C space{Q ∗ R}$, indicating that additional heap cells remain untouched. This enables the initial specification ${P} space C space{Q}$ to focus solely on the cells involved in the program's footprint.

Separation logic also includes other assertions: `emp` indicates that the heap is empty, $e_1 |-> e_2$ specifies that the heap contains a cell at address $e_1$ with the value $e_2$, and $a_1 "−∗" a_2$ asserts that extending the current heap with a disjoint part where $a_1$ holds will result in a heap where $a_2$ holds.

#example[
  The following formula is derivable in separation logic:
  $ {(x |-> -) * ((x |-> 1) "−∗" P)} space x := 1 space {P} $
]

== Viper

Viper @ViperWebSite @Viper (Verification Infrastructure for Permission-based Reasoning) is a language and suite of tools developed by ETH Zurich designed to aid in the creation of verification tools.
The Viper infrastructure (@vpr-infrastructure) consists of the Viper intermediate language and two different back-ends: one that uses symbolic execution and another that relies on verification condition generation.

The verification process with Viper follows several steps.
First, a higher-level programming language is translated into Viper's intermediate language, which incorporates permission-based reasoning to manage and express ownership of memory locations, similar to separation logic.

After translation, Viper uses one of its back-ends and an SMT solver to verify the conditions expressed in the Viper language @eilers2024verification. The back-ends are designed to automate the verification process as much as possible, allowing tool developers and users to focus on the verification task itself without needing to comprehend the inner behavior of the back-ends


#figure(
  caption: [The Viper verification infrastructure @ViperWebSite],
  image("../images/viper.png", width: 80%)
)<vpr-infrastructure>

=== Language Overview

The Viper intermediate language is a sequential, object-based language that provides simple imperative constructs along with specifications and custom statements for managing permission-based reasoning.

In Viper, methods can be seen as an abstraction over a sequence of operations. The caller of a method observes its behavior solely through the method's signature and its preconditions and postconditions. This allows Viper to perform a method-modular verification, avoiding all the complexities associated with interprocedural analysis.

#figure(
  caption: "Viper method example",
  ```vpr
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
@vpr-permissions-1 shows how a method can require field permissions in its preconditions (Line 4) and ensure that these permissions will still be valid when returning to the caller (Line 5).

#figure(
  caption: "Viper permissions example",
  ```vpr
  field b: Bool

  method negate(this: Ref)
  requires acc(this.b)
  ensures acc(this.b)
  {
    this.b := !this.b
  }
  ```
)<vpr-permissions-1>

As well as being declared in preconditions and postconditions, field permissions can also be obtained within a method's body. The operation that allows to gain permissions is called inhaling and can be seen in @vpr-permissions-2 (Line 3). The opposite operation is called exhaling and enables to drop permissions.
@vpr-permissions-2 also allows to notice how access permissions that has been seen until now are exclusive. In fact, the assertion `acc(x.b) && acc(y.b)` is similar to a separating conjunction in separation logic and so inhaling that assertion implies that `x != y`. This is confirmed by the fact that the statement at Line 6 can be verified.

#figure(
  caption: "Viper exclusivity example",
  ```vpr
  field b: Bool

  method exclusivity(x: Ref, y: Ref)
  {
    inhale acc(x.b) && acc(y.b)
    assert x != y
    x.b := true
    y.b := true
  }
  ```
)<vpr-permissions-2>

Sometimes, exclusive permissions can be too restrictive. Viper also allows to have fractional permissions for heap locations that can be shared but only read. Fractional permissions are declared with a permission amount between 0 and 1 or with the `wildcard` keyword.
The value represented by a `wildcard` is not constant, instead it is reselected each time an expression involving a `wildcard` is identified. 
The wildcard permission amount provides a convenient way to implement duplicable read-only resources, which is often suitable for the representation of immutable data. The example in @vpr-fractional shows how fractional permissions can be combined to gain full permissions (Line 6-7). In the same example it is also possible to see that Viper does not allow to have a permission amount greater than 1, in fact, since `wildcard` is an amount grater than 0, a situation in which `x == y == z` is not possible and so the assertion on Line 9 can be verified.

#figure(
  caption: "Viper fractional permissions example",
  ```vpr
  field b: Bool
  
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

Similar to predicates, functions in Viper are used to define parameterized and potentially recursive assertions. The body of a function must be an expression, ensuring that the evaluation of a function is side-effect free, just like any other Viper expression. Unlike methods, Viper reasons about functions based on their bodies, so it is not necessary to specify postconditions when the function body is provided. In @vpr-predicate (Lines 11-15), a function is first used to represent the size of a `List`, and then is utilized in the preconditions of the `get_second` method (Line 19).

#figure(
  caption: "Viper predicate example",
  ```vpr
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


  method get_second(xs: Ref) returns(res: Int)
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

=== Domains
Domains allow the creation of custom types, mathematical functions, and axioms that define their properties.

The functions defined within a domain are accessible globally across the Viper program. These are known as domain functions, and they have more limitations compared to standard Viper functions. Domain functions cannot have preconditions and can be used in any program state. They are also always abstract, meaning that they cannot have an implemented body. To give meaning to these abstract functions, domain axioms are used.

Domain axioms are also global and define properties that are assumed to be true in all states. Typically, they are expressed as standard first-order logic assertions.

#figure(
  caption: "Viper domain example",
  ```vpr
  domain Fraction {
    function nominator(f: Fraction): Int
    function denominator(f: Fraction): Int
    function create_fraction(n: Int, d: Int): Fraction
    function multiply(f1: Fraction, f2: Fraction): Fraction
    
    axiom axConstruction {
      forall f: Fraction, n: Int, d: Int ::
        f == create_fraction(n, d) ==> 
          nominator(f) == n && denominator(f) == d
    }

    axiom axMultiply {
      forall f1: Fraction, f2: Fraction, res: Fraction ::
        res == multiply(f1, f2) ==> 
          (nominator(res) == nominator(f1) * nominator(f2)) &&
          (denominator(res) == denominator(f1) * denominator(f2))
    }
  }

  method m(x: Int)
  {
    var f: Fraction
    f := create_fraction(x, 2)
    assert nominator(f) == x
    assert denominator(f) == 2
    
    var f_sq: Fraction
    f_sq := multiply(f, f)
    assert nominator(f_sq) == x * x
    assert denominator(f_sq) == 4
  }
  ```
)