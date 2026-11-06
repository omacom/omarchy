# Webové aplikace

Vlastní webové aplikace můžete přidat pomocí části _Instalovat > Webová aplikace_ v nabídce Omarchy (`Super + Space`). Zeptá se vás na název aplikace, adresu URL aplikace a adresu URL ikony, pokud ji nedokáže získat prostřednictvím favicon. Skvělé ikony PNG pro mnohé oblíbené webové aplikace získáte na webu [Dashboard Icons](https://dashboardicons.com).

Poté budou přístupné prostřednictvím spouštěče aplikací (`Super + Space`) a budou používat krásné bezrámové okno pro webové aplikace.

Pokud si přejete webovou aplikaci odebrat, stačí přejít do části _Odebrat > Webová aplikace_ v nabídce Omarchy.

Nejlepší je, pokud se před používáním zkratek pro webové aplikace přihlásíte do všech svých účtů pomocí běžného prohlížeče. Tenký rám obálky s 1passwordem dobře nefunguje, takže je jednodušší být přihlášen přímo jako první.

Všechny klávesové zkratky pro tyto webové aplikace lze změnit v souboru `~/.config/hypr/bindings.lua`.

Když jste ve webové aplikaci, můžete aktuální adresu URL zkopírovat do schránky pomocí klávesové zkratky `Shift + Alt + L`.

Ve výchozím nastavení se Omarchy již dodává s výběrem výchozích aplikací:

## HEY

[HEY](https://www.hey.com/) je e-mailová a kalendářová služba, která slouží jako skvělá alternativa pro lidi unavené Gmailem, Outlookem nebo Apple Mailem. Vytvořila ji společnost [37signals](https://37signals.com/), kde Omarchy vznikla.

Program HEY Email můžete spustit pomocí klávesové zkratky `Super + Shift + E`, přejít přímo na vytváření nového e-mailu pomocí klávesové zkratky `Super + Shift + Alt + E` a spustit Kalendář HEY pomocí klávesové zkratky `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) je služba pro správu projektů, která pomáhá malým týmům postupovat rychleji a dosahovat většího pokroku. Namísto slepování směsice Trella, Slacku, Asany, Notionu nebo čehokoli jiného můžete mít s Basecampem vše na jednom místě. Vytvořila ji společnost [37signals](https://37signals.com/), kde Omarchy vznikla.

Basecamp můžete spustit pomocí spouštěče aplikací (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) je nejoblíbenější chatovací robot s umělou inteligencí na světě.

ChatGPT můžete spustit pomocí klávesové zkratky `Super + Shift + A`.

## Grok

[Grok](https://grok.com) je chatovací robot společnosti xAI.

Grok můžete spustit pomocí klávesové zkratky `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) je jednou z nejoblíbenějších služeb pro zasílání zpráv na světě a webová verze je skvělou možností pro Linux.

WhatsApp můžete spustit pomocí klávesové zkratky `Super + Shift + Alt + G`.

## Aplikace Google

Google Messages, Google Photos, Google Maps a Google Contacts jsou všechny zahrnuty také jako webové aplikace.

Google Messages můžete spustit pomocí klávesové zkratky `Super + Shift + Ctrl + G`, Google Photos pomocí klávesové zkratky `Super + Shift + P` a Google Maps pomocí klávesové zkratky `Super + Shift + S`. Google Contacts je k dispozici prostřednictvím spouštěče aplikací (`Super + Space`).

## X

X je místo, kde se objevují zprávy.

X můžete spustit pomocí klávesové zkratky `Super + Shift + X` a přejít přímo k psaní nového příspěvku pomocí klávesové zkratky `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) je nejoblíbenější videoplatforma na světě.

YouTube můžete spustit pomocí klávesové zkratky `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) je nejoblíbenější systém pro videochat používaný v USA. Skvělá připojení po celém světě. A 40minutové schůzky lze konat i bez placeného účtu. Omarchy obaluje webového klienta Zoomu a odkazy na schůzky v Zoomu se budou otevírat přímo do něj.

Zoom spustíte pomocí spouštěče aplikací (`Super + Space`).

## Discord

[Discord](https://discord.com/) je místo, kde se schází většina herních a open source komunit, včetně [té vlastní Omarchy](https://discord.gg/tXFUdasqhY).

Discord spustíte pomocí spouštěče aplikací (`Super + Space`).

## Aplikace Microsoft

Vyberte část _Instalovat > Služba > Microsoft_, chcete-li aplikace Outlook, Word, Excel, PowerPoint, Teams a OneDrive přidat jako webové aplikace. Každá aplikace má vlastní spouštěč a otevírá se přímo pomocí komerčních adres URL Microsoft 365 a vašeho stávajícího profilu prohlížeče. Otevírají se ve stejných oknech prohlížeče jako ostatní webové aplikace Omarchy; neinstalují samostatného klienta Teams pro Linux.

Balíček odeberte pomocí části _Odebrat > Služba > Microsoft_, nebo jednotlivé aplikace odeberte pomocí části _Odebrat > Webová aplikace_. Prostřednictvím části _Instalovat > Webová aplikace_ můžete také nainstalovat pouze aplikace, které chcete.

V případě vládního nebo suverénního cloudu upravte adresu URL na řádku `Exec=` v příslušném spouštěči v adresáři `~/.local/share/applications/`, například `Microsoft Teams.desktop`, pomocí adresy URL poskytnuté vaší organizací. Každé doslovné `%` v tomto řádku zapište jako `%%`. Změny se projeví při příštím spuštění. Opětovné spuštění instalačního programu balíčku nahradí jeho spouštěče výchozími adresami URL.

Chcete-li pracovní přihlášení oddělit, připojte k řádku `Exec=` každého spouštěče adresář s daty prohlížeče:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Nahraďte ukázkový adresář absolutní cestou podle vlastního výběru a použijte stejnou cestu pro všech šest spouštěčů, chcete-li pracovní přihlášení mezi nimi sdílet. Webové aplikace používají prohlížeč podporovaný Omarchy, který byl zvolen, a záložně Chromium, když není podporován výchozí prohlížeč.
