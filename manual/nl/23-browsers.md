# Browsers

Omarchy wordt geleverd met [Google Chrome](https://www.google.com/chrome/) als standaardbrowser. Het thema ervan sluit aan bij de rest van je systeem, en dit is wat `Super + Shift + Return` (of `Super + Shift + B`) opent, met `Super + Shift + Alt + B` voor een privévenster, en waar elke [webapp](25-web-apps.md) in draait. Het opent direct met een browservenster: er is geen welkomstscherm of aanmeldprompt, gebruiksstatistieken en crashrapporten worden niet naar Google gestuurd en de prompts voor advertentieprivacy zijn uitgeschakeld. Je kunt je via de profielknop nog steeds aanmelden bij je Google-account wanneer je synchronisatie wilt.

Als Chrome niet je smaak is, zit je er niet aan vast. Onder _Installeren > Browser_ in het Omarchy-menu vind je [Chromium](https://www.chromium.org/) (de gewone open-sourceversie waarvan Chrome is gemaakt), Edge, Brave, Brave Origin, Firefox en [Zen](https://zen-browser.app/) (Edge alleen op x86-machines). Kies er een en Omarchy installeert deze, stelt de beleidsmap ervan in en past je huidige thema erop toe.

## Een browser als standaard instellen

Een browser installeren maakt hem niet tot de standaard. Ga om te wisselen naar _Instellen > Standaardapps > Browser_ en kies er een. De huidige standaardbrowser is gemarkeerd met een vinkje, en als je een browser kiest die je nog niet hebt, wordt deze eerst geïnstalleerd.

Vanaf de terminal gaat het zo:

```bash
omarchy default browser firefox
```

Voer dit uit zonder argument en het vertelt je wat de huidige standaardbrowser is. Hiermee stel je de XDG-handler in, dus het zijn niet alleen de sneltoetsen van Omarchy die volgen — alles wat een link opent, van een chatapp tot een terminalopdracht, gaat naar de browser die je hebt gekozen.

## Copy URL en Download Video

De browsers uit de Chromium-familie (Chromium zelf, Chrome, Edge, Brave en Brave Origin) worden geleverd met drie Omarchy-extensies: twee die vanuit de browser reiken tot in de rest van je systeem, en een die WhatsApp opruimt.

**Copy URL** zet het adres van het huidige tabblad op je klembord met `Alt + Shift + L`. Dat is sneller dan in de adresbalk klikken en kopiëren, en omdat het via het systeemklembord gaat in plaats van het klembord van de browser, krijg je een Omarchy-melding ter bevestiging en is de URL direct beschikbaar in de [klembordgeschiedenis](08-unified-clipboard-history.md) en in elke andere app. Er is ook een werkbalkknop, als je liever klikt.

**Download Video** pakt de video die speelt op de pagina die je bekijkt, met `Alt + Shift + D`. Het geeft de URL door aan [yt-dlp](https://github.com/yt-dlp/yt-dlp), dus het werkt op veel meer dan alleen YouTube, en de download belandt in `~/Videos`. De voortgang verschijnt in dezelfde schermweergave die volume en helderheid gebruiken, en wordt op dezelfde plek bijgewerkt in plaats van meldingen op elkaar te stapelen. Stel `OMARCHY_YTDLP_DIR` in als je de bestanden liever ergens anders naartoe laat gaan — zie de [FAQ](46-faq.md) voor waar je omgevingsvariabelen moet plaatsen.

Beide extensies communiceren met Omarchy via een kleine native messaging host, die samen met de browser voor je wordt geïnstalleerd. Dat is het onderdeel waardoor de video van een webpagina in je thuismap kan belanden en een URL in je klembordbeheerder terecht kan komen, wat een normale extensie in haar eentje niet kan.

**WhatsApp Slim** laat WhatsApp Web je systeemthema volgen en klapt de chatlijst in wanneer het venster smal is.

Deze zijn alleen voor de Chromium-familie. Firefox en Zen krijgen ze niet.

## Firefox en Zen

Firefox en Zen vormen een andere familie, dus ze krijgen een andere behandeling: Omarchy installeert een beleidsbestand voor verstandige standaardwaarden en schakelt ze in native Wayland-modus, die je wilt voor fractionele schaling en soepel scrollen met het trackpad.

Ze krijgen de Chromium-extensies hierboven niet, en ze worden niet door Omarchy voorzien van een thema, dus die onderdelen van de ervaring moet je zelf instellen.

## Er weer een verwijderen

Elk van deze browsers, Chrome inbegrepen, kan weer worden verwijderd onder _Verwijderen > Browser_. Links gaan dan naar Chrome of Chromium als de andere nog is geïnstalleerd.
