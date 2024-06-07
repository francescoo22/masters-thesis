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
#include "./chapters/1-introduction-aliasing.typ"
#include "./chapters/2-aliasing-kotlin.typ"
#include "./chapters/3-introduction-viper.typ"
#include "./chapters/4-annotations-overview.typ"
#include "./chapters/5-annotations-rules.typ"
#include "./chapters/6-encoding.typ"
#include "./chapters/7-future-work.typ"
#include "./chapters/8-related-work.typ"
#include "./chapters/9-conclusion.typ"

// // Appendix

// #include "./appendix/appendice-a.typ"

// // Backmatter

// // Praticamente il glossario

// Bibliography

#include("./appendix/bibliography/bibliography.typ")
