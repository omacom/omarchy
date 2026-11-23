# Webové aplikácie

Vlastné webové aplikácie si môžete pridať cez _Install > Web App_ v ponuke Omarchy (`Super + Space`). Vyžiada si od vás názov aplikácie, URL aplikácie a URL ikony, ak ju nedokáže získať cez favicon. Skvelé PNG ikony pre mnohé populárne webové aplikácie nájdete na [Dashboard Icons](https://dashboardicons.com).

Potom budú dostupné cez spúšťač aplikácií (`Super + Space`) a budú používať krásne bezrámové okno webovej aplikácie.

Ak chcete webovú aplikáciu odstrániť, stačí prejsť na _Remove > Web App_ v ponuke Omarchy.

Najlepšie je, ak sa do všetkých svojich účtov prihlásite v bežnom prehliadači ešte pred použitím skratiek webových aplikácií. Tenký rám obálky nefunguje dobre s 1password, takže je jednoducho ľahšie byť hneď prihlásený priamo.

Všetky klávesové skratky pre tieto webové aplikácie môžete zmeniť v `~/.config/hypr/bindings.lua`.

Keď ste vo webovej aplikácii, aktuálnu URL môžete skopírovať do schránky pomocou `Shift + Alt + L`.

Omarchy v predvolenom nastavení už obsahuje výber predvolených aplikácií:

## HEY

[HEY](https://www.hey.com/) je e-mailová a kalendárová služba, ktorá slúži ako skvelá alternatíva pre ľudí unavených z Gmail, Outlook alebo Apple Mail. Vytvorila ju spoločnosť [37signals](https://37signals.com/), kde Omarchy vznikol.

HEY Email môžete spustiť pomocou `Super + Shift + E`, prejsť rovno na písanie nového e-mailu pomocou `Super + Shift + Alt + E` a HEY Calendar spustiť pomocou `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) je služba na riadenie projektov, ktorá pomáha malým tímom postupovať rýchlejšie a dosahovať väčší pokrok. Namiesto skladania zmesi Trello, Slack, Asana, Notion alebo čohokoľvek iného môžete mať všetko na jednom mieste s Basecamp. Vytvorila ju spoločnosť [37signals](https://37signals.com/), kde Omarchy vznikol.

Basecamp môžete spustiť pomocou spúšťača aplikácií (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) je najpopulárnejší AI chat bot na svete.

ChatGPT môžete spustiť pomocou `Super + Shift + A`.

## Grok

[Grok](https://grok.com) je chat bot od xAI.

Grok môžete spustiť pomocou `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) je jedna z najpopulárnejších služieb na posielanie správ na svete a webová verzia je skvelou voľbou pre Linux.

WhatsApp môžete spustiť pomocou `Super + Shift + Alt + G`. Otvorí sa s rozšírením WhatsApp Slim od Omarchy, vďaka ktorému sleduje vašu tému a zbalí zoznam chatov, keď je okno úzke.

## Aplikácie Google

Google Messages, Google Photos, Google Maps a Google Contacts sú tiež zahrnuté ako webové aplikácie.

Google Messages môžete spustiť pomocou `Super + Shift + Ctrl + G`, Google Photos pomocou `Super + Shift + P` a Google Maps pomocou `Super + Shift + S`. Google Contacts je dostupný cez spúšťač aplikácií (`Super + Space`).

## X

X je miesto, kde sa správy objavia ako prvé.

X môžete spustiť pomocou `Super + Shift + X` a prejsť rovno na písanie nového príspevku pomocou `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) je najpopulárnejšia videoplatforma na svete.

YouTube môžete spustiť pomocou `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) je zahrnutý ako webová aplikácia pri nových inštaláciách.

Netflix spustíte pomocou spúšťača aplikácií (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) je najpopulárnejší systém na videochat používaný v USA. Skvelé spojenia po celom svete. A 40-minútové stretnutia sa dajú usporiadať aj bez plateného účtu. Omarchy obaľuje webového klienta Zoom a odkazy na stretnutia cez zoom sa otvoria priamo v ňom.

Zoom spustíte pomocou spúšťača aplikácií (`Super + Space`).

## Discord

[Discord](https://discord.com/) je miesto, kde sa stretáva väčšina herných a open source komunít vrátane [komunity samotného Omarchy](https://discord.gg/tXFUdasqhY).

Discord spustíte pomocou spúšťača aplikácií (`Super + Space`).

## Aplikácie Microsoft

Vyberte _Install > Service > Microsoft_, ak chcete pridať Outlook, Word, Excel, PowerPoint, Teams a OneDrive ako webové aplikácie. Každá aplikácia má vlastný spúšťač a otvára sa priamo, pričom používa komerčné URL Microsoft 365 a váš existujúci profil prehliadača. Otvárajú sa v rovnakých oknách aplikácií prehliadača ako ostatné webové aplikácie Omarchy; neinštalujú samostatného klienta Teams for Linux.

Balík odstránite cez _Remove > Services > Microsoft_ alebo jednotlivé aplikácie odstránite cez _Remove > Web App_. Cez _Install > Web App_ si môžete nainštalovať aj len tie aplikácie, ktoré chcete.

Pre vládny alebo suverénny cloud upravte URL na riadku `Exec=` v príslušnom spúšťači v `~/.local/share/applications/`, napríklad `Microsoft Teams.desktop`, pomocou URL, ktorú vám poskytla vaša organizácia. Každé doslovné `%` v tomto riadku zapíšte ako `%%`. Zmeny sa prejavia pri ďalšom spustení. Opätovné spustenie inštalátora balíka nahradí jeho spúšťače predvolenými URL.

Ak chcete pracovné prihlásenia držať oddelene, pridajte do riadka `Exec=` každého spúšťača adresár s údajmi prehliadača:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Príkladový adresár nahraďte absolútnou cestou podľa vlastného výberu a rovnakú cestu použite pre všetkých šesť spúšťačov, aby medzi sebou zdieľali pracovné prihlásenia. Webové aplikácie používajú podporovaný prehliadač vybraný v Omarchy, pričom keď predvolený prehliadač nie je podporovaný, prejdú na Chrome.
