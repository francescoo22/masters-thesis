#pagebreak(to:"odd")
= Aliasing in Kotlin

== Kotlin overview

// TODO: scriverlo per davvero XD
// meglio concentrarsi su caratteristiche del linguaggio (OO, concurrency, jvm, ...)

Kotlin is a statically-typed, versatile programming language that was developed by JetBrains in 2011. Built with the aim to enhance productivity and satisfaction of developers, it offers a unique blend of object-oriented and functional programming features capable of gracing any application with simplicity, clarity, and excellent interoperability. Kotlin is primarily used for Android app development and is officially recommended by Google. Its efficiency, conciseness, and safety to prevent common programming errors make it a rather compelling choice for developers worldwide.

// === Object oriented

// === Null Safety

// === Smart useCaseDetails

// === Contracts

== Why controlling aliasing can improve the language

=== Verify  contracts
// TODO (AIG)
Kotlin contracts are a feature introduced in Kotlin 1.3 designed to provide additional guarantees about code behavior, aiding the compiler in performing more precise analysis and optimizations. Contracts are defined using a special contract block within a function, describing the relationship between input parameters and the function's effects. This can include conditions such as whether a lambda is invoked or if a function returns under certain conditions. By specifying these relationships, contracts help the compiler understand the function's logic more deeply, enabling advanced features like smart casting and better null-safety checks. Essentially, contracts serve as a tool to make code safer and more predictable, reducing the likelihood of runtime errors.

// example of contracts usage

// example of improvement in verification of contracts

// quote something??

=== Static analysis (IntelliJ)
=== Smart cast
=== Function optimiztion (modify lists implace)
=== Garbage collection in Kotlin native
