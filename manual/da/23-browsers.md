# Browsere

Omarchy leveres med [Google Chrome](https://www.google.com/chrome/) som standardbrowser. Den er tematiseret, så den matcher resten af dit system, og det er den, `Super + Shift + Return` (eller `Super + Shift + B`) åbner, med `Super + Shift + Alt + B` til et privat vindue, og den, enhver [webapp](25-web-apps.md) kører i. Den åbner direkte i et browservindue: der er ingen velkomstskærm eller loginprompt, brugsstatistik og nedbrudsrapporter bliver ikke sendt til Google, og prompterne om annonceprivatliv er slået fra. Du kan stadig logge ind på din Google-konto fra profilknappen, når som helst du vil have synkronisering.

Hvis Chrome ikke er din smag, er du ikke låst fast med den. Under _Install > Browser_ i Omarchy-menuen finder du [Chromium](https://www.chromium.org/) (den helt almindelige open source-version, som Chrome er bygget ud fra), Edge, Brave, Brave Origin, Firefox og [Zen](https://zen-browser.app/) (Edge kun på x86-maskiner). Vælg en, og Omarchy installerer den, opsætter dens politikmappe og anvender dit nuværende tema på den.

## Sådan gør du en til standardbrowser

At installere en browser gør den ikke til standard. For at skifte skal du gå til _Setup > Defaults > Browser_ og vælge en. Den nuværende standard er markeret med et flueben, og hvis du vælger en browser, du ikke har endnu, bliver den installeret først.

Fra terminalen er det:

```bash
omarchy default browser firefox
```

Kør den uden argument, og den fortæller dig den nuværende standard. Det sætter XDG-handleren, så det ikke kun er Omarchys genvejstaster, der følger med — alt, hvad der åbner et link, fra en chatapp til en terminalkommando, går til den browser, du har valgt.

## Copy URL og Download Video

Browserne i Chromium-familien (Chromium selv, Chrome, Edge, Brave og Brave Origin) leveres med tre Omarchy-udvidelser: to, der rækker ud af browseren og ind i resten af dit system, og en, der rydder op i WhatsApp.

**Copy URL** lægger den aktuelle fanes adresse på din udklipsholder med `Alt + Shift + L`. Det er hurtigere end at klikke ind i adresselinjen og kopiere, og fordi det går gennem systemets udklipsholder i stedet for browserens, får du en Omarchy-notifikation, der bekræfter det, og URL'en er med det samme tilgængelig i [historikken for udklipsholderen](08-unified-clipboard-history.md) og enhver anden app. Der er også en knap på værktøjslinjen, hvis du foretrækker at klikke.

**Download Video** henter den video, der afspilles på den side, du kigger på, med `Alt + Shift + D`. Den giver URL'en videre til [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den virker på langt mere end YouTube, og downloadet lander i `~/Videos`. Fremskridtet vises i den samme skærmvisning, som lydstyrke og lysstyrke bruger, og opdateres på stedet i stedet for at stable notifikationer op. Sæt `OMARCHY_YTDLP_DIR`, hvis du hellere vil have, at filerne havner et andet sted — se [FAQ](46-faq.md) for, hvor du skal placere miljøvariabler.

Begge udvidelser taler med Omarchy gennem en lille native messaging host, som bliver installeret for dig sammen med browseren. Det er den del, der lader en websides video ende i din hjemmemappe og en URL ende i din udklipsholderstyring, hvilket en normal udvidelse ikke kan gøre på egen hånd.

**WhatsApp Slim** får WhatsApp Web til at følge dit systemtema og folder dens chatliste sammen, når vinduet er smalt.

Disse er kun til Chromium-familien. Firefox og Zen får dem ikke.

## Firefox og Zen

Firefox og Zen er en anden familie, så de får en anden behandling: Omarchy installerer en politikfil med fornuftige standarder og skifter dem til native Wayland-tilstand, hvilket du vil have til fraktioneret skalering og jævn rulning med pegepladen.

De får ikke Chromium-udvidelserne ovenfor, og de bliver ikke tematiseret af Omarchy, så de dele af oplevelsen skal du selv sætte op.

## Sådan fjerner du en igen

Enhver af disse browsere, Chrome inklusive, kan fjernes igen under _Remove > Browser_. Links går derefter til Chrome eller Chromium, hvis den anden stadig er installeret.
