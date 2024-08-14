#let classes-kt = ```kt
open class A(
    val x: Int,
    var y: Int,
)

class B(
    val a1: A,
    var a2: A,
)

class C(
    val b: B?,
) : A(0, 0)
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

#let classes-unique-kt = ```kt
class A(
    val x: Int,
    var y: Int,
)

class B(
    @property:Unique
    val a1: A,
    val a2: A,
)



class C(
    @property:Unique
    val b: B?,
) : A(0, 0)
```

#let classes-unique-vpr = ```java
predicate UniqueA(this: Ref) {
  acc(this.x, wildcard) &&
  acc(this.y, write)
}

predicate UniqueB(this: Ref) {
  acc(this.a1, wildcard) && 
  acc(SharedA(this.a1), wildcard) &&
  acc(UniqueA(this.a1), write) &&
  acc(this.a2, wildcard) &&
  acc(SharedA(this.a2), wildcard) &&
}

predicate UniqueC(this: Ref) {
  acc(this.b, wildcard) &&
  (this.b != null ==>
  acc(SharedB(this.b), wildcard)) &&
  (this.b != null ==>
  acc(UniqueB(this.b), write)) &&
  acc(UniqueA(this), write)
}
```

#let full-encoding = ```java
field bf$a1: Ref
field bf$a2: Ref
field bf$b: Ref
field bf$x: Ref
field bf$y: Ref

predicate p$c$A$shared(this: Ref) {
  acc(this.bf$x, wildcard) &&
  df$rt$isSubtype(df$rt$typeOf(this.bf$x), df$rt$intType())
}

predicate p$c$B$shared(this: Ref) {
  acc(this.bf$a1, wildcard) && 
  acc(p$c$A$shared(this.bf$a1), wildcard) &&
  df$rt$isSubtype(df$rt$typeOf(this.bf$a1), df$rt$T$c$A())
}

predicate p$c$C$shared(this: Ref) {
  acc(this.bf$b, wildcard) &&
  (this.bf$b != df$rt$nullValue() ==>
  acc(p$c$B$shared(this.bf$b), wildcard)) &&
  acc(p$c$A$shared(this), wildcard) &&
  df$rt$isSubtype(df$rt$typeOf(this.bf$b), df$rt$nullable(df$rt$T$c$B()))
}
```