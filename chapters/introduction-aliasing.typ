#pagebreak(to:"odd")

= Introduction to aliasing

// TODO: Read better these summaries and modify them (AIG)

== Aliasing overview

// TODO: cite book aliasing

Aliasing refers to the situation where a data location in memory can be accessed through different symbolic names in the program. Thus, changing the data through one name inherently leads to a change when accessed through the other name as well. This can happen due to several reasons such as pointers, references, multiple arrays pointing to the same memory location etc.

In contrast, uniqueness ensures that a particular data location is accessed through only one symbolic name at any point in time. This means that no two variables or references point to the same memory location, thus preventing unintended side effects when data is modified. Uniqueness is particularly important in concurrent programming and in functional programming paradigms, where the goal is often to avoid mutable shared state to ensure predictability and maintainability of the code. By enforcing uniqueness, programmers can guarantee that data modifications are localized and do not inadvertently affect other parts of the program, making reasoning about program behavior and correctness more straightforward.

@aliasing shows the concept of aliasing and uniqueness practically with a Kotlin @Kotlin example.
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

== Problems caused by aliasing

Aliasing is a topic that has been studied for decades in Computer Science. 
Although aliasing is essential in object-oriented programming as it allows programmers to implement designs involving sharing, as described in The Geneva Convention @GenevaConvention, aliasing can be a problem in both formal veriﬁcation and practical programming.

The example in @alias-verification illustrates how aliasing between references can complicate the formal verification process. In the given example, a class `A` is declared with a boolean field `x`, followed by the function `f` which accepts two arguments `a1` and `a2` of type `A`. The function assigns `true` to `a1.x`, `false` to `a2.x`, and finally returns `a1.x`. Despite the function being straightforward, we cannot assert that the function will always return `true`. The reason for this uncertainty is the potential aliasing of `a1` and `a2`, as the second assignment might change the value of `a1.x` as well.

Modern programming languages frequently utilize a high degree of concurrency, which can further complicate the verification process. As showed in @alias-verification-concurrent, even a simpler function than its counterpart in @alias-verification does not permit to assert that it will always return `true`. In this instance, the function only takes a single argument `a` of type `A`, assigns `true` to `a.x` and eventually retruns it. However, within a concurrent context there may exist another thread with access to a variable aliasing `a` that can modify `a.x` to `false` prior to the function's return, thus challenging the verification process.

Finally, @alias-bug presents a contrived example to illustrate how aliasing can lead to mysterious bugs. Function `f` takes two lists `xs` and `ys` as arguments.If both lists are not empty, the function removes the last element from each. One might assume this function will never raise an `IndexOutOfBoundsException`. However, if `xs` and `ys` are aliased and have a size of one, this exception will occur.

// TODO: decide whether to use pseudo code or kotlin code here
// TODO: put @alias-verification and @alias-verification-concurrency on the same line
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

== How to deal with aliasing

The Geneva Convention @GenevaConvention has established four primary methods to manage aliasing: Detection, Advertisement, Prevention, and Control. These methods aim to provide systematic approaches to identify, communicate, prevent, and manage aliasing in software systems.

=== Detection
Alias detection is a retrospective process that identifies potential or actual alias patterns in a program through static or dynamic techniques. This is beneficial for compilers, static analysis tools, and programmers as they can detect aliasing conflicts in programs, leads to more efficient code generation, helps find cases where aliasing can invalidate predicates, and assists programmers in resolving problematic conflicts. 

Alias detection needs a complex interprocedural analysis due to its non-local nature. It provides information about the alias relationship between two variables i.e. if they never, sometimes, or always alias the same object. Variables are said to sometimes alias, when they are aliased in some situations but not always. This information is particularly useful for optimization purposes.

=== Advertisement
Because global alias detection is impractical, it is crucial to develop methods and constructs for modular analysis. Programmers and formalists benefit from constructs that enhance local analysis by annotating methods based on their aliasing properties. Optimistic assumptions about aliasing are common, such as expecting a Boolean object's or(arg) method to return a new object rather than an aliased one, despite it being correct behavior.

Popular object-oriented languages lack means to indicate whether methods capture objects by creating persistent access paths. Annotations indicating which object bindings are captured by a method and which aliases a method can handle could function similarly to const in C++, offering useful behavioral specifications.

For instance, qualifying a parameter with uncaptured would indicate that the object is not bound to a variable that could be modified through side channels after the method returns. A method like or might declare that both self and arg are const and uncaptured, and the return variable is also uncaptured.

Methods could also be advertised with preconditions like noalias, indicating that actual arguments should not be aliased, a restriction common in Turing. The pattern of const, noalias, and uncaptured operands and results mirrors "pure" functions, enhancing reasoning about program behavior. Enforcing such qualifiers leads to effective alias prevention.

=== Prevention

Alias prevention techniques introduce constructs that ensure aliasing does not occur in specific contexts, enabling static checkability by compilers and program analyzers. However, this requires conservative definitions, which may restrict valid uses that are not syntactically safe. For instance, checkable constructs like "uncaptured" and "noalias" may overly limit variable bindings and changes within collections, respectively.

Conservatism ensures validity but may prevent valid formulas from being provable and safe code from compiling without errors. Therefore, fine-grained alias prevention constructs have limited utility, necessitating higher-level constructs.

One such higher-level construct is "islands," which isolate groups of related objects, preventing static references across their boundaries. This allows scalable aliasing control within these isolated groups.

A more radical approach replaces the traditional assignment operator with a swapping operator, eliminating reference copying and thus avoiding aliasing issues. However, this requires a different programming paradigm, which may not integrate well with mainstream object-oriented techniques.


=== Control

Aliasing prevention alone is insufficient because aliasing is unavoidable in conventional object-oriented programming. Aliasing control is necessary to ensure the system does not reach a state with unexpected aliasing, which requires analysis of the runtime state.

== Existing systems

In recent decades, extensive research has been conducted to address the issue of aliasing. The book "Aliasing in Object-Oriented Programming" @Aliasing-OOP provides a comprehensive survey of the latest techniques for managing aliasing in object-oriented programming. The following subsections will discuss the most relevant techniques for this work in detail.

=== Alias Burying
@boyland2001alias

=== LATTE
@zimmerman2023latte

=== aliasJava
@aldrich2002alias

=== An entante cordiale
@An-Entente-Cordiale

=== RUST, Swift