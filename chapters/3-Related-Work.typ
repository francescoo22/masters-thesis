#pagebreak(to:"odd")
= Related Work<cap:related-work>

== Systems for Aliasing Control

In recent decades, extensive research has been conducted to address the issue of aliasing. The book "Aliasing in Object-Oriented Programming" @Aliasing-OOP provides a comprehensive survey of the latest techniques for managing aliasing in object-oriented programming. The following subsections will discuss the most relevant techniques for this work in detail.

=== The Geneva Convention

The Geneva Convention @GenevaConvention has established four primary methods to manage aliasing: Detection, Advertisement, Prevention, and Control. These methods aim to provide systematic approaches to identify, communicate, prevent, and manage aliasing in software systems.

==== Detection
Alias detection is a retrospective process that identifies potential or actual alias patterns in a program through static or dynamic techniques. This is beneficial for compilers, static analysis tools, and programmers as they can detect aliasing conflicts in programs, leads to more efficient code generation, helps find cases where aliasing can invalidate predicates, and assists programmers in resolving problematic conflicts. 

Alias detection needs a complex interprocedural analysis due to its non-local nature. It provides information about the alias relationship between two variables i.e. if they never, sometimes, or always alias the same object. Variables are said to sometimes alias, when they are aliased in some situations but not always. This information is particularly useful for optimization purposes.

==== Advertisement
Because global alias detection is impractical, it is crucial to develop methods and constructs for modular analysis. Programmers and formalists benefit from constructs that improve local analysis by annotating methods based on their aliasing properties. Optimistic assumptions about aliasing are common, such as expecting a Boolean object's or(arg) method to return a new object rather than an aliased one, despite it being correct behavior.

Popular object-oriented languages lack means to indicate whether methods capture objects by creating persistent access paths. Annotations indicating which object bindings are captured by a method and which aliases a method can handle could function similarly to const in C++, offering useful behavioral specifications.

For instance, qualifying a parameter with uncaptured would indicate that the object is not bound to a variable that could be modified through side channels after the method returns. A method like or might declare that both self and arg are const and uncaptured, and the return variable is also uncaptured.

Methods could also be advertised with preconditions like noalias, indicating that actual arguments should not be aliased, a restriction common in Turing. The pattern of const, noalias, and uncaptured operands and results mirrors "pure" functions, enhancing reasoning about program behavior. Enforcing such qualifiers leads to effective alias prevention.

==== Prevention

Alias prevention techniques introduce constructs that ensure aliasing does not occur in specific contexts, enabling static checkability by compilers and program analyzers. However, this requires conservative definitions, which may restrict valid uses that are not syntactically safe. For instance, checkable constructs like "uncaptured" and "noalias" may overly limit variable bindings and changes within collections, respectively.

Conservatism ensures validity but may prevent valid formulas from being provable and safe code from compiling without errors. Therefore, fine-grained alias prevention constructs have limited utility, necessitating higher-level constructs.

One such higher-level construct is "islands," which isolate groups of related objects, preventing static references across their boundaries. This allows scalable aliasing control within these isolated groups.

A more radical approach replaces the traditional assignment operator with a swapping operator, eliminating reference copying and thus avoiding aliasing issues. However, this requires a different programming paradigm, which may not integrate well with mainstream object-oriented techniques.


==== Control

Aliasing prevention alone is insufficient because aliasing is unavoidable in conventional object-oriented programming. Aliasing control is necessary to ensure the system does not reach a state with unexpected aliasing, which requires analysis of the runtime state.

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