# Auðkenning með vélbúnaði

### Fingrafarsauðkenning

Margar fartölvur eru með fingrafarsskynjara til auðkenningar. Þú getur notað hann í Omarchy með því að keyra _Setup > Security > Fingerprint_ í Omarchy-valmyndinni (`Super + Space`).

Það setur upp fingrafarspakkann, skráir fingrafarið þitt, staðfestir það og þá ertu tilbúinn að nota fingrafarið til að aflæsa lásaskjánum (sem þú getur kallað fram með `Super + Ctrl + L`), fara í sudo-stillingu og staðfesta kerfiskvaðningar.

Þegar lásaskjárinn er búinn að slökkva á skjánum hvílir skynjarinn til að spara orku, svo vaktu skjáinn með einhverjum lykli eða snertiplattanum áður en þú snertir hann.

Þegar lok fartölvunnar er lokað er fingrafarskvaðningin sjálfkrafa sleppt, svo þú ferð beint í lykilorðskvaðninguna í stað þess að bíða eftir skynjara sem þú nærð ekki til. Ef þú þarft annars að vinna á ytra lyklaborði sem er ekki með skynjara skaltu bara ýta á `CTRL + C` þegar þú ert beðinn um fingrafarið í `sudo`.

Þú getur fjarlægt fingrafarsauðkenninguna undir _Remove > Security > Fingerprint_ í Omarchy-valmyndinni.

### Fido2-auðkenning

Ef þú notar Fido2-tæki getur þú sett það upp fyrir `sudo`-auðkenningu með því að nota _Setup > Security > Fido2_ í Omarchy-valmyndinni (`Super + Space`). Það nær þó yfir `sudo` og kerfisheimildarkvaðningar, ekki aflæsingu tölvunnar.

Þú getur fjarlægt fido2-auðkenninguna undir _Remove > Security > Fido2_ í Omarchy-valmyndinni.
