# Browser

Omarchy liefert [Chromium](https://www.chromium.org/) als Standardbrowser mit. Es ist das einfache Open-Source-Build, an den Rest deines Systems angepasst, und es ist das, was `Super + Shift + Return` öffnet und worin jede [Web-App](25-web-apps.md) läuft.

Wenn Chromium nicht dein Geschmack ist, bist du nicht darauf festgelegt. Im Omarchy-Menü findest du unter _Installieren > Browser_ Chrome, Edge, Brave, Brave Origin, Firefox und [Zen](https://zen-browser.app/). Wähle einen, und Omarchy installiert ihn, richtet sein Richtlinienverzeichnis ein und wendet dein aktuelles Design darauf an.

## Einen zum Standard machen

Das Installieren eines Browsers befördert ihn nicht. Sobald er auf dem Rechner ist, gehe zu _Einrichtung > Defaults > Browser_ und wähle ihn aus — das Menü listet nur Browser auf, die du tatsächlich installiert hast, und markiert den aktuellen Standard mit einem Häkchen.

Vom Terminal aus geht es so:

```bash
omarchy default browser firefox
```

Führe es ohne Argument aus, und es sagt dir den aktuellen Standard. Dies setzt den XDG-Handler, sodass nicht nur Omarchys Tastenkürzel folgen — alles, was einen Link öffnet, von einer Chat-App bis zu einem Terminalbefehl, geht zu dem Browser, den du ausgewählt hast.

## Copy URL und Download Video

Die Browser der Chromium-Familie (Chromium selbst, Chrome, Edge und Brave) kommen mit zwei Omarchy-Erweiterungen, die aus dem Browser heraus in den Rest deines Systems greifen.

**Copy URL** legt die Adresse des aktuellen Tabs mit `Alt + Shift + L` in deine Zwischenablage. Das ist schneller als in die Adressleiste zu klicken und zu kopieren, und weil es über die System-Zwischenablage statt über die des Browsers geht, erhältst du eine Omarchy-Benachrichtigung zur Bestätigung, und die URL ist sofort im [Verlauf der Zwischenablage](08-unified-clipboard-history.md) und in jeder anderen App verfügbar. Es gibt auch eine Schaltfläche in der Symbolleiste, falls du lieber klickst.

**Download Video** greift das Video, das auf der gerade angesehenen Seite läuft, mit `Alt + Shift + D`. Es übergibt die URL an [yt-dlp](https://github.com/yt-dlp/yt-dlp), sodass es für weit mehr als YouTube funktioniert, und der Download landet in `~/Videos`. Der Fortschritt erscheint in derselben Bildschirmanzeige, die Lautstärke und Helligkeit nutzen, und aktualisiert sich an Ort und Stelle, statt Benachrichtigungen zu stapeln. Setze `OMARCHY_YTDLP_DIR`, wenn die Dateien lieber woanders landen sollen — in der [FAQ](46-faq.md) steht, wohin Umgebungsvariablen gehören.

Beide Erweiterungen sprechen über einen kleinen nativen Messaging-Host mit Omarchy, der zusammen mit dem Browser für dich installiert wird. Das ist das Stück, das dafür sorgt, dass das Video einer Webseite in deinem Home-Verzeichnis und eine URL in deinem Zwischenablagen-Manager landet, was eine normale Erweiterung allein nicht kann.

Diese gibt es nur für die Chromium-Familie. Firefox und Zen erhalten sie nicht.

## Firefox und Zen

Firefox und Zen sind eine andere Familie, also erhalten sie eine andere Behandlung: Omarchy installiert eine Richtliniendatei für sinnvolle Standards und schaltet sie in den nativen Wayland-Modus, den du für fraktionale Skalierung und reibungsloses Trackpad-Scrollen willst.

Sie erhalten die obigen Chromium-Erweiterungen nicht, und sie werden von Omarchy nicht mit einem Design versehen, sodass diese Teile des Erlebnisses von dir einzurichten sind.

## Einen wieder entfernen

Alles, was du hier installiert hast, kannst du unter _Entfernen > Browser_ wieder deinstallieren. Chromium steht nicht in dieser Liste — es ist Teil des Basissystems.
