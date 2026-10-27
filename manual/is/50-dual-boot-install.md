# Tvöföld ræsing uppsetning

Þú getur sett Omarchy upp á eina disksneið við hlið Windows eða annarra uppsetninga.

Þessi uppsetningaraðferð kemur enn með LUKS dulritun fyrir sneiðina sjálfgefið, svo hún er í raun engu frábrugðin fullu drifi og krefst einfaldlega þess að laust pláss sé til á diskinum.

## Að búa til pláss á Windows

Til að setja upp við hlið Windows skaltu slá inn `disk management` í upphafsvalmyndinni og velja valkostinn **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Finndu viðeigandi sneið, hægrismelltu og veldu **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Sláðu inn magnið sem þú vilt minnka magnið um. Athugaðu að þetta verður stærð framtíðar Omarchy uppsetningarinnar þinnar að meðtalinni ræsisneiðinni.

 ![dual-boot-3](images/dual-boot-3.webp)

Þegar þú ert búinn ættirðu að sjá eitthvað eins og þetta þar sem 50GB hlutinn er þar sem við munum setja upp Omarchy í þessu dæmi.

 ![dual-boot-4](images/dual-boot-4.webp)

## Að setja upp Omarchy

Uppsetningarferlið fyrir Omarchy er í raun það sama og venjulegt. Eftir að þú velur diskinn þinn færðu valkostinn **Free space install**. Veldu þann valkost til að koma í veg fyrir að allur diskurinn þurrkist út.

 ![dual-boot-5](images/dual-boot-5.webp)

Staðfestu að allt líti vel út og bíddu eftir að uppsetningin klárist eins og venjulegt. Þetta er líka þar sem þú gætir valið að setja upp ódulritað (ekki mælt með) alveg eins og á fullri drifuppsetningu.
 ![dual-boot-6](images/dual-boot-6.webp)

## Að bæta öðrum uppsetningum við ræsiforritið

Þegar þú klárar Omarchy uppsetninguna þína munt þú taka eftir að Limine ræsiforritið er sjálfgildið núna. Með því geturðu líka bætt valkostum við Limine fyrir aðrar uppsetningar þínar eins og Windows.

Til að gera það skaltu keyra `limine-scan` og fylgja kvaðningunum til að bæta hvaða hlutum sem þú vilt við limine stillinguna þína. Þegar þú ræsir sérðu svo venjulega valkostina þína fyrir Omarchy, sem og Windows Boot Manager eða fleiri.

## Bitlocker

Mikilvægt er að athuga að þessi uppsetningaraðferð er ekki samhæf Bitlocker þar sem það dulritar allan drifinn, ekki bara sneiðina. Ef þú rekst á villu sem segir að Bitlocker sé virkt skaltu ræsa í Windows, fara í **Settings -> Privacy & Security -> Device encryption** og slökkva á Bitlocker. Það getur tekið nokkurn tíma að afkóða drifinn.

 ![dual-boot-7](images/dual-boot-7.webp)
