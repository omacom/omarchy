# Browsers

Omarchy wordt geleverd met [Google Chrome](https://www.google.com/chrome/) als standaardbrowser. De browser is vormgegeven zodat hij past bij de rest van je systeem, en dit is wat `Super + Shift + Return` (of `Super + Shift + B`) opent, met `Super + Shift + Alt + B` voor een privévenster, en waar elke [webapp](25-web-apps.md) in draait. De browser opent direct in een browservenster: er is geen welkomstscherm of aanmeldprompt, gebruiksstatistieken en crashrapporten worden niet naar Google gestuurd en de prompts voor advertentieprivacy zijn uitgeschakeld. Je kunt je nog steeds aanmelden bij je Google-account via de profielknop wanneer je synchronisatie wilt.

Als Chrome niet je smaak is, zit je er niet aan vast. Onder _Install > Browser_ in het Omarchy-menu vind je [Chromium](https://www.chromium.org/) (de gewone opensource-build waar Chrome van is gemaakt), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) en [Ladybird](https://ladybird.org/) (Edge alleen op x86-machines). Kies er een en Omarchy installeert hem, stelt zijn policy-map in en past je huidige thema erop toe.

## Eén als standaard instellen

Een browser installeren maakt hem niet meteen de standaard. Ga om te wisselen naar _Setup > Defaults > Browser_ en kies er een. De huidige standaard is gemarkeerd met een vinkje, en als je een browser kiest die je nog niet hebt, wordt die eerst geïnstalleerd.

Vanuit de terminal doe je het zo:

```bash
omarchy default browser firefox
```

Voer het uit zonder argument en het vertelt je wat de huidige standaard is. Dit stelt de XDG-handler in, dus niet alleen de sneltoetsen van Omarchy volgen mee — alles wat een link opent, van een chatapp tot een terminalcommando, gaat naar de browser die je hebt gekozen.

## Copy URL en Download Video

De browsers uit de Chromium-familie (Chromium zelf, Chrome, Edge, Brave en Brave Origin) worden geleverd met drie Omarchy-extensies: twee die vanuit de browser reiken naar de rest van je systeem, en een die WhatsApp opruimt.

**Copy URL** zet het adres van het huidige tabblad op je klembord met `Alt + Shift + L`. Dat is sneller dan in de adresbalk klikken en kopiëren, en omdat het via het systeemklembord gaat in plaats van dat van de browser, krijg je een Omarchy-melding ter bevestiging en is de URL meteen beschikbaar in de [klembordgeschiedenis](08-unified-clipboard-history.md) en elke andere app. Er is ook een werkbalkknop, als je liever klikt.

**Download Video** pakt de video die speelt op de pagina waar je naar kijkt met `Alt + Shift + D`. De extensie geeft de URL door aan [yt-dlp](https://github.com/yt-dlp/yt-dlp), dus het werkt op veel meer dan alleen YouTube, en de download komt terecht in `~/Videos`. De voortgang verschijnt in dezelfde schermweergave die volume en helderheid gebruiken, en wordt ter plekke bijgewerkt in plaats van meldingen op te stapelen. Stel `OMARCHY_YTDLP_DIR` in als je de bestanden liever ergens anders naartoe laat gaan — zie de [FAQ](46-faq.md) voor waar je omgevingsvariabelen moet plaatsen.

Beide extensies communiceren met Omarchy via een kleine native messaging host, die samen met de browser voor je wordt geïnstalleerd. Dat is het onderdeel waarmee de video van een webpagina in je thuismap kan belanden en een URL in je klembordbeheerder, wat een normale extensie in haar eentje niet kan.

**WhatsApp Slim** zorgt ervoor dat WhatsApp Web je systeemthema volgt en klapt de chatlijst in wanneer het venster smal is.

Deze zijn alleen voor de Chromium-familie. Firefox en Zen krijgen ze niet.

## Firefox en Zen

Firefox en Zen zijn een andere familie, dus krijgen ze een andere behandeling: Omarchy installeert een policies-bestand voor verstandige standaardinstellingen en schakelt ze in de native Wayland-modus, die je wilt voor fractionele schaalvergroting en soepel scrollen met het trackpad.

Ze krijgen de bovenstaande Chromium-extensies niet, en ze worden niet door Omarchy van een thema voorzien, dus die delen van de ervaring moet je zelf instellen.

## Ladybird

Ladybird is een browser die vanaf nul is geschreven, met een eigen engine in plaats van die van Chromium of Firefox. Hij is nog in alfa, dus verwacht sites die nog niet werken, en Omarchy installeert hem zoals hij komt: geen extensies, geen thema, geen policies. Hij heeft ook geen privévenster, dus `Super + Shift + Alt + B` opent hem met een tijdelijk profiel dat wordt verwijderd wanneer je hem sluit. [Webapps](25-web-apps.md) blijven draaien in Chrome of Chromium.

## Er weer een verwijderen

Elk van deze browsers, Chrome inbegrepen, kan weer worden verwijderd onder _Remove > Browser_. Links gaan dan naar Chrome of Chromium als de andere nog is geïnstalleerd.
