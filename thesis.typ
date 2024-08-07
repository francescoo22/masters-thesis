#import "./config/variables.typ": *
#import "./config/thesis-config.typ": *
#import "@preview/codly:1.0.0": *

#show: config.with(
  myAuthor: myName,
  myTitle: myTitle,
  myNumbering: "1.1",
  myLang: myLang
)

#include "structure.typ"
