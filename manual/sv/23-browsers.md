# Webbläsare

Omarchy levereras med [Chromium](https://www.chromium.org/) som standardwebbläsare. Det är den vanliga open-source-byggversionen, temad för att matcha resten av ditt system, och det är den som `Super + Shift + Return` öppnar och som varje [webbapp](25-web-apps.md) körs inuti.

Om Chromium inte är din smak är du inte fast med den. Under _Installera > Browser_ i Omarchy-menyn hittar du Chrome, Edge, Brave, Brave Origin, Firefox och [Zen](https://zen-browser.app/). Välj en så installerar Omarchy den, sätter upp dess policykatalog och applicerar ditt aktuella tema på den.

## Gör en till standard

Att installera en webbläsare befordrar den inte. När den väl finns på maskinen går du till _Installation > Standarder > Browser_ och väljer den — menyn listar bara webbläsare du faktiskt har installerade, och markerar det aktuella standardvalet med en bock.

Från terminalen är det:

```bash
omarchy default browser firefox
```

Kör det utan argument så talar det om det aktuella standardvalet. Det här sätter XDG-hanteraren, så det är inte bara Omarchys snabbtangenter som följer med — allt som öppnar en länk, från en chattapp till ett terminalkommando, går till webbläsaren du valde.

## Copy URL och Download Video

Webbläsarna i Chromium-familjen (Chromium självt, Chrome, Edge och Brave) kommer med två Omarchy-tillägg som sträcker sig ut ur webbläsaren och in i resten av ditt system.

**Copy URL** lägger den aktuella flikens adress i ditt urklipp med `Alt + Shift + L`. Det är snabbare än att klicka sig in i adressfältet och kopiera, och eftersom det går via systemets urklipp snarare än webbläsarens får du en Omarchy-avisering som bekräftar det och URL:en är omedelbart tillgänglig i [urklippshistoriken](08-unified-clipboard-history.md) och varje annan app. Det finns en verktygsfältsknapp också, om du föredrar att klicka.

**Download Video** hämtar videon som spelas på sidan du tittar på med `Alt + Shift + D`. Den lämnar över URL:en till [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den fungerar på långt mer än YouTube, och nedladdningen hamnar i `~/Videos`. Framstegen visas i samma skärmvisning som volym och ljusstyrka använder, och uppdateras på plats snarare än att stapla upp aviseringar. Ställ in `OMARCHY_YTDLP_DIR` om du hellre vill att filerna hamnar någon annanstans — se [FAQ](46-faq.md) för var du ska lägga miljövariabler.

Båda tilläggen pratar med Omarchy via en liten native messaging host, som installeras åt dig tillsammans med webbläsaren. Det är den biten som låter en webbsidas video hamna i din hemkatalog och en URL hamna i din urklippshanterare, vilket ett vanligt tillägg inte kan göra på egen hand.

De här är endast för Chromium-familjen. Firefox och Zen får dem inte.

## Firefox och Zen

Firefox och Zen är en annan familj, så de får annan behandling: Omarchy installerar en policyfil för förnuftiga standarder och växlar dem till native Wayland-läge, vilket du vill ha för bråkdels-skalning och smidig styrplatteskrollning.

De får inte Chromium-tilläggen ovan, och de temas inte av Omarchy, så de delarna av upplevelsen är dina att sätta upp.

## Ta bort en igen

Allt du installerade här kan tas bort igen under _Ta bort > Browser_. Chromium finns inte med i den listan — det är en del av bassystemet.
