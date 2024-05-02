#set page(numbering: "i")
#counter(page).update(1)

#v(10em)

#text(24pt, weight: "semibold", "Abstract")

#v(2em)
#set par(first-line-indent: 0pt)
Aliasing in programming languages with heap-based memory management poses significant challenges for formal verification due to the lack of control over reference uniqueness. The thesis introduces an annotation system for Kotlin designed to monitor the uniqueness of references. Developed by JetBrains, Kotlin is an open-source, statically typed programming language considered a safer, more concise alternative to Java. Nonetheless, unlike Java and other languages, Kotlin has fewer formally verifying tools. After presenting the annotation system that monitors reference uniqueness in Kotlin, the thesis shows how these annotations can be used to formally verify Kotlin code using Viper, a state of the art tool developed by ETH Zurich based on separation logic.

#v(1fr)

// Kotlin is an open-source statically typed programming language developed by JetBrains and considered to be a safer, cleaner, and concise alternative to Java. However, differently from Java and other programming languages, not too many tools for formally verifier Kotlin code have been developed.
// This work presents the development of a formal verification plugin for the Kotlin programming language. In order to verify Kotlin code, the plugin uses Viper, a state of the art tool developed by ETH Zurich based on separation logic.
// Aliasing is a problem that has been discussed for a long time in formal verification. Programming languages that make use of the heap usually do not provide a way to control aliasing between references, making verification an hard task. To address this problem in our plugin we propose an annotation system capable of tracking uniqueness of the references.

// #line(length: 100%)



// This thesis presents the creation of a formal verification plugin for the open-source, statically typed programming language, Kotlin. Developed by JetBrains, Kotlin is considered a safer, more concise alternative to Java. Nonetheless, unlike Java and other languages, Kotlin has fewer formally verifying tools.

// This study aims to fill this gap, utilizing Viper, a well-established tool created by ETH Zurich, to verify Kotlin code within the plugin. Viper has been chosen for its grounded foundation in separation logic. 

// In addition, the research addresses the long-standing challenge of aliasing in formal verification. Programming languages using heap memory often lack control over aliasing between references, creating verification difficulties. To tackle this issue, an annotation system has been introduced within the plugin, allowing for the monitoring of reference uniqueness.
