# Web-Apps

Du kannst deine eigenen Web-Apps über _Install > Web App_ im Omarchy-Menü (`Super + Space`) hinzufügen. Es fragt dich nach dem App-Namen, der App-URL und der Icon-URL, falls es das Icon nicht über das Favicon abrufen kann. Tolle PNG-Icons für viele beliebte Web-Apps findest du auf [Dashboard Icons](https://dashboardicons.com).

Sie sind dann über den App Launcher (`Super + Space`) erreichbar und nutzen das wunderschöne rahmenlose Web-App-Fenster.

Wenn du eine Web-App entfernen möchtest, gehe einfach zu _Remove > Web App_ im Omarchy-Menü.

Am besten meldest du dich bei all deinen Konten in einem normalen Browser an, bevor du die Web-App-Verknüpfungen verwendest. Der schlanke Wrapper-Rahmen funktioniert nicht gut mit 1password, deshalb ist es einfach einfacher, dich vorher direkt anzumelden.

Alle Tastaturkürzel für diese Web-Apps können in `~/.config/hypr/bindings.lua` geändert werden.

Wenn du in einer Web-App bist, kannst du die aktuelle URL mit `Shift + Alt + L` in die Zwischenablage kopieren.

Standardmäßig liefert Omarchy bereits eine Auswahl an Standard-Apps mit:

## HEY

[HEY](https://www.hey.com/) ist ein E-Mail- und Kalenderdienst, der eine großartige Alternative für alle ist, die Gmail, Outlook oder Apple Mail leid sind. Er wird von [37signals](https://37signals.com/) entwickelt, wo Omarchy seinen Ursprung hat.

Du kannst HEY Email mit `Super + Shift + E` starten, mit `Super + Shift + Alt + E` direkt zum Verfassen einer neuen E-Mail springen und HEY Calendar mit `Super + Shift + C` starten.

## Basecamp

[Basecamp](https://basecamp.com/) ist ein Projektmanagement-Dienst, der kleinen Teams hilft, schneller voranzukommen und mehr Fortschritte zu machen. Statt ein Flickwerk aus Trello, Slack, Asana, Notion oder was auch immer zusammenzustückeln, kannst du mit Basecamp alles an einem Ort haben. Er wird von [37signals](https://37signals.com/) entwickelt, wo Omarchy seinen Ursprung hat.

Du kannst Basecamp über den Application Launcher (`Super + Space`) starten

## ChatGPT

[ChatGPT](https://chatgpt.com) ist der beliebteste AI-Chatbot der Welt.

Du kannst ChatGPT mit `Super + Shift + A` starten.

## Grok

[Grok](https://grok.com) ist der Chatbot von xAI.

Du kannst Grok mit `Super + Shift + Alt + A` starten.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) ist einer der beliebtesten Nachrichtendienste der Welt, und die Web-Version ist eine großartige Option für Linux.

Du kannst WhatsApp mit `Super + Shift + Alt + G` starten. Es öffnet sich mit Omarchys WhatsApp Slim-Erweiterung, durch die es deinem Theme folgt und die Chat-Liste einklappt, wenn das Fenster schmal ist.

## Google-Apps

Google Messages, Google Photos, Google Maps und Google Contacts sind ebenfalls als Web-Apps enthalten.

Du kannst Google Messages mit `Super + Shift + Ctrl + G` starten, Google Photos mit `Super + Shift + P` und Google Maps mit `Super + Shift + S`. Google Contacts ist über den App Launcher (`Super + Space`) verfügbar.

## X

X ist der Ort, an dem Nachrichten zuerst bekannt werden.

Du kannst X mit `Super + Shift + X` starten und mit `Super + Shift + Alt + X` direkt einen neuen Beitrag schreiben.

## YouTube

[YouTube](https://youtube.com/) ist die beliebteste Videoplattform der Welt.

Du kannst YouTube mit `Super + Shift + Y` starten.

## Netflix

[Netflix](https://www.netflix.com/) ist bei Neuinstallationen als Web-App enthalten.

Du startest Netflix über den Application Launcher (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) ist das beliebteste Videochat-System in den USA. Großartige Verbindungen auf der ganzen Welt. Und 40-minütige Meetings können ohne kostenpflichtiges Konto abgehalten werden. Omarchy verpackt den Web-Client von Zoom, und Zoom-Meeting-Links öffnen sich direkt darin.

Du startest Zoom über den Application Launcher (`Super + Space`).

## Discord

[Discord](https://discord.com/) ist der Ort, an dem sich die meisten Gaming- und Open-Source-Communitys treffen, darunter auch [Omarchys eigene](https://discord.gg/tXFUdasqhY).

Du startest Discord über den Application Launcher (`Super + Space`).

## Microsoft-Apps

Wähle _Install > Service > Microsoft_, um Outlook, Word, Excel, PowerPoint, Teams und OneDrive als Web-Apps hinzuzufügen. Jede App hat ihren eigenen Launcher und öffnet sich direkt, unter Verwendung der kommerziellen Microsoft 365-URLs und deines vorhandenen Browserprofils. Sie öffnen sich in denselben Browser-App-Fenstern wie die anderen Web-Apps von Omarchy; sie installieren nicht den separaten Teams for Linux-Client.

Entferne das Bundle mit _Remove > Services > Microsoft_ oder entferne einzelne Apps mit _Remove > Web App_. Du kannst über _Install > Web App_ auch nur die Apps installieren, die du möchtest.

Für eine behördliche oder souveräne Cloud bearbeite die URL in der `Exec=`-Zeile im entsprechenden Launcher unter `~/.local/share/applications/`, z. B. `Microsoft Teams.desktop`, und verwende dabei die von deiner Organisation bereitgestellte URL. Schreibe jedes wörtliche `%` in dieser Zeile als `%%`. Die Änderungen werden beim nächsten Start wirksam. Wenn du den Bundle-Installer erneut ausführst, werden dessen Launcher durch die Standard-URLs ersetzt.

Um berufliche Anmeldungen getrennt zu halten, hänge an die `Exec=`-Zeile jedes Launchers ein Browser-Datenverzeichnis an:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Ersetze das Beispielverzeichnis durch einen absoluten Pfad deiner Wahl und verwende für alle sechs Launcher denselben Pfad, um berufliche Anmeldungen zwischen ihnen zu teilen. Die Web-Apps verwenden den von Omarchy ausgewählten unterstützten Browser und fallen auf Chrome zurück, wenn der Standardbrowser nicht unterstützt wird.
