#import "proof-tree.typ": *
#import "@preview/ctheorems:1.1.2": *

// *** NAMES ***

#let CL = "CL"
#let unique = "unique"
#let shared = "shared"
#let borrowed = $♭$
#let af = $alpha_f$
#let ret = "return"
#let var = "var"
#let this = "this"
#let null = "null"
#let fi = "if"
#let then = "then"
#let els = "else"
#let begin = "begin"
#let args = "args"
#let alias = "alias"
#let root = "root"
#let type = "type"
#let mtype = "m-type"
#let ctx = "ctx"
#let norm = "normalize"
#let sp = "supPaths"
#let std = "std"
#let loop = "while"
#let do = "do"
#let value = "value"
#let push = "push"
#let ablub = $alpha_union.sq beta_union.sq$
#let tl = $tack.l$
#let tr = $tack.r$
#let rel = $lt.eq.curly$
#let Lub = $union.sq.big$
#let lub = $union.sq$
#let mw = $-#h(-.3em)*$

// *** UTILS ***

#let inangle(it) = $angle.l it angle.r$

#let mid(it) = $Delta tack.r it tack.l Delta$

#let tree(content, text-size) = text(text-size, align(center, box(content)))

#let map_dot(it) = if it == dot {$space dot space$} else {it}

#let unify(it, it2, it3) = {
  $"unify"(#map_dot(it)\; #map_dot(it2)\; #map_dot(it3))$
}

#let display-rules(row-size: 2, ..args) = {
  let rules = {args.pos()}
  let f_rules = ()
  for i in range(rules.len()) {
    if i+1 < rules.len() and rules.at(i + 1) == "" {
      f_rules.push(grid.cell(tree(rules.at(i), 8.5pt), colspan: row-size))
    } else {
      if rules.at(i) != "" {f_rules.push(grid.cell(tree(rules.at(i), 8.5pt), align: horizon))}
    }
  }
  v(1em)
  grid(
    columns: range(row-size).map(it => 1fr),
    column-gutter: 2em,
    row-gutter: 3em,
    ..f_rules
  )
}

#let stacked-axiom(..args) = {
  let axiom-stacks = args.pos().map(
    it => stack(dir: ltr, spacing: 3em, ..it)
  )
  axiom(
    stack(
      spacing: 1em,
      ..axiom-stacks.map(it => align(center)[#it])
    )
  )
}

#let frame-box = it => {
  v(1em)
  align(
    center,
    box(
      inset: 8pt,
      stroke: black,
      it
    )
  )
}

#let code-compare(capt, s, code1, code2, same-row: true) = figure(
  caption: capt,
  if(same-row) {
    grid(
      columns: (s, 1fr),
      column-gutter: 2em,
      row-gutter: .5em,
      code1, code2
    )
  } else {
    grid(
      columns: (s),
      column-gutter: 2em,
      row-gutter: 2em,
      code1, code2
    )
  }
)

#let example = thmplain(
  "example",
  "Example",
  titlefmt: strong,
  bodyfmt: body => [
    #body #h(1fr) $square$
  ]
).with(numbering: "1.1")
