#pagebreak(to:"odd")

= Introduction to the aliasing problem

== what is aliasing, the geneva convention

Aliasing refers to the situation where a data location in memory can be accessed through different symbolic names in the program. Thus, changing the data through one name inherently leads to a change when accessed through the other name as well. This can happen due to several reasons such as pointers, references, multiple arrays pointing to the same memory location etc.

Aliasing is an historical problem in both formal verification and practical programming. As described in The Geneva Convention @GenevaConvention, 

== problems caused by aliasing

== first ideas on how to control aliasing

== Existing systems
- alias burying
- LATTE
- ...