# Browsere

Omarchy leveres med [Chromium](https://www.chromium.org/) som standardbrowser. Det er den almindelige open source-build, tematiseret til at matche resten af dit system, og det er den, `Super + Shift + Return` åbner, og den, som enhver [webapp](25-web-apps.md) kører inde i.

Hvis Chromium ikke er din smag, sidder du ikke fast med den. Under _Installer > Browser_ i Omarchy-menuen finder du Chrome, Edge, Brave, Brave Origin, Firefox og [Zen](https://zen-browser.app/). Vælg en, og Omarchy installerer den, opsætter dens politikmappe og anvender dit aktuelle tema på den.

## Gøre en til standard

At installere en browser forfremmer den ikke. Når den er på maskinen, skal du gå til _Opsætning > Defaults > Browser_ og vælge den — menuen viser kun browsere, du faktisk har installeret, og markerer den aktuelle standard med et flueben.

Fra terminalen er det:

```bash
omarchy default browser firefox
```

Kør den uden argument, og den fortæller dig den aktuelle standard. Dette sætter XDG-handleren, så det er ikke kun Omarchys genvejstaster, der følger med — alt, der åbner et link, fra en chatapp til en terminalkommando, går til den browser, du valgte.

## Kopiér URL og Download Video

Chromium-familiens browsere (Chromium selv, Chrome, Edge og Brave) leveres med to Omarchy-udvidelser, der rækker ud af browseren og ind i resten af dit system.

**Copy URL** sætter den aktuelle fanes adresse på din udklipsholder med `Alt + Shift + L`. Det er hurtigere end at klikke ind i adresselinjen og kopiere, og fordi det går gennem systemets udklipsholder frem for browserens, får du en Omarchy-notifikation, der bekræfter det, og URL'en er øjeblikkeligt tilgængelig i [udklipshistorik](08-unified-clipboard-history.md) og enhver anden app. Der er også en værktøjslinjeknap, hvis du foretrækker at klikke.

**Download Video** henter videoen, der afspilles på den side, du ser på, med `Alt + Shift + D`. Den overlader URL'en til [yt-dlp](https://github.com/yt-dlp/yt-dlp), så den virker på langt mere end YouTube, og downloadet lander i `~/Videos`. Fremskridt vises i det samme skærmdisplay, som lydstyrke og lysstyrke bruger, og opdateres på stedet frem for at stable notifikationer op. Sæt `OMARCHY_YTDLP_DIR`, hvis du hellere vil have filerne et andet sted hen — se [FAQ](46-faq.md) for, hvor miljøvariabler skal placeres.

Begge udvidelser taler med Omarchy gennem en lille native messaging host, som installeres for dig sammen med browseren. Det er den del, der lader en websides video ende i din hjemmemappe og en URL ende i din udklipsholderhåndtering, hvilket en normal udvidelse ikke kan gøre på egen hånd.

Disse er kun til Chromium-familien. Firefox og Zen får dem ikke.

## Firefox og Zen

Firefox og Zen er en anden familie, så de får en anden behandling: Omarchy installerer en politikfil til fornuftige standarder og skifter dem til native Wayland-tilstand, som du ønsker til brøkskalering og jævn pegefelt-rulning.

De får ikke Chromium-udvidelserne ovenfor, og de tematiseres ikke af Omarchy, så de dele af oplevelsen er dine at sætte op.

## Fjerne en igen

Alt, hvad du har installeret her, kan tages af igen under _Fjern > Browser_. Chromium er ikke på den liste — den er en del af basissystemet.
