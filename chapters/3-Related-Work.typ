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

== Systems for Controlling Aliasing 

In recent decades, extensive research has been conducted to address the issue of aliasing. The book _Aliasing in Object-Oriented Programming_ @Aliasing-OOP provides a comprehensive survey of the latest techniques for managing aliasing in object-oriented programming.

=== Controlling Aliasing through Uniqueness<cap:control-alias-unique>

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

=== Programming Languages with Aliasing Guarantees

Recently, several programming languages have started to introduce type systems that provide strong guarantees regarding aliasing.

Rust @rustlang is a modern programming language that prioritizes both high performance and static safety. A crucial aspect of Rust is its ownership-based type system, which ensures complete memory safety by preventing issues like dangling pointers, data races, and unintended side effects from aliased references. This type system enforces strict rules, allowing memory to be either mutable or shared, but not both simultaneously, thereby avoiding common memory errors. Additionally, this design choice simplifies the process of formal verification.

- *TODO: Swift* 
  - https://github.com/swiftlang/swift/blob/main/docs/OwnershipManifesto.md
  - https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/dataracesafety/
  - https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations#Parameter-Modifiers
- *TODO: Ocaml???*
  - https://blog.janestreet.com/oxidizing-ocaml-locality/
  - https://blog.janestreet.com/oxidizing-ocaml-ownership/

== Viper Verification Tools

Several verifiers have been built on top of Viper. The most relevant tools for this work are: Prusti, a verifier for the Rust programming language, Gobra, used to verify code written in Go, and Nagini, which can be used to verify Python programs.

All these tools require the user to add annotations to the code that has to be verified. However, the number of annotations needed is inversely proportional to the robustness of the language's type system. This is the reason why the verifier for the Rust language is able to verify significant properties even without annotations, while other verifiers cannot work without user-provided annotations.

=== Prusti

Based on the Viper infrastructure, Prusti @prusti1 @prusti2 is an automated verifier for Rust programs. It takes advantage of Rust's robust type system to make the specification and verification processes more straightforward.

By default, Prusti ensures that a Rust program will not encounter an unrecoverable error state causing it to terminate at runtime. This includes panics caused by explicit `panic!(...)` calls as well as those from bounds-checks or integer overflows.

In addition to use Prusti to ensure that programs are free from runtime panics, developers can gradually add annotations to their code, thereby achieving increasingly robust correctness guarantees and improving the overall reliability and safety of their software. 

In terms of Viper encoding, Rust structs are represented as potentially nested and recursive predicates representing unique access to a type instance. Furthermore, moves and straightforward usages of Rust's shared and mutable borrows are akin to ownership transfers within the permission semantics of separation logic assertions. Reborrowing is directly modeled using magic wands: when a reborrowed reference is returned to the caller, it includes a magic wand denoting the ownership of all locations from which borrowing occurred, except those currently in the proof. 

=== Gobra

Go is a programming language that combines typical characteristics of imperative languages, like mutable heap-based data structures, with more unique elements such as structural subtyping and efficient concurrency primitives. This mix of mutable data and sophisticated concurrency constructs presents unique challenges for static program verification.

Gobra @gobra is a tool designed for Go that allows modular verification of programs. It can ensure memory safety, crash resistance, absence of data races, and compliance with user-defined specifications.

Compared to Prusti, Gobra generally requires more user-provided annotations. Benchmarks indicate that the annotation overhead varies from 0.3 to 3.1 lines of annotations per line of code.

=== Nagini

Nagini @nagini is a verification tool for statically-typed, concurrent Python programs. Its capabilities include proving memory safety, freedom from data races, and user-defined assertions.

Programs must follow to the static, nominal type system described in PEP 484 and implemented by the Mypy type checker to be compatible with Nagini. This type system requires type annotations for function parameters and return types, while types for local variables are inferred.

The tool includes a library of specification functions to express preconditions and postconditions, loop invariants, and other assertions.

By default, Nagini verifies several safety properties, ensuring that validated programs do not emit runtime errors or undeclared exceptions. Its permission system ensures that validated code is memory safe and free of data races. Moreover, the tool can verify functional properties, input/output properties and can ensue that no thread is indefinitely blocked when acquiring a lock or joining another thread, thus including deadlock freedom and termination.

Similarly to Gobra, Nagini requires a significant amount of annotations provided by the user and requires users to write fold operations. 