#import "../config/utils.typ": code-compare
#import "../vars/kt-to-vpr-examples.typ": intro-kt, intro-vpr
#pagebreak(to:"odd")

= Introduction

Aliasing is a topic that has been studied for decades  @Aliasing-OOP @beyondGenevaConvention @GenevaConvention in Computer Science and it refers to the situation where two or more references point to the same object.
Aliasing is an important characteristic of object-oriented programming languages allowing the programmers to develope complex designs involving sharing. However, reasoning about programs written with languages that allow aliasing without any kind of control is a hard task for programmers, compilers and formal verification tools. In fact, as reported in the Geneva Convention @GenevaConvention, without having guarantees about aliasing it can be difficult to prove the correctness of a simple Hoare formula like the following. $ {x = "true"} space y := "false" {x = "true"} $ 
Indeed, when $x$ and $y$ are aliased, the formula is not valid, and most of the time proving that aliasing cannot occur is not straightforward.

== Contributions

This work demonstrates how controlling aliasing through an annotation system can enhance the formal verification process performed by an existing plugin @FormVerPlugin for the Kotlin language @KotlinSpec @Kotlin. The plugin verifies Kotlin using Viper @ViperWebSite @Viper, an intermediate verification language developed by ETH Zurich. Viper is designed to verify programs by enabling the specification of functions with preconditions and postconditions, which are then checked for correctness. This verification is performed using one of two back-ends: symbolic execution or verification condition generation, both of which rely on an SMT solver to validate the specified conditions.

In order to verify to Kotlin with Viper, it is necessary to translate the former language into the latter. However, this translation presents challenges due to fundamental differences between the two languages. Specifically, Viper's memory model is based on separation logic @separationLogic1 @separationLogic2 @separationLogic3, which disallows shared mutable references. In contrast, Kotlin does not restrict aliasing, meaning that references in Kotlin can be both shared and mutable, posing a significant challenge when trying to encode Kotlin code into Viper.

This issue is clearly illustrated in the Kotlin code example provided in @intro-comp. In that example, the language allows the same reference to be passed multiple times when calling function `f`, thereby creating aliasing. @intro-comp also shows a wrong approach for encoding that Kotlin code into Viper. Despite the Viper code closely resembling the original Kotlin code, it fails verification when `f(x, x)` is called. This failure occurs because `f` requires write access to the field `n` of its arguments, but as previously mentioned, Viper’s separation logic disallows references from being both shared and mutable simultaneously.

#code-compare("Kotlin code with aliasing and its problematic encoding into Viper", .8fr, intro-kt, intro-vpr)<intro-comp>

As mentioned before, Kotlin does not have built-in mechanisms to manage or prevent aliasing, which can lead to unintended side effects and make it harder to ensure code correctness. To address this issue, this work proposes and formalizes an annotation system specifically designed to manage and control aliasing within Kotlin.

The proposed annotation system introduces a way for developers to specify and enforce stricter aliasing rules by tagging references with appropriate annotations. 
This helps to clearly distinguish between references that might be shared and those that are unique. Additionally, the system differentiates between functions that create new aliases for their parameters and those that do not.
This level of control is important for preventing common programming errors related to mutable shared state, such as race conditions or unintended side effects.

The introduction of this annotation system not only improves the reliability of Kotlin programs by reducing the risk of aliasing-related bugs but also enhances the formal verification process using Viper. This work demonstrates how to effectively encode Kotlin programs into Viper by aligning Kotlin’s memory model with Viper’s memory model through the proposed annotation system.

== Structure of the thesis

The rest of the thesis is organized as follows:

/ @cap:background : provides a description of the background information needed to understand the concepts presented by this work. In particular, this chapter presents the Kotlin programming language and its feature of interest for the thesis. After that, an overview to the "Aliasing" topic in Computer Science is provided and finally it is presented an introduction to the Viper language and set of verification tools.

/ @cap:related-work : analyzes works that has been fundamental for the development of this thesis. The chapter is divided in two parts, the former describing existing works about aliasing and systems for controlling it; the latter gives an overview of the already existing tools that perform formal verification using Viper.

/ @cap:annotation-system : presents a novel annotation system for controlling aliasing on a language that can represent a significant subset of the Kotlin language. After introducing the language and several auxiliary rules and functions, the typing rules for the system are formalized.

/ @cap:annotations-kt : discusses the application of the proposed annotation system in the Kotlin language. It shows several examples of Kotlin code extended with these annotations and explores how the annotations can be used for bringing improvements to the language.

/ @cap:encoding : shows how the annotation system presented before can be used to obtain a better encoding of Kotlin into Viper, thus improving the quality of verification.

/ @cap:conclusion : summarizes the contributions of this research and points out reasonable extensions to this work as well as potential new areas for future research.
