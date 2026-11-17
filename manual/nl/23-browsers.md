# Browsers

Omarchy wordt geleverd met [Google Chrome](https://www.google.com/chrome/) als standaardbrowser. Het thema sluit aan bij de rest van je systeem, en het is wat `Super + Shift + Return` opent en waar elke [webapp](25-web-apps.md) in draait. Het opent direct in een browservenster: er is geen welkomstscherm of aanmeldprompt, gebruiksstatistieken en crashrapporten worden niet naar Google gestuurd, en de prompts over advertentieprivacy zijn uitgeschakeld. Je kunt je via de profielknop nog steeds aanmelden bij je Google-account wanneer je synchronisatie wilt.

Als Chrome niet je smaak is, zit je er niet aan vast. Onder _Install > Browser_ in het Omarchy-menu vind je [Chromium](https://www.chromium.org/) (de gewone open-source build waarvan Chrome is gemaakt), Edge, Brave, Brave Origin, Firefox en [Zen](https://zen-browser.app/). Kies er een en Omarchy installeert hem, stelt zijn policy-directory in en past je huidige thema erop toe.

## Er één de standaard van maken

Een browser installeren maakt hem nog niet tot de standaard. Zodra hij op de machine staat, ga je naar _Setup > Defaults > Browser_ en kies je hem — het menu toont alleen browsers die je daadwerkelijk hebt geïnstalleerd, en markeert de huidige standaard met een vinkje.

Vanaf de terminal is het:

```bash
omarchy default browser firefox
```

Voer het uit zonder argument en het vertelt je de huidige standaard. Dit stelt de XDG-handler in, dus het zijn niet alleen de sneltoetsen van Omarchy die meebewegen — alles wat een link opent, van een chat-app tot een terminalopdracht, gaat naar de browser die je hebt gekozen.

## URL kopiëren en video downloaden

De browsers uit de Chromium-familie (Chromium zelf, Chrome, Edge en Brave) worden geleverd met twee Omarchy-extensies die buiten de browser reiken tot in de rest van je systeem.

**Copy URL** zet het adres van het huidige tabblad op je klembord met `Alt + Shift + L`. Dat is sneller dan in de adresbalk klikken en kopiëren, en omdat het via het systeemklembord gaat in plaats van dat van de browser, krijg je een Omarchy-melding ter bevestiging en is de URL direct beschikbaar in de [klembordgeschiedenis](08-unified-clipboard-history.md) en in elke andere app. Er is ook een werkbalkknop, als je liever klikt.

**Download Video** pakt met `Alt + Shift + D` de video die speelt op de pagina waar je naar kijkt. Het geeft de URL door aan [yt-dlp](https://github.com/yt-dlp/yt-dlp), dus het werkt op veel meer dan alleen YouTube, en de download belandt in `~/Videos`. De voortgang verschijnt in dezelfde on-screen display die volume en helderheid gebruiken, en wordt ter plekke bijgewerkt in plaats van meldingen op te stapelen. Stel `OMARCHY_YTDLP_DIR` in als je de bestanden liever ergens anders wilt hebben — zie de [FAQ](46-faq.md) voor waar je omgevingsvariabelen moet plaatsen.

Beide extensies communiceren met Omarchy via een kleine native messaging host, die samen met de browser voor je wordt geïnstalleerd. Dat is het onderdeel waardoor een video van een webpagina in je home-directory kan belanden en een URL in je klembordbeheerder terecht kan komen, iets wat een normale extensie in haar eentje niet kan.

Deze zijn alleen voor de Chromium-familie. Firefox en Zen krijgen ze niet.

## Firefox en Zen

Firefox en Zen vormen een andere familie, dus krijgen ze een andere behandeling: Omarchy installeert een policies-bestand met verstandige standaardinstellingen en schakelt ze over naar de native Wayland-modus, die je wilt voor fractionele schaling en soepel scrollen met het trackpad.

Ze krijgen de Chromium-extensies hierboven niet, en ze krijgen geen thema van Omarchy, dus die onderdelen van de ervaring moet je zelf instellen.

## Er weer een verwijderen

Elk van deze browsers, Chrome inbegrepen, kun je weer verwijderen onder _Remove > Browser_. Links gaan dan naar Chrome of Chromium als de andere nog is geïnstalleerd.
