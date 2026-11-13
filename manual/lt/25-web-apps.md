# Žiniatinklio programos

Galite pridėti savų žiniatinklio programų per Omarchy meniu (`Super + Space`) pasirinkę _Install > Web App_. Bus paprašyta nurodyti programos pavadinimą, programos URL ir piktogramos URL, jei jos nepavyks gauti per favicon. Puikių PNG piktogramų daugeliui populiarių žiniatinklio programų rasite [Dashboard Icons](https://dashboardicons.com).

Tuomet jas galėsite pasiekti per programų paleidyklę (`Super + Space`), ir jos naudos gražų berėmį žiniatinklio programos langą.

Jei norite pašalinti žiniatinklio programą, tiesiog eikite į _Remove > Web App_ Omarchy meniu.

Geriausia pirmiausia prisijungti prie visų savo paskyrų įprastoje naršyklėje, o tik tada naudoti žiniatinklio programų sparčiuosius paleidimo būdus. Plonas apvalkalo rėmas prastai veikia su 1password, todėl paprasčiau iš anksto prisijungti tiesiogiai.

Visus šių žiniatinklio programų sparčiuosius klavišus galima pakeisti `~/.config/hypr/bindings.lua`.

Būdami žiniatinklio programoje, dabartinį URL galite nukopijuoti į iškarpinę naudodami `Shift + Alt + L`.

Pagal numatytuosius nustatymus Omarchy jau pateikiama su įvairiomis numatytosiomis programomis:

## HEY

[HEY](https://www.hey.com/) yra el. pašto ir kalendoriaus paslauga, puiki alternatyva tiems, kuriems pabodo Gmail, Outlook ar Apple Mail. Ją sukūrė [37signals](https://37signals.com/), kur ir atsirado Omarchy.

HEY Email galite paleisti naudodami `Super + Shift + E`, iškart pereiti prie naujo el. laiško rašymo naudodami `Super + Shift + Alt + E`, o HEY Calendar paleisti naudodami `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) yra projektų valdymo paslauga, padedanti mažoms komandoms dirbti greičiau ir pasiekti daugiau. Užuot lipdę viską iš Trello, Slack, Asana, Notion ar dar bala žino ko, su Basecamp viską galite turėti vienoje vietoje. Ją sukūrė [37signals](https://37signals.com/), kur ir atsirado Omarchy.

Basecamp galite paleisti per programų paleidyklę (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) yra populiariausias dirbtinio intelekto pokalbių robotas pasaulyje.

ChatGPT galite paleisti naudodami `Super + Shift + A`.

## Grok

[Grok](https://grok.com) yra xAI pokalbių robotas.

Grok galite paleisti naudodami `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) yra viena populiariausių susirašinėjimo paslaugų pasaulyje, o žiniatinklio versija yra puikus pasirinkimas Linux.

WhatsApp galite paleisti naudodami `Super + Shift + Alt + G`.

## Google programos

Google Messages, Google Photos, Google Maps ir Google Contacts taip pat įtrauktos kaip žiniatinklio programos.

Google Messages galite paleisti naudodami `Super + Shift + Ctrl + G`, Google Photos – naudodami `Super + Shift + P`, o Google Maps – naudodami `Super + Shift + S`. Google Contacts pasiekiama per programų paleidyklę (`Super + Space`).

## X

X yra vieta, kurioje pirmiausia pasirodo naujienos.

X galite paleisti naudodami `Super + Shift + X`, o tiesiai prie naujo įrašo rašymo pereiti naudodami `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) yra populiariausia vaizdo įrašų platforma pasaulyje.

YouTube galite paleisti naudodami `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) yra populiariausia vaizdo pokalbių sistema, naudojama JAV. Puikus ryšys visame pasaulyje. O 40 minučių susitikimus galima rengti ir be mokamos paskyros. Omarchy apgaubia Zoom žiniatinklio klientą, ir Zoom susitikimų nuorodos atsidarys tiesiai jame.

Zoom paleisite per programų paleidyklę (`Super + Space`).

## Discord

[Discord](https://discord.com/) yra vieta, kurioje renkasi dauguma žaidimų ir atvirojo kodo bendruomenių, įskaitant [Omarchy bendruomenę](https://discord.gg/tXFUdasqhY).

Discord paleisite per programų paleidyklę (`Super + Space`).

## Microsoft programos

Pasirinkite _Install > Service > Microsoft_, kad pridėtumėte Outlook, Word, Excel, PowerPoint, Teams ir OneDrive kaip žiniatinklio programas. Kiekviena programa turi savo paleidyklę ir atsidaro tiesiogiai, naudodama komercinius Microsoft 365 URL ir jūsų esamą naršyklės profilį. Jos atsidaro tuose pačiuose naršyklės programų languose kaip ir kitos Omarchy žiniatinklio programos; jos neįdiegia atskiro Teams for Linux kliento.

Pašalinkite rinkinį per _Remove > Service > Microsoft_ arba pašalinkite atskiras programas per _Remove > Web App_. Taip pat galite įdiegti tik norimas programas per _Install > Web App_.

Valstybinio ar suverenaus debesies atveju redaguokite URL atitinkamos paleidyklės `Exec=` eilutėje, esančioje `~/.local/share/applications/`, pavyzdžiui, `Microsoft Teams.desktop`, naudodami organizacijos pateiktą URL. Bet kokį pažodinį `%` toje eilutėje rašykite kaip `%%`. Pakeitimai įsigalios kitą kartą paleidus. Paleidus rinkinio diegimo programą dar kartą, jos paleidyklės bus pakeistos numatytaisiais URL.

Kad darbo prisijungimai liktų atskirti, prie kiekvienos paleidyklės `Exec=` eilutės pridėkite naršyklės duomenų katalogą:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Pavyzdinį katalogą pakeiskite pasirinktu absoliučiu keliu ir naudokite tą patį kelią visoms šešioms paleidyklėms, kad jos dalytųsi darbo prisijungimais. Žiniatinklio programos naudoja Omarchy pasirinktą palaikomą naršyklę, o jei numatytoji naršyklė nepalaikoma – grįžta prie Chrome.
