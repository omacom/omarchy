# Skrifttyper

Omarchy bruger som standard JetBrainsMono Nerd Font som både terminal- og systemskrifttype.

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

Du kan ændre det via menuen _Udseende > Skrifttype_ i Omarchy-menuen (`Super + Space`). Det indstiller monospace-skrifttypen overalt: i terminalen, i bjælken og i alt andet, der beder om den.

Du kan installere andre populære programmeringsskrifttyper via _Installer > Stil > Skrifttype_ i Omarchy-menuen: Cascadia Mono, Meslo LG Mono, Fira Code, Victor Code, Bitstream Vera Mono og Iosevka er alle kun et klik væk, i deres Nerd Font-versioner, så glyfferne i bjælken og terminalen bliver ved med at fungere. Når du installerer en af dem, skifter hele systemet også til den, og du kan til enhver tid skifte tilbage under _Udseende > Skrifttype_.

## Kinesisk, japansk og koreansk

Kinesisk, japansk og koreansk deler mange tegn, men tegner nogle af dem forskelligt, så det samme tegn ser rigtigt ud for den ene læser og fremmed ud for en anden. Når du vælger et af disse sprog under _Opsætning > Region > Sprog_, eller dets inputmetode, indstilles de matchende former. Hvis du vil vælge dem selv, skal du køre `omarchy font cjk jp`, `kr`, `sc`, `tc` (Taiwan) eller `hk` (Hong Kong) i en terminal; `omarchy font cjk default` går tilbage til systemets valg, som er japanske former. Tekst, som en webside eller et dokument markerer med sit eget sprog, og hele skrivebordet, mens det er på et af disse sprog, beholder det pågældende sprogs former.
