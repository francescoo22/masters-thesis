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
@Unique
fun returnUnique(): T {
    // ...
}

fun returnShared(): T {
    // ...
}
```

#let return-vpr = ```java
method returnUnique()
returns(ret: Ref)
ensures acc(SharedT(ret), wildcard)
ensures acc(UniqueT(ret), write)

method returnShared()
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

#let param-table = table(
  columns: (auto, auto, auto, auto, auto),
  inset: 8pt,
  align: horizon,
  table.header(
    "", "Unique", "Unique\nBorrowed", "Shared", "Shared\nBorrowed",
  ),
  "Requires Shared Predicate", $checkmark$, $checkmark$, $checkmark$, $checkmark$,
  "Ensures Shared Predicate", $checkmark$, $checkmark$, $checkmark$, $checkmark$,
  "Requires Unique Predicate", $checkmark$, $checkmark$, "✗", "✗",
  "Ensures Unique Predicate", "✗", $checkmark$, "✗", "✗",
)

#let receiver-kt = ```kt
fun @receiver:Unique T.uniqueReceiver() {}

fun @receiver:Unique @receiver:Borrowed T.uniqueBorrowedReceiver() {}
```

#let receiver-vpr = ```java
method uniqueReceiver(this: Ref)
requires acc(SharedT(this), wildcard)
requires acc(UniqueT(this), write)
ensures acc(SharedT(this), wildcard)

method uniqueBorrowedReceiver(this: Ref)
requires acc(SharedT(this), wildcard)
requires acc(UniqueT(this), write)
ensures acc(SharedT(this), wildcard)
ensures acc(UniqueT(this), write)
```

#let unique-call-kt = ```kt
fun uniqueParam(
    @Unique t: T
) {
}

fun uniqueBorrowedParam(
    @Unique @Borrowed t: T
) {
}

fun call(
    @Unique @Borrowed t1: T,
    @Unique t2: T
) {
    uniqueBorrowedParam(t1)
    uniqueBorrowedParam(t2)
    uniqueParam(t2)
}
```

#let unique-call-vpr = ```java
method uniqueParam(t: Ref)
requires acc(UniqueT(t), write) && acc(SharedT(t), wildcard)
ensures acc(SharedT(t), wildcard)

method uniqueBorrowedParam(t: Ref)
requires acc(UniqueT(t), write) && acc(SharedT(t), wildcard)
ensures acc(UniqueT(t), write) && acc(SharedT(t), wildcard)

method call(t1: Ref, t2: Ref)
requires acc(UniqueT(t1), write) && acc(SharedT(t1), wildcard)
requires acc(UniqueT(t2), write) && acc(SharedT(t2), wildcard)
ensures acc(UniqueT(t1), write) && acc(SharedT(t1), wildcard)
ensures acc(SharedT(t2), wildcard)
{
  uniqueBorrowedParam(t1)
  uniqueBorrowedParam(t2)
  uniqueParam(t2)
}
```

#let shared-call-kt = ```kt
fun sharedParam(
    t: T
) {
}

fun sharedBorrowedParam(
    @Borrowed t: T
) {
}

fun call(@Unique t: T) {
    sharedBorrowedParam(t)
    sharedParam(t)
}
```

#let shared-call-vpr = ```java
method sharedParam(t: Ref)
requires acc(SharedT(t), wildcard)
ensures acc(SharedT(t), wildcard)

method sharedBorrowedParam(t: Ref)
requires acc(SharedT(t), wildcard)
ensures acc(SharedT(t), wildcard)

method call(t: Ref)
requires acc(UniqueT(t), write) && acc(SharedT(t), wildcard)
ensures acc(SharedT(t), wildcard)
{
  exhale acc(UniqueT(t), write)
  inhale acc(UniqueT(t), write)
  sharedBorrowedParam(t)

  exhale acc(UniqueT(t), write)
  sharedParam(t)
}
```

#let constructor-kt = ```kt
class A(val x: Int, var y: Int)

class B(@property:Unique var a1: A, var a2: A)
```

#let constructor-vpr = ```java
method constructorA(p1: Int, p2: Int) returns (ret: Ref)
  ensures acc(SharedA(ret), wildcard)
  ensures acc(UniqueA(ret), write)
  ensures unfolding acc(SharedA(ret), wildcard) in
    ret.x == p1
  ensures unfolding acc(UniqueA(ret), write) in
    ret.x == p1 && ret.y == p2

method constructorB(p1: Ref, p2: Ref) returns (ret: Ref)
  requires acc(UniqueA(p1), write)
  requires acc(SharedA(p1), wildcard)
  requires acc(SharedA(p2), wildcard)
  ensures acc(SharedB(ret), wildcard)
  ensures acc(UniqueB(ret), write)
  ensures unfolding acc(UniqueB(ret), write) in
    ret.a1 == p1 && ret.a2 == p2
```