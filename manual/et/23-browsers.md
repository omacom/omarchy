# Brauserid

Omarchyga on vaikebrauserina kaasas [Google Chrome](https://www.google.com/chrome/). Selle välimus on kohandatud ülejäänud süsteemiga sobima, just selle avab `Super + Shift + Return` ja just selle sees töötab iga [veebirakendus](25-web-apps.md). See avaneb otse brauseriaknas: ei mingit tervituskuva ega sisselogimisviipa, kasutustatistikat ja kokkujooksmisarjandeid Google'ile ei saadeta ning reklaamiprivaatsuse viibad on välja lülitatud. Kui soovid sünkroonimist, saad profiilinupu kaudu siiski igal ajal oma Google'i kontosse sisse logida.

Kui Chrome sulle ei meeldi, ei pea sa selle juurde pidama jääma. Omarchy menüüs leiad valiku _Paigalda > Brauser_ alt [Chromium](https://www.chromium.org/) (lihtsa avatud lähtekoodiga versiooni, mille põhjal Chrome on tehtud), Edge'i, Brave'i, Brave Origini, Firefoxi ja [Zen](https://zen-browser.app/). Vali üks ning Omarchy paigaldab selle, valmistab ette selle poliitikakataloogi ja rakendab sellele sinu praeguse teema.

## Ühe vaikebrauseriks määramine

Brauseri paigaldamine ei tee sellest vaikebrauserit. Kui see on masinas olemas, mine valiku _Seadistus > Vaikesätted > Brauser_ juurde ja vali see välja — menüü loetleb ainult brausereid, mis sul tegelikult paigaldatud on, ja tähistab praeguse vaikebrauseri linnukesega.

Terminalist käib see nii:

```bash
omarchy default browser firefox
```

Käivita see ilma argumendita ja see ütleb sulle praeguse vaikebrauseri. See määrab XDG käsitleja, nii et kaasas ei käi ainult Omarchy kiirklahvid — kõik, mis avab lingi, alates vestlusrakendusest kuni terminalikäskluseni, läheb sinu valitud brauserisse.

## Copy URL ja Download Video

Chromiumi perekonna brauseritega (Chromium ise, Chrome, Edge ja Brave) on kaasas kaks Omarchy laiendust, mis ulatuvad brauserist välja ülejäänud süsteemi.

**Copy URL** paneb praeguse vahekaardi aadressi `Alt + Shift + L` abil sinu lõikepuhvrisse. See on kiirem kui aadressiribale klõpsamine ja sealt kopeerimine, ning kuna see käib brauseri lõikepuhvri asemel süsteemi lõikepuhvri kaudu, saad kinnituseks Omarchy teavituse ja URL on kohe saadaval [lõikepuhvri ajaloos](08-unified-clipboard-history.md) ja igas teises rakenduses. Kui eelistad klõpsata, on olemas ka tööriistariba nupp.

**Download Video** haarab `Alt + Shift + D` abil video, mis mängib sinu vaadataval lehel. See annab URL-i edasi [yt-dlp](https://github.com/yt-dlp/yt-dlp)-le, nii et see töötab palju enamaga kui ainult YouTube'iga, ning allalaadimine maandub kausta `~/Videos`. Edenemine kuvatakse samal ekraanikuval, mida kasutavad helitugevus ja heledus, ning see uueneb kohapeal, selle asemel et teavitusi kuhjata. Määra `OMARCHY_YTDLP_DIR`, kui eelistad, et failid läheksid kuhugi mujale — keskkonnamuutujate paigutamise kohta vaata [KKK](46-faq.md).

Mõlemad laiendused suhtlevad Omarchyga väikese natiivse sõnumside hosti kaudu, mis paigaldatakse sinu eest koos brauseriga. Just see tükk laseb veebilehe videol sinu kodukataloogi ja URL-il sinu lõikepuhvri haldurisse jõuda, mida tavaline laiendus üksinda teha ei suuda.

Need on ainult Chromiumi perekonnale. Firefox ja Zen neid ei saa.

## Firefox ja Zen

Firefox ja Zen on teine perekond, nii et neid koheldakse teisiti: Omarchy paigaldab mõistlike vaikesätetega poliitikafaili ja lülitab need natiivsesse Waylandi režiimi, mida sa tahad murdosalise skaleerimise ja sujuva puuteplaadi kerimise jaoks.

Nad ei saa ülaltoodud Chromiumi laiendusi ega kohanda Omarchy nende välimust, nii et need kogemuse osad jäävad sinu enda seadistada.

## Ühe uuesti eemaldamine

Kõiki neid brausereid, Chrome kaasa arvatud, saab valiku _Eemalda > Brauser_ alt uuesti maha võtta. Lingid lähevad seejärel Chrome'i või Chromiumi, kui teine neist on endiselt paigaldatud.
