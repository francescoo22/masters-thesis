// Frontmatter

#include "./preface/firstpage.typ"
#include "./preface/copyright.typ"
#include "./preface/abstract.typ"
#include "./preface/acknowledgements.typ"
#include "./preface/table-of-contents.typ"

// Mainmatter

#counter(page).update(1)
#set heading(numbering: "1.1", supplement: "Chapter")

#include "./chapters/1-Introduction.typ"
#include "./chapters/2-Background.typ"
#include "./chapters/3-Related-Work.typ"
#include "./chapters/4-Annotations-Kotlin.typ"
#include "./chapters/5-Annotation-System.typ"
#include "./chapters/6-Encoding.typ"
#include "./chapters/7-Conclusion.typ"

// Bibliography

#include("./appendix/bibliography/bibliography.typ")

// Appendix

#set heading(numbering: "A.1", supplement: "Appendix")
#counter(heading).update(0)

#include("./appendix/full-rules-set.typ")
#include("./appendix/stack-proof.typ")