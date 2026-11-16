# Skrifttyper

Omarchy bruger JetBrainsMono Nerd Font som både terminal- og systemskrifttype som standard.

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

Du kan ændre det via menuen _Udseende > Skrifttype_ i Omarchy-menuen (`Super + Space`). Det indstiller monospace-skrifttypen overalt: terminalen, baren og alt andet, der beder om den.

Du kan installere andre populære programmerskrifttyper via _Installér > Stil > Skrifttype_ i Omarchy-menuen: Cascadia Mono, Meslo LG Mono, Fira Code, Victor Code, Bitstream Vera Mono og Iosevka er alle ét klik væk, i deres Nerd Font-versioner, så glyfferne i baren og terminalen bliver ved med at virke. Når du har installeret en, skal du vælge den under _Udseende > Skrifttype_.

## Kinesisk, japansk og koreansk

Kinesisk, japansk og koreansk deler mange tegn, men tegner nogle af dem forskelligt, så det samme tegn ser rigtigt ud for én læser og fremmed ud for en anden. Når du vælger et af disse sprog under _Opsætning > Sprog_, eller dets indtastningsmetode, indstilles de matchende former. For selv at vælge dem skal du køre `omarchy font cjk jp`, `kr`, `sc`, `tc` (Taiwan) eller `hk` (Hong Kong) i en terminal; `omarchy font cjk default` går tilbage til systemets valg, som er japanske former. Tekst, som en webside eller et dokument markerer med sit eget sprog, og hele skrivebordet, mens det er på et af disse sprog, beholder det pågældende sprogs former.
