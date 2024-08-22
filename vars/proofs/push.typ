#import "../../config/proof-tree.typ": *
#import "../../config/utils.typ": *

#let template = prooftree(
  axiom($$),
  rule(label: "", $$),
)

#let push-1 = prooftree(
  axiom($push(this\: unique borrowed, value: unique): shared {...}$),
  rule(label: "M-type", $mtype(push) = unique borrowed, unique -> shared$),
  axiom($push(this\: unique borrowed, value: unique): shared {...}$),
  rule(label: "M-args", $args(push) = this, value$),
  rule(n:2, label: "Begin", $dot tr begin_push tl this: unique borrowed, value: unique$),
)

#let push-2 = prooftree(
  axiom($r != this$),
  axiom($r != value$),
  axiom($r in.not dot$),
  rule(n:2, label: "Not-In-Rec", $r in.not value: unique$),
  rule(n:2, label: "Not-In-Rec", $r in.not this: unique borrowed, value: unique$),
  rule(label: "Decl", $this: unique borrowed, value: unique tr var r tl  this: unique borrowed, value: unique, r: top$),
)

#let push-3 = {
  let a1 = $this."root" subset.sq.eq.not r$
  let a2 = $Delta(r) = top$
  let a3 = $Delta(this."root") = unique borrowed$
  let a4 = $unique != top$
  let a5 = $(dot = borrowed) => (unique = unique)$
  let a6 = $Delta[this."root" |-> top] = Delta, this."root": top equiv Delta_1$
  let a7 = $Delta tr sp(this."root") = dot$
  let a8 = $Delta_1 [r |-> unique] = Delta'$
  prooftree(
    stacked-axiom((a1,a2,a3,a4, a5), (a6, a7, a8)),
    rule(label: "", $Delta equiv this: unique borrowed, value: unique, r: top tr r = this."root" tl this: unique borrowed, value: unique, r: unique, this."root": top equiv Delta'$),
  )
}
