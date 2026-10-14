# Žiniatinklio programos

Savo žiniatinklio programas gali pridėti naudodamas _Įdiegti > Web App_ Omarchy meniu (`Super + Space`). Jis paklaus programos pavadinimo, programos URL ir piktogramos URL, jei negali jo gauti per favicon. Puikių PNG piktogramų daugeliui populiarių žiniatinklio programų gali rasti [Dashboard Icons](https://dashboardicons.com).

Tada jos bus pasiekiamos per programų paleidimo priemonę (`Super + Space`) ir naudos gražų berėmį žiniatinklio programos langą.

Jei norėtum pašalinti žiniatinklio programą, tiesiog eik į _Pašalinti > Web App_ Omarchy meniu.

Geriausia, jei į visas savo paskyras prisijungi įprastoje naršyklėje prieš naudodamas žiniatinklio programų sparčiuosius klavišus. Plonas apvalkalo rėmas nelabai gerai veikia su 1password, tad tiesiog lengviau pirmiausia prisijungti tiesiogiai.

Visi šių žiniatinklio programų sparčiuosius klavišus galima pakeisti `~/.config/hypr/bindings.lua`.

Būdamas žiniatinklio programoje, dabartinį URL gali nukopijuoti į iškarpinę naudodamas `Shift + Alt + L`.

Pagal nutylėjimą Omarchy jau pristatoma su rinkiniu numatytųjų programų:

## HEY

[HEY](https://www.hey.com/) yra el. pašto ir kalendoriaus paslauga, tarnaujanti kaip puiki alternatyva žmonėms, pavargusiems nuo Gmail, Outlook ar Apple Mail. Ją sukūrė [37signals](https://37signals.com/), iš kur kilo Omarchy.

HEY Email gali paleisti naudodamas `Super + Shift + E`, pereiti tiesiai prie naujo el. laiško rašymo naudodamas `Super + Shift + Alt + E` ir paleisti HEY Calendar naudodamas `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) yra projektų valdymo paslauga, padedanti mažoms komandoms judėti greičiau ir daryti daugiau pažangos. Užuot jungęs Trello, Slack, Asana, Notion ar bet ko kito kratinį, gali viską turėti vienoje vietoje su Basecamp. Ją sukūrė [37signals](https://37signals.com/), iš kur kilo Omarchy.

Basecamp gali paleisti naudodamas programų paleidimo priemonę (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) yra populiariausias AI pokalbių botas pasaulyje.

ChatGPT gali paleisti naudodamas `Super + Shift + A`.

## Grok

[Grok](https://grok.com) yra xAI pokalbių botas.

Grok gali paleisti naudodamas `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) yra viena populiariausių susirašinėjimo paslaugų pasaulyje, o žiniatinklio versija yra puikus pasirinkimas Linux.

WhatsApp gali paleisti naudodamas `Super + Shift + Alt + G`.

## Google programos

Google Messages, Google Photos, Google Maps ir Google Contacts taip pat įtraukti kaip žiniatinklio programos.

Google Messages gali paleisti naudodamas `Super + Shift + Ctrl + G`, Google Photos naudodamas `Super + Shift + P`, o Google Maps naudodamas `Super + Shift + S`. Google Contacts prieinama per programų paleidimo priemonę (`Super + Space`).

## X

X yra vieta, kur gimsta naujienos.

X gali paleisti naudodamas `Super + Shift + X` ir pereiti tiesiai prie naujo įrašo rašymo su `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) yra populiariausia vaizdo įrašų platforma pasaulyje.

YouTube gali paleisti naudodamas `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) yra populiariausia vaizdo pokalbių sistema, naudojama JAV. Puikūs ryšiai visame pasaulyje. Ir 40 minučių susitikimus galima rengti be mokamos paskyros. Omarchy apvynioja Zoom žiniatinklio klientą, o zoom susitikimų nuorodos atsidarys tiesiai jame.

Zoom paleidi naudodamas programų paleidimo priemonę (`Super + Space`).

## Discord

[Discord](https://discord.com/) yra vieta, kur buriasi dauguma žaidimų ir atviro kodo bendruomenių, įskaitant [pačią Omarchy](https://discord.gg/tXFUdasqhY).

Discord paleidi naudodamas programų paleidimo priemonę (`Super + Space`).

## Microsoft programos

Pasirink _Įdiegti > Service > Microsoft_, kad pridėtum Outlook, Word, Excel, PowerPoint, Teams ir OneDrive kaip žiniatinklio programas. Kiekviena programa turi savo paleidikį ir atsidaro tiesiogiai, naudodama komercinius Microsoft 365 URL ir tavo esamą naršyklės profilį. Jos atsidaro tuose pačiuose naršyklės programų languose kaip ir kitos Omarchy žiniatinklio programos; jos neįdiegia atskiro Teams for Linux kliento.

Pašalink paketą su _Pašalinti > Service > Microsoft_ arba pašalink atskiras programas su _Pašalinti > Web App_. Taip pat gali įdiegti tik tas programas, kurių nori, per _Įdiegti > Web App_.

Valstybiniam ar suvereniame debesyje redaguok URL eilutėje `Exec=` atitinkamame paleidikyje skiltyje `~/.local/share/applications/`, pavyzdžiui, `Microsoft Teams.desktop`, naudodamas URL, kurį pateikė tavo organizacija. Bet kokį tiesioginį `%` toje eilutėje rašyk kaip `%%`. Pakeitimai pritaikomi kitame paleidime. Paleidus paketo diegimo programą dar kartą, jos paleidikiai pakeičiami numatytaisiais URL.

Kad darbo prisijungimai liktų atskiri, prie kiekvieno paleidikio `Exec=` eilutės pridėk naršyklės duomenų katalogą:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Pakeisk pavyzdinį katalogą savo pasirinktu absoliučiu keliu ir naudok tą patį kelią visiems šešiems paleidikiams, kad dalytumeisi darbo prisijungimais tarp jų. Žiniatinklio programos naudoja Omarchy pasirinktą palaikomą naršyklę, grįšdama prie Chromium, kai numatytoji naršyklė nepalaikoma.
