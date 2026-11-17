# Webbläsare

Omarchy levereras med [Google Chrome](https://www.google.com/chrome/) som standardwebbläsare. Den är temad för att matcha resten av ditt system, och det är den som `Super + Shift + Return` öppnar och som varje [webbapp](25-web-apps.md) körs i. Den öppnar rakt in i ett webbläsarfönster: det finns ingen välkomstskärm eller inloggningsuppmaning, användningsstatistik och kraschrapporter skickas inte till Google, och integritetsuppmaningarna för annonser är avstängda. Du kan fortfarande logga in på ditt Google-konto från profilknappen när du vill ha synkronisering.

Om Chrome inte är din smak är du inte låst vid den. Under _Install > Browser_ i Omarchy-menyn hittar du [Chromium](https://www.chromium.org/) (den rena byggen med öppen källkod som Chrome är gjord av), Edge, Brave, Brave Origin, Firefox och [Zen](https://zen-browser.app/). Välj en så installerar Omarchy den, sätter upp dess policykatalog och tillämpar ditt aktuella tema på den.

## Gör en till standard

Att installera en webbläsare gör den inte till standard. När den väl finns på maskinen går du till _Setup > Defaults > Browser_ och väljer den — menyn listar bara webbläsare som du faktiskt har installerade och markerar den nuvarande standarden med en bock.

Från terminalen är det:

```bash
omarchy default browser firefox
```

Kör den utan argument så talar den om för dig vad som är nuvarande standard. Detta sätter XDG-hanteraren, så det är inte bara Omarchys snabbtangenter som följer med — allt som öppnar en länk, från en chattapp till ett terminalkommando, går till webbläsaren du valde.

## Copy URL and Download Video

Webbläsarna i Chromium-familjen (Chromium själv, Chrome, Edge och Brave) kommer med två Omarchy-tillägg som sträcker sig ut ur webbläsaren och in i resten av ditt system.

**Copy URL** lägger den aktuella flikens adress i urklippet med `Alt + Shift + L`. Det går snabbare än att klicka i adressfältet och kopiera, och eftersom det går via systemets urklipp snarare än webbläsarens får du en Omarchy-avisering som bekräftar det och URL:en blir omedelbart tillgänglig i [urklippshistoriken](08-unified-clipboard-history.md) och varje annan app. Det finns en knapp i verktygsfältet också, om du föredrar att klicka.

**Download Video** hämtar videon som spelas på sidan du tittar på med `Alt + Shift + D`. Den lämnar över URL:en till [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den fungerar på betydligt mer än YouTube, och nedladdningen hamnar i `~/Videos`. Förloppet visas i samma skärmvisning som volym och ljusstyrka använder och uppdateras på plats istället för att stapla aviseringar på hög. Sätt `OMARCHY_YTDLP_DIR` om du hellre vill att filerna hamnar någon annanstans — se [FAQ](46-faq.md) för var du ska placera miljövariabler.

Båda tilläggen pratar med Omarchy via en liten native messaging-värd, som installeras åt dig tillsammans med webbläsaren. Det är den biten som gör att en webbsidas video kan hamna i din hemkatalog och en URL kan hamna i din urklippshanterare, vilket ett vanligt tillägg inte kan göra på egen hand.

Dessa finns bara för Chromium-familjen. Firefox och Zen får dem inte.

## Firefox and Zen

Firefox och Zen tillhör en annan familj, så de får annan behandling: Omarchy installerar en policyfil för vettiga standardinställningar och växlar dem till inbyggt Wayland-läge, vilket du vill ha för fraktionell skalning och mjuk rullning på styrplattan.

De får inte Chromium-tilläggen ovan, och de temas inte av Omarchy, så de delarna av upplevelsen får du sätta upp själv.

## Ta bort en igen

Vilken som helst av dessa webbläsare, Chrome inkluderad, kan tas bort igen under _Remove > Browser_. Länkar går då till Chrome eller Chromium om den andra fortfarande är installerad.
