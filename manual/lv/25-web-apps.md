# Tīmekļa lietotnes

Savējās tīmekļa lietotnes varat pievienot Omarchy izvēlnē (`Super + Space`) sadaļā _Instalēt > Web App_. Jums tiks prasīts lietotnes nosaukums, lietotnes vietrādis (URL) un ikonas vietrādis, ja to nevar iegūt ar vietnes ikonu (favicon). Lieliskas PNG ikonas daudzām populārām tīmekļa lietotnēm var atrast vietnē [Dashboard Icons](https://dashboardicons.com).

Tad tās būs pieejamas lietotņu palaidējā (`Super + Space`) un izmantos skaistu bezrāmja tīmekļa lietotnes logu.

Ja vēlaties tīmekļa lietotni noņemt, vienkārši Omarchy izvēlnē dodieties uz _Noņemt > Web App_.

Vislabāk ir, ja pirms tīmekļa lietotņu saīsņu izmantošanas visos savos kontos pierakstāties parastā pārlūkprogrammā. Plānais ietvara rāmis ar 1password sadarbojas slikti, tāpēc vienkārši ir vieglāk jau iepriekš būt pierakstītam tieši.

Visas šo tīmekļa lietotņu tastatūras saīsnes var mainīt failā `~/.config/hypr/bindings.lua`.

Kad esat tīmekļa lietotnē, pašreizējo vietrādi starpliktuvē varat kopēt ar `Shift + Alt + L`.

Pēc noklusējuma Omarchy jau tiek piegādāts ar noklusējuma lietotņu sortimentu:

## HEY

[HEY](https://www.hey.com/) ir e-pasta un kalendāra pakalpojums, kas kalpo kā lieliska alternatīva cilvēkiem, kuri noguruši no Gmail, Outlook vai Apple Mail. To izveidojis uzņēmums [37signals](https://37signals.com/), kur Omarchy radās.

HEY Email varat palaist ar `Super + Shift + E`, pārlēkt tieši uz jaunas vēstules sastādīšanu ar `Super + Shift + Alt + E` un palaist HEY Calendar ar `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) ir projektu pārvaldības pakalpojums, kas mazām komandām palīdz izdarīt darbu ātrāk un panākt lielāku progresu. Trello, Slack, Asana, Notion vai jebkāda cita raibuma vietā, ko lāpīt kopā, ar Basecamp visu var iegūt vienuviet. To izveidojis uzņēmums [37signals](https://37signals.com/), kur Omarchy radās.

Basecamp varat palaist ar lietotņu palaidēju (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) ir populārākais mākslīgā intelekta tērzēšanas robots pasaulē.

ChatGPT varat palaist ar `Super + Shift + A`.

## Grok

[Grok](https://grok.com) ir uzņēmuma xAI tērzēšanas robots.

Grok varat palaist ar `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) ir viens no populārākajiem ziņojumapmaiņas pakalpojumiem pasaulē, un tīmekļa versija Linux vidē ir lieliska iespēja.

WhatsApp varat palaist ar `Super + Shift + Alt + G`.

## Google lietotnes

Kā tīmekļa lietotnes ir iekļautas arī Google Messages, Google Photos, Google Maps un Google Contacts.

Google Messages varat palaist ar `Super + Shift + Ctrl + G`, Google Photos — ar `Super + Shift + P`, bet Google Maps — ar `Super + Shift + S`. Google Contacts ir pieejams lietotņu palaidējā (`Super + Space`).

## X

X ir vieta, kur sākas ziņas.

X varat palaist ar `Super + Shift + X` un doties tieši uz jauna ieraksta rakstīšanu ar `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) ir populārākā video platforma pasaulē.

YouTube varat palaist ar `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) ir populārākā video tērzēšanas sistēma, ko izmanto ASV. Lielisks savienojums visā pasaulē. Turklāt 40 minūšu sapulces var rīkot arī bez maksas konta. Omarchy ietver Zoom tīmekļa klientu, un Zoom sapulču saites atvērsies tieši tajā.

Zoom palaižat ar lietotņu palaidēju (`Super + Space`).

## Discord

[Discord](https://discord.com/) ir vieta, kur uzturas lielākā daļa spēļu un atvērtā pirmkoda kopienu, ieskaitot [pašu Omarchy kopienu](https://discord.gg/tXFUdasqhY).

Discord palaižat ar lietotņu palaidēju (`Super + Space`).

## Microsoft lietotnes

Atlasiet _Instalēt > Service > Microsoft_, lai kā tīmekļa lietotnes pievienotu Outlook, Word, Excel, PowerPoint, Teams un OneDrive. Katrai lietotnei ir savs palaidējs, un tā atveras tieši, izmantojot komerciālos Microsoft 365 vietrāžus un jūsu esošo pārlūkprogrammas profilu. Tās atveras tajos pašos pārlūkprogrammas lietotņu logos, kuros darbojas citas Omarchy tīmekļa lietotnes; tās neinstalē atsevišķo Teams for Linux klientu.

Komplektu noņemiet ar _Noņemt > Service > Microsoft_ vai atsevišķas lietotnes noņemiet ar _Noņemt > Web App_. Varat arī instalēt tikai vajadzīgās lietotnes caur _Instalēt > Web App_.

Valdības vai suverēna mākoņa gadījumā rediģējiet vietrādi attiecīgā palaidēja rindā `Exec=` mapē `~/.local/share/applications/`, piemēram, `Microsoft Teams.desktop`, izmantojot jūsu organizācijas norādīto vietrādi. Katru burtisku `%` šajā rindā rakstiet kā `%%`. Izmaiņas stājas spēkā nākamajā palaišanā. Komplekta instalētāja atkārtota palaišana tā palaidējus aizstāj ar noklusējuma vietrāžiem.

Lai darba pierakstīšanās turētu atsevišķi, katra palaidēja rindai `Exec=` pievienojiet pārlūkprogrammas datu direktoriju:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Piemēra direktoriju aizstājiet ar paša izvēlētu absolūtu ceļu un izmantojiet vienotu ceļu visiem sešiem palaidējiem, lai tie koplietotu darba pierakstīšanās. Tīmekļa lietotnes izmanto Omarchy izvēlēto atbalstīto pārlūkprogrammu, bet, kad noklusējuma pārlūkprogramma netiek atbalstīta, atgriežas pie Chromium.
