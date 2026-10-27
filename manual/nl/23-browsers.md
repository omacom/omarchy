# Browsers

Omarchy wordt geleverd met [Chromium](https://www.chromium.org/) als standaardbrowser. Het is de gewone opensource-build, gethemed om bij de rest van je systeem te passen, en het is wat `Super + Shift + Return` opent en waar elke [webapp](25-web-apps.md) in draait.

Als Chromium niet je smaak is, zit je er niet aan vast. Onder _Installeren > Browser_ in het Omarchy-menu vind je Chrome, Edge, Brave, Brave Origin, Firefox en [Zen](https://zen-browser.app/). Kies er een en Omarchy installeert hem, zet de beleidsmap op, en past je huidige thema erop toe.

## Eentje als standaard instellen

Een browser installeren promoveert hem niet. Zodra hij op de machine staat, ga je naar _Instellen > Standaardwaarden > Browser_ en kies je hem — het menu toont alleen browsers die je daadwerkelijk hebt geïnstalleerd, en markeert de huidige standaard met een vinkje.

Vanuit de terminal is het:

```bash
omarchy default browser firefox
```

Voer het uit zonder argument en het vertelt je de huidige standaard. Dit stelt de XDG-handler in, dus het zijn niet alleen Omarchy's sneltoetsen die volgen — alles wat een link opent, van een chatapp tot een terminalcommando, gaat naar de browser die je hebt gekozen.

## Copy URL en Download Video

De Chromium-familie browsers (Chromium zelf, Chrome, Edge en Brave) worden geleverd met twee Omarchy-extensies die vanuit de browser naar de rest van je systeem reiken.

**Copy URL** zet het adres van het huidige tabblad op je klembord met `Alt + Shift + L`. Dat is sneller dan in de adresbalk klikken en kopiëren, en omdat het via het systeemklembord gaat in plaats van dat van de browser, krijg je een Omarchy-melding die het bevestigt en is de URL direct beschikbaar in de [klembordgeschiedenis](08-unified-clipboard-history.md) en elke andere app. Er is ook een werkbalkknop, als je liever klikt.

**Download Video** pakt de video die speelt op de pagina waar je naar kijkt met `Alt + Shift + D`. Het geeft de URL door aan [yt-dlp](https://github.com/yt-dlp/yt-dlp), dus het werkt op veel meer dan YouTube, en de download belandt in `~/Videos`. De voortgang verschijnt in dezelfde on-screen display die volume en helderheid gebruiken, en wordt ter plaatse bijgewerkt in plaats van meldingen op te stapelen. Stel `OMARCHY_YTDLP_DIR` in als je liever hebt dat de bestanden ergens anders heengaan — zie de [FAQ](46-faq.md) voor waar je omgevingsvariabelen moet zetten.

Beide extensies praten met Omarchy via een kleine native messaging host, die samen met de browser voor je wordt geïnstalleerd. Dat is het stuk waardoor een video van een webpagina in je thuismap kan belanden en een URL in je klembordbeheerder, wat een normale extensie op zichzelf niet kan.

Deze zijn alleen voor de Chromium-familie. Firefox en Zen krijgen ze niet.

## Firefox en Zen

Firefox en Zen zijn een andere familie, dus ze krijgen een andere behandeling: Omarchy installeert een beleidsbestand voor verstandige standaardwaarden en schakelt ze over naar de native Wayland-modus, die je wilt voor fractionele schaling en soepel scrollen met het touchpad.

Ze krijgen de bovenstaande Chromium-extensies niet, en ze worden niet gethemed door Omarchy, dus die delen van de ervaring moet je zelf opzetten.

## Eentje weer verwijderen

Alles wat je hier hebt geïnstalleerd, kan weer worden verwijderd onder _Verwijderen > Browser_. Chromium staat niet in die lijst — het maakt deel uit van het basissysteem.
