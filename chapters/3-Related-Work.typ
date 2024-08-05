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

In recent decades, extensive research has been conducted to address the issue of aliasing. The book "Aliasing in Object-Oriented Programming" @Aliasing-OOP provides a comprehensive survey of the latest techniques for managing aliasing in object-oriented programming. The following subsections will discuss the most relevant techniques for this work in detail.

// deve parlare di destructive reads (aliasJava), altri sistemi come aliasburying, latte
// decidere se mettere an entente cordiale da qualche parte

=== Something about destructive reads?

=== Alias Burying
Boyland @boyland2001alias proposes a system for controlling aliasing in Java.
The system introduces several annotations:
- Procedure parameters and return values may be declared *unique*.
- Parameters and return values that are not *unique* are called *shared*.
- A parameter that is *shared* may be declared *borrowed*, return values may never be *borrowed*.
- Fields can be declared as *unique*, otherwise they are considered to be *shared*.
The main contribution of this work is the introduction of the "alias burying" rule: "When a unique field of an object is read, all aliases of the field are made undefined". This means that aliases of a *unique* field are allowed if they are assigned before being used again. The "alias burying" rule is important because it allows to avoid having destructive reads for *unique* references.
On the other hand, having a *shared* reference does not provide any guarantee on the uniqueness of that reference.
Finally the object referred to by a *borrowed* parameter may not be returned from a procedure, assigned to a field or passed as an owned (that is, not borrowed) actual parameter.

=== Latte
Zimmerman et al. @zimmerman2023latte propose an approach to reduce both the volume of annotations and the complexity of invariants necessary for reasoning about aliasing in an object-oriented language with mutation.

The system requires few annotations to be provided by the user:
- *unique* or *shared* for object ﬁelds and return types.
- *unique*, *shared* or *owned* for method parameters.
- The remaining information for local variables is inferred.

Furthermore, the system provides flexibility for uniqueness by permitting local variable aliasing, as long as this aliasing can be precisely determined.
A uniqueness invariant is defined as follows: "a unique
object is stored at most once on the heap. In addition, all
usable references to a unique object from the local environ-
ment are precisely inferred".

Latte's analysis produces at each program point an *alias graph*, that is an undirected graph whose nodes are syntactic paths and distinct paths $p_1$ and $p_2$ are connected iff $p_1$ and $p_2$ are aliased. Moreover a directed graph whose nodes are syntactic path called *reference graph* is also produced for every program point. Intuitively, having an edge from $p_1$ to $p_2$ in the reference graph means that the annotation of $p_1$ requires to be updated when $p_2$ is updated.

=== AliasJava
Destructive reads -> @aldrich2002alias

== Languages that provides guarantees on aliasing

=== Rust
// TODO: write it based on the content of the paper

Rust @Rust and its "Shared XOR Mutable" principle. 

@An-Entente-Cordiale describes the difference between linearity and uniqueness.
// Rust @Rust is a programming language that prioritizes safety and performance, offering some unique tools for managing memory. One of its principles is the "Shared XOR Mutable" rule, which maintains that any given piece of data can either have any number of readers or exactly one writer at any given time. This principle is key in preventing data races, as it ensures safe concurrency. With this principle, Rust provides the advantages of thread safety without necessitating a garbage collector, delivering an optimal balance between performance and security.

=== Swift


== Tools for verification with Viper

=== Prusti
@AstrauskasBilyFialaGrannanMathejaMuellerPoliSummers22

=== Gobra
@WolfArquintClochardOortwijnPereiraMueller21

=== Nagini
@eilers2018nagini