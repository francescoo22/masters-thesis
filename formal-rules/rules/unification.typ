#import "../proof-tree.typ": *
#import "../vars.typ": *

// *********** Unify ***********

// TODO: too much complicated, needs to be re-designed

#let U-Empty-1 = prooftree(
  axiom($$),
  rule(label: "U-Empty-1", $unify(Delta, dot, dot) = dot$),
)

#let U-Empty-2 = prooftree(
  axiom($$),
  rule(label: "U-Empty-2", $unify(Delta, dot, (x: alpha beta, Delta_2)) = unify(Delta, dot, Delta_2)$),
)

#let U-Field-1 = prooftree(
  axiom($root(p.f) = x$),
  axiom($x in.not Delta$),
  rule(n:2, label: "U-Field-1", $unify(Delta, dot, (p.f: alpha beta, Delta_2)) = unify(Delta, dot, Delta_2)$),
)

#let U-Field-2 = prooftree(
  axiom($root(p.f) = x$),
  axiom($Delta(x) = alpha'' beta''$),
  axiom($dot inangle(p.f) = alpha' beta'$),
  axiom($lub{alpha beta, alpha' beta'} = ablub$),
  rule(n:4, label: "U-Field-2", $unify(Delta, dot, (p.f: alpha beta, Delta_2)) = p.f: ablub, unify(Delta, dot, Delta_2)$),
)

#let U-Var-1 = prooftree(
  axiom($x in.not Delta$),
  rule(label: "U-Var-1", $unify(
      Delta,
      (x: alpha beta, Delta_1),
      Delta_2
    ) 
    = unify(Delta, Delta_1, Delta_2)$),
)

#let U-Var-2 = prooftree(
  axiom($Delta(x) = alpha' beta'$),
  axiom($Delta_2(x) = alpha'' beta''$),
  axiom($Delta_2 without x = Delta'_2$),
  axiom($lub{alpha beta, alpha'' beta''} = alpha_(union.sq), beta_union.sq$),
  rule(n:4, label: "U-Var-2", $unify(
      Delta,
      (x: alpha beta, Delta_1),
      Delta_2
    )
    = x : ablub, unify(Delta, Delta_1, Delta'_2)$),
)

#let U-Field-3 = prooftree(
  axiom($root(p.f) = x$),
  axiom($x in.not Delta$),
  rule(n: 2, label: "U-Field-3", $unify(
      Delta,
      (p.f: alpha beta, Delta_1),
      Delta_2
    ) 
    = unify(Delta, Delta_1, Delta_2)$),
)

#let U-Field-4 = prooftree(
  axiom($root(p.f) = x$),
  axiom($Delta(x) = alpha' beta'$),
  axiom($Delta_2(p.f) = alpha'' beta''$),
  axiom($Delta_2 without p.f = Delta'_2$),
  axiom($lub{alpha beta, alpha'' beta''} = ablub$),
  rule(n:5, label: "U-Field-4", $unify(
      Delta,
      (p.f: alpha beta, Delta_1),
      Delta_2
    )
    = p.f : ablub, unify(Delta, Delta_1, Delta'_2)$),
)

// *********** Normalize ***********

#let N-Empty = prooftree(
  axiom($$),
  rule(label: "N-Empty", $norm(dot) = dot$)
)

#let N-Rec = prooftree(
  axiom($lub(alpha_i beta_i | x_i = x_0 and i <= n) = ablub$),
  axiom($norm(x_i: alpha_i beta_i | x_i != x_0) = x'_0 : alpha'_0 beta'_0, ..., x'_m : alpha'_m beta'_m$),
  rule(n:2, label: "N-rec", $norm(x_0\: alpha_0 beta_0, ..., x_n\: alpha_n beta_n) = x_0 : ablub, x'_0 : alpha'_0 beta'_0, ..., x'_m : alpha'_m beta'_m$)
)