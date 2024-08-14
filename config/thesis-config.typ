#import "../config/constants.typ": chapter
#import "@preview/codly:1.0.0": *


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

#let config(
    myAuthor: "Nome cognome",
    myTitle: "Titolo",
    myLang: "en",
    myNumbering: "1.",
    body
) = {
  // Set the document's basic properties.
    set document(author: myAuthor, title: myTitle)
    show: codly-init.with()
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
          java: (name: vpr-name, color: orange),
          cpp: (name: cpp-name, color: blue)
        )
      )
      it
      codly-disable()
    }
    show par: set block(spacing: 0.55em)
    show heading: set block(above: 1.4em, below: 1em)


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
