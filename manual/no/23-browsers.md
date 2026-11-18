# Nettlesere

Omarchy leveres med [Google Chrome](https://www.google.com/chrome/) som standard nettleser. Den har et tema som matcher resten av systemet ditt, og det er den `Super + Shift + Return` åpner og den alle [nettapper](25-web-apps.md) kjører inni. Den åpner rett i et nettleservindu: det er ingen velkomstskjerm eller påloggingsforespørsel, bruksstatistikk og krasjrapporter sendes ikke til Google, og meldingene om annonsepersonvern er slått av. Du kan fortsatt logge på Google-kontoen din fra profilknappen når som helst du vil ha synkronisering.

Hvis Chrome ikke er i din smak, er du ikke låst til den. Under _Install > Browser_ i Omarchy-menyen finner du [Chromium](https://www.chromium.org/) (den rene byggeversjonen med åpen kildekode som Chrome er laget av), Edge, Brave, Brave Origin, Firefox og [Zen](https://zen-browser.app/). Velg en, så installerer Omarchy den, setter opp policymappen dens og bruker det nåværende temaet ditt på den.

## Slik gjør du en til standard

Å installere en nettleser gjør den ikke til standard. Når den er på maskinen, går du til _Setup > Defaults > Browser_ og velger den — menyen lister bare opp nettlesere du faktisk har installert, og markerer den nåværende standarden med en hake.

Fra terminalen er det:

```bash
omarchy default browser firefox
```

Kjør den uten argument, så forteller den deg hva som er nåværende standard. Dette setter XDG-håndtereren, så det er ikke bare hurtigtastene i Omarchy som følger etter — alt som åpner en lenke, fra en chatapp til en terminalkommando, går til nettleseren du valgte.

## Copy URL og Download Video

Nettleserne i Chromium-familien (Chromium selv, Chrome, Edge og Brave) leveres med to Omarchy-utvidelser som strekker seg ut av nettleseren og inn i resten av systemet ditt.

**Copy URL** legger adressen til den nåværende fanen på utklippstavlen din med `Alt + Shift + L`. Det er raskere enn å klikke seg inn i adressefeltet og kopiere, og fordi det går gjennom systemets utklippstavle i stedet for nettleserens, får du et varsel fra Omarchy som bekrefter det, og URL-en er umiddelbart tilgjengelig i [utklippstavlehistorikken](08-unified-clipboard-history.md) og alle andre apper. Det finnes en knapp på verktøylinjen også, hvis du foretrekker å klikke.

**Download Video** henter videoen som spilles av på siden du ser på, med `Alt + Shift + D`. Den gir URL-en videre til [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den fungerer på langt mer enn YouTube, og nedlastingen havner i `~/Videos`. Fremdriften vises i den samme skjermvisningen som volum og lysstyrke bruker, og oppdateres på stedet i stedet for å stable opp varsler. Sett `OMARCHY_YTDLP_DIR` hvis du heller vil at filene skal et annet sted — se [FAQ](46-faq.md) for hvor du legger miljøvariabler.

Begge utvidelsene snakker med Omarchy gjennom en liten vert for native messaging, som installeres for deg sammen med nettleseren. Det er den biten som lar en video fra en nettside ende opp i hjemmemappen din og en URL ende opp i utklippstavlebehandleren din, noe en vanlig utvidelse ikke kan gjøre på egen hånd.

Disse er kun for Chromium-familien. Firefox og Zen får dem ikke.

## Firefox og Zen

Firefox og Zen er en annen familie, så de får en annen behandling: Omarchy installerer en policyfil for fornuftige standardinnstillinger og slår dem over i innebygd Wayland-modus, som du vil ha for brøkskalering og jevn rulling med styreflaten.

De får ikke Chromium-utvidelsene ovenfor, og de får ikke tema fra Omarchy, så de delene av opplevelsen må du sette opp selv.

## Fjerne en igjen

Alle disse nettleserne, Chrome inkludert, kan fjernes igjen under _Remove > Browser_. Lenker går da til Chrome eller Chromium hvis den andre fortsatt er installert.
