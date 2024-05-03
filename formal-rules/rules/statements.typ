#import "../proof-tree.typ": *
#import "../vars.typ": *

// ****************** Statements semantics ******************

#let Decl = prooftree(
  axiom(""),
  rule(label: "Decl", $mid(var x), x : top$),
)

#let Assign-Null = prooftree(
  axiom($Delta[p |-> unique] = Delta'$),
  rule(label: "Assign-Null", $mid(p = null)'$),
)

// TODO: define supset.eq?
#let Assign-Var-Unique = {
  let a0 = $p' supset.eq.not p$
  let a1 = $Delta(p) = alpha$
  let a2 = $Delta(p') = unique$
  let a3 = $Delta tr "subpaths"(p') = p'.overline(f_0) : alpha_0 beta_0, ..., p'.overline(f_n) : alpha_n beta_n$
  let a4 = $Delta[p' |-> top] = Delta_1$
  let a5 = $Delta_1[p |-> unique] = Delta'$
  prooftree(
    axiom(stack(
      spacing: 1em,
      stack(dir: ltr, spacing: 3em, a0, a1, a2, a4),
      stack(dir: ltr, spacing: 3em, a3, a5),
    )),
    rule(label: "Assign-Var-Unique", $mid(p = p')', p.overline(f_0) : alpha_0 beta_0, ..., p.overline(f_n) : alpha_n beta_n$),
  )
}

#let Assign-Var-Shared = {
  let a0 = $p' supset.eq.not p$
  let a1 = $Delta(p) = alpha$
  let a2 = $Delta(p') = shared$
  let a3 = $Delta tr sp(p') = p'.overline(f_0) : alpha_0 beta_0, ..., p'.overline(f_n) : alpha_n beta_n$
  let a4 = $Delta[p |-> shared] = Delta'$
  prooftree(
    axiom(stack(
      spacing: 1em,
      stack(dir: ltr, spacing: 3em, a0, a1, a2),
      stack(dir: ltr, spacing: 3em, a3, a4),
    )),
    rule(label: "Assign-Var-Shared", $mid(p = p')', p.overline(f_0) : alpha_0 beta_0, ..., p.overline(f_n) : alpha_n beta_n$),
  )
}

#let Begin = prooftree(
  axiom($mtype(m) = alpha_0 beta_0, ..., alpha_n beta_n -> alpha$),
  axiom($args(m) = x_0, ..., x_n$),
  rule(n:2, label: "Begin", $dot tr begin_m tl x_0 : alpha_0 beta_0, ..., x_n : alpha_n beta_n$),
)

#let Seq-Base = prooftree(
  axiom($$),
  rule(label: "Seq-Base", $mid(overline(s) equiv dot)$)
)

#let Seq-Rec = prooftree(
  axiom($mid(s_0)'$),
  axiom($Delta' tr overline(s') tl Delta''$),
  rule(n:2, label: "Seq-Rec", $mid(overline(s) equiv s_0\; overline(s'))''$)
)

// TODO: allow different expression in the guard
#let If = prooftree(
  axiom($Delta tr overline(s_1) tl Delta_1$),
  axiom($Delta tr overline(s_2) tl Delta_2$),
  axiom($unify(Delta, Delta_1, Delta_2) = Delta'$),
  rule(n:3, label: "If", $mid(fi e then overline(s_1) els overline(s_2))'$),
)

#let Assign-Call = prooftree(
  axiom($Delta(p) = alpha' beta'$),
  axiom($Delta tr m(overline(p)) tl Delta_1$),
  axiom($mtype(m) = alpha_0 beta_0, ..., alpha_n beta_n -> alpha beta$),
  axiom($Delta_1[x |-> alpha beta] = Delta'$),
  rule(n:4, label: "Assing-Call", $mid(p = m(overline(p)))'$)
)

// #let Call-Old = {
//   let a1 = $forall 0 <= i <= n : Delta(x_i) = alpha_i beta_i$
//   let a2 = $mtype(m) = alpha_0^m, beta_0^m, ..., alpha_n^m beta_n^m -> alpha_r beta_r$
//   let a4 = $forall 0 <= i, j <= n : (i != j and x_i = x_j) => alpha_i^m = shared$
//   let a5 = $Delta without (x_0, ..., x_n) = Delta'$
//   let a6 = $forall 0 <= i <= n : alpha_i beta_i ~> alpha_i^m beta_i^m ~> alpha'_i beta'_i$
//   let a7 = $norm(x_0 : alpha'_0 beta'_0, ..., x_n : alpha'_n beta'_n) = x'_0 : alpha''_0 beta''_0, ..., x'_m : alpha''_m beta''_m$
//   prooftree(
//     axiom(stack(
//       spacing: 1em,
//       stack(dir: ltr, spacing: 3em, a1, a2),
//       stack(dir: ltr, spacing: 3em, a4, a5),
//       stack(dir: ltr, spacing: 3em, a6, a7)
//     )),
//     rule(label: "Call-Old", $mid(m(x_0, ..., x_n))', x'_0 : alpha''_0 beta''_0, ..., x'_m : alpha''_m beta''_m$)
//   )
//   v(1em)
// }

#let Call = {
  let a0 = $forall 0 <= i <= n : Delta tr std(p_i, alpha_i)$
  let a1 = $forall 0 <= i <= n : Delta(p_i) = alpha_i beta_i$
  let a2 = $mtype(m) = alpha_0^m, beta_0^m, ..., alpha_n^m beta_n^m -> alpha_r beta_r$
  // TODO: understand if there are any issues with this a3, a4
  let a3 = $forall 0 <= i, j <= n : (i != j and p_i = p_j) => alpha_i^m = shared$
  let a4 = $forall 0 <= i, j <= n : p_i supset p_j => (Delta(p_j) = shared or a_i^m = a_j^m = shared)$
  let a5 = $Delta without (p_0, ..., p_n) = Delta'$
  let a6 = $forall 0 <= i <= n : alpha_i beta_i ~> alpha_i^m beta_i^m ~> alpha'_i beta'_i$
  let a7 = $norm(p_0 : alpha'_0 beta'_0, ..., p_n : alpha'_n beta'_n) = p'_0 : alpha''_0 beta''_0, ..., p'_m : alpha''_m beta''_m$
  prooftree(
    axiom(stack(
      spacing: 1em,
      stack(dir: ltr, spacing: 3em, a0, a1),
      stack(dir: ltr, spacing: 3em, a2, a3),
      stack(dir: ltr, spacing: 3em, a4, a5),
      stack(dir: ltr, spacing: 3em, a6, a7)
    )),
    rule(label: "Call", $mid(m(p_0, ..., p_n))', p'_0 : alpha''_0 beta''_0, ..., p'_m : alpha''_m beta''_m$)
  )
}