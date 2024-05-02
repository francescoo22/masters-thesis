#pagebreak(to:"odd")

= Introduction to the aliasing problem

== Kotlin overview

== what is aliasing, the geneva convention

Aliasing refers to the situation where a data location in memory can be accessed through different symbolic names in the program. Thus, changing the data through one name inherently leads to a change when accessed through the other name as well. This can happen due to several reasons such as pointers, references, multiple arrays pointing to the same memory location etc.

Aliasing is an historical problem in both formal verification and practical programming. As described in The Geneva Convention @GenevaConvention, 

== problems caused by aliasing

== first ideas on how to control aliasing

=== Dealing with aliasing

This document outlines the issue of aliasing and provides a summary of a potential solution, as detailed in the paper [
*Alias Burying: Unique Variables Without Destructive Reads*](https://onlinelibrary.wiley.com/doi/abs/10.1002/spe.370).
It then shows how the solution can be employed to refine the verification process achieved by converting Kotlin into
Viper.

=== Aliasing problem overview

As described in [The Geneva Convention](https://dl.acm.org/doi/pdf/10.1145/130943.130947) aliasing between references
can make it difficult to verify simple programs.
Let's consider the following Hoare formula: $$\{x = true\} y := false \{x = true\}$$ If $x$ and $y$ refers to the same
reference (they are aliased) the formula is not valid.

The set of (object address) values associated with variables during the execution of a method is a context. It is only
meaningful to speak of aliasing occurring within some context; if two instance variables refer to a single object, but
one of them belongs to an object that cannot be reached from anywhere in the system, then the
aliasing is irrelevant.

Within any method, objects may be accessed through paths rooted at any of:

- Self
- An anonymous locally constructed object
- A method argument
- A result returned by another method
- A (global) variable accessible from the method scope
- A local method variable bounded to any of the above

An object is *aliased* with respect to some context if two or more such paths to it exist.

=== Aliasing problem while encoding Kotlin into Viper

The problem described above is reflected in Kotlin and its encoding into Viper.

Let's consider this example:

```kotlin
class A(var a: Int)

fun f(a1: A, a2: A) {}

fun main(a3: A) {
    f(a3, a3)
}
```

Since aliasing is allowed in Kotlin, it is not possible to represent `A` as a predicate and require the predicate to be
true in preconditions and postconditions. In fact doing that would make the encoding of `main` not to verify.

```
field a: Int

predicate A(this: Ref){
    acc(this.a)
}

method f (a1: Ref, a2: Ref)
requires A(a1) && A(a2)
ensures A(a1) && A(a2)

method use_f (a3: Ref)
requires A(a3)
ensures A(a3)
{
    f(a3, a3) // does not verify
}
```

Aliasing is also problematic for the static analyzer used by IntelliJ IDEA

```kt
class A(var a: Boolean = false)

fun f(a1: A, a2: A) {
    a1.a = true
    a2.a = false
    // suggestion: Condition '!a1.a' is always false 
    if (!a1.a) {
        println("ALIASED!")
    }
}

fun main() {
    val a1 = A()
    f(a1, a1) // prints "ALIASED!"
}
```

=== Uniqueness

The value of a *unique* variable is either `null` or it refers to an *unshared* object. This specific situation is
identified as the *uniqueness invariant*.
It is easy to see that problems previously described could be solved by annotating a variable as *unique*. Additionally,
uniqueness could be utilized to perform compile-time garbage collection.

=== Destructive reads

We are most likely not going to choose the "destructive reads" approach, but it's worth mentioning.
In this approach, a *unique* variable is atomically set to null at the same time its value is read. This action
maintains the *uniqueness invariant*. However, programming with destructive reads can be awkward, and furthermore, this
approach is unsuitable for Kotlin due to null-safety requirements.