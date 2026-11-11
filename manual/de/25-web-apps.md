# Web-Apps

Du kannst deine eigenen Web-Apps über _Installieren > Web-App_ im Omarchy-Menü (`Super + Space`) hinzufügen. Es fragt dich nach dem Namen der App, der URL der App und der URL des Symbols, falls es dieses nicht per Favicon abrufen kann. Tolle PNG-Symbole für viele beliebte Web-Apps findest du auf [Dashboard Icons](https://dashboardicons.com).

Sie sind dann über den App-Launcher (`Super + Space`) erreichbar und nutzen das schöne rahmenlose Web-App-Fenster.

Wenn du eine Web-App entfernen möchtest, gehe einfach zu _Entfernen > Web-App_ im Omarchy-Menü.

Am besten meldest du dich in einem normalen Browser bei all deinen Konten an, bevor du die Web-App-Verknüpfungen verwendest. Der dünne Wrapper-Rahmen funktioniert nicht gut mit 1password, deshalb ist es einfach einfacher, dich vorher direkt anzumelden.

Alle Tastaturkürzel für diese Web-Apps kannst du in `~/.config/hypr/bindings.lua` ändern.

Wenn du in einer Web-App bist, kannst du die aktuelle URL mit `Shift + Alt + L` in die Zwischenablage kopieren.

Standardmäßig liefert Omarchy bereits eine Auswahl an Standard-Apps mit:

## HEY

[HEY](https://www.hey.com/) ist ein E-Mail- und Kalenderdienst, der eine großartige Alternative für alle ist, die Gmail, Outlook oder Apple Mail satt haben. Er wird von [37signals](https://37signals.com/) entwickelt, wo Omarchy seinen Ursprung hat.

Du kannst HEY Email mit `Super + Shift + E` starten, mit `Super + Shift + Alt + E` direkt zum Verfassen einer neuen E-Mail springen und HEY Calendar mit `Super + Shift + C` starten.

## Basecamp

[Basecamp](https://basecamp.com/) ist ein Projektmanagementdienst, der kleinen Teams hilft, schneller voranzukommen und mehr zu erreichen. Statt ein Sammelsurium aus Trello, Slack, Asana, Notion oder was auch immer zusammenzuflicken, hast du mit Basecamp alles an einem Ort. Er wird von [37signals](https://37signals.com/) entwickelt, wo Omarchy seinen Ursprung hat.

Du kannst Basecamp über den App-Launcher starten (`Super + Space`)

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

Du kannst Google Messages mit `Super + Shift + Ctrl + G` starten, Google Photos mit `Super + Shift + P` und Google Maps mit `Super + Shift + S`. Google Contacts ist über den App-Launcher verfügbar (`Super + Space`).

## X

X ist der Ort, an dem Nachrichten als Erstes die Runde machen.

Du kannst X mit `Super + Shift + X` starten und mit `Super + Shift + Alt + X` direkt einen neuen Beitrag schreiben.

## YouTube

[YouTube](https://youtube.com/) ist die beliebteste Videoplattform der Welt.

Du kannst YouTube mit `Super + Shift + Y` starten.

## Zoom

[Zoom](https://zoom.us/) ist das beliebteste Videochat-System in den USA. Großartige Verbindungen auf der ganzen Welt. Und 40-minütige Meetings können ohne kostenpflichtiges Konto abgehalten werden. Omarchy verpackt den Web-Client von Zoom, und Zoom-Meeting-Links öffnen sich direkt darin.

Du startest Zoom über den App-Launcher (`Super + Space`).

## Discord

[Discord](https://discord.com/) ist der Ort, an dem sich die meisten Gaming- und Open-Source-Communitys aufhalten, einschließlich [Omarchys eigener](https://discord.gg/tXFUdasqhY).

Du startest Discord über den App-Launcher (`Super + Space`).

## Microsoft-Apps

Wähle _Installieren > Dienst > Microsoft_, um Outlook, Word, Excel, PowerPoint, Teams und OneDrive als Web-Apps hinzuzufügen. Jede App hat ihren eigenen Launcher und öffnet sich direkt, unter Verwendung der kommerziellen Microsoft 365-URLs und deines vorhandenen Browserprofils. Sie öffnen sich in denselben Browser-App-Fenstern wie die anderen Web-Apps von Omarchy; sie installieren nicht den separaten Teams for Linux-Client.

Entferne das Paket mit _Entfernen > Dienst > Microsoft_ oder entferne einzelne Apps mit _Entfernen > Web-App_. Du kannst auch nur die gewünschten Apps über _Installieren > Web-App_ installieren.

Für eine behördliche oder souveräne Cloud bearbeite die URL in der `Exec=`-Zeile im entsprechenden Launcher unter `~/.local/share/applications/`, zum Beispiel `Microsoft Teams.desktop`, und verwende dabei die von deiner Organisation bereitgestellte URL. Schreibe jedes literale `%` in dieser Zeile als `%%`. Änderungen werden beim nächsten Start wirksam. Wenn du das Paket-Installationsprogramm erneut ausführst, werden seine Launcher durch die Standard-URLs ersetzt.

Um Arbeitsanmeldungen getrennt zu halten, hänge an die `Exec=`-Zeile jedes Launchers ein Browser-Datenverzeichnis an:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Ersetze das Beispielverzeichnis durch einen absoluten Pfad deiner Wahl und verwende denselben Pfad für alle sechs Launcher, um Arbeitsanmeldungen zwischen ihnen zu teilen. Die Web-Apps verwenden den von Omarchy ausgewählten unterstützten Browser und weichen auf Chrome aus, wenn der Standardbrowser nicht unterstützt wird.
