#pagebreak(to:"odd")
= Related Work<cap:related-work>

== The Geneva Convention

The Geneva Convention @GenevaConvention examines the issues related to aliasing management in object-oriented programming languages.

The paper has established four primary methods to manage aliasing: Detection, Advertisement, Prevention, and Control. These methods aim to provide systematic approaches to identify, communicate, prevent, and manage aliasing in software systems.

=== Detection

Alias detection is a retrospective process that identifies potential or actual alias patterns in a program through static or dynamic techniques. This is beneficial for compilers, static analysis tools, and programmers as they can detect aliasing conflicts in programs, leads to more efficient code generation, helps find cases where aliasing can invalidate predicates, and assists programmers in resolving problematic conflicts.

Alias detection requires complex interprocedural analysis due to its non-local nature, which can make comprehensive analyses too slow to be practical.

=== Advertisement

Given the impracticality of global detection, it is essential to create techniques and constructs that enable a more modular approach to analysis. Constructs that improve the locality of analysis by annotating methods based on their resulting aliasing behaviors can be useful for both programmers and formalists.

One example of this concept is to specify that the output of a function is not aliased anywhere else in the program, signifying that it is unique. Additionally, an "uncaptured" qualifier could state that an object is never assigned to a variable that might lead to further modifications through side channels once the method has returned.

=== Prevention

Alias prevention techniques introduce constructs that ensure aliasing does not occur in specific contexts, in a way that can be statically verified.

For static checkability, constructs must be conservatively defined. For instance, a checkable version of "uncaptured" might restrict all variable bindings within a method, except when calling other methods that also have uncaptured attributes. This approach would forbid uses that programmers may happen to know as alias-free but cannot be statically checked to be safe. 

=== Control

Aliasing prevention alone is not sufficient because aliasing is unavoidable in conventional object-oriented programming. Aliasing control is necessary to ensure the system does not reach a state with unexpected aliasing, which requires analysis of the runtime state.

== Systems for controlling Aliasing 

In recent decades, extensive research has been conducted to address the issue of aliasing. The book _Aliasing in Object-Oriented Programming_ @Aliasing-OOP provides a comprehensive survey of the latest techniques for managing aliasing in object-oriented programming.

=== Controlling aliasing with uniqueness

// TODO: decidere se usare virgolette o corsivo per linear logi, uniqueness locic ecc.

A uniqueness type system distinguishes values referenced no more than once from values that can be referenced multiple times in a program. Harrington's _Uniqueness Logic_ @uniqueness-logic provides a formalization of the concept of uniqueness.

Uniqueness logic might seem similar to the more well-known _Linear Logic_.
_Linearity and Uniqueness: An Entente Cordiale_ @An-Entente-Cordiale describes the differences between linearity and uniqueness and shows how they can coexist.

#v(1em)

The common trait of all systems based on uniqueness is that a reference declared as unique points to an object that is not accessible by any other unknown reference. Moreover, the unique status of a reference can be dropped at any point in the program.

#v(1em)

A first approach to ensuring uniqueness consists of using destructive reads. AliasJava @aldrich2002alias is a system for controlling aliasing that uses this approach.
AliasJava is characterized by a strong uniqueness invariant asserting that "at a particular point in dynamic program execution, if a variable or field that refers to an object `o` is annotated unique, then no other field in the program refers to `o`, and all other local variables that refer to `o` are annotated lent".
This invariant is maintained by the fact that unique references can only be read in a destructive manner, meaning that immediately being read, the value `null` is assigned to the reference.

#v(1em)

Alias Burying @boyland2001alias proposes a system for controlling aliasing in Java that does not require to use destructive reads.
The system introduces several annotations:
- Procedure parameters and return values may be declared *unique*.
- Parameters and return values that are not *unique* are called *shared*.
- A parameter that is *shared* may be declared *borrowed*, return values may never be *borrowed*.
- Fields can be declared as *unique*, otherwise they are considered to be *shared*.
The main contribution of this work is the introduction of the "alias burying" rule: "When a unique field of an object is read, all aliases of the field are made undefined". This means that aliases of a *unique* field are allowed if they are assigned before being used again. The "alias burying" rule is important because it allows to avoid having destructive reads for *unique* references.
On the other hand, having a *shared* reference does not provide any guarantee on the uniqueness of that reference.
Finally the object referred to by a *borrowed* parameter may not be returned from a procedure, assigned to a field or passed as an owned (that is, not borrowed) actual parameter.

#v(1em)

Latte @zimmerman2023latte proposes an approach to reduce both the volume of annotations and the complexity of invariants necessary for reasoning about aliasing in an object-oriented language with mutation.

The system requires few annotations to be provided by the user:
- *unique* or *shared* for object ﬁelds and return types.
- *unique*, *shared* or *owned* for method parameters.
- The remaining information for local variables is inferred.

Furthermore, the system provides flexibility for uniqueness by permitting local variable aliasing, as long as this aliasing can be precisely determined.
A uniqueness invariant is defined as follows: "a unique object is stored at most once on the heap. In addition, all usable references to a unique object from the local environment are precisely inferred".

Latte's analysis produces at each program point an "alias graph", that is an undirected graph whose nodes are syntactic paths and distinct paths $p_1$ and $p_2$ are connected iff $p_1$ and $p_2$ are aliased. Moreover a directed graph whose nodes are syntactic path called "reference graph" is also produced for every program point. Intuitively, having an edge from $p_1$ to $p_2$ in the reference graph means that the annotation of $p_1$ requires to be updated when $p_2$ is updated.

=== Programming languages that control aliasing

*TODO: decide whether to include this section or not*

- *Rust* and its "Shared XOR Mutable" principle.

// It can be something similar to what is written in the prusti page.

// The Rust /* @ https://www.rust-lang.org/ */ programming language includes an ownership type system which guarantees rich memory safety properties: well-typed Rust programs are guaranteed to not exhibit problems such as dangling pointers, data races, and unexpected side effects through aliased references.

// Rust is a modern systems programming language designed to offer both performance and static safety. A key distinguishing feature is a strong type system, which enforces by default that memory is either shared or mutable, but never both. This guarantee is used to prevent common pitfalls such as memory errors and data races. It can also be used to greatly simplify formal verification

- *Swift*

== Tools for verification with Viper

Several verifiers have been built on top of Viper. The most relevant tools for this work are: Prusti, a verifier for the Rust programming language, Gobra, used to verify code written in Go, and Nagini, which can be used to verify Python programs.

=== Prusti

Based on the Viper infrastructure, Prusti @prusti1 @prusti2 is an automated verifier for Rust programs. It takes advantage of Rust's robust type system to make the specification and verification processes more straightforward.

By default, Prusti ensures that a Rust program will not encounter an unrecoverable error state causing it to terminate at runtime. This includes panics caused by explicit `panic!(...)` calls as well as those from bounds-checks or integer overflows.

In addition to use Prusti to ensure that programs are free from runtime panics, developers can gradually add annotations to their code, thereby achieving increasingly robust correctness guarantees and improving the overall reliability and safety of their software. 

In terms of Viper encoding, Rust structs are represented as potentially nested and recursive predicates representing unique access to a type instance. Furthermore, moves and straightforward usages of Rust’s shared and mutable borrows are akin to ownership transfers within the permission semantics of separation logic assertions. Reborrowing is directly modeled using magic wands: when a reborrowed reference is returned to the caller, it includes a magic wand denoting the ownership of all locations from which borrowing occurred, except those currently in the proof. 

=== Gobra
@gobra

=== Nagini
@nagini