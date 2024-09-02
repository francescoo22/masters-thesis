#let intro-kt = ```kt
class A(
    var n: Int
)

fun f(x: A, y: A) {
    x.n = 1
    y.n = 2
}

fun use_f(x: A) {
    f(x, x)
}
```

#let intro-vpr = ```vpr
field n: Int

method f(x: Ref, y: Ref)
requires acc(x.n) && acc(y.n)
{
  x.n := 1
  y.n := 2
}

method use_f(x: Ref)
requires acc(x.n)
{
  f(x, x) // verification error
}
```

#let intro-kt-annotated = ```kt
class A(var n: Int)

fun f(@Unique @Borrowed x: A, @Unique @Borrowed y: A) {
    x.n = 1
    y.n = 2
}

fun use_f(@Unique x: A) {
    f(x, x) // annotations checking error
}
```

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

#let classes-vpr = ```vpr
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

#let return-vpr = ```vpr
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

#let param-vpr = ```vpr
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

#let classes-unique-vpr = ```vpr
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

#let full-encoding = ```vpr
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

#let receiver-vpr = ```vpr
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

#let unique-call-vpr = ```vpr
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

#let shared-call-vpr = ```vpr
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

#let constructor-vpr = ```vpr
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

// ************* Chapter 5 comparison *************

#let grammar_annotations-5 = ```
class C(
  f1: unique,
  f2: shared
)

m1() : unique { 
  ... 
}

m2(this: unique) : shared {
  ... 
}

m3(
  x1: unique,
  x2: unique borrowed,
  x3: shared,
  x4: shared borrowed
) {
  ...
}
```

#let kt_annotations-5 = ```kt
class C(
    @property:Unique var f1: Any,
    var f2: Any
)

@Unique fun m1(): Any {
    /* ... */
}

fun @receiver:Unique Any.m2() {
    /* ... */
}

fun m3(
    @Unique x1: Any,
    @Unique @Borrowed x2: Any,
    x3: Any,
    @Borrowed x4: Any
) {
    /* ... */
}
```

#let compare-grammar-kt = align(
  center,
  figure(
    caption: "Comparison between the grammar and annotated Kotlin",
    grid(
      columns: (auto, auto),
      column-gutter: 2em,
      row-gutter: .5em,
      grammar_annotations-5, kt_annotations-5
    )
  )
)

#let unfold-shared-kt = ```kt
class A(
    val n: Int
)

class B(
    val a: A
)

fun f(b: B): Int {
    return b.a.n
}
```

#let unfold-shared-vpr = ```vpr
field n: Int, a: Ref

predicate SharedA(this: Ref) {
  acc(this.n, wildcard)
}

predicate SharedB(this: Ref) {
  acc(this.a, wildcard) &&
  acc(SharedA(this.a), wildcard)
}

method f(b: Ref) returns(res: Int)
requires acc(SharedB(b), wildcard)
ensures acc(SharedB(b), wildcard)
{
  unfold acc(SharedB(b), wildcard)
  unfold acc(SharedA(b.a), wildcard)
  res := b.a.n
}
```

#let unfold-unique-kt = ```kt
class A(
    var n: Int
)

class B(
    @property:Unique
    var a: A
)

fun f(
    @Unique b: B
): Int {
    return b.a.n
}
```

#let unfold-unique-vpr = ```vpr
field n: Int, a: Ref

predicate UniqueA(this: Ref) {
  acc(this.n, write)
}

predicate UniqueB(this: Ref) {
  acc(this.a, write) &&
  acc(UniqueA(this.a), write)
}

method f(b: Ref) returns(res: Int)
requires acc(UniqueB(b), write)
ensures acc(UniqueB(b), write)
{
  unfold acc(UniqueB(b), write)
  unfold acc(UniqueA(b.a), write)
  res := b.a.n
  fold acc(UniqueA(b.a), write)
  fold acc(UniqueB(b), write)
}
```

#let inhale-shared-kt = ```kt
class A(
    val x: Int,
    var y: Int
)

fun f(
    a: A
) {
    a.y = 1
}
```

#let inhale-shared-vpr = ```vpr
field x: Int, y: Int

predicate SharedA(this: Ref) {
  acc(this.x, wildcard)
}

method f(a: Ref) returns(res: Int)
requires acc(SharedA(a), wildcard)
ensures acc(SharedA(a), wildcard)
{
  inhale acc(a.y, write)
  a.y := 1
  exhale acc(a.y, write)
}
```