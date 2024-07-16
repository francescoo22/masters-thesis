#import "../../config/proof-tree.typ": *
#import "../../config/utils.typ": *

// ************** Annotations Relations **************

#let A-id = prooftree(
  axiom($$),
  rule(label: "Rel-Id", $alpha beta rel alpha beta$),
)

#let A-trans = prooftree(
  axiom($alpha beta rel alpha' beta'$),
  axiom($alpha' beta' rel alpha'' beta''$),
  rule(n:2, label: "Rel-Trans", $alpha beta rel alpha'' beta''$),
)

#let A-bor-sh = prooftree(
  axiom($$),
  rule(label: "Rel-Sb-T", $shared borrowed rel top$),
)

#let A-sh = prooftree(
  axiom($$),
  rule(label: "Rel-S-Sb", $shared rel shared borrowed$),
)

#let A-bor-un = prooftree(
  axiom($$),
  rule(label: "Rel-Ub-Sb", $unique borrowed rel shared borrowed$),
)

#let A-un-1 = prooftree(
  axiom($$),
  rule(label: "Rel-U-S", $unique rel shared$),
)

#let A-un-2 = prooftree(
  axiom($$),
  rule(label: "Rel-U-Ub", $unique rel unique borrowed$),
)

// ************** Parameters Passing **************

#let Pass-Bor = prooftree(
  axiom($alpha beta rel alpha' borrowed$),
  rule(label: "Pass-B", $alpha beta ~> alpha' borrowed ~> alpha beta$)
)

#let Pass-Un = prooftree(
  axiom($$),
  rule(label: "Pass-U", $unique ~> unique ~> top$)
)

#let Pass-Sh = prooftree(
  axiom($alpha rel shared$),
  rule(label: "Pass-S", $alpha ~> shared ~> shared$)
)