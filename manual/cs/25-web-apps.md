# Webové aplikace

Vlastní webové aplikace si můžete přidat pomocí _Install > Web App_ v nabídce Omarchy (`Super + Space`). Zeptá se vás na název aplikace, URL aplikace a URL ikony, pokud ji nedokáže získat přes favicon. Skvělé PNG ikony pro mnoho populárních webových aplikací najdete na [Dashboard Icons](https://dashboardicons.com).

Budou pak dostupné přes spouštěč aplikací (`Super + Space`) a používají krásné bezrámové okno webové aplikace.

Pokud chcete webovou aplikaci odebrat, stačí přejít do _Remove > Web App_ v nabídce Omarchy.

Nejlepší je přihlásit se ke všem svým účtům v běžném prohlížeči, než začnete používat zkratky webových aplikací. Tenký rám wrapperu s 1password moc dobře nefunguje, takže je prostě snazší být předem přihlášený přímo.

Všechny klávesové zkratky pro tyto webové aplikace můžete změnit v `~/.config/hypr/bindings.lua`.

Když jste ve webové aplikaci, můžete aktuální URL zkopírovat do schránky pomocí `Shift + Alt + L`.

Omarchy ve výchozím nastavení už obsahuje řadu výchozích aplikací:

## HEY

[HEY](https://www.hey.com/) je e-mailová a kalendářová služba, která je skvělou alternativou pro lidi, které už nebaví Gmail, Outlook nebo Apple Mail. Vytváří ji [37signals](https://37signals.com/), odkud Omarchy pochází.

HEY Email můžete spustit pomocí `Super + Shift + E`, rovnou přejít k psaní nového e-mailu pomocí `Super + Shift + Alt + E` a HEY Calendar spustit pomocí `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) je služba pro řízení projektů, která pomáhá malým týmům postupovat rychleji a dělat větší pokroky. Místo abyste lepili dohromady směsici Trello, Slack, Asana, Notion nebo čehokoli jiného, můžete mít s Basecamp všechno na jednom místě. Vytváří ji [37signals](https://37signals.com/), odkud Omarchy pochází.

Basecamp můžete spustit pomocí spouštěče aplikací (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) je nejpopulárnější AI chatbot na světě.

ChatGPT můžete spustit pomocí `Super + Shift + A`.

## Grok

[Grok](https://grok.com) je chatbot společnosti xAI.

Grok můžete spustit pomocí `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) je jednou z nejpopulárnějších služeb pro zasílání zpráv na světě a webová verze je skvělou volbou pro Linux.

WhatsApp můžete spustit pomocí `Super + Shift + Alt + G`.

## Aplikace Google

Google Messages, Google Photos, Google Maps a Google Contacts jsou také zahrnuty jako webové aplikace.

Google Messages můžete spustit pomocí `Super + Shift + Ctrl + G`, Google Photos pomocí `Super + Shift + P` a Google Maps pomocí `Super + Shift + S`. Google Contacts je dostupný přes spouštěč aplikací (`Super + Space`).

## X

X je místo, kde se objevují nejnovější zprávy.

X můžete spustit pomocí `Super + Shift + X` a rovnou přejít k psaní nového příspěvku pomocí `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) je nejpopulárnější videoplatforma na světě.

YouTube můžete spustit pomocí `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) je nejpopulárnější systém pro videochat používaný v USA. Skvělé spojení po celém světě. A 40minutové schůzky můžete pořádat i bez placeného účtu. Omarchy obaluje webového klienta Zoomu a odkazy na zoom schůzky se budou otevírat přímo do něj.

Zoom spustíte pomocí spouštěče aplikací (`Super + Space`).

## Discord

[Discord](https://discord.com/) je místo, kde se schází většina herních a open source komunit, včetně [té vlastní od Omarchy](https://discord.gg/tXFUdasqhY).

Discord spustíte pomocí spouštěče aplikací (`Super + Space`).

## Aplikace Microsoft

Vyberte _Install > Service > Microsoft_ a přidejte Outlook, Word, Excel, PowerPoint, Teams a OneDrive jako webové aplikace. Každá aplikace má vlastní spouštěč a otevírá se přímo, používá komerční URL Microsoft 365 a váš stávající profil prohlížeče. Otevírají se ve stejných oknech prohlížečových aplikací jako ostatní webové aplikace Omarchy; neinstalují samostatného klienta Teams for Linux.

Balíček odeberete pomocí _Remove > Service > Microsoft_, jednotlivé aplikace pak pomocí _Remove > Web App_. Přes _Install > Web App_ si také můžete nainstalovat jen ty aplikace, které chcete.

Pro vládní nebo suverénní cloud upravte URL na řádku `Exec=` v příslušném spouštěči v `~/.local/share/applications/`, například `Microsoft Teams.desktop`, a použijte URL, kterou vám poskytla vaše organizace. Jakékoli doslovné `%` na tomto řádku zapište jako `%%`. Změny se projeví při příštím spuštění. Opětovné spuštění instalátoru balíčku nahradí jeho spouštěče výchozími URL.

Chcete-li pracovní přihlášení držet odděleně, připojte ke každému řádku `Exec=` spouštěče adresář s daty prohlížeče:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Příkladový adresář nahraďte absolutní cestou podle své volby a stejnou cestu použijte pro všech šest spouštěčů, aby mezi nimi byla pracovní přihlášení sdílená. Webové aplikace používají podporovaný prohlížeč vybraný v Omarchy, a když výchozí prohlížeč není podporovaný, sáhnou po Chrome.
