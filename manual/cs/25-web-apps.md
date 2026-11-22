# Webové aplikace

Vlastní webové aplikace můžete přidat pomocí _Install > Web App_ v nabídce Omarchy (`Super + Space`). Zeptá se vás na název aplikace, URL aplikace a URL ikony, pokud ji nedokáže získat přes favicon. Skvělé ikony PNG pro mnoho populárních webových aplikací najdete na [Dashboard Icons](https://dashboardicons.com).

Budou pak přístupné přes spouštěč aplikací (`Super + Space`) a používají krásné bezrámové okno webové aplikace.

Pokud chcete webovou aplikaci odebrat, stačí přejít do _Remove > Web App_ v nabídce Omarchy.

Nejlepší je přihlásit se ke všem svým účtům pomocí běžného prohlížeče, než začnete používat zkratky webových aplikací. Tenký obalový rámec s 1password moc dobře nefunguje, takže je prostě jednodušší být předem přihlášený přímo.

Všechny klávesové zkratky pro tyto webové aplikace můžete změnit v `~/.config/hypr/bindings.lua`.

Když jste ve webové aplikaci, můžete aktuální URL zkopírovat do schránky pomocí `Shift + Alt + L`.

Omarchy ve výchozím nastavení už obsahuje řadu výchozích aplikací:

## HEY

[HEY](https://www.hey.com/) je e-mailová a kalendářová služba, která slouží jako skvělá alternativa pro lidi, kteří už mají dost služeb Gmail, Outlook nebo Apple Mail. Vytváří ji [37signals](https://37signals.com/), odkud Omarchy pochází.

HEY Email spustíte pomocí `Super + Shift + E`, rovnou přejít k psaní nového e-mailu můžete pomocí `Super + Shift + Alt + E` a HEY Calendar spustíte pomocí `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) je služba pro řízení projektů, která pomáhá malým týmům postupovat rychleji a dosahovat většího pokroku. Místo abyste lepili dohromady změť služeb Trello, Slack, Asana, Notion nebo čehokoli jiného, můžete mít vše na jednom místě s Basecamp. Vytváří ji [37signals](https://37signals.com/), odkud Omarchy pochází.

Basecamp spustíte pomocí spouštěče aplikací (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) je nejpopulárnější AI chatbot na světě.

ChatGPT spustíte pomocí `Super + Shift + A`.

## Grok

[Grok](https://grok.com) je chatbot od xAI.

Grok spustíte pomocí `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) je jedna z nejpopulárnějších služeb pro posílání zpráv na světě a webová verze je pro Linux skvělou volbou.

WhatsApp spustíte pomocí `Super + Shift + Alt + G`. Otevírá se s rozšířením WhatsApp Slim od Omarchy, díky kterému se přizpůsobí vašemu motivu a při úzkém okně sbalí seznam chatů.

## Aplikace Google

Google Messages, Google Photos, Google Maps a Google Contacts jsou také zahrnuty jako webové aplikace.

Google Messages spustíte pomocí `Super + Shift + Ctrl + G`, Google Photos pomocí `Super + Shift + P` a Google Maps pomocí `Super + Shift + S`. Google Contacts je k dispozici přes spouštěč aplikací (`Super + Space`).

## X

X je místo, kde se rodí zprávy.

X spustíte pomocí `Super + Shift + X` a rovnou přejít k psaní nového příspěvku můžete pomocí `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) je nejpopulárnější videoplatforma na světě.

YouTube spustíte pomocí `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) je na nových instalacích zahrnutý jako webová aplikace.

Netflix spustíte pomocí spouštěče aplikací (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) je nejpopulárnější systém pro videohovory používaný v USA. Skvělé spojení po celém světě. A 40minutové schůzky můžete pořádat i bez placeného účtu. Omarchy obaluje webového klienta Zoom a odkazy na schůzky v Zoom se v něm otevřou přímo.

Zoom spustíte pomocí spouštěče aplikací (`Super + Space`).

## Discord

[Discord](https://discord.com/) je místo, kde se schází většina herních a open source komunit, včetně [vlastní komunity Omarchy](https://discord.gg/tXFUdasqhY).

Discord spustíte pomocí spouštěče aplikací (`Super + Space`).

## Aplikace Microsoft

Vyberte _Install > Service > Microsoft_ a přidejte Outlook, Word, Excel, PowerPoint, Teams a OneDrive jako webové aplikace. Každá aplikace má vlastní spouštěč a otevírá se přímo, používá komerční URL Microsoft 365 a váš stávající profil prohlížeče. Otevírají se ve stejných oknech prohlížečových aplikací jako ostatní webové aplikace Omarchy; neinstalují samostatného klienta Teams for Linux.

Balíček odeberete pomocí _Remove > Services > Microsoft_, jednotlivé aplikace odeberete pomocí _Remove > Web App_. Přes _Install > Web App_ si také můžete nainstalovat jen ty aplikace, které chcete.

Pro státní nebo suverénní cloud upravte URL na řádku `Exec=` v příslušném spouštěči v `~/.local/share/applications/`, například `Microsoft Teams.desktop`, pomocí URL, kterou vám poskytne vaše organizace. Každé doslovné `%` na tomto řádku zapište jako `%%`. Změny se projeví při příštím spuštění. Opětovné spuštění instalátoru balíčku nahradí jeho spouštěče výchozími URL.

Pokud chcete pracovní přihlášení oddělit, připojte ke každému řádku `Exec=` spouštěče adresář dat prohlížeče:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Nahraďte ukázkový adresář absolutní cestou podle svého výběru a stejnou cestu použijte u všech šesti spouštěčů, aby mezi nimi sdílely pracovní přihlášení. Webové aplikace používají podporovaný prohlížeč vybraný v Omarchy a vrátí se k Chrome, když výchozí prohlížeč není podporovaný.
