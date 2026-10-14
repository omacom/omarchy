# Przeglądarki

Omarchy dostarcza [Chromium](https://www.chromium.org/) jako domyślną przeglądarkę. Jest to zwykła kompilacja open source, z motywem dopasowanym do reszty systemu, i to ona otwiera się za pomocą `Super + Shift + Return` oraz to w niej działa każda [aplikacja webowa](25-web-apps.md).

Jeśli Chromium nie jest w twoim guście, nie jesteś na nie skazany. W menu Omarchy w _Instaluj > Browser_ znajdziesz Chrome, Edge, Brave, Brave Origin, Firefox i [Zen](https://zen-browser.app/). Wybierz jedną, a Omarchy zainstaluje ją, skonfiguruje jej katalog polityk i zastosuje do niej twój bieżący motyw.

## Ustawianie jednej jako domyślnej

Zainstalowanie przeglądarki nie awansuje jej. Gdy już jest na komputerze, przejdź do _Ustawienia > Defaults > Browser_ i wybierz ją — menu wymienia tylko przeglądarki, które rzeczywiście masz zainstalowane, i oznacza bieżącą domyślną znacznikiem wyboru.

Z terminala jest to:

```bash
omarchy default browser firefox
```

Uruchom to bez argumentu, a powie ci bieżącą domyślną. Ustawia to handler XDG, więc nie tylko skróty Omarchy podążają za tym — wszystko, co otwiera link, od aplikacji czatu po polecenie terminala, trafia do wybranej przez ciebie przeglądarki.

## Copy URL i Download Video

Przeglądarki z rodziny Chromium (sam Chromium, Chrome, Edge i Brave) zawierają dwa rozszerzenia Omarchy, które wychodzą poza przeglądarkę do reszty systemu.

**Copy URL** umieszcza adres bieżącej karty w schowku za pomocą `Alt + Shift + L`. To szybciej niż klikanie w pasek adresu i kopiowanie, a ponieważ przechodzi przez schowek systemowy, a nie przeglądarki, otrzymujesz powiadomienie Omarchy potwierdzające to, a URL jest natychmiast dostępny w [historii schowka](08-unified-clipboard-history.md) i każdej innej aplikacji. Jest również przycisk na pasku narzędzi, jeśli wolisz klikać.

**Download Video** pobiera wideo odtwarzane na stronie, na którą patrzysz, za pomocą `Alt + Shift + D`. Przekazuje URL do [yt-dlp](https://github.com/yt-dlp/yt-dlp), więc działa na znacznie więcej niż YouTube, a pobieranie ląduje w `~/Videos`. Postęp pojawia się w tym samym ekranowym wyświetlaczu, którego używają głośność i jasność, aktualizując się w miejscu, a nie gromadząc powiadomienia. Ustaw `OMARCHY_YTDLP_DIR`, jeśli wolisz, aby pliki trafiały gdzie indziej — zobacz [FAQ](46-faq.md), aby dowiedzieć się, gdzie umieszczać zmienne środowiskowe.

Oba rozszerzenia komunikują się z Omarchy poprzez małego natywnego hosta wiadomości, który jest instalowany dla ciebie wraz z przeglądarką. To element, który pozwala wideo ze strony internetowej trafić do twojego katalogu domowego, a URL-owi trafić do menedżera schowka, czego normalne rozszerzenie nie potrafi samo.

Są one tylko dla rodziny Chromium. Firefox i Zen ich nie otrzymują.

## Firefox i Zen

Firefox i Zen należą do innej rodziny, więc otrzymują inne traktowanie: Omarchy instaluje dla nich plik polityk z rozsądnymi ustawieniami domyślnymi i przełącza je w natywny tryb Wayland, którego chcesz do skalowania ułamkowego i płynnego przewijania gładzikiem.

Nie otrzymują powyższych rozszerzeń Chromium i nie są tematyzowane przez Omarchy, więc te części doświadczenia należą do ciebie do skonfigurowania.

## Ponowne usuwanie jednej

Wszystko, co tu zainstalowałeś, można ponownie usunąć w _Usuń > Browser_. Chromium nie ma na tej liście — jest częścią systemu podstawowego.
