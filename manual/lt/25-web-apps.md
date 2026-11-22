# Žiniatinklio programos

Galite pridėti savo žiniatinklio programų naudodami _Įdiegti > Žiniatinklio programa_ Omarchy meniu (`Super + Space`). Ji paprašys programos pavadinimo, programos URL ir piktogramos URL, jei negalės jos gauti per favicon. Puikių PNG piktogramų daugeliui populiarių žiniatinklio programų galite rasti [Dashboard Icons](https://dashboardicons.com).

Jos tada bus pasiekiamos per programų paleidyklę (`Super + Space`) ir naudos gražų berėmį žiniatinklio programos langą.

Jei norite pašalinti žiniatinklio programą, tiesiog eikite į _Pašalinti > Žiniatinklio programa_ Omarchy meniu.

Geriausia į visas savo paskyras prisijungti įprastoje naršyklėje prieš naudojant žiniatinklio programų sparčiuosius klavišus. Plonas apvalkalo rėmelis blogai veikia su 1password, todėl tiesiog lengviau iš karto būti prisijungus tiesiogiai.

Visus šių žiniatinklio programų sparčiuosius klavišus galima keisti faile `~/.config/hypr/bindings.lua`.

Kai esate žiniatinklio programoje, dabartinį URL galite nukopijuoti į iškarpinę naudodami `Shift + Alt + L`.

Pagal numatytuosius nustatymus Omarchy jau pateikiama su rinkiniu numatytųjų programų:

## HEY

[HEY](https://www.hey.com/) yra el. pašto ir kalendoriaus paslauga, kuri yra puiki alternatyva žmonėms, pavargusiems nuo Gmail, Outlook ar Apple Mail. Ją sukūrė [37signals](https://37signals.com/), kur atsirado Omarchy.

HEY Email galite paleisti naudodami `Super + Shift + E`, iš karto pereiti prie naujo el. laiško kūrimo naudodami `Super + Shift + Alt + E`, o HEY Calendar paleisti naudodami `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) yra projektų valdymo paslauga, padedanti mažoms komandoms judėti greičiau ir pasiekti daugiau. Užuot lipdę kartu Trello, Slack, Asana, Notion ar dar ko nors kratinį, su Basecamp viską galite turėti vienoje vietoje. Ją sukūrė [37signals](https://37signals.com/), kur atsirado Omarchy.

Basecamp galite paleisti naudodami programų paleidyklę (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) yra populiariausias AI pokalbių robotas pasaulyje.

ChatGPT galite paleisti naudodami `Super + Shift + A`.

## Grok

[Grok](https://grok.com) yra xAI pokalbių robotas.

Grok galite paleisti naudodami `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) yra viena populiariausių susirašinėjimo paslaugų pasaulyje, o žiniatinklio versija yra puikus pasirinkimas Linux.

WhatsApp galite paleisti naudodami `Super + Shift + Alt + G`. Ji atsidaro su Omarchy WhatsApp Slim plėtiniu, dėl kurio ji atitinka jūsų temą ir suskleidžia pokalbių sąrašą, kai langas siauras.

## Google programos

Google Messages, Google Photos, Google Maps ir Google Contacts taip pat įtrauktos kaip žiniatinklio programos.

Google Messages galite paleisti naudodami `Super + Shift + Ctrl + G`, Google Photos naudodami `Super + Shift + P`, o Google Maps naudodami `Super + Shift + S`. Google Contacts pasiekiama per programų paleidyklę (`Super + Space`).

## X

X yra vieta, kur pirmiausia pasirodo naujienos.

X galite paleisti naudodami `Super + Shift + X` ir iš karto pereiti prie naujo įrašo rašymo naudodami `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) yra populiariausia vaizdo įrašų platforma pasaulyje.

YouTube galite paleisti naudodami `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) naujuose įdiegimuose įtrauktas kaip žiniatinklio programa.

Netflix paleidžiate naudodami programų paleidyklę (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) yra populiariausia vaizdo pokalbių sistema, naudojama JAV. Puikūs ryšiai visame pasaulyje. O 40 minučių susitikimus galima rengti be mokamos paskyros. Omarchy apgaubia Zoom žiniatinklio klientą, o zoom susitikimų nuorodos atsidarys tiesiai jame.

Zoom paleidžiate naudodami programų paleidyklę (`Super + Space`).

## Discord

[Discord](https://discord.com/) yra vieta, kur renkasi dauguma žaidimų ir atvirojo kodo bendruomenių, įskaitant [pačios Omarchy](https://discord.gg/tXFUdasqhY).

Discord paleidžiate naudodami programų paleidyklę (`Super + Space`).

## Microsoft programos

Pasirinkite _Įdiegti > Paslauga > Microsoft_, kad pridėtumėte Outlook, Word, Excel, PowerPoint, Teams ir OneDrive kaip žiniatinklio programas. Kiekviena programa turi savo paleidyklę ir atsidaro tiesiogiai, naudodama komercinius Microsoft 365 URL ir jūsų esamą naršyklės profilį. Jos atsidaro tuose pačiuose naršyklės programų languose kaip ir kitos Omarchy žiniatinklio programos; jos neįdiegia atskiro Teams for Linux kliento.

Pašalinkite rinkinį naudodami _Pašalinti > Paslaugos > Microsoft_ arba pašalinkite atskiras programas naudodami _Pašalinti > Žiniatinklio programa_. Taip pat galite įdiegti tik norimas programas per _Įdiegti > Žiniatinklio programa_.

Vyriausybinei ar suvereniai debesijai redaguokite URL eilutėje `Exec=` atitinkamoje paleidyklėje kataloge `~/.local/share/applications/`, pavyzdžiui, `Microsoft Teams.desktop`, naudodami jūsų organizacijos pateiktą URL. Bet kokį tiesioginį `%` toje eilutėje rašykite kaip `%%`. Pakeitimai įsigalios kitą kartą paleidus. Paleidus rinkinio diegimo programą dar kartą, jos paleidyklės bus pakeistos numatytaisiais URL.

Kad darbo prisijungimai būtų atskirti, prie kiekvienos paleidyklės eilutės `Exec=` pridėkite naršyklės duomenų katalogą:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Pakeiskite pavyzdinį katalogą savo pasirinktu absoliučiu keliu ir naudokite tą patį kelią visoms šešioms paleidyklėms, kad darbo prisijungimai būtų bendrinami tarp jų. Žiniatinklio programos naudoja Omarchy pasirinktą palaikomą naršyklę, o kai numatytoji naršyklė nepalaikoma, grįžta prie Chrome.
