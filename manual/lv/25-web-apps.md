# Tīmekļa lietotnes

Savas tīmekļa lietotnes vari pievienot Omarchy izvēlnē (`Super + Space`) ar _Instalēt > Tīmekļa lietotne_. Tas tev prasīs lietotnes nosaukumu, lietotnes URL un ikonas URL, ja to nevarēs iegūt caur favicon. Daudzām populārām tīmekļa lietotnēm lieliskas PNG ikonas vari iegūt vietnē [Dashboard Icons](https://dashboardicons.com).

Pēc tam tās būs pieejamas caur lietotņu palaidēju (`Super + Space`) un izmantos skaisto bezrāmju tīmekļa lietotnes logu.

Ja vēlies kādu tīmekļa lietotni noņemt, Omarchy izvēlnē vienkārši dodies uz _Noņemt > Tīmekļa lietotne_.

Vislabāk visos savos kontos vispirms ielogoties ar parasto pārlūkprogrammu, pirms sāc lietot tīmekļa lietotņu saīsnes. Plānais ietvara rāmis īsti labi nestrādā kopā ar 1password, tāpēc vienkārši vieglāk ir vispirms ielogoties pa tiešo.

Visus šo tīmekļa lietotņu tastatūras karstos taustiņus var mainīt failā `~/.config/hypr/bindings.lua`.

Kad esi tīmekļa lietotnē, pašreizējo URL starpliktuvē vari nokopēt ar `Shift + Alt + L`.

Pēc noklusējuma Omarchy jau tiek piegādāts ar veselu klāstu noklusējuma lietotņu:

## HEY

[HEY](https://www.hey.com/) ir e-pasta un kalendāra pakalpojums, kas ir lieliska alternatīva cilvēkiem, kuri ir noguruši no Gmail, Outlook vai Apple Mail. To ir izveidojis [37signals](https://37signals.com/), kur radās arī Omarchy.

HEY Email vari palaist ar `Super + Shift + E`, uzreiz pāriet pie jauna e-pasta rakstīšanas ar `Super + Shift + Alt + E` un palaist HEY Calendar ar `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) ir projektu pārvaldības pakalpojums, kas palīdz mazām komandām strādāt ātrāk un paveikt vairāk. Tā vietā, lai lāpītu kopā mistrojumu no Trello, Slack, Asana, Notion vai kā tur vēl, ar Basecamp visu vari dabūt vienā vietā. To ir izveidojis [37signals](https://37signals.com/), kur radās arī Omarchy.

Basecamp vari palaist, izmantojot lietotņu palaidēju (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) ir populārākais AI čatbots pasaulē.

ChatGPT vari palaist ar `Super + Shift + A`.

## Grok

[Grok](https://grok.com) ir xAI čatbots.

Grok vari palaist ar `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) ir viens no populārākajiem ziņojumapmaiņas pakalpojumiem pasaulē, un tīmekļa versija ir lieliska izvēle Linux.

WhatsApp vari palaist ar `Super + Shift + Alt + G`.

## Google lietotnes

Google Messages, Google Photos, Google Maps un Google Contacts arī ir iekļautas kā tīmekļa lietotnes.

Google Messages vari palaist ar `Super + Shift + Ctrl + G`, Google Photos ar `Super + Shift + P` un Google Maps ar `Super + Shift + S`. Google Contacts ir pieejama caur lietotņu palaidēju (`Super + Space`).

## X

X ir vieta, kur ziņas parādās pirmās.

X vari palaist ar `Super + Shift + X` un uzreiz pāriet pie jauna ieraksta rakstīšanas ar `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) ir populārākā video platforma pasaulē.

YouTube vari palaist ar `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) ir populārākā videočata sistēma, ko lieto ASV. Lieliski savienojumi visā pasaulē. Un 40 minūšu sapulces var rīkot arī bez maksas konta. Omarchy aptver Zoom tīmekļa klientu ar ietvaru, un Zoom sapulču saites atvērsies tieši tajā.

Zoom palaid, izmantojot lietotņu palaidēju (`Super + Space`).

## Discord

[Discord](https://discord.com/) ir vieta, kur uzturas lielākā daļa spēļu un atvērtā koda kopienu, tostarp [paša Omarchy](https://discord.gg/tXFUdasqhY).

Discord palaid, izmantojot lietotņu palaidēju (`Super + Space`).

## Microsoft lietotnes

Izvēlies _Instalēt > Pakalpojums > Microsoft_, lai pievienotu Outlook, Word, Excel, PowerPoint, Teams un OneDrive kā tīmekļa lietotnes. Katrai lietotnei ir savs palaidējs, un tā atveras pa tiešo, izmantojot komerciālos Microsoft 365 URL un tavu esošo pārlūkprogrammas profilu. Tās atveras tajos pašos pārlūkprogrammas lietotņu logos kā pārējās Omarchy tīmekļa lietotnes; tās neinstalē atsevišķo Teams for Linux klientu.

Noņem komplektu ar _Noņemt > Pakalpojums > Microsoft_ vai noņem atsevišķas lietotnes ar _Noņemt > Tīmekļa lietotne_. Caur _Instalēt > Tīmekļa lietotne_ vari arī instalēt tikai tās lietotnes, kuras vēlies.

Valdības vai suverēnam mākonim rediģē URL attiecīgā palaidēja `Exec=` rindā mapē `~/.local/share/applications/`, piemēram, `Microsoft Teams.desktop`, izmantojot tavas organizācijas sniegto URL. Katru burtisku `%` šajā rindā raksti kā `%%`. Izmaiņas stāsies spēkā nākamajā palaišanas reizē. Ja komplekta instalētāju palaidīsi vēlreiz, tā palaidēji tiks aizstāti ar noklusējuma URL.

Lai darba pieteikšanās turētu atsevišķi, katra palaidēja `Exec=` rindai pievieno pārlūkprogrammas datu direktoriju:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Piemēra direktoriju aizstāj ar absolūtu ceļu pēc savas izvēles un visiem sešiem palaidējiem izmanto vienu un to pašu ceļu, lai darba pieteikšanās starp tiem būtu koplietota. Tīmekļa lietotnes izmanto Omarchy izvēlēto atbalstīto pārlūkprogrammu, un, ja noklusējuma pārlūkprogramma netiek atbalstīta, pāriet uz Chrome kā rezerves variantu.
