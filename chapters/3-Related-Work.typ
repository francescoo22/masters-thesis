#pagebreak(to:"odd")
= Related Work

== Systems for controlling aliasing

In recent decades, extensive research has been conducted to address the issue of aliasing. The book "Aliasing in Object-Oriented Programming" @Aliasing-OOP provides a comprehensive survey of the latest techniques for managing aliasing in object-oriented programming. The following subsections will discuss the most relevant techniques for this work in detail.

=== Something about destructuive reads??
=== Alias Burying: Unique variables without destructive reads
Boyland @boyland2001alias proposes a system for controlling aliasing in Java.
The system introduces several annotations:
- Procedure parameters and return values may be declared *unique*.
- Parameters and return values that are not *unique* are called *shared*.
- A parameter that is *shared* may be declared *borrowed*, return values may never be *borrowed*.
- Fields can be declared as *unique*, otherwise they are considered to be *shared*.
The main contribution of this work is the introduction of the "alias burying" rule: "When a unique field of an object is read, all aliases of the field are made undefined". This mean that having aliases of a *unique* field is allowed if these aliases are assigned before being used again. The "alias burying" rule is important because allows to avoid having destructive reads for *unique* references.
On the other hand, having a *shared* reference does not provide any guarantee on the uniqueness of that reference.
Finally the object referred to by a *borrowed* parameter may not be returned from a procedure, assigned to a field or passed as an owned (that is, not borrowed) actual parameter.

=== LATTE
@zimmerman2023latte
=== aliasJava
@aldrich2002alias
=== An entante cordiale
@An-Entente-Cordiale
=== RUST, Swift

== Tools for verification with Viper
=== Prusti
@AstrauskasBilyFialaGrannanMathejaMuellerPoliSummers22
=== Gobra
@WolfArquintClochardOortwijnPereiraMueller21
=== Nagini
@eilers2018nagini