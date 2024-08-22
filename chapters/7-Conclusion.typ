#pagebreak(to:"odd")
= Conclusion<cap:conclusion>

== Results

*TODO*

== Future Work

=== Improving Annotations Inference

The annotation system requires the user to write annotations only for methods and classes. The rest of the annotations can be inferred automatically. Although the current number of annotations that a user needs to write is reasonable, it would be better to infer even more annotations automatically.
Specifically, the `Borrowed` annotation could be inferred for certain functions. It might be possible to perform static analysis to check that a function does not create new aliases for a given parameter and only passes it to functions that do not consume its uniqueness. In this way, the user would not need to write the `Borrowed` annotation for parameters that can be guaranteed as borrowed by static analysis.
Moreover, manually annotating functions in the standard library, can improve this kind of analysis.

=== Tracking of Local Aliases

The uniqueness system proposed by Zimmerman et al. @zimmerman2023latte guarantees the following uniqueness invariant: "A unique object is stored at most once on the heap. In addition, all usable references to a unique object from the local environment are precisely inferred." This invariant allows for the creation of local aliases of unique objects without compromising their uniqueness.

In contrast, the uniqueness system proposed in this work takes a different approach. When local aliases are created, the original reference becomes inaccessible, and the local alias is treated as unique. This design choice prioritizes flexibility in the usage of paths while maintaining simplicity in the typing rules.

However, there is potential for future improvements to the system. By refining the existing rules, it may be possible to achieve a uniqueness invariant that allows the creation of controlled aliases without losing the guarantees of uniqueness. Such an enhancement would expand the range of Kotlin code supported by the system while preserving the integrity of uniqueness guarantees.

=== Checking Annotations

This work presents a uniqueness system and shows how it can be used to verify Kotlin code by encoding it into Viper. Currently, the plugin assumes that any annotated Kotlin program is well-typed according to the typing rules presented in @cap:annotation-system.

To improve the system, a static checker is under development. This checker will use Kotlin's control flow graph to ensure that the annotations satisfy the typing rules of the uniqueness system. By integrating this static analysis, the formal verification plugin will start to encode Kotlin into Viper only if the program is well-typed, reducing the need for manual validation and increasing the reliability of the verification process.

=== Extending the Language

Extending the range of Kotlin features supported by the annotation system is a natural next step for this work.

One area for extension is support for `while` loops. Currently, loops are not well supported by the formal verification plugin due to the lack of support for inferring invariants. As a result, handling loops was not a primary focus for the uniqueness system.

Lambdas are another important feature in Kotlin that the uniqueness system must support. Lambdas often capture references through closures, which presents challenges for maintaining uniqueness. Handling these references correctly requires careful tracking to ensure that the captured variables do not lead to unintended aliasing.
Bao et al. @reachability-types have proposed a system for tracking aliasing in higher-order functional programs, which could provide valuable insights for addressing these challenges.