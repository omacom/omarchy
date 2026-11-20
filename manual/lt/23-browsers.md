# Naršyklės

Omarchy pateikiama su [Google Chrome](https://www.google.com/chrome/) kaip numatytąja naršykle. Ji pritaikyta prie likusios jūsų sistemos temos, būtent ją atidaro `Super + Shift + Return` ir būtent joje veikia kiekviena [žiniatinklio programa](25-web-apps.md). Ji atsidaro tiesiai į naršyklės langą: nėra jokio pasveikinimo ekrano ar raginimo prisijungti, naudojimo statistika ir strigčių ataskaitos nesiunčiamos į Google, o reklamų privatumo raginimai išjungti. Vis tiek galite prisijungti prie savo Google paskyros profilio mygtuku, kai tik norėsite sinchronizavimo.

Jei Chrome ne pagal jūsų skonį, nesate prie jos pririšti. Omarchy meniu dalyje _Install > Browser_ rasite [Chromium](https://www.chromium.org/) (paprastą atvirojo kodo versiją, iš kurios pagaminta Chrome), Edge, Brave, Brave Origin, Firefox ir [Zen](https://zen-browser.app/). Pasirinkite vieną, ir Omarchy ją įdiegs, nustatys jos politikos katalogą ir pritaikys jai jūsų dabartinę temą.

## Kaip vieną padaryti numatytąja

Naršyklės įdiegimas jos nepaverčia numatytąja. Kai ji jau yra kompiuteryje, eikite į _Setup > Defaults > Browser_ ir pasirinkite ją — meniu rodo tik tas naršykles, kurias iš tikrųjų esate įdiegę, o dabartinę numatytąją pažymi varnele.

Iš terminalo tai daroma taip:

```bash
omarchy default browser firefox
```

Paleiskite komandą be argumento, ir ji nurodys dabartinę numatytąją. Tai nustato XDG tvarkyklę, todėl prisitaiko ne tik Omarchy spartieji klavišai — viskas, kas atidaro nuorodą, nuo pokalbių programos iki terminalo komandos, nukreipiama į jūsų pasirinktą naršyklę.

## Copy URL ir Download Video

Chromium šeimos naršyklės (pati Chromium, Chrome, Edge ir Brave) pateikiamos su dviem Omarchy plėtiniais, kurie iš naršyklės pasiekia likusią jūsų sistemą.

**Copy URL** su `Alt + Shift + L` įdeda dabartinio skirtuko adresą į jūsų iškarpinę. Tai greičiau, nei spustelėti į adreso juostą ir kopijuoti, o kadangi tai vyksta per sistemos, o ne naršyklės iškarpinę, gaunate tai patvirtinantį Omarchy pranešimą, o URL iškart pasiekiamas [iškarpinės istorijoje](08-unified-clipboard-history.md) ir kiekvienoje kitoje programoje. Įrankių juostoje taip pat yra mygtukas, jei labiau mėgstate spustelėti.

**Download Video** su `Alt + Shift + D` paima vaizdo įrašą, leidžiamą jūsų žiūrimame puslapyje. Ji perduoda URL [yt-dlp](https://github.com/yt-dlp/yt-dlp), todėl veikia su kur kas daugiau nei vien YouTube, o atsisiuntimas atsiduria `~/Videos`. Eiga rodoma tame pačiame ekrano rodinyje, kurį naudoja garsumas ir ryškumas, ir atnaujinama vietoje, o ne kraunama pranešimais vienam ant kito. Nustatykite `OMARCHY_YTDLP_DIR`, jei norėtumėte, kad failai būtų dedami kitur — žr. [FAQ](46-faq.md), kur nurodyta, kur dėti aplinkos kintamuosius.

Abu plėtiniai bendrauja su Omarchy per mažą native messaging host, kuris jums įdiegiamas kartu su naršykle. Būtent ši dalis leidžia tinklalapio vaizdo įrašui atsidurti jūsų namų kataloge, o URL — jūsų iškarpinės tvarkytuvėje, ko paprastas plėtinys pats savaime padaryti negali.

Tai skirta tik Chromium šeimai. Firefox ir Zen jų negauna.

## Firefox ir Zen

Firefox ir Zen yra kita šeima, todėl su jomis elgiamasi kitaip: Omarchy įdiegia politikos failą su protingais numatytaisiais nustatymais ir perjungia jas į savąjį Wayland režimą, kurio norite trupmeniniam mastelio keitimui ir sklandžiam slinkimui jutikliniu kilimėliu.

Jos negauna pirmiau minėtų Chromium plėtinių ir Omarchy joms netaiko temos, todėl tas naudojimo dalis turėsite susitvarkyti patys.

## Kaip ją vėl pašalinti

Bet kurią iš šių naršyklių, įskaitant Chrome, galima vėl pašalinti dalyje _Remove > Browser_. Tada nuorodos nukreipiamos į Chrome arba Chromium, jei kita vis dar įdiegta.
