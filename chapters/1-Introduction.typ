#pagebreak(to:"odd")

= Introduction

Aliasing is a topic that has been studied for decades  @Aliasing-OOP @GenevaConvention @beyondGenevaConvention in Computer Science and it refers to the situation where two or more references point to the same object.
Aliasing is an important characteristic of object-oriented programming languages allowing the programmers to develope complex designs involving sharing. However, reasoning about programs written with languages that allow aliasing without any kind of control is a hard task for programmers, compilers and formal verifcation tools. In fact, as reported in the Geneva Convention @GenevaConvention, without having guarantees about aliasing it can be difficult to prove the correctness of a simple Hoare formula like the following. $ {x = "true"} space y := "false" {x = "true"} $ 
Indeed, when $x$ and $y$ are aliased, the formula is not valid, and most of the time proving that aliasing cannot occur is not straightforward.

== Contributions

This work aims to show how controlling aliasing through an annotation system can allow to refine formal verifcation performed by an already existing plugin @FormVerPlugin for the Kotlin language @Kotlin @KotlinSpec.
In particular, formal verification is performed using Viper @ViperWebSite @Viper, a language developed by ETH Zurich.
Viper is an intermediate verification language that allows to write functions with preconditions and postconditions. The correctness of these conditions is verified using one of the two verification back-ends (one based on symbolic execution and one based on verification condition generation) and an SMT solver.
In order to verify Kotlin code with Viper it is just necessary to translate the former language into the latter.
However, Viper's memory model is based on separation logic @separationLogic1 @separationLogic2 @separationLogic3 disallowing references that are both shared and mutable.
This restriction becomes problematic when encoding Kotlin code into Viper since Kotlin does not provide such guarantees.

To understand better the problem, it is possible to look at the Kotlin code in @example-kt-1 where passing the same reference twice when calling function `f`, and thus creating aliasing, is completely allowed by the language. @example-vpr-1 shows a wrong way to encoding the example presented in @example-kt-1. The Viper example, despite being really similar to the Kotlin one, fails verification when calling `f(x, x)`. This happens because `f` requires write access to the field `n` of its arguments and, as mentioned before, Viper disallows references to be shared and mutable at the same time.

#figure(
  caption: "Kotlin code containing aliasing",
  ```kt
  class A(var n: Int)

  fun f(x: A, y: A) {
      x.n = 1
      y.n = 2
  }

  fun use_f(x: A) {
      f(x, x)
  }
  ```
)<example-kt-1>

#figure(
  caption: "Viper code containing aliasing",
  ```java
  field n: Int

  method f(x: Ref, y: Ref)
  requires acc(x.n) && acc(y.n)
  {
    x.n := 1
    y.n := 2
  }

  method use_f(x: Ref)
  requires acc(x.n)
  {
    f(x, x) // verifcation error
  }
  ```
)<example-vpr-1>

Differently from other programming languages, Kotlin lacks built-in mechanisms to control or prevent aliasing.
This work addresses this issue by proposing the introduction of an annotation system specifically designed to manage and control aliasing in Kotlin. By incorporating this annotation system, developers can enforce stricter aliasing rules, improving the reliability of their code. This also enables to perform better formal verification, allowing to prove more interesting properties.

== Overview

The rest of the thesis is organized as follows:

/ @cap:background : provides a description of the background information needed to understand the concepts presented by this work. In particular, this chapter presents the Kotlin programming language and its feature of interest for the thesis. After that, an overview to the "Aliasing" topic in Computer Science is provided and finally it is presented an introduction to the Viper language and set of verifcation tools.

/ @cap:related-work : analyzes works that has been fundamental for the development of this thesis. The chapter is divided in two parts, the former describing existing works about aliasing and systems for controlling it; the latter gives an overview of the already existing tools that perform formal verification using Viper.

/ @cap:annotation-system : presents a novel annotation system for controlling aliasing on a language that can represent a significant subset of the Kotlin language. After introducing the language and several auxiliary rules and functions, the typing rules for the system are formalized.

/ @cap:annotations-kt : discusses the application of the proposed annotation system in the Kotlin language. It shows several examples of Kotlin code extended with these annotations and explores how the annotations can be used for bringing improvements to the language.

/ @cap:encoding : shows how the annotation system presented before can be used to obtain a better encoding of Kotlin into Viper, thus improving the quality of verification.

/ @cap:conclusion : summarizes the contributions of this research and points out reasonable extensions to this work as well as potential new areas for future research.
