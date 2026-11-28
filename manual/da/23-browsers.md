# Browsere

Omarchy leveres med [Google Chrome](https://www.google.com/chrome/) som standardbrowser. Den er tematiseret, så den matcher resten af dit system, og det er den, som `Super + Shift + Return` (eller `Super + Shift + B`) åbner, med `Super + Shift + Alt + B` til et privat vindue, og den, som alle [webapps](25-web-apps.md) kører i. Den åbner direkte til et browservindue: Der er ingen velkomstskærm eller loginprompt, brugsstatistik og crashrapporter sendes ikke til Google, og annoncerelaterede privatlivsprompter er slået fra. Du kan stadig logge ind på din Google-konto fra profilknappen, når som helst du ønsker synkronisering.

Hvis Chrome ikke er din smag, er du ikke låst til den. Under _Install > Browser_ i Omarchy-menuen finder du [Chromium](https://www.chromium.org/) (den helt almindelige open source-build, som Chrome er lavet ud fra), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) og [Ladybird](https://ladybird.org/) (Edge kun på x86-maskiner). Vælg en, og Omarchy installerer den, opsætter dens policymappe og anvender dit nuværende tema på den.

## Gør en til standard

At installere en browser gør den ikke til standard. For at skifte skal du gå til _Setup > Defaults > Browser_ og vælge en. Den nuværende standard er markeret med et flueben, og hvis du vælger en browser, du ikke har endnu, installeres den først.

Fra terminalen er det:

```bash
omarchy default browser firefox
```

Kør den uden argument, og den fortæller dig den nuværende standard. Det sætter XDG-handleren, så det er ikke kun Omarchys genvejstaster, der følger med — alt, hvad der åbner et link, fra en chatapp til en terminalkommando, går til den browser, du har valgt.

## Copy URL og Download Video

Browserne i Chromium-familien (Chromium selv, Chrome, Edge, Brave og Brave Origin) leveres med tre Omarchy-udvidelser: to, der rækker ud af browseren og ind i resten af dit system, og en, der rydder op i WhatsApp.

**Copy URL** lægger den aktuelle fanes adresse på dit udklipsholder med `Alt + Shift + L`. Det er hurtigere end at klikke ind i adresselinjen og kopiere, og fordi det går gennem systemets udklipsholder i stedet for browserens, får du en Omarchy-notifikation, der bekræfter det, og URL'en er med det samme tilgængelig i [udklipsholderhistorikken](08-unified-clipboard-history.md) og alle andre apps. Der er også en knap på værktøjslinjen, hvis du foretrækker at klikke.

**Download Video** henter den video, der afspilles på den side, du kigger på, med `Alt + Shift + D`. Den giver URL'en videre til [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den virker på langt mere end YouTube, og downloadet lander i `~/Videos`. Fremskridtet vises i den samme skærmvisning, som lydstyrke og lysstyrke bruger, og opdateres på stedet i stedet for at stable notifikationer op. Sæt `OMARCHY_YTDLP_DIR`, hvis du hellere vil have, at filerne havner et andet sted — se [FAQ](46-faq.md) for, hvor du skal placere miljøvariabler.

Begge udvidelser taler med Omarchy gennem en lille native messaging host, som installeres for dig sammen med browseren. Det er den del, der lader en websides video ende i din hjemmemappe og en URL ende i din udklipsholdermanager, hvilket en almindelig udvidelse ikke kan gøre på egen hånd.

**WhatsApp Slim** får WhatsApp Web til at følge dit systemtema og kollapser dens chatliste, når vinduet er smalt.

De findes kun til Chromium-familien. Firefox og Zen får dem ikke.

## Firefox og Zen

Firefox og Zen er en anden familie, så de får en anden behandling: Omarchy installerer en policies-fil med fornuftige standarder og skifter dem til native Wayland-tilstand, hvilket du ønsker for fraktionel skalering og jævn trackpad-scrollning.

De får ikke Chromium-udvidelserne ovenfor, og de tematiseres ikke af Omarchy, så de dele af oplevelsen skal du selv sætte op.

## Ladybird

Ladybird er en browser skrevet fra bunden, med sin egen engine frem for Chromiums eller Firefox'. Den er stadig i alpha, så forvent sites, der ikke virker endnu, og Omarchy installerer den, som den kommer: ingen udvidelser, intet tema, ingen policies. Den har heller ikke noget privat vindue, så `Super + Shift + Alt + B` åbner den med en midlertidig profil, der slettes, når du lukker den. [Webapps](25-web-apps.md) kører fortsat i Chrome eller Chromium.

## Fjern en igen

Enhver af disse browsere, Chrome inkluderet, kan fjernes igen under _Remove > Browser_. Links går så til Chrome eller Chromium, hvis den anden stadig er installeret.
