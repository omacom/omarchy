# Browser

Omarchy wird mit [Google Chrome](https://www.google.com/chrome/) als Standardbrowser ausgeliefert. Er ist optisch auf den Rest deines Systems abgestimmt, und er ist es, der sich mit `Super + Shift + Return` öffnet und in dem jede [Web-App](25-web-apps.md) läuft. Er öffnet sich direkt in einem Browserfenster: Es gibt keinen Willkommensbildschirm und keine Anmeldeaufforderung, Nutzungsstatistiken und Absturzberichte werden nicht an Google gesendet, und die Abfragen zu Werbung und Datenschutz sind abgeschaltet. Du kannst dich über die Profilschaltfläche trotzdem jederzeit bei deinem Google-Konto anmelden, wenn du Sync nutzen willst.

Wenn Chrome nicht dein Geschmack ist, musst du nicht dabei bleiben. Unter _Install > Browser_ im Omarchy-Menü findest du [Chromium](https://www.chromium.org/) (die schlichte Open-Source-Version, aus der Chrome gemacht ist), Edge, Brave, Brave Origin, Firefox und [Zen](https://zen-browser.app/). Wähl einen aus, und Omarchy installiert ihn, richtet sein Policy-Verzeichnis ein und wendet dein aktuelles Theme auf ihn an.

## Einen zum Standard machen

Einen Browser zu installieren, macht ihn noch nicht zum Standard. Sobald er auf dem Rechner ist, geh zu _Setup > Defaults > Browser_ und wähl ihn aus — das Menü listet nur Browser auf, die du tatsächlich installiert hast, und markiert den aktuellen Standard mit einem Haken.

Im Terminal geht das so:

```bash
omarchy default browser firefox
```

Führe den Befehl ohne Argument aus, und er zeigt dir den aktuellen Standard an. Das setzt den XDG-Handler, also folgen nicht nur Omarchys Hotkeys — alles, was einen Link öffnet, von einer Chat-App bis zu einem Terminalbefehl, geht an den Browser, den du ausgewählt hast.

## Copy URL und Download Video

Die Browser der Chromium-Familie (Chromium selbst, Chrome, Edge und Brave) kommen mit zwei Omarchy-Erweiterungen, die aus dem Browser heraus in den Rest deines Systems greifen.

**Copy URL** legt die Adresse des aktuellen Tabs mit `Alt + Shift + L` in deine Zwischenablage. Das geht schneller, als in die Adressleiste zu klicken und zu kopieren, und weil es über die System-Zwischenablage läuft statt über die des Browsers, bekommst du eine Omarchy-Benachrichtigung zur Bestätigung, und die URL ist sofort im [Zwischenablageverlauf](08-unified-clipboard-history.md) und in jeder anderen App verfügbar. Es gibt auch eine Schaltfläche in der Toolbar, wenn du lieber klickst.

**Download Video** greift sich das Video, das auf der Seite läuft, die du gerade ansiehst, mit `Alt + Shift + D`. Es übergibt die URL an [yt-dlp](https://github.com/yt-dlp/yt-dlp), also funktioniert es auf weit mehr als nur YouTube, und der Download landet in `~/Videos`. Der Fortschritt erscheint in derselben Bildschirmanzeige, die auch Lautstärke und Helligkeit nutzen, und aktualisiert sich an Ort und Stelle, statt Benachrichtigungen zu stapeln. Setze `OMARCHY_YTDLP_DIR`, wenn die Dateien lieber woanders landen sollen — siehe die [FAQ](46-faq.md) dazu, wo Umgebungsvariablen hingehören.

Beide Erweiterungen sprechen über einen kleinen Native-Messaging-Host mit Omarchy, der zusammen mit dem Browser für dich installiert wird. Das ist das Stück, das dafür sorgt, dass ein Video von einer Webseite in deinem Home-Verzeichnis und eine URL in deinem Clipboard-Manager landen kann, was eine normale Erweiterung allein nicht kann.

Die gibt es nur für die Chromium-Familie. Firefox und Zen bekommen sie nicht.

## Firefox und Zen

Firefox und Zen gehören zu einer anderen Familie, also werden sie anders behandelt: Omarchy installiert eine Policies-Datei für sinnvolle Standardeinstellungen und schaltet sie in den nativen Wayland-Modus, den du für fraktionale Skalierung und flüssiges Trackpad-Scrollen willst.

Sie bekommen die Chromium-Erweiterungen oben nicht, und sie werden von Omarchy nicht gethemt, also musst du diese Teile des Erlebnisses selbst einrichten.

## Einen wieder entfernen

Jeden dieser Browser, Chrome eingeschlossen, kannst du unter _Remove > Browser_ wieder entfernen. Links gehen dann an Chrome oder Chromium, wenn der andere noch installiert ist.
