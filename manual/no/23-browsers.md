# Nettlesere

Omarchy leveres med [Chromium](https://www.chromium.org/) som standard nettleser. Det er den rene åpen kildekode-versjonen, tematisert for å matche resten av systemet ditt, og det er den `Super + Shift + Return` åpner og hver [webapp](25-web-apps.md) kjører inni.

Hvis Chromium ikke er din smak, sitter du ikke fast med den. Under _Installer > Nettleser_ i Omarchy-menyen finner du Chrome, Edge, Brave, Brave Origin, Firefox og [Zen](https://zen-browser.app/). Velg en, så installerer Omarchy den, setter opp policymappen dens og bruker gjeldende tema på den.

## Gjøre en til standard

Å installere en nettleser fremmer den ikke. Når den er på maskinen, gå til _Oppsett > Standarder > Nettleser_ og velg den — menyen lister bare opp nettlesere du faktisk har installert, og merker gjeldende standard med en hake.

Fra terminalen er det:

```bash
omarchy default browser firefox
```

Kjør den uten argument, så forteller den deg gjeldende standard. Dette setter XDG-behandleren, så det er ikke bare Omarchys hurtigtaster som følger med — alt som åpner en lenke, fra en chat-app til en terminalkommando, går til nettleseren du valgte.

## Kopier URL og Last ned video

Chromium-familiens nettlesere (selve Chromium, Chrome, Edge og Brave) kommer med to Omarchy-utvidelser som strekker seg ut av nettleseren og inn i resten av systemet ditt.

**Kopier URL** legger adressen til gjeldende fane på utklippstavlen med `Alt + Shift + L`. Det er raskere enn å klikke i adressefeltet og kopiere, og fordi det går gjennom systemutklippstavlen i stedet for nettleserens, får du en Omarchy-varsling som bekrefter det, og URL-en er umiddelbart tilgjengelig i [utklippstavlehistorikken](08-unified-clipboard-history.md) og alle andre apper. Det finnes også en verktøylinjeknapp, hvis du foretrekker å klikke.

**Last ned video** henter videoen som spilles på siden du ser på med `Alt + Shift + D`. Den overlater URL-en til [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den fungerer på langt mer enn YouTube, og nedlastingen lander i `~/Videos`. Fremdriften vises i samme skjermvisning som volum og lysstyrke bruker, og oppdateres på plass i stedet for å stable opp varslinger. Angi `OMARCHY_YTDLP_DIR` hvis du heller vil at filene skal et annet sted — se [Ofte stilte spørsmål](46-faq.md) for hvor du legger miljøvariabler.

Begge utvidelsene snakker med Omarchy via en liten nativ meldingsvert, som installeres for deg sammen med nettleseren. Det er biten som lar en nettsides video ende opp i hjemmemappen din og en URL ende opp i utklippstavlebehandleren din, noe en vanlig utvidelse ikke kan på egen hånd.

Disse er kun for Chromium-familien. Firefox og Zen får dem ikke.

## Firefox og Zen

Firefox og Zen er en annen familie, så de får en annen behandling: Omarchy installerer en policyfil for fornuftige standarder og setter dem i nativ Wayland-modus, som du vil ha for brøkskalering og jevn styreflate-rulling.

De får ikke Chromium-utvidelsene ovenfor, og de tematiseres ikke av Omarchy, så de delene av opplevelsen må du sette opp selv.

## Fjerne en igjen

Alt du installerte her, kan tas av igjen under _Fjern > Nettleser_. Chromium finnes ikke i den listen — den er en del av basissystemet.
