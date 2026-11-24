# Naršyklės

Omarchy pristatoma su [Google Chrome](https://www.google.com/chrome/) kaip numatytąja naršykle. Jai pritaikyta tema, kad derėtų su likusia jūsų sistema, ir būtent ją atveria `Super + Shift + Return` (arba `Super + Shift + B`), su `Super + Shift + Alt + B` atveriamas privatus langas, o joje veikia ir kiekviena [žiniatinklio programa](25-web-apps.md). Ji iš karto atveria naršyklės langą: nėra jokio pasveikinimo ekrano ar raginimo prisijungti, naudojimo statistika ir strigčių ataskaitos nesiunčiamos Google, o reklamos privatumo raginimai išjungti. Vis tiek galite prisijungti prie savo Google paskyros profilio mygtuku, kada tik norite sinchronizavimo.

Jei Chrome ne pagal jūsų skonį, nesate prie jos prirakinti. Omarchy meniu skiltyje _Įdiegti > Naršyklė_ rasite [Chromium](https://www.chromium.org/) (paprastą atvirojo kodo versiją, iš kurios pagaminta Chrome), Edge, Brave, Brave Origin, Firefox ir [Zen](https://zen-browser.app/) (Edge tik x86 kompiuteriuose). Pasirinkite vieną, ir Omarchy ją įdiegs, sukurs jos politikos katalogą ir pritaikys jai jūsų dabartinę temą.

## Kaip vieną padaryti numatytąja

Naršyklės įdiegimas jos nepaverčia numatytąja. Norėdami pakeisti, eikite į _Sąranka > Numatytieji nustatymai > Naršyklė_ ir pasirinkite vieną. Dabartinė numatytoji pažymėta varnele, o pasirinkus naršyklę, kurios dar neturite, ji pirmiausia įdiegiama.

Iš terminalo tai daroma taip:

```bash
omarchy default browser firefox
```

Paleiskite šią komandą be argumentų, ir ji pasakys dabartinę numatytąją. Taip nustatoma XDG tvarkyklė, todėl prisitaiko ne tik Omarchy spartieji klavišai — viskas, kas atveria nuorodą, nuo pokalbių programos iki terminalo komandos, naudoja jūsų pasirinktą naršyklę.

## Copy URL ir Download Video

Chromium šeimos naršyklės (pati Chromium, Chrome, Edge, Brave ir Brave Origin) pateikiamos su trimis Omarchy plėtiniais: du iš jų išeina už naršyklės ribų į likusią jūsų sistemą, o vienas sutvarko WhatsApp.

**Copy URL** su `Alt + Shift + L` įdeda dabartinio skirtuko adresą į jūsų iškarpinę. Tai greičiau, nei spustelėti adreso juostoje ir kopijuoti, o kadangi tai daroma per sistemos, o ne naršyklės, iškarpinę, gaunate tai patvirtinantį Omarchy pranešimą, o URL iš karto pasiekiamas [iškarpinės istorijoje](08-unified-clipboard-history.md) ir kiekvienoje kitoje programoje. Įrankių juostoje taip pat yra mygtukas, jei mieliau spustelėjate.

**Download Video** su `Alt + Shift + D` paima vaizdo įrašą, leidžiamą jūsų žiūrimame puslapyje. Ji perduoda URL [yt-dlp](https://github.com/yt-dlp/yt-dlp), todėl veikia su daug daugiau nei vien YouTube, o atsisiuntimas patenka į `~/Videos`. Eiga rodoma tame pačiame ekrano rodinyje, kurį naudoja garsumas ir ryškumas, ir atnaujinama vietoje, o ne kaupiama pranešimais. Nustatykite `OMARCHY_YTDLP_DIR`, jei norėtumėte, kad failai būtų dedami kitur — žr. [DUK](46-faq.md), kur rašyti aplinkos kintamuosius.

Abu plėtiniai susisiekia su Omarchy per nedidelę vietinę pranešimų priimančią programą, kuri jums įdiegiama kartu su naršykle. Būtent ši dalis leidžia tinklalapio vaizdo įrašui atsidurti jūsų namų kataloge, o URL — jūsų iškarpinės tvarkyklėje, ko įprastas plėtinys pats savaime padaryti negali.

**WhatsApp Slim** pritaiko WhatsApp Web prie jūsų sistemos temos ir suskleidžia jos pokalbių sąrašą, kai langas siauras.

Tai skirta tik Chromium šeimai. Firefox ir Zen jų negauna.

## Firefox ir Zen

Firefox ir Zen priklauso kitai šeimai, todėl su jomis elgiamasi kitaip: Omarchy įdiegia politikos failą su protingais numatytaisiais nustatymais ir perjungia jas į vietinį Wayland režimą, kurio norite dėl trupmeninio mastelio ir sklandaus slinkimo jutikliniu kilimėliu.

Jos negauna pirmiau aprašytų Chromium plėtinių, ir Omarchy joms netaiko temų, todėl tas patirties dalis turėsite susitvarkyti patys.

## Kaip vėl pašalinti naršyklę

Bet kurią iš šių naršyklių, įskaitant Chrome, galima vėl pašalinti skiltyje _Pašalinti > Naršyklė_. Tuomet nuorodos atidaromos Chrome arba Chromium, jei kuri nors iš jų vis dar įdiegta.
