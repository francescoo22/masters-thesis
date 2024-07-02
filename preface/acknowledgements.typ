#import "../config/variables.typ" : profTitle, myProf, myLocation, myTime, myName
#import "../config/constants.typ" : acknlowledgements

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

#text(24pt, weight: "semibold", acknlowledgements)

#v(3em)

#text(style: "italic", "Innanzitutto, vorrei esprimere la mia gratitudine al " + profTitle + myProf + " relatore della mia tesi, per l'aiuto e il sostegno fornitomi durante la stesura del lavoro.")

#linebreak()

#text(style: "italic", "Desidero ringraziare con affetto i miei genitori per il sostegno, il grande aiuto e per essermi stati vicini in ogni momento durante gli anni di studio.")

#linebreak()

#text(style: "italic", "Ho desiderio di ringraziare poi i miei amici per tutti i bellissimi anni passati insieme e le mille avventure vissute.")

#v(2em)

#text(style: "italic", myLocation + ", " + myTime + h(1fr) + myName)

#v(1fr)