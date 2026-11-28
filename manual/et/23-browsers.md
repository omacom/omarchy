# Brauserid

Omarchyga on vaikebrauserina kaasas [Google Chrome](https://www.google.com/chrome/). See on kujundatud nii, et sobituda ülejäänud süsteemiga, ja just selle avab `Super + Shift + Return` (või `Super + Shift + B`), privaatakna puhul `Super + Shift + Alt + B`, ning selle sees töötab iga [veebirakendus](25-web-apps.md). See avaneb otse brauseriaknasse: pole tervituskuva ega sisselogimisviipa, kasutusstatistikat ja krahhiaruandeid Google'ile ei saadeta ning reklaamide privaatsusviibad on välja lülitatud. Kui tahad sünkroonimist, saad profiilinupust siiski igal ajal oma Google'i kontole sisse logida.

Kui Chrome pole sinu maitse, ei pea sa selle juurde jääma. Omarchy menüü jaotisest _Paigalda > Brauser_ leiad [Chromium](https://www.chromium.org/) (lihtne avatud lähtekoodiga versioon, millest Chrome on tehtud), Edge'i, Brave'i, Brave Origini, Firefoxi, [Zen](https://zen-browser.app/) ja [Ladybird](https://ladybird.org/) (Edge ainult x86 masinatel). Vali üks ja Omarchy paigaldab selle, seab üles selle poliitikakataloogi ning rakendab sellele sinu praeguse teema.

## Ühe vaikebrauseriks määramine

Brauseri paigaldamine ei tee sellest vaikebrauserit. Vahetamiseks mine _Seadista > Vaikevalikud > Brauser_ ja vali üks. Praegune vaikebrauser on märgitud linnukesega ja kui valid brauseri, mida sul veel pole, paigaldatakse see kõigepealt.

Terminalist käib see nii:

```bash
omarchy default browser firefox
```

Käivita see ilma argumendita ja see ütleb sulle praeguse vaikebrauseri. See määrab XDG käsitleja, nii et kaasa ei tule ainult Omarchy kiirklahvid — kõik, mis avab lingi, alates vestlusrakendusest kuni terminalikäsuni, läheb sinu valitud brauserisse.

## Copy URL ja Download Video

Chromiumi perekonna brauseritega (Chromium ise, Chrome, Edge, Brave ja Brave Origin) on kaasas kolm Omarchy laiendust: kaks, mis ulatuvad brauserist välja ülejäänud süsteemi, ja üks, mis korrastab WhatsAppi.

**Copy URL** paneb praeguse vahekaardi aadressi `Alt + Shift + L`-iga sinu lõikelauale. See on kiirem kui aadressiribale klõpsamine ja sealt kopeerimine ning kuna see käib brauseri asemel läbi süsteemi lõikelaua, saad kinnituseks Omarchy teavituse ja URL on kohe saadaval [lõikelaua ajaloos](08-unified-clipboard-history.md) ja igas teises rakenduses. Kui eelistad klõpsamist, on olemas ka tööriistariba nupp.

**Download Video** haarab `Alt + Shift + D`-ga video, mis mängib sinu vaadataval lehel. See annab URL-i edasi [yt-dlp](https://github.com/yt-dlp/yt-dlp)-le, nii et see töötab palju enamaga kui ainult YouTube'iga, ja allalaadimine jõuab kausta `~/Videos`. Edenemine kuvatakse samal ekraanikuval, mida kasutavad helitugevus ja heledus, ning see uueneb kohapeal, selle asemel et teavitusi üksteise otsa kuhjata. Määra `OMARCHY_YTDLP_DIR`, kui eelistad, et failid läheksid kuhugi mujale — vaata [KKK](46-faq.md), et teada saada, kuhu keskkonnamuutujad panna.

Mõlemad laiendused suhtlevad Omarchyga läbi väikese natiivse sõnumside hosti, mis paigaldatakse sinu eest koos brauseriga. Just see tükk laseb veebilehe videol jõuda sinu kodukataloogi ja URL-il sinu lõikelauahaldurisse, mida tavaline laiendus üksinda teha ei saa.

**WhatsApp Slim** paneb WhatsApp Webi järgima sinu süsteemi teemat ja tõmbab selle vestlusloendi kokku, kui aken on kitsas.

Need on ainult Chromiumi perekonnale. Firefox ja Zen neid ei saa.

## Firefox ja Zen

Firefox ja Zen on teine perekond, nii et nendega käitutakse teisiti: Omarchy paigaldab mõistlike vaikesätetega poliitikafaili ja lülitab need natiivsesse Waylandi režiimi, mida sa tahad murdosa skaleerimise ja sujuva puuteplaadi kerimise jaoks.

Neile ei anta ülaltoodud Chromiumi laiendusi ja Omarchy ei teemasta neid, nii et need kogemuse osad jäävad sinu enda seadistada.

## Ladybird

Ladybird on nullist kirjutatud brauser, millel on Chromiumi või Firefoxi asemel oma mootor. See on endiselt alfafaasis, nii et oota saite, mis veel ei tööta, ja Omarchy paigaldab selle nii, nagu see on: ei laiendusi, ei teemat, ei poliitikaid. Sellel pole ka privaatakent, nii et `Super + Shift + Alt + B` avab selle ajutise profiiliga, mis selle sulgemisel kustutatakse. [Veebirakendused](25-web-apps.md) töötavad edasi Chrome'is või Chromiumis.

## Ühe uuesti eemaldamine

Kõiki neid brausereid, Chrome kaasa arvatud, saab jaotise _Eemalda > Brauser_ alt uuesti maha võtta. Lingid lähevad siis Chrome'i või Chromiumi, kui teine on endiselt paigaldatud.
