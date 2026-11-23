# Browser

Omarchy wird mit [Google Chrome](https://www.google.com/chrome/) als Standardbrowser ausgeliefert. Er ist an das restliche System angepasst und wird mit `Super + Shift + Return` (oder `Super + Shift + B`) geöffnet, mit `Super + Shift + Alt + B` für ein privates Fenster, und in ihm läuft auch jede [web app](25-web-apps.md). Er öffnet sich direkt in einem Browserfenster: Es gibt keinen Begrüßungsbildschirm und keine Aufforderung zur Anmeldung, Nutzungsstatistiken und Absturzberichte werden nicht an Google gesendet, und die Werbe-Datenschutzabfragen sind ausgeschaltet. Du kannst dich trotzdem jederzeit über die Profiltaste bei deinem Google-Konto anmelden, wenn du Synchronisierung willst.

Wenn Chrome nicht dein Geschmack ist, musst du nicht dabei bleiben. Unter _Install > Browser_ im Omarchy-Menü findest du [Chromium](https://www.chromium.org/) (die einfache Open-Source-Version, aus der Chrome gebaut wird), Edge, Brave, Brave Origin, Firefox und [Zen](https://zen-browser.app/) (Edge nur auf x86-Rechnern). Wähle einen aus, und Omarchy installiert ihn, richtet sein Policy-Verzeichnis ein und wendet dein aktuelles Theme darauf an.

## Einen zum Standard machen

Einen Browser zu installieren, macht ihn noch nicht zum Standard. Um zu wechseln, gehe zu _Setup > Defaults > Browser_ und wähle einen aus. Der aktuelle Standard ist mit einem Häkchen markiert, und wenn du einen Browser auswählst, den du noch nicht hast, wird er zuerst installiert.

Im Terminal geht das so:

```bash
omarchy default browser firefox
```

Führe den Befehl ohne Argument aus, und er zeigt dir den aktuellen Standard an. Das setzt den XDG-Handler, also folgen nicht nur Omarchys Tastenkürzel – alles, was einen Link öffnet, von einer Chat-App bis zu einem Terminalbefehl, geht an den Browser, den du ausgewählt hast.

## Copy URL und Download Video

Die Browser der Chromium-Familie (Chromium selbst, Chrome, Edge, Brave und Brave Origin) kommen mit drei Omarchy-Erweiterungen: zwei, die aus dem Browser heraus in den Rest deines Systems greifen, und eine, die WhatsApp aufräumt.

**Copy URL** legt die Adresse des aktuellen Tabs mit `Alt + Shift + L` in deine Zwischenablage. Das ist schneller, als in die Adressleiste zu klicken und zu kopieren, und weil es über die Systemzwischenablage statt über die des Browsers läuft, bekommst du eine Omarchy-Benachrichtigung zur Bestätigung und die URL ist sofort in der [clipboard history](08-unified-clipboard-history.md) und in jeder anderen App verfügbar. Es gibt auch eine Schaltfläche in der Symbolleiste, wenn du lieber klickst.

**Download Video** holt das Video, das auf der gerade angezeigten Seite abgespielt wird, mit `Alt + Shift + D`. Es übergibt die URL an [yt-dlp](https://github.com/yt-dlp/yt-dlp), also funktioniert es auf weit mehr als nur YouTube, und der Download landet in `~/Videos`. Der Fortschritt erscheint in derselben Bildschirmanzeige, die auch Lautstärke und Helligkeit nutzen, und wird direkt aktualisiert, statt Benachrichtigungen zu stapeln. Setze `OMARCHY_YTDLP_DIR`, wenn die Dateien lieber woanders landen sollen – siehe die [FAQ](46-faq.md), wo Umgebungsvariablen hingehören.

Beide Erweiterungen kommunizieren mit Omarchy über einen kleinen Native Messaging Host, der zusammen mit dem Browser für dich installiert wird. Das ist das Stück, das es ermöglicht, dass ein Video einer Webseite in deinem Home-Verzeichnis und eine URL in deinem Clipboard Manager landet, was eine normale Erweiterung allein nicht kann.

**WhatsApp Slim** lässt WhatsApp Web deinem System-Theme folgen und klappt seine Chatliste ein, wenn das Fenster schmal ist.

Diese gibt es nur für die Chromium-Familie. Firefox und Zen bekommen sie nicht.

## Firefox und Zen

Firefox und Zen gehören zu einer anderen Familie, also werden sie anders behandelt: Omarchy installiert eine Policies-Datei für sinnvolle Standardeinstellungen und schaltet sie in den nativen Wayland-Modus, den du für fraktionale Skalierung und gleichmäßiges Trackpad-Scrollen willst.

Sie bekommen die oben genannten Chromium-Erweiterungen nicht und werden von Omarchy nicht mit einem Theme versehen, also musst du diese Teile der Erfahrung selbst einrichten.

## Einen wieder entfernen

Jeder dieser Browser, Chrome eingeschlossen, kann unter _Remove > Browser_ wieder entfernt werden. Links gehen dann an Chrome oder Chromium, wenn der jeweils andere noch installiert ist.
