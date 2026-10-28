# Webové aplikácie

Vlastné webové aplikácie môžeš pridať pomocou _Inštalovať > Webová aplikácia_ v menu Omarchy (`Super + Space`). Požiada ťa o názov aplikácie, URL aplikácie a URL ikony, ak ju nedokáže získať prostredníctvom faviconu. Skvelé ikony PNG pre mnoho populárnych webových aplikácií môžeš získať na [Dashboard Icons](https://dashboardicons.com).

Potom budú dostupné prostredníctvom spúšťača aplikácií (`Super + Space`) a budú používať krásne bezrámové okno webovej aplikácie.

Ak chceš webovú aplikáciu odstrániť, stačí prejsť do časti _Odstrániť > Webová aplikácia_ v menu Omarchy.

Najlepšie je, ak sa do všetkých svojich účtov prihlásiš pomocou bežného prehliadača skôr, než použiješ skratky webových aplikácií. Tenký obalový rám (wrapper) nefunguje dobre s 1password, takže je jednoduchšie byť najprv prihlásený priamo.

Všetky klávesové skratky pre tieto webové aplikácie sa dajú zmeniť v súbore `~/.config/hypr/bindings.lua`.

Keď si vo webovej aplikácii, môžeš skopírovať aktuálnu URL do schránky pomocou `Shift + Alt + L`.

Omarchy sa predvolene dodáva už s výberom predvolených aplikácií:

## HEY

[HEY](https://www.hey.com/) je e-mailová a kalendárová služba, ktorá slúži ako skvelá alternatíva pre ľudí unavených z Gmailu, Outlooku alebo Apple Mail. Vyrába ju [37signals](https://37signals.com/), odkiaľ pochádza aj Omarchy.

HEY Email môžeš spustiť pomocou `Super + Shift + E`, preskočiť priamo na písanie nového e-mailu pomocou `Super + Shift + Alt + E` a spustiť HEY Calendar pomocou `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) je služba na riadenie projektov, ktorá pomáha malým tímom pohybovať sa rýchlejšie a robiť väčší pokrok. Namiesto látania zmesi Trella, Slacku, Asany, Notionu alebo čohokoľvek iného to môžeš mať všetko na jednom mieste s Basecampom. Vyrába ho [37signals](https://37signals.com/), odkiaľ pochádza aj Omarchy.

Basecamp môžeš spustiť pomocou spúšťača aplikácií (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) je najpopulárnejší AI chatovací bot na svete.

ChatGPT môžeš spustiť pomocou `Super + Shift + A`.

## Grok

[Grok](https://grok.com) je chatovací bot spoločnosti xAI.

Grok môžeš spustiť pomocou `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) je jednou z najpopulárnejších služieb na posielanie správ na svete a webová verzia je skvelou možnosťou pre Linux.

WhatsApp môžeš spustiť pomocou `Super + Shift + Alt + G`.

## Aplikácie Google

Google Messages, Google Photos, Google Maps a Google Contacts sú tiež zahrnuté ako webové aplikácie.

Google Messages môžeš spustiť pomocou `Super + Shift + Ctrl + G`, Google Photos pomocou `Super + Shift + P` a Google Maps pomocou `Super + Shift + S`. Google Contacts je dostupná prostredníctvom spúšťača aplikácií (`Super + Space`).

## X

X je miesto, kde sa lámu správy.

X môžeš spustiť pomocou `Super + Shift + X` a prejsť priamo na písanie nového príspevku pomocou `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) je najpopulárnejšia videoplatforma na svete.

YouTube môžeš spustiť pomocou `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) je najpopulárnejší systém na videochat používaný v USA. Skvelé spojenia po celom svete. A 40-minútové stretnutia sa dajú konať aj bez platiaceho účtu. Omarchy obalí webového klienta Zoomu a odkazy na stretnutia zoom sa otvoria priamo doň.

Zoom spúšťaš pomocou spúšťača aplikácií (`Super + Space`).

## Discord

[Discord](https://discord.com/) je miesto, kde sa zdržiava väčšina herných a open-source komunít vrátane [vlastnej komunity Omarchy](https://discord.gg/tXFUdasqhY).

Discord spúšťaš pomocou spúšťača aplikácií (`Super + Space`).

## Aplikácie Microsoft

Vyber _Inštalovať > Služba > Microsoft_ a pridaj Outlook, Word, Excel, PowerPoint, Teams a OneDrive ako webové aplikácie. Každá aplikácia má vlastný spúšťač a otvára sa priamo, pričom používa komerčné URL služby Microsoft 365 a tvoj existujúci profil prehliadača. Otvárajú sa v tých istých oknách aplikácií prehliadača ako ostatné webové aplikácie Omarchy; neinštalujú samostatného klienta Teams for Linux.

Balík odstrániš pomocou _Odstrániť > Služby > Microsoft_ alebo jednotlivé aplikácie odstrániš pomocou _Odstrániť > Webová aplikácia_. Prostredníctvom _Inštalovať > Webová aplikácia_ môžeš nainštalovať aj len tie aplikácie, ktoré chceš.

V prípade vládneho alebo suverénneho cloudu uprav URL na riadku `Exec=` v príslušnom spúšťači v adresári `~/.local/share/applications/`, napríklad `Microsoft Teams.desktop`, pomocou URL poskytnutej tvojou organizáciou. Každé doslovné `%` v tomto riadku zapíš ako `%%`. Zmeny sa prejavia pri ďalšom spustení. Opätovné spustenie inštalátora balíka nahradí jeho spúšťače predvolenými URL.

Ak chceš pracovné prihlásenia udržiavať oddelené, pripoj k riadku `Exec=` každého spúšťača adresár údajov prehliadača:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Nahraď vzorový adresár absolútnou cestou podľa svojho výberu a použi tú istú cestu pre všetkých šesť spúšťačov, aby medzi sebou zdieľali pracovné prihlásenia. Webové aplikácie používajú vybraný podporovaný prehliadač Omarchy a vrátia sa k prehliadaču Chromium, keď predvolený prehliadač nie je podporovaný.
