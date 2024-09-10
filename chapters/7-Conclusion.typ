#pagebreak(to:"odd")
= Conclusion<cap:conclusion>

== Results

This thesis has introduced a novel uniqueness system for the Kotlin language, bringing several important improvements over existing approaches @aldrich2002alias @boyland2001alias @zimmerman2023latte.
The system provides improved flexibility in managing field accesses, particularly in handling nested properties within Kotlin programs. It allows the correct permissions for nested field accesses to be determined at any point of the program, without imposing any restrictions based on whether properties are unique, shared, or inaccessible. Furthermore, the uniqueness of properties can evolve during program execution, similarly to variables.
The system also introduces a clear distinction between borrowed-shared and borrowed-unique references, making it easier to integrate uniqueness annotations into existing codebases. 
Indeed, one of its key benefits is the ability to be adopted incrementally, enabling developers to incorporate it into their Kotlin code without the need for significant changes.

The uniqueness system has been rigorously formalized, detailing the rules and constraints necessary to ensure that unique references are properly maintained within a program.

Finally, this work has demonstrated how the uniqueness system can be used to encode Kotlin into Viper more precisely, enabling more accurate and reliable verification of Kotlin programs.

== Future Work

=== Extending the Language

Extending the range of Kotlin features supported by the annotation system is a natural next step for this work.

One area for extension is support for `while` loops. Currently, loops are not well supported by SnaKt due to the lack of support for inferring invariants. As a result, handling loops was not a primary focus for the uniqueness system.

Lambdas are another important feature in Kotlin that the uniqueness system must support. Lambdas often capture references through closures, which presents challenges for maintaining uniqueness. Handling these references correctly requires careful tracking to ensure that the captured variables do not lead to unintended aliasing.
Bao et al. @reachability-types have proposed a system for tracking aliasing in higher-order functional programs, which could provide valuable insights for addressing these challenges.

=== Improving Borrowed Fields Flexibility

Currently, fields of borrowed parameters are subject to restrictions necessary for ensuring system soundness when unique references are passed to functions expecting shared borrowed parameters.
Specifically, borrowed fields can only be reassigned using a unique reference. However, in some cases, allowing reassignment with shared references would also be safe. Similarly, borrowed fields become inaccessible after being read, even though there are situations where they could safely remain shared. Introducing rules to manage these scenarios would enhance the system's flexibility in handling borrowed fields, representing a significant improvement.

=== Tracking of Local Aliases

The uniqueness system proposed by Zimmerman et al. @zimmerman2023latte guarantees the following uniqueness invariant: "A unique object is stored at most once on the heap. In addition, all usable references to a unique object from the local environment are precisely inferred." This invariant allows for the creation of local aliases of unique objects without compromising their uniqueness.

In contrast, the uniqueness system proposed in this work takes a different approach. When local aliases are created, the original reference becomes inaccessible, and the local alias is treated as unique. This design choice prioritizes flexibility in the usage of paths while maintaining simplicity in the typing rules.

However, there is potential for future improvements to the system. By refining the existing rules, it may be possible to achieve a uniqueness invariant that allows the creation of controlled aliases without losing the guarantees of uniqueness. Such an enhancement would expand the range of Kotlin code supported by the system while preserving the integrity of uniqueness guarantees.

=== Checking Annotations

This work presents a uniqueness system and shows how it can be used to verify Kotlin code by encoding it into Viper. Currently, SnaKt assumes that any annotated Kotlin program is well-typed according to the typing rules presented in @cap:annotation-system.

To improve the system, a static checker is under development. This checker will use Kotlin's control flow graph to ensure that the annotations satisfy the typing rules of the uniqueness system. By integrating this static analysis, SnaKt will start to encode Kotlin into Viper only if the program is well-typed, reducing the need for manual validation and increasing the reliability of the verification process.

=== Proving the Soundness of the Annotation System

Another area for future work is proving the soundness of the proposed annotation system. Establishing soundness would involve formally demonstrating that the system's rules and annotations prevent illegal aliasing and correctly track ownership throughout program execution.
For instance, it would be important to prove that when a path is unique at any given point in the program, no other accessible paths point to the same object as that path. Additionally, it would be valuable to demonstrate that borrowed parameters are not further aliased by any function, ensuring that the borrowing mechanism preserves the integrity of reference uniqueness and prevents unintended aliasing.