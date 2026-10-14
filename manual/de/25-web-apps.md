# Web-Apps

Du kannst deine eigenen Web-Apps über _Installieren > Web App_ im Omarchy-Menü (`Super + Space`) hinzufügen. Es fragt dich nach dem App-Namen, der App-URL und der Symbol-URL, falls es sie nicht über das Favicon abrufen kann. Großartige PNG-Symbole für viele beliebte Web-Apps findest du auf [Dashboard Icons](https://dashboardicons.com).

Sie sind dann über den App-Launcher (`Super + Space`) erreichbar und nutzen das schöne rahmenlose Web-App-Fenster.

Wenn du eine Web-App entfernen möchtest, gehe einfach im Omarchy-Menü zu _Entfernen > Web App_.

Am besten meldest du dich bei all deinen Konten mit einem normalen Browser an, bevor du die Web-App-Kürzel verwendest. Der dünne Wrapper-Rahmen funktioniert nicht gut mit 1password, sodass es einfach einfacher ist, zuerst direkt angemeldet zu sein.

Alle Tastenkürzel für diese Web-Apps lassen sich in `~/.config/hypr/bindings.lua` ändern.

Wenn du in einer Web-App bist, kannst du die aktuelle URL mit `Shift + Alt + L` in die Zwischenablage kopieren.

Standardmäßig liefert Omarchy bereits eine Auswahl an Standard-Apps mit:

## HEY

[HEY](https://www.hey.com/) ist ein E-Mail- und Kalenderdienst, der eine großartige Alternative für Menschen ist, die von Gmail, Outlook oder Apple Mail genug haben. Es wird von [37signals](https://37signals.com/) gemacht, wo Omarchy seinen Ursprung hat.

Du kannst HEY Email mit `Super + Shift + E` starten, mit `Super + Shift + Alt + E` direkt zum Verfassen einer neuen E-Mail springen und HEY Calendar mit `Super + Shift + C` starten.

## Basecamp

[Basecamp](https://basecamp.com/) ist ein Projektmanagement-Dienst, der kleinen Teams hilft, schneller voranzukommen und mehr Fortschritt zu erzielen. Statt ein Sammelsurium aus Trello, Slack, Asana, Notion oder was auch immer zusammenzuflicken, kannst du mit Basecamp alles an einem Ort haben. Es wird von [37signals](https://37signals.com/) gemacht, wo Omarchy seinen Ursprung hat.

Du kannst Basecamp über den App-Launcher (`Super + Space`) starten

## ChatGPT

[ChatGPT](https://chatgpt.com) ist der beliebteste KI-Chatbot der Welt.

Du kannst ChatGPT mit `Super + Shift + A` starten.

## Grok

[Grok](https://grok.com) ist der Chatbot von xAI.

Du kannst Grok mit `Super + Shift + Alt + A` starten.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) ist einer der beliebtesten Nachrichtendienste der Welt, und die Webversion ist eine großartige Option für Linux.

Du kannst WhatsApp mit `Super + Shift + Alt + G` starten.

## Google-Apps

Google Messages, Google Photos, Google Maps und Google Contacts sind ebenfalls als Web-Apps enthalten.

Du kannst Google Messages mit `Super + Shift + Ctrl + G`, Google Photos mit `Super + Shift + P` und Google Maps mit `Super + Shift + S` starten. Google Contacts ist über den App-Launcher (`Super + Space`) verfügbar.

## X

Auf X brechen die Nachrichten aus.

Du kannst X mit `Super + Shift + X` starten und mit `Super + Shift + Alt + X` direkt zum Verfassen eines neuen Beitrags gehen.

## YouTube

[YouTube](https://youtube.com/) ist die beliebteste Videoplattform der Welt.

Du kannst YouTube mit `Super + Shift + Y` starten.

## Zoom

[Zoom](https://zoom.us/) ist das beliebteste Videochat-System in den USA. Großartige Verbindungen rund um die Welt. Und 40-minütige Meetings können ohne kostenpflichtiges Konto abgehalten werden. Omarchy verpackt Zooms Web-Client, und Zoom-Meeting-Links öffnen sich direkt darin.

Du startest Zoom über den App-Launcher (`Super + Space`).

## Discord

[Discord](https://discord.com/) ist der Ort, an dem sich die meisten Gaming- und Open-Source-Communities treffen, einschließlich [Omarchys eigener](https://discord.gg/tXFUdasqhY).

Du startest Discord über den App-Launcher (`Super + Space`).

## Microsoft-Apps

Wähle _Installieren > Service > Microsoft_, um Outlook, Word, Excel, PowerPoint, Teams und OneDrive als Web-Apps hinzuzufügen. Jede App hat ihren eigenen Launcher und öffnet sich direkt, unter Nutzung der kommerziellen Microsoft-365-URLs und deines bestehenden Browserprofils. Sie öffnen sich in denselben Browser-App-Fenstern wie Omarchys andere Web-Apps; sie installieren nicht den separaten Client Teams for Linux.

Entferne das Paket über _Entfernen > Service > Microsoft_ oder entferne einzelne Apps über _Entfernen > Web App_. Du kannst über _Installieren > Web App_ auch nur die Apps installieren, die du willst.

Für eine staatliche oder souveräne Cloud bearbeite die URL in der Zeile `Exec=` im jeweiligen Launcher unter `~/.local/share/applications/`, zum Beispiel `Microsoft Teams.desktop`, und verwende die von deiner Organisation bereitgestellte URL. Schreibe jedes literale `%` in dieser Zeile als `%%`. Änderungen wirken beim nächsten Start. Das erneute Ausführen des Bundle-Installers ersetzt seine Launcher durch die Standard-URLs.

Um geschäftliche Anmeldungen getrennt zu halten, hänge ein Browser-Datenverzeichnis an die Zeile `Exec=` jedes Launchers an:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Ersetze das Beispielverzeichnis durch einen absoluten Pfad deiner Wahl und verwende denselben Pfad für alle sechs Launcher, um geschäftliche Anmeldungen zwischen ihnen zu teilen. Die Web-Apps nutzen Omarchys ausgewählten unterstützten Browser und fallen auf Chromium zurück, wenn der Standardbrowser nicht unterstützt wird.
