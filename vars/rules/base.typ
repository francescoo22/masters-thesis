#import "../../config/proof-tree.typ": *
#import "../../config/utils.typ": *

// ****************** General ******************

#let M-Type = prooftree(
  axiom($m(x_0: alpha_0 beta_0, ..., x_n: alpha_n beta_n): alpha {begin_m; s; ret_m e} in P$),
  rule(label: "M-Type", $mtype(m) = alpha_0 beta_0, ..., alpha_n beta_n -> alpha$),
)
  
#let M-Args = prooftree(
  axiom($m(x_0: alpha_0 beta_0, ..., x_n: alpha_n beta_n): alpha {begin_m; s; ret_m e} in P$),
  rule(label: "M-Args", $args(m) = x_0, ..., x_n$),
)

// ****************** Context ******************

#let Not-In-Base = prooftree(
  axiom(""),
  rule(label: "Not-In-Base", $p in.not dot$),
)

#let Not-In-Rec = prooftree(
  axiom($p != p'$),
  axiom($p in.not Delta$),
  rule(n:2, label: "Not-In-Rec", $p in.not (p' : alpha beta, Delta)$),
)

#let Root-Base = prooftree(
  axiom(""),
  rule(label: "Root-Base", $root(x) = x$),
)

#let Root-Rec = prooftree(
  axiom($root(p) = x$),
  rule(label: "Root-Rec", $root(p.f) = x$),
)

#let Ctx-Base = prooftree(
  axiom(""),
  rule(label: "Ctx-Base", $dot ctx$),
)

#let Ctx-Rec = prooftree(
  axiom($Delta ctx$),
  axiom($p in.not Delta$),
  rule(n:2, label: "Ctx-Rec", $p: alpha beta, Delta ctx$),
)

#let Lookup-Base = prooftree(
  axiom($(p: alpha beta, Delta) ctx$),
  rule(label: "Lookup-Base", $(p: alpha beta, Delta) inangle(p) = alpha beta$),
)

#let Lookup-Rec = {
  let a1 = $(p: alpha beta, Delta) ctx$
  let a2 = $p != p'$
  let a3 = $Delta inangle(p') = alpha' beta'$
  prooftree(
    stacked-axiom((a1,), (a2, a3)),
    rule(label: "Lookup-Rec", $(p: alpha beta, Delta) inangle(p') = alpha' beta'$),
  )
}


#let Lookup-Default = prooftree(
  axiom($type(p) = C$),
  axiom($class C(overline(f': alpha'_f), f: alpha, overline(f'': alpha''_f))$),
  rule(n:2, label: "Lookup-Default", $dot inangle(p.f) = alpha$),
)

#let Remove-Empty = prooftree(
  axiom(""),
  rule(label: "Remove-Empty", $dot without p = dot$),
)

#let Remove-Base = prooftree(
  axiom(""),
  rule(label: "Remove-Base", $(p: alpha beta, Delta) without p = Delta$),
)

#let Remove-Rec = prooftree(
  axiom($Delta without p = Delta'$),
  axiom($p != p'$),
  rule(n:2, label: "Remove-Rec", $(p': alpha beta, Delta) without p = p': alpha beta, Delta'$),
)

#let SubPath-Base = prooftree(
  axiom(""),
  rule(label: "Sub-Path-Base", $p subset.sq p.f$),
)

#let SubPath-Rec = prooftree(
  axiom($p subset.sq p'$),
  rule(label: "Sub-Path-Rec", $p subset.sq p'.f$),
)

#let SubPath-Eq-1 = prooftree(
  axiom($p = p'$),
  rule(label: "Sub-Path-Eq-1", $p subset.sq.eq p'$),
)

#let SubPath-Eq-2 = prooftree(
  axiom($p subset.sq p'$),
  rule(label: "Sub-Path-Eq-2", $p subset.sq.eq p'$),
)

#let Remove-SupPathsEq-Empty = prooftree(
  axiom(""),
  rule(label: "Deep-Remove-Empty", $dot minus.circle p = dot$),
)

#let Remove-SupPathsEq-Discard = prooftree(
  axiom($p subset.sq.eq p'$),
  axiom($Delta minus.circle p = Delta'$),
  rule(n:2, label: "Deep-Remove-Discard", $(p': alpha beta, Delta) minus.circle p = Delta'$),
)

#let Remove-SupPathsEq-Keep = prooftree(
  axiom($p subset.not.sq.eq p'$),
  axiom($Delta minus.circle p = Delta'$),
  rule(n:2, label: "Deep-Remove-Keep", $(p': alpha beta, Delta) minus.circle p = (p': alpha beta, Delta')$),
)

#let Replace = prooftree(
  axiom($Delta minus.circle p = Delta'$),
  rule(label: "Replace", $Delta[p |-> alpha beta] = Delta', p: alpha beta$),
)

#let Get-SupPaths-Empty = prooftree(
  axiom(""),
  rule(label: "Get-Sup-Paths-Empty", $dot tr sp(p) = dot$),
)

#let Get-SupPaths-Discard = prooftree(
  axiom($not (p subset.sq p')$),
  axiom($Delta tr sp(p) = p_0 : alpha_0 beta_0, ..., p_n : alpha_n beta_n$),
  rule(n: 2, label: "Get-Sup-Paths-Discard", $p': alpha beta, Delta tr sp(p) = p_0 : alpha_0 beta_0, ..., p_n : alpha_n beta_n$),
)

#let Get-SupPaths-Keep = prooftree(
  axiom($p subset.sq p'$),
  axiom($Delta tr sp(p) = p_0 : alpha_0 beta_0, ..., p_n : alpha_n beta_n$),
  rule(n: 2, label: "Get-Sup-Paths-Keep", $p': alpha beta, Delta tr sp(p) = p': alpha beta, p_0 : alpha_0 beta_0, ..., p_n : alpha_n beta_n$),
)

// ************ Get ************

#let Get-Var = prooftree(
  axiom($Delta inangle(x) = alpha beta$),
  rule(label: "Get-Var", $Delta(x) = alpha beta$)
)

#let Get-Path = prooftree(
  axiom($Delta(p) = alpha beta$),
  axiom($Delta inangle(p.f) = alpha'$),
  rule(n: 2, label: "Get-Path", $Delta(p.f) = Lub{alpha beta, alpha'}$)
)

#let Std-Empty = prooftree(
  axiom(""),
  rule(label: "Std-Empty", $dot tr std(p, alpha beta)$),
)

#let Std-Rec-1 = prooftree(
  axiom($not (p subset.sq p')$),
  axiom($Delta tr std(p, alpha beta)$),
  rule(n:2, label: "Std-Rec-1", $p' : alpha beta, Delta tr std(p, alpha beta)$),
)

#let Std-Rec-2 = {
  let a1 = $p subset.sq p'$
  let a2 = $root(p) = x$
  let a3 = $(x : alpha beta) (p') = alpha'' beta''$
  let a4 = $alpha' beta' rel alpha'' beta''$
  let a5 = $Delta tr std(p, alpha beta)$
  prooftree(
    stacked-axiom((a1, a2), (a3, a4, a5)),
    rule(label: "Std-Rec-2", $p' : alpha' beta', Delta tr std(p, alpha beta)$),
  )
}
