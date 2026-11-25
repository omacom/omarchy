# Webbläsare

Omarchy levereras med [Google Chrome](https://www.google.com/chrome/) som standardwebbläsare. Den har ett tema som matchar resten av ditt system, och det är den som `Super + Shift + Return` (eller `Super + Shift + B`) öppnar, med `Super + Shift + Alt + B` för ett privat fönster, och det som varje [webbapp](25-web-apps.md) körs inuti. Den öppnas direkt i ett webbläsarfönster: det finns ingen välkomstskärm eller inloggningsuppmaning, användningsstatistik och kraschrapporter skickas inte till Google, och uppmaningarna om annonsintegritet är avstängda. Du kan fortfarande logga in på ditt Google-konto från profilknappen när du vill synkronisera.

Om Chrome inte är din smak är du inte fast med den. Under _Install > Browser_ i Omarchy-menyn hittar du [Chromium](https://www.chromium.org/) (den rena byggen med öppen källkod som Chrome är gjord av), Edge, Brave, Brave Origin, Firefox och [Zen](https://zen-browser.app/) (Edge endast på x86-maskiner). Välj en så installerar Omarchy den, ställer in dess policykatalog och tillämpar ditt nuvarande tema på den.

## Gör en till standard

Att installera en webbläsare gör den inte till standard. För att byta går du till _Setup > Defaults > Browser_ och väljer en. Den nuvarande standarden är markerad med en bock, och väljer du en webbläsare du inte har ännu installeras den först.

Från terminalen är det:

```bash
omarchy default browser firefox
```

Kör det utan argument så talar det om vilken som är den nuvarande standarden. Detta sätter XDG-hanteraren, så det är inte bara Omarchys snabbtangenter som följer med — allt som öppnar en länk, från en chattapp till ett terminalkommando, går till webbläsaren du valde.

## Kopiera URL och Ladda ner video

Webbläsarna i Chromium-familjen (Chromium själv, Chrome, Edge, Brave och Brave Origin) levereras med tre Omarchy-tillägg: två som sträcker sig ut ur webbläsaren och in i resten av ditt system, och ett som snyggar till WhatsApp.

**Copy URL** lägger den aktuella flikens adress i ditt urklipp med `Alt + Shift + L`. Det går snabbare än att klicka i adressfältet och kopiera, och eftersom det går via systemets urklipp i stället för webbläsarens får du en Omarchy-avisering som bekräftar det och URL:en är omedelbart tillgänglig i [urklippshistoriken](08-unified-clipboard-history.md) och varje annan app. Det finns också en knapp i verktygsfältet om du föredrar att klicka.

**Download Video** hämtar videon som spelas på sidan du tittar på med `Alt + Shift + D`. Den lämnar URL:en till [yt-dlp](https://github.com/yt-dlp/yt-dlp), så det fungerar på långt mer än YouTube, och nedladdningen hamnar i `~/Videos`. Förloppet visas i samma skärmvisning som volym och ljusstyrka använder, och uppdateras på plats i stället för att stapla aviseringar. Sätt `OMARCHY_YTDLP_DIR` om du hellre vill att filerna ska hamna någon annanstans — se [FAQ](46-faq.md) för var du lägger miljövariabler.

Båda tilläggen pratar med Omarchy via en liten native messaging-värd, som installeras åt dig tillsammans med webbläsaren. Det är den delen som låter en webbsidas video hamna i din hemkatalog och en URL hamna i din urklippshanterare, vilket ett vanligt tillägg inte kan göra på egen hand.

**WhatsApp Slim** får WhatsApp Web att följa ditt systemtema och fäller ihop dess chattlista när fönstret är smalt.

Dessa finns endast för Chromium-familjen. Firefox och Zen får dem inte.

## Firefox och Zen

Firefox och Zen är en annan familj, så de får en annan behandling: Omarchy installerar en policyfil för vettiga standardinställningar och växlar dem till native Wayland-läge, vilket du vill ha för fraktionell skalning och mjuk rullning med styrplattan.

De får inte Chromium-tilläggen ovan, och de temas inte av Omarchy, så de delarna av upplevelsen får du ställa in själv.

## Ta bort en igen

Vilken som helst av dessa webbläsare, Chrome inkluderad, kan tas bort igen under _Remove > Browser_. Länkar går då till Chrome eller Chromium om den andra fortfarande är installerad.
