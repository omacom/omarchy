# Nettlesere

Omarchy leveres med [Google Chrome](https://www.google.com/chrome/) som standardnettleser. Den er tilpasset temaet til resten av systemet ditt, og det er den som `Super + Shift + Return` (eller `Super + Shift + B`) åpner, med `Super + Shift + Alt + B` for et privat vindu, og den som alle [webapper](25-web-apps.md) kjører i. Den åpner rett i et nettleservindu: det er ingen velkomstskjerm eller påloggingsforespørsel, bruksstatistikk og krasjrapporter sendes ikke til Google, og personvernvarslene for annonser er slått av. Du kan fortsatt logge på Google-kontoen din fra profilknappen når du vil ha synkronisering.

Hvis Chrome ikke faller i smak, er du ikke låst til den. Under _Installer > Nettleser_ i Omarchy-menyen finner du [Chromium](https://www.chromium.org/) (den rene åpen kildekode-versjonen Chrome er laget av), Edge, Brave, Brave Origin, Firefox og [Zen](https://zen-browser.app/) (Edge kun på x86-maskiner). Velg én, så installerer Omarchy den, setter opp policymappen dens og bruker det gjeldende temaet ditt på den.

## Gjøre én til standard

Å installere en nettleser gjør den ikke til standard. For å bytte går du til _Oppsett > Standarder > Nettleser_ og velger én. Den gjeldende standarden er merket med en hake, og hvis du velger en nettleser du ikke har ennå, installeres den først.

Fra terminalen er det:

```bash
omarchy default browser firefox
```

Kjør den uten argumenter, så forteller den deg hva som er gjeldende standard. Dette setter XDG-behandleren, så det er ikke bare hurtigtastene i Omarchy som følger etter — alt som åpner en lenke, fra en chat-app til en terminalkommando, går til nettleseren du valgte.

## Kopier URL og Last ned video

Nettleserne i Chromium-familien (Chromium selv, Chrome, Edge, Brave og Brave Origin) leveres med tre Omarchy-utvidelser: to som strekker seg ut av nettleseren og inn i resten av systemet ditt, og én som rydder opp i WhatsApp.

**Copy URL** legger adressen til den gjeldende fanen på utklippstavlen med `Alt + Shift + L`. Det er raskere enn å klikke seg inn i adressefeltet og kopiere, og fordi det går gjennom systemutklippstavlen i stedet for nettleserens, får du et Omarchy-varsel som bekrefter det, og URL-en er umiddelbart tilgjengelig i [utklippstavlehistorikken](08-unified-clipboard-history.md) og alle andre apper. Det finnes en verktøylinjeknapp også, hvis du foretrekker å klikke.

**Download Video** henter videoen som spilles på siden du ser på, med `Alt + Shift + D`. Den leverer URL-en til [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den fungerer på langt mer enn YouTube, og nedlastingen havner i `~/Videos`. Fremdriften vises i den samme skjermvisningen som volum og lysstyrke bruker, og oppdateres på stedet i stedet for å stable opp varsler. Sett `OMARCHY_YTDLP_DIR` hvis du heller vil at filene skal havne et annet sted — se [FAQ](46-faq.md) for hvor du skal plassere miljøvariabler.

Begge utvidelsene snakker med Omarchy gjennom en liten vert for innebygd meldingsutveksling, som installeres for deg sammen med nettleseren. Det er den biten som lar en video fra en nettside havne i hjemmemappen din og en URL havne i utklippstavlebehandleren din, noe en vanlig utvidelse ikke kan gjøre på egen hånd.

**WhatsApp Slim** får WhatsApp Web til å følge systemtemaet ditt og slår sammen chattelisten når vinduet er smalt.

Disse er kun for Chromium-familien. Firefox og Zen får dem ikke.

## Firefox og Zen

Firefox og Zen tilhører en annen familie, så de får annen behandling: Omarchy installerer en policyfil med fornuftige standarder og setter dem i innebygd Wayland-modus, som du vil ha for brøkskalering og jevn rulling med styreflaten.

De får ikke Chromium-utvidelsene ovenfor, og de tilpasses ikke temaet av Omarchy, så de delene av opplevelsen må du sette opp selv.

## Fjerne én igjen

Alle disse nettleserne, Chrome inkludert, kan fjernes igjen under _Fjern > Nettleser_. Lenker går da til Chrome eller Chromium hvis den andre fortsatt er installert.
