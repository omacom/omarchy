# Tīmekļa lietotnes

Varat pievienot savas tīmekļa lietotnes, izmantojot _Instalēt > Tīmekļa lietotne_ Omarchy izvēlnē (`Super + Space`). Tā prasīs lietotnes nosaukumu, lietotnes URL un ikonas URL, ja nevarēs to iegūt, izmantojot favicon. Daudzām populārām tīmekļa lietotnēm lieliskas PNG ikonas varat atrast vietnē [Dashboard Icons](https://dashboardicons.com).

Tās pēc tam būs pieejamas, izmantojot lietotņu palaidēju (`Super + Space`), un izmantos skaisto bezrāmja tīmekļa lietotnes logu.

Ja vēlaties noņemt tīmekļa lietotni, vienkārši dodieties uz _Noņemt > Tīmekļa lietotne_ Omarchy izvēlnē.

Vislabāk ir vispirms pieteikties visos savos kontos, izmantojot parastu pārlūkprogrammu, pirms izmantojat tīmekļa lietotņu saīsnes. Plānais ietvara apvalks labi nedarbojas ar 1password, tāpēc vienkārši ir vieglāk vispirms pieteikties tieši.

Visus šo tīmekļa lietotņu tastatūras karstos taustiņus var mainīt failā `~/.config/hypr/bindings.lua`.

Kad atrodaties tīmekļa lietotnē, varat kopēt pašreizējo URL starpliktuvē, izmantojot `Shift + Alt + L`.

Pēc noklusējuma Omarchy jau tiek piegādāts ar dažādu noklusējuma lietotņu sortimentu:

## HEY

[HEY](https://www.hey.com/) ir e-pasta un kalendāra pakalpojums, kas kalpo kā lieliska alternatīva cilvēkiem, kuri ir noguruši no Gmail, Outlook vai Apple Mail. To izgatavo [37signals](https://37signals.com/), kur radās Omarchy.

Varat palaist HEY Email, izmantojot `Super + Shift + E`, pāriet uzreiz pie jauna e-pasta rakstīšanas, izmantojot `Super + Shift + Alt + E`, un palaist HEY Calendar, izmantojot `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) ir projektu pārvaldības pakalpojums, kas palīdz mazām komandām strādāt ātrāk un sasniegt vairāk. Tā vietā, lai savienotu kopā dažādu Trello, Slack, Asana, Notion vai jebko citu sajaukumu, ar Basecamp varat iegūt to visu vienā vietā. To izgatavo [37signals](https://37signals.com/), kur radās Omarchy.

Varat palaist Basecamp, izmantojot lietotņu palaidēju (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) ir populārākais AI tērzēšanas bots pasaulē.

Varat palaist ChatGPT, izmantojot `Super + Shift + A`.

## Grok

[Grok](https://grok.com) ir xAI tērzēšanas bots.

Varat palaist Grok, izmantojot `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) ir viens no populārākajiem ziņojumapmaiņas pakalpojumiem pasaulē, un tīmekļa versija ir lieliska iespēja Linux.

Varat palaist WhatsApp, izmantojot `Super + Shift + Alt + G`. Tā atveras ar Omarchy WhatsApp Slim paplašinājumu, kas liek tai sekot jūsu motīvam un sakļauj tērzēšanas sarakstu, kad logs ir šaurs.

## Google lietotnes

Google Messages, Google Photos, Google Maps un Google Contacts arī ir iekļautas kā tīmekļa lietotnes.

Varat palaist Google Messages, izmantojot `Super + Shift + Ctrl + G`, Google Photos, izmantojot `Super + Shift + P`, un Google Maps, izmantojot `Super + Shift + S`. Google Contacts ir pieejama, izmantojot lietotņu palaidēju (`Super + Space`).

## X

X ir vieta, kur izplatās ziņas.

Varat palaist X, izmantojot `Super + Shift + X`, un pāriet uzreiz pie jauna ieraksta rakstīšanas ar `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) ir populārākā video platforma pasaulē.

Varat palaist YouTube, izmantojot `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) jaunās instalācijās ir iekļauts kā tīmekļa lietotne.

Netflix palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) ir populārākā video tērzēšanas sistēma, ko izmanto ASV. Lieliski savienojumi visā pasaulē. Un 40 minūšu sapulces var rīkot bez maksas konta. Omarchy aptver Zoom tīmekļa klientu, un Zoom sapulču saites tajā atvērsies tieši.

Zoom palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Discord

[Discord](https://discord.com/) ir vieta, kur pulcējas lielākā daļa spēļu un atvērtā pirmkoda kopienu, tostarp [paša Omarchy](https://discord.gg/tXFUdasqhY).

Discord palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Microsoft lietotnes

Atlasiet _Instalēt > Pakalpojums > Microsoft_, lai pievienotu Outlook, Word, Excel, PowerPoint, Teams un OneDrive kā tīmekļa lietotnes. Katrai lietotnei ir savs palaidējs, un tā atveras tieši, izmantojot komerciālos Microsoft 365 URL un jūsu esošo pārlūkprogrammas profilu. Tās atveras tajos pašos pārlūkprogrammas lietotņu logos kā citas Omarchy tīmekļa lietotnes; tās neinstalē atsevišķo Teams for Linux klientu.

Noņemiet paketi ar _Noņemt > Pakalpojumi > Microsoft_ vai noņemiet atsevišķas lietotnes ar _Noņemt > Tīmekļa lietotne_. Varat arī instalēt tikai vajadzīgās lietotnes, izmantojot _Instalēt > Tīmekļa lietotne_.

Valdības vai suverēnam mākonim rediģējiet URL rindā `Exec=` attiecīgajā palaidējā mapē `~/.local/share/applications/`, piemēram, `Microsoft Teams.desktop`, izmantojot jūsu organizācijas norādīto URL. Jebkuru burtisku `%` šajā rindā rakstiet kā `%%`. Izmaiņas stājas spēkā nākamajā palaišanas reizē. Paketes instalētāja atkārtota palaišana aizstāj tās palaidējus ar noklusējuma URL.

Lai darba pieteikšanās datus turētu atsevišķi, pievienojiet pārlūkprogrammas datu direktoriju katra palaidēja rindai `Exec=`:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Aizstājiet piemēra direktoriju ar absolūtu ceļu pēc savas izvēles un izmantojiet to pašu ceļu visiem sešiem palaidējiem, lai koplietotu darba pieteikšanās datus starp tiem. Tīmekļa lietotnes izmanto Omarchy izvēlēto atbalstīto pārlūkprogrammu, atgriežoties pie Chrome, kad noklusējuma pārlūkprogramma netiek atbalstīta.
