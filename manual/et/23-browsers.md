# Brauserid

Omarchy tuleb vaikebrauserina koos [Chromiumiga](https://www.chromium.org/). See on tavaline avatud lähtekoodiga versioon, teemaga sobitatud ülejäänud süsteemiga, ja see on see, mille avab `Super + Shift + Return` ja mille sees töötab iga [veebirakendus](25-web-apps.md).

Kui Chromium pole sinu maitsele, ei ole sa sellega kinni. Omarchy menüü jaotises _Paigalda > Browser_ leiad Chrome'i, Edge'i, Brave'i, Brave Origini, Firefoxi ja [Zen](https://zen-browser.app/) brauseri. Vali üks ja Omarchy paigaldab selle, seadistab selle poliitikakausta ja rakendab sellele sinu praeguse teema.

## Ühe vaikebrauseriks tegemine

Brauseri paigaldamine ei tee sellest vaikebrauserit. Kui see on masinas, mine jaotisesse _Seaded > Defaults > Browser_ ja vali see — menüü loetleb ainult brausereid, mis sul tegelikult paigaldatud on, ja märgib praeguse vaikeväärtuse linnukesega.

Terminalist on see:

```bash
omarchy default browser firefox
```

Käivita see ilma argumendita ja see ütleb praeguse vaikeväärtuse. See määrab XDG töötleja, nii et mitte ainult Omarchy kiirklahvid ei järgi seda — kõik, mis avab lingi, alates vestlusrakendusest kuni terminalikäsuni, läheb sinu valitud brauserisse.

## Copy URL ja Download Video

Chromiumi perekonna brauserid (Chromium ise, Chrome, Edge ja Brave) tulevad kahe Omarchy laiendusega, mis ulatuvad brauserist välja ülejäänud süsteemi.

**Copy URL** paneb praeguse vahelehe aadressi sinu lõikelauale kombinatsiooniga `Alt + Shift + L`. See on kiirem kui aadressiribale klõpsamine ja kopeerimine ning kuna see läheb läbi süsteemi lõikelaua, mitte brauseri oma, saad Omarchy teavituse, mis seda kinnitab, ja URL on kohe saadaval [lõikelaua ajaloos](08-unified-clipboard-history.md) ja igas teises rakenduses. Samuti on tööriistariba nupp, kui eelistad klõpsata.

**Download Video** haarab vaadataval lehel mängiva video kombinatsiooniga `Alt + Shift + D`. See annab URL-i edasi tööriistale [yt-dlp](https://github.com/yt-dlp/yt-dlp), nii et see töötab palju rohkema kui ainult YouTube'i puhul, ja allalaadimine jõuab kausta `~/Videos`. Edenemine kuvatakse samas ekraanikuva elemendis, mida kasutavad helitugevus ja heledus, uueneb kohapeal, mitte ei kuhja teavitusi. Määra `OMARCHY_YTDLP_DIR`, kui eelistad, et failid läheksid mujale — vaata [KKK](46-faq.md), et teada saada, kuhu keskkonnamuutujaid panna.

Mõlemad laiendused suhtlevad Omarchyga väikese natiivse sõnumihosti kaudu, mis paigaldatakse sulle koos brauseriga. See on tükk, mis võimaldab veebilehe videol jõuda sinu kodukausta ja URL-il sinu lõikelaua haldurisse, mida tavaline laiendus üksi teha ei saa.

Need on ainult Chromiumi perekonnale. Firefox ja Zen neid ei saa.

## Firefox ja Zen

Firefox ja Zen on teine perekond, nii et neid käsitletakse teisiti: Omarchy paigaldab mõistlike vaikeväärtuste jaoks poliitikafaili ja lülitab need natiivsesse Waylandi režiimi, mida soovid murdskaleerimise ja sujuva puuteplaadi kerimise jaoks.

Nad ei saa ülaltoodud Chromiumi laiendusi ega ole Omarchy poolt teemaga sobitatud, nii et need kogemuse osad tuleb sul endal seadistada.

## Ühe uuesti eemaldamine

Kõike siin paigaldatut saab uuesti eemaldada jaotises _Eemalda > Browser_. Chromium ei ole selles loendis — see on osa baassüsteemist.
