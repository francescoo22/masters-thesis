#pagebreak(to:"odd")

#import "../config/variables.typ" : profTitle, myProf, myLocation, myTime, myName
#import "../config/constants.typ" : acknowledgements

#set par(first-line-indent: 0pt)
#set page(numbering: "i")

#align(right, [
    #box(align( 
        start,
        text(
            style: "italic",
            [“E il treno io l'ho preso e ho fatto bene \
            Spago sulla mia valigia non ce n'era \
            Solo un po' d'amore la teneva insieme \
            Solo un po' di rancore la teneva insieme”]
        )
    ))
    #v(6pt)
    #sym.dash#sym.dash#sym.dash Francesco De Gregori
])

#v(10em)

#text(24pt, weight: "semibold", acknowledgements)

#v(3em)

#text(style: "italic", "First of all, I would like to thank everyone who supported me during these months, making this work possible. My sincere thanks go to all the people at JetBrains, especially Komi Golov and Ilya Chernikov, for giving me the opportunity to work on this project and for their guidance throughout. I would also like to express my gratitude to my supervisor, Prof. Francesco Ranzato, for his guidance and suggestions both before and during the development of this thesis.")

#linebreak()

#text(style: "italic", "Voglio poi ringraziare i miei genitori per avermi sempre aiutato nei momenti di difficoltà e per tutti i sacrifici che hanno fatto per me, solo ora riesco a capire davvero quanto certe scelte siano state complicate. Un grazie speciale anche a Chiara per essermi stata sempre vicina, sia nei momenti belli che in quelli più difficili. Grazie anche ai nonni per avermi sempre supportato.")

#linebreak()

#text(style: "italic", "Un grazie anche a tutti gli amici che ho incontrato a Padova per aver reso questi anni di università indimenticabili.")

#linebreak()

#text(style: "italic", "I would also like to thank all the friends I met in Munich over the past year. You are truly making my time there extraordinary.")

#linebreak()

#text(style: "italic", "Infine voglio ringraziare Niko e Ghenzo per tutti i bei momenti e per essere stati sempre presenti quando ho avuto bisogno di un confronto.")

#v(2em)

#text(style: "italic", myLocation + ", " + myTime + h(1fr) + myName)

#v(1fr)