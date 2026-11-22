# Brauserid

Omarchy-ga tuleb vaikebrauserina kaasa [Google Chrome](https://www.google.com/chrome/). See on kujundatud nii, et sobituks ülejäänud süsteemiga, ja just selle avab `Super + Shift + Return` (või `Super + Shift + B`), privaatse akna jaoks `Super + Shift + Alt + B`, ning selle sees töötavad kõik [veebirakendused](25-web-apps.md). See avaneb otse brauseriaknasse: ei mingit tervituskuva ega sisselogimisviipa, kasutusstatistikat ja kokkujooksmisraporteid Google'ile ei saadeta ning reklaamide privaatsusviibad on välja lülitatud. Sa saad siiski profiilinupust igal ajal oma Google'i kontole sisse logida, kui soovid sünkroonimist.

Kui Chrome ei ole sinu maitse, ei pea sa sellega leppima. Omarchy menüüs _Install > Browser_ alt leiad [Chromium](https://www.chromium.org/) (lihtne avatud lähtekoodiga versioon, millest Chrome on tehtud), Edge, Brave, Brave Origin, Firefox ja [Zen](https://zen-browser.app/) (Edge ainult x86 masinatel). Vali üks ja Omarchy installib selle, seadistab selle poliitikakataloogi ja rakendab sellele sinu praeguse teema.

## Ühe vaikebrauseriks määramine

Brauseri installimine ei tee veel sellest vaikebrauserit. Vahetamiseks mine _Setup > Defaults > Browser_ ja vali üks. Praegune vaikebrauser on tähistatud linnukesega ja kui valid brauseri, mida sul veel ei ole, installitakse see esmalt.

Terminalist käib see nii:

```bash
omarchy default browser firefox
```

Käivita see argumendita ja see ütleb sulle praeguse vaikebrauseri. See määrab XDG handleri, nii et sellega ei lähe kaasa mitte ainult Omarchy kiirklahvid — kõik, mis avab lingi, alates vestlusrakendusest kuni terminalikäsuni, läheb sinu valitud brauserisse.

## Copy URL ja Download Video

Chromium-perekonna brauseritega (Chromium ise, Chrome, Edge, Brave ja Brave Origin) tulevad kaasa kolm Omarchy laiendust: kaks, mis sirutuvad brauserist välja ülejäänud süsteemi, ja üks, mis korrastab WhatsAppi.

**Copy URL** paneb praeguse vahekaardi aadressi kombinatsiooniga `Alt + Shift + L` sinu lõikelauale. See on kiirem kui aadressiribale klõpsamine ja kopeerimine, ja kuna see läheb brauseri oma asemel läbi süsteemi lõikelaua, saad kinnituseks Omarchy teavituse ning URL on kohe saadaval [lõikelaua ajaloos](08-unified-clipboard-history.md) ja igas teises rakenduses. Ka tööriistaribal on nupp, kui eelistad klõpsata.

**Download Video** haarab kombinatsiooniga `Alt + Shift + D` video, mis mängib lehel, mida parajasti vaatad. See annab URL-i [yt-dlp](https://github.com/yt-dlp/yt-dlp)-le, nii et see töötab palju enamaga kui ainult YouTube'iga, ja allalaadimine jõuab kausta `~/Videos`. Edenemist näidatakse samas ekraanil kuvatavas indikaatoris, mida kasutavad helitugevus ja heledus, ning see uueneb samas kohas, selle asemel et teavitusi kuhjata. Määra `OMARCHY_YTDLP_DIR`, kui eelistad, et failid läheksid mujale — vaata [FAQ](46-faq.md), et teada saada, kuhu keskkonnamuutujad panna.

Mõlemad laiendused suhtlevad Omarchyga väikese native messaging hosti vahendusel, mis installitakse sulle koos brauseriga. See on see tükk, mis laseb veebilehe videol jõuda sinu kodukataloogi ja URL-il sinu lõikelauahaldurisse, mida tavaline laiendus üksinda teha ei suuda.

**WhatsApp Slim** paneb WhatsApp Webi järgima sinu süsteemi teemat ja ahendab selle vestluste loendi, kui aken on kitsas.

Need on ainult Chromium-perekonnale. Firefox ja Zen neid ei saa.

## Firefox ja Zen

Firefox ja Zen on teine perekond, nii et neisse suhtutakse teisiti: Omarchy installib mõistlike vaikeseadetega poliitikafaili ja lülitab need natiivsesse Wayland-režiimi, mida sa tahad murdosalise skaleerimise ja sujuva puuteplaadiga kerimise jaoks.

Nad ei saa ülaltoodud Chromium-laiendusi ja Omarchy ei rakenda neile teemat, nii et need kogemuse osad tuleb sul endal seadistada.

## Ühe uuesti eemaldamine

Kõiki neid brausereid, Chrome kaasa arvatud, saab _Remove > Browser_ alt uuesti maha võtta. Lingid lähevad siis Chrome'i või Chromiumisse, kui teine neist on endiselt installitud.
