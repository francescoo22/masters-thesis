#pagebreak(to:"odd")

= Introduction to aliasing

== Aliasing overview

Aliasing refers to the situation where a data location in memory can be accessed through different symbolic names in the program. Thus, changing the data through one name inherently leads to a change when accessed through the other name as well. This can happen due to several reasons such as pointers, references, multiple arrays pointing to the same memory location etc.

In contrast, uniqueness ensures that a particular data location is accessed through only one symbolic name at any point in time. This means that no two variables or references point to the same memory location, thus preventing unintended side effects when data is modified. Uniqueness is particularly important in concurrent programming and in functional programming paradigms, where the goal is often to avoid mutable shared state to ensure predictability and maintainability of the code. By enforcing uniqueness, programmers can guarantee that data modifications are localized and do not inadvertently affect other parts of the program, making reasoning about program behavior and correctness more straightforward.
// TODO: elaborate

== Problems caused by aliasing

Aliasing is a topic that has been studied for decades in Computer Science. Although aliasing is essential in object-oriented programming as it allows programmers to implement designs involving sharing, as described in The Geneva Convention @GenevaConvention, aliasing can be a problem in both formal veriﬁcation and practical programming.

// TODO: examples: proving, bugs, concurrency
// TODO: decide whether to use pseudo code or kotlin code here

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

// TODO: Read better these summaries and modify them (AIG)

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

// Talk about systems that enables to control alisasing

// Alias Burying, LATTE, An entante cordiale, RUST, Swift