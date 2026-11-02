# Uppsetning með tvöfaldri ræsingu

Þú getur sett upp Omarchy á eina disksneið við hliðina á Windows eða öðrum uppsetningum.

Þessi uppsetningaraðferð fylgir samt LUKS-dulkóðun fyrir disksneiðina sjálfgefið, svo hún er í raun ekkert öðruvísi en uppsetning á allan diskinn og krefst einfaldlega þess að laust pláss sé tiltækt á diskinum.

## Að gera pláss á Windows

Til að setja upp við hliðina á Windows skaltu slá inn `disk management` í upphafsvalmyndinni og velja valkostinn **Búa til og forsníða harðdisksneiðar**.

 ![dual-boot-1](images/dual-boot-1.webp)

Finndu viðeigandi disksneið, hægrismelltu og veldu **Draga saman drif**.

![dual-boot-2](images/dual-boot-2.webp)

 Sláðu inn hversu mikið þú vilt draga drifið saman um. Athugaðu að þetta verður stærð framtíðaruppsetningarinnar þinnar á Omarchy, að ræsidisksneiðinni meðtalinni.

 ![dual-boot-3](images/dual-boot-3.webp)

Þegar þú ert búinn ættir þú að sjá eitthvað á þessa leið, þar sem 50GB hlutinn er þar sem við munum setja upp Omarchy í þessu dæmi.

 ![dual-boot-4](images/dual-boot-4.webp)

## Að setja upp Omarchy

Uppsetningarferlið fyrir Omarchy er í raun það sama og venjulega. Eftir að þú velur diskinn þinn færðu valkostinn **Uppsetning á lausu plássi**. Veldu þann valkost til að koma í veg fyrir að allur diskurinn sé þurrkaður út.

 ![dual-boot-5](images/dual-boot-5.webp)

Staðfestu að allt líti vel út og bíddu eftir að uppsetningin klárist eins og venjulega. Þetta er líka þar sem þú getur valið að setja upp ódulkóðað (ekki mælt með því), rétt eins og við uppsetningu á allan diskinn.
 ![dual-boot-6](images/dual-boot-6.webp)

## Að bæta öðrum uppsetningum við ræsiforritið

Þegar þú lýkur uppsetningunni á Omarchy munt þú taka eftir því að Limine-ræsiforritið er núna sjálfgefið. Með því getur þú líka bætt valkostum við Limine fyrir aðrar uppsetningar þínar, svo sem Windows.

Til að bæta við öðrum stýrikerfum skaltu keyra `limine-scan` og fylgja leiðbeiningunum til að bæta þeim færslum sem þú vilt við Limine-stillingarnar þínar. Ræsivalmyndin helst falin sjálfgefið og ræsir Omarchy eftir eina sekúndu. Til að velja Windows eða aðra færslu skaltu ýta á einhvern lykil um leið og Limine ræsist; þegar valmyndin birtist skaltu nota örvalyklana til að velja færslu og ýta á Enter. Ef Omarchy ræsist áður en þú ýtir á lykil skaltu endurræsa og reyna aftur. Ef þú kveiktir á _Setup > Direct Boot_ sleppir fastbúnaðurinn Limine alveg, svo veldu Limine í BIOS-ræsivalmyndinni þinni eða keyrðu _Setup > Direct Boot_ aftur til að fjarlægja færsluna.

## Bitlocker

Það er mikilvægt að athuga að þessi uppsetningaraðferð er ekki samhæf við Bitlocker, þar sem það dulkóðar allan diskinn, ekki bara disksneiðina. Ef þú færð villu þar sem tekið er fram að Bitlocker sé virkt skaltu ræsa í Windows, fara í **Stillingar -> Persónuvernd og öryggi -> Dulkóðun tækis** og slökkva á Bitlocker. Það getur tekið nokkurn tíma að afkóða diskinn.

 ![dual-boot-7](images/dual-boot-7.webp)
