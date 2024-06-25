#import "../config/utils.typ": *

#pagebreak(to:"odd")
= Annotation System

This chapter describes an annotation system for controlling aliasing within a subset of the Kotlin language.
The system takes inspiration from some previous works @boyland2001alias @zimmerman2023latte @aldrich2002alias  but it also introduces significant modifications.

One distinguishing trait of this system is that it is designed exclusively for Kotlin, while the majority of previous works are made for Java and other languages.
It is also specifically made for being as lightweight as possible and gradually integrable with already existing code.
// TODO: borrowed unique / borrowed shared distinction here?

A unique design goal of this system is to improve the verification process with Viper by establishing a link between separation logic and the absence of aliasing control in Kotlin.

== Grammar

@Featherweight-Java

#frame-box(
  $
    CL &::= class C(overline(f\: alpha_f)) \
    af &::= unique | shared \
    beta &::= dot | borrowed \
    M &::= m(overline(af beta space x)): af {begin_m; overline(s); ret_m e} \
    p &::= x | p.f \
    e &::= null | p | m(overline(p)) \
    s &::= var x | p = e |  fi p_1 == p_2 then overline(s_1) els overline(s_2) | m(overline(p))
    // \ &| loop p_1 == p_2 do overline(s)
  $
)

- Only *fields*, *method parameters*, and *return values* have to be annotated.
- A reference annotated as `unique` may either be `null` or point to an object, and it is the sole *accessible* reference pointing to that object.
- A reference marked as `shared` can point to an object without being the exclusive reference to that object.
- `T` is an annotation that can only be inferred and means that the reference is *not accessible*.
- $borrowed$ (borrowed) indicates that the function receiving the reference won't create extra aliases to it, and on return, its fields will maintain at least the permissions stated in the class declaration. 
- Annotations on fields indicate only the default permissions, in order to understand the real permissions of a fields it is necessary to look at the context. This concept is formalized by rules in /*@cap:paths*/ and shown in /*@field-annotations.*/
- Primitive fields are not considered
- `this` can be seen as a parameter
- constructors can be seen as functions returning a `unique` value

== Context

#frame-box(
  $
    alpha &::= unique | shared | top \
    beta &::= dot | borrowed \
    Delta &::= dot | p : alpha beta, Delta
  $
)

// TODO: put this in a separate chapter

// == Aliasing control in Kotlin

// === Verify  contracts


// // example of contracts usage

// // example of improvement in verification of contracts

// // quote something??

// === Static analysis (IntelliJ)
// === Smart cast
// === Function optimiztion (modify lists implace)
// === Garbage collection in Kotlin native

// == The system