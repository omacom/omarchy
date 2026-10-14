# Naršyklės

Omarchy pagal nutylėjimą pristatoma su [Chromium](https://www.chromium.org/) kaip numatytąja naršykle. Tai paprasta atviro kodo versija, pritaikyta prie likusios tavo sistemos, ir būtent ją atverčia `Super + Shift + Return` ir joje veikia kiekviena [žiniatinklio programa](25-web-apps.md).

Jei Chromium ne tavo skonio, nesi su ja susietas. Omarchy meniu skiltyje _Įdiegti > Browser_ rasi Chrome, Edge, Brave, Brave Origin, Firefox ir [Zen](https://zen-browser.app/). Pasirink vieną ir Omarchy ją įdiegs, paruoš jos strategijų katalogą ir pritaikys jai tavo esamą temą.

## Nustatyti vieną numatytąja

Įdiegus naršyklę ji nepakylama. Kai ji jau kompiuteryje, eik į _Nuostatos > Defaults > Browser_ ir pasirink ją — meniu išvardija tik tas naršykles, kurias iš tikrųjų įdiegei, ir pažymi dabartinę numatytąją varnele.

Iš terminalo tai:

```bash
omarchy default browser firefox
```

Paleisk be argumento ir jis pasakys, kokia yra dabartinė numatytoji. Tai nustato XDG tvarkyklę, tad ne tik Omarchy spartieji klavišai paklūsta — viskas, kas atveria nuorodą, nuo pokalbių programos iki terminalo komandos, eina į tavo pasirinktą naršyklę.

## Copy URL ir Download Video

Chromium šeimos naršyklės (pati Chromium, Chrome, Edge ir Brave) pristatomos su dviem Omarchy plėtiniais, kurie išsitiesia iš naršyklės į likusią tavo sistemos dalį.

**Copy URL** su `Alt + Shift + L` įkelia dabartinio skirtuko adresą į tavo iškarpinę. Tai greičiau nei spustelėti adreso juostą ir kopijuoti, o kadangi tai eina per sistemos iškarpinę, o ne naršyklės, gauni Omarchy pranešimą, tai patvirtinantį, ir URL iškart prieinamas [iškarpinės istorijoje](08-unified-clipboard-history.md) ir kiekvienoje kitoje programoje. Taip pat yra įrankių juostos mygtukas, jei mėgsti spustelėti.

**Download Video** su `Alt + Shift + D` paima vaizdo įrašą, grojamą puslapyje, į kurį žvelgi. Jis perduoda URL [yt-dlp](https://github.com/yt-dlp/yt-dlp), tad veikia gerokai plačiau nei YouTube, o atsisiuntimas atsiduria `~/Videos`. Progresas pasirodo tame pačiame ekrano rodinyje, kurį naudoja garsumas ir ryškumas, atnaujinamas vietoje, o ne sukraunant pranešimus. Nustatyk `OMARCHY_YTDLP_DIR`, jei norėtum, kad failai eitų kur kitur — žr. [DUK](46-faq.md) apie tai, kur dėti aplinkos kintamuosius.

Abu plėtiniai kalbasi su Omarchy per mažą nativežinių mainų šeimininką, kuris įdiegiamas tau kartu su naršykle. Tai ta dalis, kuri leidžia tinklalapio vaizdo įrašui atsidurti tavo namų kataloge, o URL — tavo iškarpinės tvarkytuvėje, ko įprastas plėtinys pats negali padaryti.

Jie veikia tik Chromium šeimoje. Firefox ir Zen jų negauna.

## Firefox ir Zen

Firefox ir Zen yra kita šeima, tad jos gauna kitokį požiūrį: Omarchy įdiegia strategijų failą protingiems numatytiesiems ir perjungia jas į native Wayland režimą, kurio nori trupmeniniam masteliui ir sklandžiam jutiklinio kilimėlio slinkimui.

Jos negauna aukščiau minėtų Chromium plėtinių ir nėra temiruojamos Omarchy, tad tas patirties dalis turi susitvarkyti pats.

## Vėl pašalinti vieną

Bet ką, ką čia įdiegei, gali vėl pašalinti skiltyje _Pašalinti > Browser_. Chromium tame sąraše nėra — tai bazinės sistemos dalis.
