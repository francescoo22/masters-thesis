// Frontmatter

#include "./preface/firstpage.typ"
#include "./preface/copyright.typ"
#include "./preface/dedication.typ"
#include "./preface/abstract.typ"
#include "./preface/acknowledgements.typ"
#include "./preface/table-of-contents.typ"

// Mainmatter

#counter(page).update(1)

#include "./chapters/1-Introduction.typ"
#include "./chapters/2-Background.typ"
#include "./chapters/3-Related-Work.typ"
#include "./chapters/4-Annotation-System.typ"
#include "./chapters/5-Encoding.typ"
#include "./chapters/6-Conclusion.typ"

// // Appendix

// #include "./appendix/appendice-a.typ"

// // Backmatter

// // Praticamente il glossario

// Bibliography

#include("./appendix/bibliography/bibliography.typ")
