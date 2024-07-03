#import "../config/constants.typ": abstract
#set page(numbering: "i")
#counter(page).update(1)

#v(10em)

#text(24pt, weight: "semibold", abstract)

#v(2em)
#set par(first-line-indent: 0pt)

In Computer Science, aliasing refers to the situation where two or more references point to the same object.
On the one hand, aliasing can be useful in object-oriented programming, allowing programmers to implement designs involving sharing.
On the other hand, aliasing poses significant challenges for formal verification. This is because changing a reference can modify the data that other references also point to. As a result, it becomes more challenging to predict the behavior of the program.

Developed by JetBrains, Kotlin is an open-source, statically typed programming language that gained popularity in recent years especially in the Android software development field. However, unlike other programming languages, there are not many ad-hoc tools for performing formal verification in Kotlin. Moreover, Kotlin does not provide any guarantee against aliasing, making formal verification a hard task for the language.

This work introduces an annotation system for a subset of the Kotlin language, designed to provide some guarantees on the uniqueness of references. After presenting and formalizing the annotation system, the thesis shows how to use these annotations for performing formal verification of Kotlin by encoding it into Viper, a language and suite of tools developed by ETH Zurich to provide an architecture for the development of new verification tools.

#v(1fr)