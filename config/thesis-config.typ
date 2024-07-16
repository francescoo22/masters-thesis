#import "../config/constants.typ": chapter
#import "../config/utils.typ": frame-box

#let config(
    myAuthor: "Nome cognome",
    myTitle: "Titolo",
    myLang: "en",
    myNumbering: "1.",
    body
) = {
  // Set the document's basic properties.
    set document(author: myAuthor, title: myTitle)
    show math.equation: set text(weight: 400)

    // LaTeX look (secondo la doc di Typst)
    // set page(margin: 1.75in, numbering: myNumbering, number-align: center)
    set page(margin: 1.55in, numbering: "1", number-align: center)
    // set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
    set par(leading: 0.55em, justify: true)
    set text(font: "New Computer Modern", size: 10pt, lang: myLang)
    set heading(numbering: myNumbering)
    // show raw.where(block: false): set text(font: "New Computer Modern Mono", size: 10pt, lang: myLang)
    show raw.where(block: true): frame-box
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
