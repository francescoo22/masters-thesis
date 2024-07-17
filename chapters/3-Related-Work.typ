#pagebreak(to:"odd")
= Related Work

== Systems for Aliasing Control

In recent decades, extensive research has been conducted to address the issue of aliasing. The book "Aliasing in Object-Oriented Programming" @Aliasing-OOP provides a comprehensive survey of the latest techniques for managing aliasing in object-oriented programming. The following subsections will discuss the most relevant techniques for this work in detail.

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
@aldrich2002alias

=== An Entante Cordiale
@An-Entente-Cordiale

=== Rust
// TODO: write it based on the content of the paper

Rust @Rust and its "Shared XOR Mutable" principle. 
// Rust @Rust is a programming language that prioritizes safety and performance, offering some unique tools for managing memory. One of its principles is the "Shared XOR Mutable" rule, which maintains that any given piece of data can either have any number of readers or exactly one writer at any given time. This principle is key in preventing data races, as it ensures safe concurrency. With this principle, Rust provides the advantages of thread safety without necessitating a garbage collector, delivering an optimal balance between performance and security.

=== Swift


== Tools for verification with Viper

=== Prusti
@AstrauskasBilyFialaGrannanMathejaMuellerPoliSummers22

=== Gobra
@WolfArquintClochardOortwijnPereiraMueller21

=== Nagini
@eilers2018nagini