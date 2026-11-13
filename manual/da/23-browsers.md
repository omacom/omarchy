# Browsere

Omarchy leveres med [Google Chrome](https://www.google.com/chrome/) som standardbrowser. Den er tematiseret til at matche resten af dit system, og det er den, som `Super + Shift + Return` åbner, og som hver [webapp](25-web-apps.md) kører i. Den åbner direkte til et browservindue: der er ingen velkomstskærm eller opfordring til at logge ind, brugsstatistik og fejlrapporter bliver ikke sendt til Google, og prompts om annonceprivatliv er slået fra. Du kan stadig logge ind på din Google-konto fra profilknappen, når som helst du vil have synkronisering.

Hvis Chrome ikke er din smag, er du ikke låst til den. Under _Install > Browser_ i Omarchy-menuen finder du [Chromium](https://www.chromium.org/) (den rene open source-udgave, som Chrome er bygget af), Edge, Brave, Brave Origin, Firefox og [Zen](https://zen-browser.app/). Vælg en, så installerer Omarchy den, opsætter dens policymappe og anvender dit nuværende tema på den.

## At gøre en til standard

At installere en browser fremmer den ikke. Når den er på maskinen, skal du gå til _Setup > Defaults > Browser_ og vælge den — menuen viser kun browsere, du faktisk har installeret, og markerer den nuværende standard med et flueben.

Fra terminalen er det:

```bash
omarchy default browser firefox
```

Kør den uden argument, så fortæller den dig, hvad den nuværende standard er. Det indstiller XDG-handleren, så det er ikke kun Omarchys genvejstaster, der følger med — alt, hvad der åbner et link, fra en chatapp til en terminalkommando, går til den browser, du valgte.

## Copy URL og Download Video

Browserne i Chromium-familien (selve Chromium, Chrome, Edge og Brave) leveres med to Omarchy-udvidelser, der rækker ud af browseren og ind i resten af dit system.

**Copy URL** lægger den nuværende fanes adresse på din udklipsholder med `Alt + Shift + L`. Det er hurtigere end at klikke ind i adresselinjen og kopiere, og fordi det går gennem systemets udklipsholder frem for browserens, får du en Omarchy-meddelelse, der bekræfter det, og URL'en er med det samme tilgængelig i [historikken for udklipsholderen](08-unified-clipboard-history.md) og alle andre apps. Der er også en knap på værktøjslinjen, hvis du foretrækker at klikke.

**Download Video** henter den video, der afspilles på den side, du kigger på, med `Alt + Shift + D`. Den giver URL'en til [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den virker på langt mere end YouTube, og downloadet lander i `~/Videos`. Fremskridtene vises i den samme visning på skærmen, som lydstyrke og lysstyrke bruger, og opdateres på stedet i stedet for at hobe meddelelser op. Sæt `OMARCHY_YTDLP_DIR`, hvis du hellere vil have, at filerne havner et andet sted — se [FAQ](46-faq.md) for, hvor du skal placere miljøvariabler.

Begge udvidelser taler med Omarchy gennem en lille native messaging host, som bliver installeret for dig sammen med browseren. Det er den del, der lader en websides video ende i din hjemmemappe og en URL ende i din håndtering af udklipsholderen, hvilket en normal udvidelse ikke kan på egen hånd.

De er kun til Chromium-familien. Firefox og Zen får dem ikke.

## Firefox og Zen

Firefox og Zen er en anden familie, så de får en anden behandling: Omarchy installerer en policies-fil til fornuftige standarder og skifter dem til indbygget Wayland-tilstand, hvilket du vil have til fraktioneret skalering og jævn rulning med pegeplade.

De får ikke Chromium-udvidelserne ovenfor, og de bliver ikke tematiseret af Omarchy, så de dele af oplevelsen skal du selv sætte op.

## At fjerne en igen

Enhver af disse browsere, Chrome inklusive, kan fjernes igen under _Remove > Browser_. Links går derefter til Chrome eller Chromium, hvis den anden stadig er installeret.
