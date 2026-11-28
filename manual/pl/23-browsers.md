# Przeglądarki

Omarchy jest dostarczane z [Google Chrome](https://www.google.com/chrome/) jako domyślną przeglądarką. Ma motyw dopasowany do reszty systemu i to właśnie ją otwiera `Super + Shift + Return` (lub `Super + Shift + B`), przy czym `Super + Shift + Alt + B` otwiera okno prywatne, a wewnątrz niej działa każda [aplikacja internetowa](25-web-apps.md). Otwiera się bezpośrednio w oknie przeglądarki: nie ma ekranu powitalnego ani monitu o zalogowanie, statystyki użytkowania i raporty o awariach nie są wysyłane do Google, a monity dotyczące prywatności reklam są wyłączone. Nadal możesz zalogować się na swoje konto Google za pomocą przycisku profilu, kiedy tylko zechcesz korzystać z synchronizacji.

Jeśli Chrome nie jest w twoim guście, nie jesteś na niego skazany. W menu Omarchy, w sekcji _Install > Browser_, znajdziesz [Chromium](https://www.chromium.org/) (zwykłą, open-source'ową wersję, z której powstaje Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) oraz [Ladybird](https://ladybird.org/) (Edge tylko na komputerach x86). Wybierz jedną, a Omarchy ją zainstaluje, skonfiguruje jej katalog zasad i zastosuje do niej twój aktualny motyw.

## Ustawianie jednej jako domyślnej

Zainstalowanie przeglądarki nie czyni jej domyślną. Aby ją zmienić, przejdź do _Setup > Defaults > Browser_ i wybierz jedną. Aktualnie domyślna jest oznaczona znacznikiem wyboru, a wybranie przeglądarki, której jeszcze nie masz, najpierw ją zainstaluje.

Z terminala wygląda to tak:

```bash
omarchy default browser firefox
```

Uruchom to polecenie bez argumentu, a poda ci aktualną przeglądarkę domyślną. Ustawia to program obsługi XDG, więc nie tylko skróty klawiszowe Omarchy się do tego dostosowują — wszystko, co otwiera link, od aplikacji do czatu po polecenie w terminalu, trafia do wybranej przez ciebie przeglądarki.

## Copy URL i Download Video

Przeglądarki z rodziny Chromium (samo Chromium, Chrome, Edge, Brave i Brave Origin) są dostarczane z trzema rozszerzeniami Omarchy: dwoma, które sięgają poza przeglądarkę i do reszty twojego systemu, oraz jednym, które porządkuje WhatsApp.

**Copy URL** umieszcza adres bieżącej karty w schowku za pomocą `Alt + Shift + L`. To szybsze niż klikanie w pasek adresu i kopiowanie, a ponieważ odbywa się to przez schowek systemowy, a nie schowek przeglądarki, otrzymasz powiadomienie Omarchy z potwierdzeniem, a adres URL będzie od razu dostępny w [historii schowka](08-unified-clipboard-history.md) i w każdej innej aplikacji. Jest też przycisk na pasku narzędzi, jeśli wolisz klikać.

**Download Video** pobiera wideo odtwarzane na stronie, którą oglądasz, za pomocą `Alt + Shift + D`. Przekazuje adres URL do [yt-dlp](https://github.com/yt-dlp/yt-dlp), więc działa na znacznie większej liczbie serwisów niż tylko YouTube, a pobrany plik trafia do `~/Videos`. Postęp pokazuje się na tym samym ekranowym wskaźniku, którego używają głośność i jasność, aktualizując się w miejscu zamiast piętrzyć powiadomienia. Ustaw `OMARCHY_YTDLP_DIR`, jeśli wolisz, aby pliki trafiały gdzie indziej — zobacz [FAQ](46-faq.md), aby dowiedzieć się, gdzie umieszczać zmienne środowiskowe.

Oba rozszerzenia komunikują się z Omarchy przez mały natywny host komunikacyjny, który instaluje się dla ciebie wraz z przeglądarką. To właśnie ten element sprawia, że wideo ze strony internetowej może trafić do twojego katalogu domowego, a adres URL do menedżera schowka, czego zwykłe rozszerzenie samo w sobie nie potrafi.

**WhatsApp Slim** sprawia, że WhatsApp Web stosuje twój motyw systemowy i zwija listę czatów, gdy okno jest wąskie.

Są one dostępne wyłącznie dla rodziny Chromium. Firefox i Zen ich nie otrzymują.

## Firefox i Zen

Firefox i Zen to inna rodzina, więc są traktowane inaczej: Omarchy instaluje plik zasad z rozsądnymi ustawieniami domyślnymi i przełącza je w natywny tryb Wayland, który jest ci potrzebny do skalowania ułamkowego i płynnego przewijania gładzikiem.

Nie otrzymują powyższych rozszerzeń Chromium i nie mają motywu Omarchy, więc te elementy doświadczenia musisz skonfigurować samodzielnie.

## Ladybird

Ladybird to przeglądarka napisana od zera, z własnym silnikiem, innym niż silnik Chromium czy Firefox. Nadal jest w wersji alpha, więc spodziewaj się witryn, które jeszcze nie działają, a Omarchy instaluje ją taką, jaka jest: bez rozszerzeń, bez motywu, bez zasad. Nie ma też okna prywatnego, więc `Super + Shift + Alt + B` otwiera ją z tymczasowym profilem, który jest usuwany po jej zamknięciu. [Aplikacje internetowe](25-web-apps.md) nadal działają w Chrome lub Chromium.

## Ponowne usuwanie przeglądarki

Każdą z tych przeglądarek, w tym Chrome, można ponownie usunąć w sekcji _Remove > Browser_. Linki będą wtedy trafiać do Chrome lub Chromium, jeśli ta druga przeglądarka nadal jest zainstalowana.
