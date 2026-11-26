# Vélbúnaðarauðkenning

### Fingrafaraauðkenning

Margar fartölvur eru með fingrafaraskynjara til auðkenningar. Þú getur notað þetta með Omarchy með því að keyra _Setup > Security > Fingerprint_ í Omarchy-valmyndinni (`Super + Space`).

Það opnar fingrafar á öllum skjánum sem fyllist út þegar þú snertir skynjarann. Á bak við tjöldin mun Omarchy setja upp fingrafarapakkan, skrá fingrafarið þitt, staðfesta það, og þá er allt klárt til að nota fingrafarið þitt til að aflæsa af lásskjánum (sem þú getur opnað með `Super + Ctrl + L`), fara í sudo-ham og heimila beiðnir frá kerfinu.

Þegar lásskjárinn hefur slökkt á skjánum hvílir skynjarinn sér til að spara orku, svo vek þú skjáinn með hvaða lykli sem er eða snertiborðinu áður en þú snertir hann.

Þegar lok fartölvunnar er lokað er sjálfkrafa sleppt yfir fingrafarabeiðnina, svo þú ferð beint í lykilorðabeiðnina í stað þess að bíða eftir skynjara sem þú nærð ekki til. Ef þú þarft annars að vinna á ytra lyklaborði sem er ekki með skynjara skaltu bara ýta á `CTRL + C`, þegar beðið er um fingrafarið þitt í `sudo`.

Þú getur fjarlægt fingrafaraauðkenninguna undir _Remove > Security > Fingerprint_ í Omarchy-valmyndinni.

### Fido2-auðkenning

Ef þú notar Fido2-tæki getur þú sett það upp fyrir `sudo`-auðkenningu með því að nota _Setup > Security > Fido2_ í Omarchy-valmyndinni (`Super + Space`). Það nær þó yfir `sudo` og beiðnir um heimild frá kerfinu, ekki að aflæsa tölvunni þinni.

Þú getur fjarlægt fido2-auðkenninguna undir _Remove > Security > Fido2_ í Omarchy-valmyndinni.
