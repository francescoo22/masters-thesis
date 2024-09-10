#import "../config/constants.typ": chapter
#import "@preview/codly:1.0.0": *
#import "@preview/ctheorems:1.1.2": *

#let vpr-name = stack(
  dir: ltr,
  image("../images/viper-logo.png", width: .9em), " Viper",
)

#let kt-name = stack(
  dir: ltr,
  image("../images/Kotlin.svg", width: .9em), " Kotlin",
)

#let cpp-name = stack(
  dir: ltr,
  image("../images/cpp-logo.svg", width: .8em), " C++",
)

#let vpr-show() = r => {
  // Types:
  show regex("\b(Ref)\b"): set text(rgb("#4b69c6"))
  show regex("\b(Bool)\b"): set text(rgb("#4b69c6"))
  show regex("\b(Int)\b"): set text(rgb("#4b69c6"))

  // Keywords:
  show regex("\b(inhale)\b"): set text(rgb("#d73a49"))
  show regex("\b(exhale)\b"): set text(rgb("#d73a49"))
  show regex("\b(method)\b"): set text(rgb("#d73a49"))
  show regex("\b(function)\b"): set text(rgb("#d73a49"))
  show regex("\b(predicate)\b"): set text(rgb("#d73a49"))
  show regex("\b(field)\b"): set text(rgb("#d73a49"))
  show regex("\b(fold)\b"): set text(rgb("#d73a49"))
  show regex("\b(unfold)\b"): set text(rgb("#d73a49"))
  show regex("\b(unfolding)\b"): set text(rgb("#d73a49"))
  show regex("\b(in)\b"): set text(rgb("#d73a49"))
  show regex("\b(requires)\b"): set text(rgb("#d73a49"))
  show regex("\b(ensures)\b"): set text(rgb("#d73a49"))
  show regex("\b(returns)\b"): set text(rgb("#d73a49"))
  show regex("\b(var)\b"): set text(rgb("#d73a49"))
  show regex("\b(if)\b"): set text(rgb("#d73a49"))
  show regex("\b(else)\b"): set text(rgb("#d73a49"))
  show regex("\b(acc)\b"): set text(rgb("#d73a49"))
  show regex("\b(while)\b"): set text(rgb("#d73a49"))
  show regex("\b(forall)\b"): set text(rgb("#d73a49"))
  show regex("\b(axiom)\b"): set text(rgb("#d73a49"))
  show regex("\b(invariant)\b"): set text(rgb("#d73a49"))
  show regex("\b(assert)\b"): set text(rgb("#d73a49"))
  show regex("\b(wildcard)\b"): set text(rgb("#d73a49"))
  show regex("\b(null)\b"): set text(rgb("#d73a49"))
  show regex("\b(true)\b"): set text(rgb("#d73a49"))
  show regex("\b(false)\b"): set text(rgb("#d73a49"))
  show regex("\b(domain)\b"): set text(rgb("#d73a49"))
  show regex("\b(write)\b"): set text(rgb("#d73a49"))
  show "&&": set text(rgb("#d73a49"))
  show "||": set text(rgb("#d73a49"))
  show "=": set text(rgb("#d73a49"))
  show "<": set text(rgb("#d73a49"))
  show ">": set text(rgb("#d73a49"))
  show ":": set text(rgb("#d73a49"))
  show "!": set text(rgb("#d73a49"))
  show "*": set text(rgb("#d73a49"))

  show regex("//.*"): set text(rgb("#8a8a8a"))

  r
}

#let grammar-show() = r => {
  show regex("//.*"): set text(rgb("#9a9a5b"))
  show regex("⊣.*"): set text(rgb("#8a8a8a"))

  r
}


#let config(
    myAuthor: "Nome cognome",
    myTitle: "Titolo",
    myLang: "en",
    myNumbering: "1.",
    body
) = {
  // Set the document's basic properties.
    set document(author: myAuthor, title: myTitle)
    show: codly-init
    show: thmrules
    show math.equation: set text(weight: 400)
    show table.cell.where(y: 0): strong

    // LaTeX look (secondo la doc di Typst)
    // set page(margin: 1.75in, numbering: myNumbering, number-align: center)
    set page(margin: 1.55in, numbering: "1", number-align: center)
    // set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
    set par(leading: 0.55em, justify: true)
    set text(font: "New Computer Modern", size: 10pt, lang: myLang)
    set heading(numbering: myNumbering)
    // show raw.where(block: false): set text(font: "New Computer Modern Mono", size: 10pt, lang: myLang)
    show raw.where(block: true): it => {
      // #let kt-logo = image("images/Kotlin.svg", width: 200%)
      codly(
        enabled: true,
        languages: (
          kt: (name: kt-name, color: purple),
          vpr: (name: vpr-name, color: orange),
          cpp: (name: cpp-name, color: blue)
        )
      )
      it
      codly-disable()
    }

    show raw.where(lang: "vpr"): vpr-show()

    show raw.where(lang: none): grammar-show()

    show par: set block(spacing: 0.55em)
    show heading: set block(above: 1.4em, below: 1em)

    show heading.where(level: 2): set heading(supplement: [Section])
    show heading.where(level: 3): set heading(supplement: [Subsection])

    show heading.where(level: 1): it => {
        stack(
            spacing: 2em,
            if it.numbering != none {
                text(size: 1.5em)[#heading.supplement #counter(heading).display()]
                // text(size: 1em)[Chapter #counter(heading).display()]
            },
            text(size:1.75em, it.body),
            // text(size:1.5em,it.body),
            []
        )
    }

  body
}
