#import "../../config/proof-tree.typ": *
#import "../../config/utils.typ": *

// ****************** Statements typing rules ******************

#let Decl = prooftree(
  axiom($x in.not Delta$),
  rule(label: "Decl", $mid(var x), x : top$),
)

#let Assign-Null = prooftree(
  axiom($Delta(p) = alpha beta$),
  axiom($Delta[p |-> unique] = Delta'$),
  rule(n:2, label: "Assign-Null", $mid(p = null)'$),
)

// TODO: in the case where the lhs is borrowed, should we require std?
#let Assign-Unique = {
  let a0 = $p' subset.sq.eq.not p$
  let a1 = $Delta(p) = alpha beta$
  let a2 = $Delta(p') = unique$
  let a3 = $Delta tr sp(p') = p'.overline(f_0) : alpha_0 beta_0, ..., p'.overline(f_n) : alpha_n beta_n$
  let a4 = $Delta[p' |-> top] = Delta_1$
  let a5 = $Delta_1[p |-> unique] = Delta'$
  prooftree(
    stacked-axiom(
      (a0, a1, a2, a4),
      (a3, a5)
    ),
    rule(label: "Assign-Unique", $mid(p = p')', p.overline(f_0) : alpha_0 beta_0, ..., p.overline(f_n) : alpha_n beta_n$),
  )
}

#let Assign-Shared = {
  let a0 = $p' subset.sq.eq.not p$
  let a1 = $Delta(p) = alpha$
  let a2 = $Delta(p') = shared$
  let a3 = $Delta tr sp(p') = p'.overline(f_0) : alpha_0 beta_0, ..., p'.overline(f_n) : alpha_n beta_n$
  let a4 = $Delta[p |-> shared] = Delta'$
  prooftree(
    stacked-axiom(
      (a0, a1, a2),
      (a3, a4),
    ),
    rule(label: "Assign-Shared", $mid(p = p')', p.overline(f_0) : alpha_0 beta_0, ..., p.overline(f_n) : alpha_n beta_n$),
  )
}

#let Assign-Borrowed-Field = {
  let a0 = $p'.f subset.sq.eq.not p$
  let a1 = $Delta(p) = alpha beta$
  let a2 = $Delta(p'.f) = alpha' borrowed$
  let a3 = $alpha' != top$
  let a4 = $(beta = borrowed) => (alpha' = unique)$
  let a5 = $Delta[p'.f |-> top] = Delta_1$
  let a6 = $Delta tr sp(p'.f) = p'.f.overline(f_0) : alpha_0 beta_0, ..., p'.f.overline(f_n) : alpha_n beta_n$
  let a7 = $Delta_1[p |-> alpha'] = Delta'$
  
  prooftree(
    stacked-axiom(
      (a0, a1, a2), (a3, a4, a5), (a6, a7)
    ),
    rule(
      label: $"Assign-"borrowed"-Field"$,
      $mid(p = p'.f)', p.overline(f_0) : alpha_0 beta_0, ..., p.overline(f_n) : alpha_n beta_n$
    )
  )
}

#let Begin = prooftree(
  axiom($mtype(m) = alpha_0 beta_0, ..., alpha_n beta_n -> alpha$),
  axiom($args(m) = x_0, ..., x_n$),
  rule(n:2, label: "Begin", $dot tr begin_m tl x_0 : alpha_0 beta_0, ..., x_n : alpha_n beta_n$),
)

#let Seq-New = prooftree(
  axiom($Delta tr s_1 tl Delta_1$),
  axiom($Delta_1 tr s_2 tl Delta'$),
  rule(n:2, label: "Seq", $mid(s_1 \; s_2)'$)
)

#let If = {
  let a1 = $Delta(p_1) != top$
  let a2 = $Delta(p_2) != top$
  let a3 = $Delta tr s_1 tl Delta_1$
  let a4 = $Delta tr s_2 tl Delta_2$
  let a5 = $unify(Delta, Delta_1, Delta_2) = Delta'$
  prooftree(
    stacked-axiom((a1, a2), (a3, a4, a5)),
    rule(label: "If", $mid(fi p_1 == p_2 then s_1 els s_2)'$),
  )
}

#let Assign-Call = {
  let a1 = $Delta(p) = alpha' beta'$
  let a2 = $Delta tr m(overline(p)) tl Delta_1$
  let a3 = $mtype(m) = alpha_0 beta_0, ..., alpha_n beta_n -> alpha$
  let a4 = $(beta' = borrowed) => (alpha = unique)$
  let a5 = $Delta_1[p |-> alpha] = Delta'$
  prooftree(
    stacked-axiom((a1, a2), (a3,), (a4, a5)),
    rule(label: "Assign-Call", $mid(p = m(overline(p)))'$)
  )
}


#let Call = {
  let a0 = $forall 0 <= i <= n : Delta(p_i) = alpha_i beta_i$
  let a1 = $mtype(m) = alpha_0^m, beta_0^m, ..., alpha_n^m beta_n^m -> alpha_r$
  let a2 = $forall 0 <= i <= n : Delta tr std(p_i, alpha_i^m beta_i^m)$
  let a3 = $forall 0 <= i, j <= n : (i != j and p_i = p_j) => alpha_i^m = shared$
  let a4 = $forall 0 <= i, j <= n : p_i subset.sq p_j => (Delta(p_j) = shared or alpha_i^m = alpha_j^m = shared)$
  // Note: If we have more permissions than std, by passing to borrowed we should be able to keep those permissions. Anyway this is probably going to be false in the future so it's ok to keep it as it is
  let a5 = $Delta minus.circle (p_0, ..., p_n) = Delta'$
  let a6 = $forall 0 <= i <= n : alpha_i beta_i ~> alpha_i^m beta_i^m ~> alpha'_i beta'_i$
  let a7 = $norm(p_0 : alpha'_0 beta'_0, ..., p_n : alpha'_n beta'_n) = p'_0 : alpha''_0 beta''_0, ..., p'_m : alpha''_m beta''_m$
  prooftree(
    stacked-axiom(
      (a0,), (a1,), (a2,), (a3,), (a4,), (a5, a6), (a7,)
    ),
    rule(label: "Call", $mid(m(p_0, ..., p_n))', p'_0 : alpha''_0 beta''_0, ..., p'_m : alpha''_m beta''_m$)
  )
}

#let Return-p = {
  let a1 = $mtype(m) = alpha_0^m, beta_0^m, ..., alpha_n^m beta_n^m -> alpha_r$
  let a2 = $Delta(p) = alpha$
  let a3 = $alpha rel alpha_r$
  let a4 = $Delta tr std(p, alpha_r)$
  let a5 = $forall 0 <= i, j <= n : (alpha_i beta_i != unique) => Delta tr std(p_i, alpha_i beta_i)$
  prooftree(
    stacked-axiom(
      (a1, a2, a3),
      (a4, a5)
    ),
    rule(label: "Return-p", $Delta tr ret_m space p tl dot$),
  )

}

#let U-Fun = prooftree(
    axiom($mid(s)'$),
    axiom($unify(Delta, Delta, Delta') = Delta_1$),
    rule(n:2, label: "", $u_s (Delta) = Delta_1$)
  )