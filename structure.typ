// Frontmatter

#include "./preface/firstpage.typ"
#include "./preface/copyright.typ"
#include "./preface/dedication.typ"
#include "./preface/abstract.typ"
#include "./preface/acknowledgements.typ"
#include "./preface/table-of-contents.typ"

// Mainmatter

#counter(page).update(1)

// 1. Introduction to the aliasing problem
#include "./chapters/introduction-aliasing.typ"
#include "./chapters/introduction-viper.typ"
#include "./chapters/annotations-overview.typ"
#include "./chapters/annotations-rules.typ"
#include "./chapters/encoding.typ"
#include "./chapters/future-work.typ"
#include "./chapters/related-work.typ"
#include "./chapters/conclusion.typ"

// // Appendix

// #include "./appendix/appendice-a.typ"

// // Backmatter

// // Praticamente il glossario

// Bibliography

#include("./appendix/bibliography/bibliography.typ")
