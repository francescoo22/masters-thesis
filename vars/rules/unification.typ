#import "../../config/proof-tree.typ": *
#import "../../config/utils.typ": *

// *********** Unify ***********

#let Ctx-Lub-Empty = prooftree(
  axiom($$),
  rule(label: "Ctx-LUB-Empty", $dot space lub space dot space = space dot$),
)

#let Ctx-Lub-Sym = prooftree(
  axiom($$),
  rule(label: "Ctx-LUB-Sym", $Delta_1 lub Delta_2 = Delta_2 lub Delta_1$),
)

#let Ctx-Lub-1 = {
  let a1 = $Delta_2 inangle(p) = alpha'' beta''$
  let a2 = $Delta_2 without p = Delta'_2$
  let a3 = $Delta_1 lub Delta'_2 = Delta'$
  let a4 = $Lub{alpha beta, alpha'' beta''} = alpha' beta'$
  prooftree(
    stacked-axiom((a1, a2), (a3, a4)),
    rule(label: "Ctx-LUB-1", $(p : alpha beta, Delta_1) lub Delta_2 = p : alpha' beta', Delta'$),
  )
}

#let Ctx-Lub-2 = prooftree(
  axiom($x in.not Delta_2$),
  axiom($Delta_1 lub Delta_2 = Delta'$),
  rule(n:2, label: "Ctx-LUB-2", $(x : alpha beta, Delta_1) lub Delta_2 = x : top, Delta'$),
)

#let Remove-Locals-Base = prooftree(
  axiom($$),
  rule(label: "Remove-Locals-Base", $dot triangle.filled.small.l Delta = dot$),
)

#let Remove-Locals-Keep = prooftree(
  axiom($root(p) = x$),
  axiom($Delta_1 inangle(x) = alpha' beta'$),
  axiom($Delta triangle.filled.small.l Delta_1 = Delta'$),
  rule(n:3, label: "Remove-Locals-Keep", $p : alpha beta, Delta triangle.filled.small.l Delta_1 = p : alpha beta, Delta'$),
)

#let Remove-Locals-Discard = prooftree(
  axiom($root(p) = x$),
  axiom($x in.not Delta_1$),
  axiom($Delta triangle.filled.small.l Delta_1 = Delta'$),
  rule(n:3, label: "Remove-Locals-Discard", $p : alpha beta, Delta triangle.filled.small.l Delta_1 = Delta'$),
)

#let Unify = prooftree(
  axiom($Delta_1 lub Delta_2 = Delta_lub$),
  axiom($Delta_lub triangle.filled.small.l Delta = Delta'$),
  rule(n:2, label: "Unify", $unify(Delta, Delta_1, Delta_2) = Delta'$),
)

// *********** Normalize ***********

#let N-Empty = prooftree(
  axiom($$),
  rule(label: "N-Empty", $norm(dot) = dot$)
)

#let N-Rec = {
  let a1 = $Lub(alpha_i beta_i | p_i = p_0 and 0 <= i <= n) = ablub$
  let a2 = $norm(p_i: alpha_i beta_i | p_i != p_0 and 0 <= i <= n) = p'_0 : alpha'_0 beta'_0, ..., p'_m : alpha'_m beta'_m$
  prooftree(
    stacked-axiom((a1,), (a2,)),
    rule(label: "N-Rec", $norm(p_0\: alpha_0 beta_0, ..., p_n\: alpha_n beta_n) = p_0 : ablub, p'_0 : alpha'_0 beta'_0, ..., p'_m : alpha'_m beta'_m$)
  )
}
