# Naršyklės

Omarchy pateikiama su [Google Chrome](https://www.google.com/chrome/) kaip numatytąja naršykle. Ji pritaikyta pagal likusią jūsų sistemos temą, ir būtent ją atidaro `Super + Shift + Return` (arba `Super + Shift + B`), o `Super + Shift + Alt + B` atidaro privatų langą, ir būtent joje veikia kiekviena [žiniatinklio programa](25-web-apps.md). Ji iškart atsidaro naršyklės lange: nėra jokio sveikinimo ekrano ar raginimo prisijungti, naudojimo statistika ir strigčių ataskaitos nesiunčiamos Google, o reklamos privatumo raginimai išjungti. Vis tiek galite prisijungti prie savo Google paskyros naudodami profilio mygtuką, kada tik norėsite sinchronizavimo.

Jei Chrome ne pagal jūsų skonį, nesate prie jos prirakinti. Omarchy meniu skiltyje _Install > Browser_ rasite [Chromium](https://www.chromium.org/) (paprastą atvirojo kodo versiją, iš kurios pagaminta Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) ir [Ladybird](https://ladybird.org/) (Edge tik x86 kompiuteriuose). Pasirinkite vieną, ir Omarchy ją įdiegs, sukurs jos politikos katalogą ir pritaikys jai jūsų dabartinę temą.

## Kaip vieną padaryti numatytąja

Naršyklės įdiegimas nepaverčia jos numatytąja. Norėdami perjungti, eikite į _Setup > Defaults > Browser_ ir pasirinkite vieną. Dabartinė numatytoji pažymėta varnele, o pasirinkus naršyklę, kurios dar neturite, ji pirmiausia įdiegiama.

Iš terminalo tai daroma taip:

```bash
omarchy default browser firefox
```

Paleiskite ją be argumento, ir ji pasakys dabartinę numatytąją. Tai nustato XDG tvarkyklę, todėl prie to prisitaiko ne tik Omarchy spartieji klavišai — viskas, kas atidaro nuorodą, nuo pokalbių programos iki terminalo komandos, keliauja į jūsų pasirinktą naršyklę.

## Copy URL ir Download Video

Chromium šeimos naršyklės (pati Chromium, Chrome, Edge, Brave ir Brave Origin) pateikiamos su trimis Omarchy plėtiniais: du iš jų pasiekia sritis už naršyklės ribų ir likusią jūsų sistemą, o vienas sutvarko WhatsApp.

**Copy URL** įdeda dabartinio skirtuko adresą į jūsų iškarpinę paspaudus `Alt + Shift + L`. Tai greičiau nei spustelėti adreso juostą ir kopijuoti, o kadangi tai vyksta per sistemos iškarpinę, o ne per naršyklės, gaunate tai patvirtinantį Omarchy pranešimą, ir URL iškart tampa pasiekiamas [iškarpinės istorijoje](08-unified-clipboard-history.md) ir kiekvienoje kitoje programoje. Jei mieliau spustelėjate, yra ir įrankių juostos mygtukas.

**Download Video** paima vaizdo įrašą, leidžiamą jūsų žiūrimame puslapyje, paspaudus `Alt + Shift + D`. Ji perduoda URL [yt-dlp](https://github.com/yt-dlp/yt-dlp), todėl veikia gerokai daugiau nei vien YouTube, o atsisiuntimas patenka į `~/Videos`. Eiga rodoma tame pačiame ekrano rodinyje, kurį naudoja garsumas ir ryškumas, atnaujinama vietoje, o ne kraunant pranešimus vieną ant kito. Nustatykite `OMARCHY_YTDLP_DIR`, jei norėtumėte, kad failai keliautų kur nors kitur — žr. [DUK](46-faq.md), kur dėti aplinkos kintamuosius.

Abu plėtiniai su Omarchy bendrauja per mažą savąjį pranešimų mazgą, kuris jums įdiegiamas kartu su naršykle. Būtent ši dalis leidžia tinklalapio vaizdo įrašui atsidurti jūsų namų kataloge, o URL — jūsų iškarpinės tvarkytuvėje, ko paprastas plėtinys pats vienas padaryti negalėtų.

**WhatsApp Slim** priverčia WhatsApp Web sekti jūsų sistemos temą ir suskleidžia jos pokalbių sąrašą, kai langas siauras.

Jie skirti tik Chromium šeimai. Firefox ir Zen jų negauna.

## Firefox ir Zen

Firefox ir Zen yra kita šeima, todėl su jomis elgiamasi kitaip: Omarchy įdiegia politikos failą su protingais numatytaisiais parametrais ir perjungia jas į savąjį Wayland režimą, kurio norite trupmeniniam masteliui ir sklandžiam slinkimui jutikliniu kilimėliu.

Jos negauna pirmiau minėtų Chromium plėtinių, ir Omarchy joms netaiko temos, todėl tas patirties dalis turėsite susitvarkyti patys.

## Ladybird

Ladybird yra nuo nulio parašyta naršyklė su savo varikliu, o ne Chromium ar Firefox. Ji vis dar yra alfa versijos, todėl tikėkitės svetainių, kurios dar neveiks, o Omarchy ją įdiegia tokią, kokia ji yra: be plėtinių, be temos, be politikų. Ji neturi ir privataus lango, todėl `Super + Shift + Alt + B` ją atidaro su laikinu profiliu, kuris ištrinamas, kai ją uždarote. [Žiniatinklio programos](25-web-apps.md) ir toliau veikia Chrome arba Chromium.

## Kaip vieną vėl pašalinti

Bet kurią iš šių naršyklių, įskaitant Chrome, galima vėl pašalinti skiltyje _Remove > Browser_. Tada nuorodos keliauja į Chrome arba Chromium, jei kita vis dar įdiegta.
