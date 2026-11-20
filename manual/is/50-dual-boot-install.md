# Uppsetning með tvöfaldri ræsingu

Þú getur sett Omarchy upp á einni disksneið samhliða Windows eða öðrum uppsetningum.

Þessi uppsetningaraðferð kemur samt með LUKS-dulritun fyrir disksneiðina sem sjálfgefna, svo hún er í raun ekkert frábrugðin uppsetningu á allan diskinn og krefst einfaldlega þess að laust pláss sé tiltækt á diskinum.

## Að gera pláss í Windows

Til að setja upp samhliða Windows skaltu skrifa `disk management` í upphafsvalmyndina og velja valkostinn **Búa til og forsníða disksneiðar á harða diski**.

 ![dual-boot-1](images/dual-boot-1.webp)

Finndu viðeigandi disksneið, hægrismelltu og veldu **Minnka rúmmál**.

![dual-boot-2](images/dual-boot-2.webp)

 Sláðu inn magnið sem þú vilt minnka rúmmálið um. Athugaðu að þetta verður stærð framtíðaruppsetningar þinnar á Omarchy, að ræsidisksneiðinni meðtalinni.

 ![dual-boot-3](images/dual-boot-3.webp)

Þegar þú ert búinn ættir þú að sjá eitthvað á þessa leið, þar sem 50GB hlutinn er sá staður þar sem við setjum upp Omarchy í þessu dæmi.

 ![dual-boot-4](images/dual-boot-4.webp)

## Að setja upp Omarchy

Uppsetningarferlið fyrir Omarchy er í raun það sama og venjulega. Eftir að þú velur diskinn þinn færðu valkostinn **Uppsetning í lausu plássi**. Veldu þann valkost til að koma í veg fyrir að allur diskurinn sé þurrkaður út.

 ![dual-boot-5](images/dual-boot-5.webp)

Staðfestu að allt líti vel út og bíddu eftir að uppsetningin klárist eins og venjulega. Hér getur þú líka valið að setja upp án dulritunar (ekki mælt með því), rétt eins og við uppsetningu á allan diskinn.
 ![dual-boot-6](images/dual-boot-6.webp)

## Að bæta öðrum uppsetningum við ræsistjórann

Þegar þú klárar uppsetninguna á Omarchy muntu taka eftir því að Limine-ræsistjórinn er núna sjálfgefinn. Með honum getur þú líka bætt valkostum við Limine fyrir aðrar uppsetningar þínar, svo sem Windows.

Til að bæta við öðrum stýrikerfum skaltu keyra `limine-scan` og fylgja leiðbeiningunum til að bæta þeim færslum sem þú vilt við Limine-stillingarnar þínar. Ræsivalmyndin helst falin sjálfgefið og ræsir Omarchy eftir eina sekúndu. Til að velja Windows eða aðra færslu skaltu ýta á hvaða takka sem er um leið og Limine ræsist; þegar valmyndin birtist skaltu nota örvatakkana til að velja færslu og ýta á Enter. Ef Omarchy ræsist áður en þú ýtir á takka skaltu endurræsa og reyna aftur.

## Bitlocker

Mikilvægt er að athuga að þessi uppsetningaraðferð er ekki samhæf Bitlocker, þar sem það dulritar allan diskinn, ekki bara disksneiðina. Ef þú lendir í villu þar sem segir að Bitlocker sé virkt skaltu ræsa í Windows, fara í **Stillingar -> Persónuvernd og öryggi -> Dulritun tækis** og slökkva á Bitlocker. Það getur tekið nokkurn tíma að afkóða diskinn.

 ![dual-boot-7](images/dual-boot-7.webp)
