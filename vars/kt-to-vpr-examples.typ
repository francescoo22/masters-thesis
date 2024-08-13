#let classes-kt = ```kt
open class A(
    val x: Int,
    var y: Int
)

class B(
    val a1: A,
    var a2: A
)
```

#let classes-vpr = ```java
field x: Int
field y: Int
field a1: Ref
field a2: Ref
field b: Ref

predicate SharedA(this: Ref) {
  acc(this.x, wildcard)
}


predicate SharedB(this: Ref) {
  acc(this.a1, wildcard) &&
  acc(SharedA(this.a1), wildcard)
}
```

#let classes-2-kt = ```kt
class C(
    val b: B?
) : A(0, 0)
```

#let classes-2-vpr = ```java
predicate SharedC(this: Ref) {
  acc(SharedA(this), wildcard)
  acc(this.b, wildcard) &&
  (this.b != null ==>
  acc(SharedB(this.b), wildcard))
}
```

#let return-kt = ```kt
class T()

@Unique
fun return_unique(): T {
    // ...
}

fun return_shared(): T {
    // ...
}
```

#let return-vpr = ```java
predicate SharedT(this: Ref)
predicate UniqueT(this: Ref)

method return_unique()
returns(ret: Ref)
ensures acc(SharedT(ret), wildcard)
ensures UniqueT(ret)

method return_shared()
returns(ret: Ref)
ensures acc(SharedT(ret), wildcard)
```

#let param-kt = ```kt
fun arg_unique(
    @Unique t: T
) {
}

fun arg_shared(
    t: T
) {
}

fun arg_unique_b(
    @Unique @Borrowed t: T
) {
}

fun arg_shared_b(
    @Borrowed t: T
) {
}
```

#let param-vpr = ```java
method arg_unique(t: Ref)
requires acc(UniqueT(t))
requires acc(SharedT(t), wildcard)
ensures acc(SharedT(t), wildcard)

method arg_shared(t: Ref)
requires acc(SharedT(t), wildcard)
ensures acc(SharedT(t), wildcard)

method arg_unique_b(t: Ref)
requires acc(UniqueT(t))
requires acc(SharedT(t), wildcard)
ensures acc(UniqueT(t))
ensures acc(SharedT(t), wildcard)

method arg_shared_b(t: Ref)
requires acc(SharedT(t), wildcard)
ensures acc(SharedT(t), wildcard)
```