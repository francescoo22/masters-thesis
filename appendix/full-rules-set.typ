#import "../config/utils.typ": *
#import "../vars/rules/base.typ": *
#import "../vars/rules/relations.typ": *
#import "../vars/rules/unification.typ": *
#import "../vars/rules/statements.typ": *

#pagebreak(to:"odd")

= Typing Rules

== General

#display-rules(
  M-Type, "",
  M-Args, "",
)

== Context

=== Well-Formed Contexts

#display-rules(
  Not-In-Base, Not-In-Rec,
  Ctx-Base, Ctx-Rec,
)

=== Lookup

#display-rules(
  Lookup-Base, Lookup-Rec,
  Lookup-Default, "",
)

=== Remove

#display-rules(
  Remove-Empty, Remove-Base,
  Remove-Rec, "",
)

== Sub-Paths and Sup-Paths

=== Definition

#display-rules(
  SubPath-Base, SubPath-Rec,
  SubPath-Eq-1, SubPath-Eq-2,
)

=== Deep Remove

#display-rules(
  Remove-SupPathsEq-Empty, "",
  Remove-SupPathsEq-Discard, "",
  Remove-SupPathsEq-Keep, "",
)

=== Replace

#display-rules(
  Replace, "",
)

=== Get Sup-Paths

#display-rules(
  Get-SupPaths-Empty, "",
  Get-SupPaths-Discard, "",
  Get-SupPaths-Keep, "",
)

== Relations between Annotations

=== Partial Ordering

#display-rules(
  A-id, A-trans,
  A-bor-sh, A-sh,
  A-bor-un, A-un-1,
  A-un-2, "",
)

=== Passing

#display-rules(
  Pass-Bor, Pass-Un,
  Pass-Sh, ""
)

== Paths

=== Root

#display-rules(
  Root-Base, Root-Rec,
)

=== Get

#display-rules(
  Get-Var, Get-Path,
)

=== Standard Form

#display-rules(
  Std-Empty, Std-Rec-1,
  Std-Rec-2, "",
)

== Unification

=== Pointwise LUB

#display-rules(
  Ctx-Lub-Empty, Ctx-Lub-Sym,
  Ctx-Lub-1, "",
  Ctx-Lub-2, "",
)

=== Removal of Local Declarations

#display-rules(
  Remove-Locals-Base, "",
  Remove-Locals-Keep, "",
  Remove-Locals-Discard, "",
)

=== Unify

#display-rules(
  Unify, ""
)

== Normalization

#display-rules(
  N-Empty, "",
  N-Rec, ""
)

== Statements Typing

#display-rules(
  Begin, "",
  Decl, Assign-Null,
  Seq-New, "",
  Assign-Unique, "",
  Assign-Shared, "",
  Assign-Borrowed-Field, "",
  Assign-Call, "",
  Call, "",
  If, "",
  Return-p, "",
)

// IMPROVE: derivation tree for the examples in chapter 5?