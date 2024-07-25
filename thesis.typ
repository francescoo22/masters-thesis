#import "./config/variables.typ": *
#import "./config/thesis-config.typ": *
#import "@preview/codly:1.0.0": *

#show: config.with(
  myAuthor: myName,
  myTitle: myTitle,
  myNumbering: "1.1",
  myLang: myLang
)

// #let kt-logo = image("images/Kotlin.svg", width: 200%)

#show: codly-init.with()
#codly(
  languages: (
    kt: (name: "Kotlin", color: purple),
    java: (name: "Viper", color: orange)
  )
)

#include "structure.typ"
