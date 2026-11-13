# Przeglądarki

Omarchy jest dostarczane z [Google Chrome](https://www.google.com/chrome/) jako domyślną przeglądarką. Ma motyw dopasowany do reszty systemu i to właśnie ona otwiera się za pomocą `Super + Shift + Return` oraz to w niej działa każda [aplikacja internetowa](25-web-apps.md). Otwiera się od razu w oknie przeglądarki: nie ma ekranu powitalnego ani prośby o zalogowanie, statystyki użycia i raporty o awariach nie są wysyłane do Google, a monity dotyczące prywatności reklam są wyłączone. Nadal możesz zalogować się na swoje konto Google przyciskiem profilu, kiedy tylko chcesz korzystać z synchronizacji.

Jeśli Chrome nie jest w twoim guście, nie jesteś na nią skazany. W menu Omarchy, w _Install > Browser_, znajdziesz [Chromium](https://www.chromium.org/) (zwykłą, otwartoźródłową wersję, z której powstaje Chrome), Edge, Brave, Brave Origin, Firefox oraz [Zen](https://zen-browser.app/). Wybierz jedną, a Omarchy ją zainstaluje, skonfiguruje jej katalog zasad i zastosuje do niej twój bieżący motyw.

## Ustawianie jednej jako domyślnej

Zainstalowanie przeglądarki nie czyni jej domyślną. Gdy już znajdzie się na komputerze, przejdź do _Setup > Defaults > Browser_ i wybierz ją — menu pokazuje tylko przeglądarki, które faktycznie masz zainstalowane, i oznacza bieżącą domyślną znacznikiem wyboru.

Z terminala zrobisz to tak:

```bash
omarchy default browser firefox
```

Uruchom to polecenie bez argumentu, a powie ci, która przeglądarka jest bieżącą domyślną. Ustawia to procedurę obsługi XDG, więc nie tylko skróty klawiszowe Omarchy podążają za tym wyborem — wszystko, co otwiera łącze, od aplikacji do czatu po polecenie w terminalu, trafia do wybranej przez ciebie przeglądarki.

## Copy URL i Download Video

Przeglądarki z rodziny Chromium (sam Chromium, Chrome, Edge i Brave) są dostarczane z dwoma rozszerzeniami Omarchy, które wychodzą poza przeglądarkę i sięgają do reszty systemu.

**Copy URL** umieszcza adres bieżącej karty w schowku za pomocą `Alt + Shift + L`. Jest to szybsze niż klikanie w pasek adresu i kopiowanie, a ponieważ odbywa się przez schowek systemowy, a nie przeglądarkowy, otrzymujesz potwierdzenie w formie powiadomienia Omarchy, a adres URL jest od razu dostępny w [historii schowka](08-unified-clipboard-history.md) i w każdej innej aplikacji. Jest też przycisk na pasku narzędzi, jeśli wolisz klikać.

**Download Video** pobiera wideo odtwarzane na stronie, którą oglądasz, za pomocą `Alt + Shift + D`. Przekazuje adres URL do [yt-dlp](https://github.com/yt-dlp/yt-dlp), więc działa na znacznie większej liczbie serwisów niż tylko YouTube, a pobrany plik ląduje w `~/Videos`. Postęp pokazuje się w tym samym menu ekranowym, którego używają głośność i jasność, aktualizując się w miejscu, zamiast piętrzyć powiadomienia. Ustaw `OMARCHY_YTDLP_DIR`, jeśli wolisz, żeby pliki trafiały gdzie indziej — zobacz [FAQ](46-faq.md), aby dowiedzieć się, gdzie umieszczać zmienne środowiskowe.

Oba rozszerzenia komunikują się z Omarchy za pośrednictwem małego natywnego hosta komunikatów, który jest instalowany razem z przeglądarką. To właśnie ten element sprawia, że wideo ze strony internetowej może wylądować w twoim katalogu domowym, a adres URL w twoim menedżerze schowka, czego zwykłe rozszerzenie samo w sobie nie potrafi zrobić.

Są dostępne tylko dla rodziny Chromium. Firefox i Zen ich nie dostają.

## Firefox i Zen

Firefox i Zen to inna rodzina, więc są traktowane inaczej: Omarchy instaluje plik zasad z rozsądnymi ustawieniami domyślnymi i przełącza je w natywny tryb Wayland, którego potrzebujesz do skalowania ułamkowego i płynnego przewijania na gładziku.

Nie dostają powyższych rozszerzeń Chromium i Omarchy nie stosuje do nich motywu, więc te części doświadczenia musisz skonfigurować samodzielnie.

## Usuwanie przeglądarki

Każdą z tych przeglądarek, w tym Chrome, można ponownie usunąć w _Remove > Browser_. Łącza trafiają wtedy do Chrome lub Chromium, jeśli ta druga przeglądarka jest nadal zainstalowana.
