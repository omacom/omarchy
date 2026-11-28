# Nettlesere

Omarchy leveres med [Google Chrome](https://www.google.com/chrome/) som standard nettleser. Den er tematisert for å matche resten av systemet ditt, og det er den `Super + Shift + Return` (eller `Super + Shift + B`) åpner, med `Super + Shift + Alt + B` for et privat vindu, og den alle [nettapper](25-web-apps.md) kjører i. Den åpner rett i et nettleservindu: det er ingen velkomstskjerm eller påloggingsforespørsel, bruksstatistikk og krasjrapporter sendes ikke til Google, og forespørslene om annonsepersonvern er slått av. Du kan fortsatt logge på Google-kontoen din fra profilknappen når du vil ha synkronisering.

Hvis Chrome ikke er din smak, er du ikke låst til den. Under _Install > Browser_ i Omarchy-menyen finner du [Chromium](https://www.chromium.org/) (den enkle åpen kildekode-versjonen Chrome er laget fra), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) og [Ladybird](https://ladybird.org/) (Edge kun på x86-maskiner). Velg én, så installerer Omarchy den, setter opp policymappen dens og bruker det gjeldende temaet ditt på den.

## Slik gjør du én til standard

Å installere en nettleser gjør den ikke til standard. For å bytte går du til _Setup > Defaults > Browser_ og velger én. Den gjeldende standarden er markert med en hake, og hvis du velger en nettleser du ikke har ennå, installeres den først.

Fra terminalen er det:

```bash
omarchy default browser firefox
```

Kjør den uten argument, så forteller den deg hva som er gjeldende standard. Dette setter XDG-håndtereren, så det er ikke bare Omarchys hurtigtaster som følger med — alt som åpner en lenke, fra en chat-app til en terminalkommando, går til nettleseren du valgte.

## Copy URL og Download Video

Nettleserne i Chromium-familien (Chromium selv, Chrome, Edge, Brave og Brave Origin) leveres med tre Omarchy-utvidelser: to som strekker seg ut av nettleseren og inn i resten av systemet ditt, og én som rydder opp i WhatsApp.

**Copy URL** legger adressen til den gjeldende fanen på utklippstavlen din med `Alt + Shift + L`. Det er raskere enn å klikke i adressefeltet og kopiere, og fordi det går via systemets utklippstavle i stedet for nettleserens, får du et Omarchy-varsel som bekrefter det, og URL-en er umiddelbart tilgjengelig i [utklippstavlehistorikken](08-unified-clipboard-history.md) og alle andre apper. Det finnes en knapp på verktøylinjen også, hvis du foretrekker å klikke.

**Download Video** henter videoen som spilles av på siden du ser på, med `Alt + Shift + D`. Den leverer URL-en til [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den fungerer på langt mer enn YouTube, og nedlastingen havner i `~/Videos`. Fremdriften vises i samme skjermvisning som volum og lysstyrke bruker, og oppdateres på stedet i stedet for å hope seg opp som varsler. Sett `OMARCHY_YTDLP_DIR` hvis du heller vil at filene skal et annet sted — se [FAQ](46-faq.md) for hvor du skal legge miljøvariabler.

Begge utvidelsene snakker med Omarchy gjennom en liten native messaging-vert, som installeres for deg sammen med nettleseren. Det er den biten som lar en video på en nettside havne i hjemmemappen din og en URL havne i utklippstavlebehandleren din, noe en vanlig utvidelse ikke kan gjøre på egen hånd.

**WhatsApp Slim** får WhatsApp Web til å følge systemtemaet ditt og kollapser chattelisten når vinduet er smalt.

Disse er kun for Chromium-familien. Firefox og Zen får dem ikke.

## Firefox og Zen

Firefox og Zen er en annen familie, så de får annen behandling: Omarchy installerer en policyfil for fornuftige standardvalg og setter dem i innebygd Wayland-modus, som du vil ha for fraksjonell skalering og jevn rulling med styreflaten.

De får ikke Chromium-utvidelsene ovenfor, og de tematiseres ikke av Omarchy, så de delene av opplevelsen må du sette opp selv.

## Ladybird

Ladybird er en nettleser skrevet fra bunnen av, med sin egen motor i stedet for Chromium eller Firefox sin. Den er fortsatt i alfa, så forvent nettsteder som ikke fungerer ennå, og Omarchy installerer den som den kommer: ingen utvidelser, intet tema, ingen policyer. Den har heller ikke noe privat vindu, så `Super + Shift + Alt + B` åpner den med en midlertidig profil som slettes når du lukker den. [Nettapper](25-web-apps.md) fortsetter å kjøre i Chrome eller Chromium.

## Slik fjerner du én igjen

Alle disse nettleserne, Chrome inkludert, kan fjernes igjen under _Remove > Browser_. Lenker går da til Chrome eller Chromium hvis den andre fortsatt er installert.
