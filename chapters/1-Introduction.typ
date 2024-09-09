#import "../config/utils.typ": code-compare
#import "../vars/kt-to-vpr-examples.typ": intro-kt, intro-vpr, intro-kt-annotated
#pagebreak(to:"odd")

= Introduction

Aliasing is a topic that has been studied for decades  @Aliasing-OOP @beyondGenevaConvention @GenevaConvention in computer science and it refers to the situation where two or more references point to the same object.
Aliasing is an important characteristic of object-oriented programming languages allowing the programmers to develope complex designs involving sharing. However, reasoning about programs written with languages that allow aliasing without any kind of control is a hard task for programmers, compilers and formal verification tools. In fact, as reported in _the Geneva Convention on the Treatment of Object Aliasing_ @GenevaConvention, without having guarantees about aliasing it can be difficult to prove the correctness of a simple Hoare formula like the following. $ {x = "true"} space y := "false" {x = "true"} $ 
Indeed, when $x$ and $y$ are aliased, the formula is not valid, and most of the time proving that aliasing cannot occur is not straightforward.

On the other hand, ensuring disjointness of the heap enables the verification of such formulas. For instance, in separation logic @separationLogic1 @separationLogic2 @separationLogic3, it is possible to prove the correctness of the following formula. $ {(x |-> "true") * (y |-> -)} space y := "false" {(x |-> "true") * (y |-> "false")} $ 
This verification is possible because separation logic allows to express that $x$ and $y$ are not aliased by using the separating conjunction operator "$*$". Similarly, programming languages can incorporate annotation systems @aldrich2002alias @boyland2001alias @zimmerman2023latte or built-in constructs @swift-parameter-modifiers @rustlang to provide similar guarantees regarding aliasing, thereby simplifying any verification process.

// TODO: aggiungere altre citazioni a @rustlang se dovessi aggiungere altro per swift, rust, ocaml

== Contributions

This work demonstrates how controlling aliasing through an annotation system can enhance the formal verification process performed by an existing plugin @FormVerPlugin for the Kotlin language @KotlinSpec @Kotlin. The plugin verifies Kotlin using Viper @ViperWebSite @Viper, an intermediate verification language developed by ETH Zurich. Viper is designed to verify programs by enabling the specification of functions with preconditions and postconditions, which are then checked for correctness. This verification is performed using one of two back-ends: symbolic execution @MuellerSchwerhoffSummers16b or verification condition generation @HeuleKassiosMuellerSummers13, both of which rely on an SMT solver to validate the specified conditions.

In order to verify to Kotlin with Viper, it is necessary to translate the former language into the latter. However, this translation presents challenges due to fundamental differences between the two languages. Specifically, Viper's memory model is based on separation logic, which disallows shared mutable references. In contrast, Kotlin does not restrict aliasing, meaning that references in Kotlin can be both shared and mutable, posing a significant challenge when trying to encode Kotlin code into Viper.

This issue is clearly illustrated in the Kotlin code example provided in @intro-comp. In that example, the language allows the same reference to be passed multiple times when calling function `f`, thereby creating aliasing. Additionally, @intro-comp presents a naive approach for encoding that Kotlin code into Viper. Despite the Viper code closely resembling the original Kotlin code, it fails verification when `f(x, x)` is called. This failure occurs because `f` requires write access to the field `n` of its arguments, but as previously mentioned, Viper’s separation logic disallows references from being both shared and mutable simultaneously.

#code-compare("Kotlin code with aliasing and its problematic encoding into Viper", .8fr, intro-kt, intro-vpr)<intro-comp>

As mentioned before, Kotlin does not have built-in mechanisms to manage or prevent aliasing, which can lead to unintended side effects and make it harder to ensure code correctness. To address this issue, this work proposes and formalizes an annotation system specifically designed to manage and control aliasing within Kotlin.

The proposed annotation system introduces a way for developers to specify and enforce stricter aliasing rules by tagging references with appropriate annotations. 
This helps to clearly distinguish between references that might be shared and those that are unique. Additionally, the system differentiates between functions that create new aliases for their parameters and those that do not.
This level of control is important for preventing common programming errors related to mutable shared state, such as race conditions or unintended side effects.

@kt-ann-intro provides an overview of the annotation system. Specifically, the `@Unique` annotation ensures that a reference is not aliased, while the `@Borrowed` annotation guarantees that a function does not create new aliases for a reference. The example also demonstrates how the problematic function call presented in @intro-comp is disallowed by the annotation system, as `x` and `y` would be aliased when the function `f` requires them to be unique.

The thesis finally shows how aligning Kotlin’s memory model with Viper’s, using the proposed annotation system, enhances the encoding process performed by the plugin.

#figure(
  caption: "Kotlin code with annotations for aliasing control",
  intro-kt-annotated
)<kt-ann-intro>

== Structure of the thesis

The rest of the thesis is organized as follows:

/ @cap:background : provides a description of the background information needed to understand the concepts presented by this work. In particular, this chapter presents the Kotlin programming language and its feature of interest for the thesis. Following this, the chapter provides an overview of the "Aliasing" topic in Computer Science and presents an introduction to the Viper language and its set of verification tools.

/ @cap:related-work : analyzes works that has been fundamental for the development of this thesis. The chapter is divided in two parts, the former describing existing works about aliasing and systems for controlling it; the latter gives an overview of the already existing tools that perform formal verification using Viper.

/ @cap:annotation-system : presents a novel annotation system for controlling aliasing on a language that can represent a significant subset of the Kotlin language. After introducing the language and several auxiliary rules and functions, the typing rules for the system are formalized.

/ @cap:annotations-kt : discusses the application of the proposed annotation system in the Kotlin language. It shows several examples of Kotlin code extended with these annotations and explores how the annotations can be used for bringing improvements to the language.

/ @cap:encoding : shows how the annotation system presented before can be used to obtain a better encoding of Kotlin into Viper, thus improving the quality of verification.

/ @cap:conclusion : summarizes the contributions of this research and points out reasonable extensions to this work as well as potential new areas for future research.
