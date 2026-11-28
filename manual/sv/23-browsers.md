# Webbläsare

Omarchy levereras med [Google Chrome](https://www.google.com/chrome/) som standardwebbläsare. Den är temaanpassad för att matcha resten av ditt system, och det är den som `Super + Shift + Return` (eller `Super + Shift + B`) öppnar, med `Super + Shift + Alt + B` för ett privat fönster, och det som varje [webbapp](25-web-apps.md) körs i. Den öppnar direkt till ett webbläsarfönster: det finns ingen välkomstskärm eller uppmaning att logga in, användningsstatistik och kraschrapporter skickas inte till Google, och integritetsuppmaningarna för annonser är avstängda. Du kan fortfarande logga in på ditt Google-konto från profilknappen när du vill ha synkronisering.

Om Chrome inte faller dig i smaken sitter du inte fast med den. Under _Install > Browser_ i Omarchy-menyn hittar du [Chromium](https://www.chromium.org/) (den rena versionen med öppen källkod som Chrome är gjord av), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) och [Ladybird](https://ladybird.org/) (Edge endast på x86-maskiner). Välj en så installerar Omarchy den, sätter upp dess policykatalog och applicerar ditt nuvarande tema på den.

## Att göra en till standard

Att installera en webbläsare gör den inte till standard. För att byta går du till _Setup > Defaults > Browser_ och väljer en. Den nuvarande standarden är markerad med en bock, och väljer du en webbläsare du inte har än installeras den först.

Från terminalen är det:

```bash
omarchy default browser firefox
```

Kör den utan argument så talar den om för dig vilken som är standard just nu. Det här sätter XDG-hanteraren, så det är inte bara Omarchys snabbtangenter som följer med — allt som öppnar en länk, från en chattapp till ett terminalkommando, går till webbläsaren du valde.

## Copy URL och Download Video

Webbläsarna i Chromium-familjen (Chromium själv, Chrome, Edge, Brave och Brave Origin) kommer med tre Omarchy-tillägg: två som sträcker sig ut ur webbläsaren och in i resten av ditt system, och ett som städar upp WhatsApp.

**Copy URL** lägger den aktuella flikens adress i ditt urklipp med `Alt + Shift + L`. Det går snabbare än att klicka i adressfältet och kopiera, och eftersom det går via systemets urklipp i stället för webbläsarens får du en Omarchy-avisering som bekräftar det och URL:en är omedelbart tillgänglig i [urklippshistoriken](08-unified-clipboard-history.md) och varje annan app. Det finns en knapp i verktygsfältet också, om du föredrar att klicka.

**Download Video** hämtar videon som spelas på sidan du tittar på med `Alt + Shift + D`. Den lämnar över URL:en till [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den fungerar på betydligt mer än YouTube, och nedladdningen hamnar i `~/Videos`. Förloppet visas i samma skärmvisning som volym och ljusstyrka använder, och uppdateras på plats i stället för att stapla aviseringar på hög. Sätt `OMARCHY_YTDLP_DIR` om du hellre vill att filerna hamnar någon annanstans — se [FAQ](46-faq.md) för var du ska lägga miljövariabler.

Båda tilläggen pratar med Omarchy via en liten native messaging-värd, som installeras åt dig tillsammans med webbläsaren. Det är den biten som låter en webbsidas video hamna i din hemkatalog och en URL hamna i din urklippshanterare, vilket ett vanligt tillägg inte kan göra på egen hand.

**WhatsApp Slim** får WhatsApp Web att följa ditt systemtema och fäller ihop dess chattlista när fönstret är smalt.

De här finns bara för Chromium-familjen. Firefox och Zen får dem inte.

## Firefox och Zen

Firefox och Zen är en annan familj, så de får annan behandling: Omarchy installerar en policyfil för vettiga standardinställningar och växlar dem till inbyggt Wayland-läge, vilket du vill ha för fraktionell skalning och mjuk skrollning med styrplattan.

De får inte Chromium-tilläggen ovan, och de temas inte av Omarchy, så de delarna av upplevelsen får du sätta upp själv.

## Ladybird

Ladybird är en webbläsare skriven från grunden, med sin egen motor i stället för Chromiums eller Firefox. Den är fortfarande i alfa, så räkna med webbplatser som inte fungerar än, och Omarchy installerar den som den är: inga tillägg, inget tema, inga policyer. Den har inget privat fönster heller, så `Super + Shift + Alt + B` öppnar den med en tillfällig profil som raderas när du stänger den. [Webbappar](25-web-apps.md) fortsätter att köra i Chrome eller Chromium.

## Att ta bort en igen

Alla de här webbläsarna, Chrome inräknad, kan tas bort igen under _Remove > Browser_. Länkar går då till Chrome eller Chromium om den andra fortfarande är installerad.
