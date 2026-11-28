# Browser

Omarchy wird mit [Google Chrome](https://www.google.com/chrome/) als Standardbrowser ausgeliefert. Er ist an das Erscheinungsbild des restlichen Systems angepasst, und er ist das, was `Super + Shift + Return` (oder `Super + Shift + B`) öffnet, mit `Super + Shift + Alt + B` für ein privates Fenster, und worin jede [Web-App](25-web-apps.md) läuft. Er öffnet sich direkt als Browserfenster: Es gibt keinen Begrüßungsbildschirm und keine Anmeldeaufforderung, Nutzungsstatistiken und Absturzberichte werden nicht an Google gesendet, und die Aufforderungen zum Datenschutz bei Werbung sind ausgeschaltet. Du kannst dich trotzdem jederzeit über die Profilschaltfläche bei deinem Google-Konto anmelden, wenn du Synchronisierung willst.

Wenn Chrome nicht dein Geschmack ist, bist du nicht darauf festgenagelt. Unter _Install > Browser_ im Omarchy-Menü findest du [Chromium](https://www.chromium.org/) (den schlichten Open-Source-Build, aus dem Chrome gemacht ist), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) und [Ladybird](https://ladybird.org/) (Edge nur auf x86-Rechnern). Such dir einen aus, und Omarchy installiert ihn, richtet sein Policy-Verzeichnis ein und wendet dein aktuelles Theme darauf an.

## Einen zum Standard machen

Einen Browser zu installieren, macht ihn noch nicht zum Standard. Um zu wechseln, geh zu _Setup > Defaults > Browser_ und such dir einen aus. Der aktuelle Standard ist mit einem Häkchen markiert, und wenn du einen Browser auswählst, den du noch nicht hast, wird er zuerst installiert.

Vom Terminal aus geht es so:

```bash
omarchy default browser firefox
```

Führe ihn ohne Argument aus, und er sagt dir den aktuellen Standard. Das setzt den XDG-Handler, also ziehen nicht nur Omarchys Tastenkürzel nach — alles, was einen Link öffnet, von einer Chat-App bis zu einem Terminalbefehl, geht an den Browser, den du ausgewählt hast.

## URL kopieren und Video herunterladen

Die Browser der Chromium-Familie (Chromium selbst, Chrome, Edge, Brave und Brave Origin) bringen drei Omarchy-Erweiterungen mit: zwei, die aus dem Browser heraus in den Rest deines Systems greifen, und eine, die WhatsApp aufräumt.

**Copy URL** legt die Adresse des aktuellen Tabs mit `Alt + Shift + L` in deine Zwischenablage. Das ist schneller, als in die Adressleiste zu klicken und zu kopieren, und weil es über die Systemzwischenablage läuft statt über die des Browsers, bekommst du eine Omarchy-Benachrichtigung zur Bestätigung, und die URL ist sofort im [Verlauf der Zwischenablage](08-unified-clipboard-history.md) und in jeder anderen App verfügbar. Es gibt auch eine Schaltfläche in der Symbolleiste, falls du lieber klickst.

**Download Video** schnappt sich mit `Alt + Shift + D` das Video, das auf der Seite läuft, die du dir gerade ansiehst. Es übergibt die URL an [yt-dlp](https://github.com/yt-dlp/yt-dlp), also funktioniert es auf weit mehr als nur YouTube, und der Download landet in `~/Videos`. Der Fortschritt wird in derselben Bildschirmanzeige gezeigt, die auch Lautstärke und Helligkeit nutzen, und aktualisiert sich an Ort und Stelle, statt Benachrichtigungen zu stapeln. Setze `OMARCHY_YTDLP_DIR`, wenn die Dateien lieber woanders landen sollen — im [FAQ](46-faq.md) steht, wo du Umgebungsvariablen ablegst.

Beide Erweiterungen sprechen über einen kleinen Native-Messaging-Host mit Omarchy, der zusammen mit dem Browser für dich installiert wird. Das ist das Stück, das es möglich macht, dass das Video einer Webseite in deinem Home-Verzeichnis landet und eine URL in deinem Zwischenablage-Manager, was eine normale Erweiterung allein nicht kann.

**WhatsApp Slim** lässt WhatsApp Web deinem System-Theme folgen und klappt dessen Chatliste ein, wenn das Fenster schmal ist.

Die gibt es nur für die Chromium-Familie. Firefox und Zen bekommen sie nicht.

## Firefox und Zen

Firefox und Zen gehören zu einer anderen Familie, also werden sie anders behandelt: Omarchy installiert eine Policies-Datei mit sinnvollen Standardeinstellungen und schaltet sie in den nativen Wayland-Modus, den du für fraktionelle Skalierung und sanftes Trackpad-Scrollen willst.

Sie bekommen die Chromium-Erweiterungen oben nicht, und sie werden von Omarchy nicht mit einem Theme versehen, also musst du diese Teile des Erlebnisses selbst einrichten.

## Ladybird

Ladybird ist ein von Grund auf neu geschriebener Browser, mit eigener Engine statt der von Chromium oder Firefox. Er ist noch in der Alpha-Phase, also rechne mit Seiten, die noch nicht funktionieren, und Omarchy installiert ihn so, wie er kommt: keine Erweiterungen, kein Theme, keine Policies. Er hat auch kein privates Fenster, also öffnet `Super + Shift + Alt + B` ihn mit einem temporären Profil, das gelöscht wird, wenn du ihn schließt. [Web-Apps](25-web-apps.md) laufen weiterhin in Chrome oder Chromium.

## Einen wieder entfernen

Jeder dieser Browser, Chrome eingeschlossen, kann unter _Remove > Browser_ wieder entfernt werden. Links gehen dann an Chrome oder Chromium, falls der jeweils andere noch installiert ist.
