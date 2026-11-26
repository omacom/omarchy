# Przeglądarki

Omarchy jest dostarczane z [Google Chrome](https://www.google.com/chrome/) jako domyślną przeglądarką. Ma motyw dopasowany do reszty Twojego systemu i to właśnie ją otwiera `Super + Shift + Return` (lub `Super + Shift + B`), przy czym `Super + Shift + Alt + B` służy do okna prywatnego, a w niej działa też każda [aplikacja webowa](25-web-apps.md). Otwiera się bezpośrednio w oknie przeglądarki: nie ma ekranu powitalnego ani monitu o zalogowanie, statystyki użytkowania i raporty o awariach nie są wysyłane do Google, a monity dotyczące prywatności reklam są wyłączone. Nadal możesz w każdej chwili zalogować się na swoje konto Google za pomocą przycisku profilu, jeśli chcesz korzystać z synchronizacji.

Jeśli Chrome nie jest w Twoim guście, nie jesteś na niego skazany. W menu Omarchy, w sekcji _Zainstaluj > Przeglądarka_, znajdziesz [Chromium](https://www.chromium.org/) (zwykłą, open-source'ową wersję, na której bazuje Chrome), Edge, Brave, Brave Origin, Firefox i [Zen](https://zen-browser.app/) (Edge tylko na maszynach x86). Wybierz jedną, a Omarchy ją zainstaluje, skonfiguruje jej katalog zasad i zastosuje do niej Twój bieżący motyw.

## Ustawianie jednej z nich jako domyślnej

Zainstalowanie przeglądarki nie czyni jej domyślną. Aby ją zmienić, przejdź do _Konfiguracja > Domyślne > Przeglądarka_ i wybierz jedną. Bieżąca domyślna jest oznaczona znacznikiem wyboru, a wybranie przeglądarki, której jeszcze nie masz, najpierw ją zainstaluje.

Z terminala wygląda to tak:

```bash
omarchy default browser firefox
```

Uruchom to polecenie bez argumentu, a powie Ci, która przeglądarka jest bieżącą domyślną. Ustawia to handler XDG, więc nie tylko skróty klawiszowe Omarchy się do tego dostosowują — wszystko, co otwiera link, od aplikacji do czatu po polecenie w terminalu, trafia do wybranej przez Ciebie przeglądarki.

## Kopiowanie adresu URL i pobieranie wideo

Przeglądarki z rodziny Chromium (sam Chromium, Chrome, Edge, Brave i Brave Origin) otrzymują trzy rozszerzenia Omarchy: dwa, które wychodzą poza przeglądarkę i sięgają do reszty Twojego systemu, oraz jedno, które porządkuje WhatsApp.

**Copy URL** umieszcza adres bieżącej karty w Twoim schowku za pomocą `Alt + Shift + L`. To szybsze niż klikanie w pasek adresu i kopiowanie, a ponieważ odbywa się to przez schowek systemowy, a nie schowek przeglądarki, dostajesz powiadomienie Omarchy potwierdzające wykonanie operacji, a adres URL jest od razu dostępny w [historii schowka](08-unified-clipboard-history.md) i w każdej innej aplikacji. Jest też przycisk na pasku narzędzi, jeśli wolisz klikać.

**Download Video** pobiera wideo odtwarzane na stronie, którą oglądasz, za pomocą `Alt + Shift + D`. Przekazuje adres URL do [yt-dlp](https://github.com/yt-dlp/yt-dlp), więc działa na znacznie większej liczbie serwisów niż tylko YouTube, a pobrany plik trafia do `~/Videos`. Postęp pokazuje się w tym samym wyświetlaczu ekranowym, z którego korzystają regulacja głośności i jasności, aktualizując się w miejscu, zamiast piętrzyć powiadomienia. Ustaw `OMARCHY_YTDLP_DIR`, jeśli wolisz, aby pliki trafiały gdzie indziej — zobacz [FAQ](46-faq.md), aby dowiedzieć się, gdzie umieszczać zmienne środowiskowe.

Oba rozszerzenia komunikują się z Omarchy za pośrednictwem małego natywnego hosta wiadomości, który jest instalowany razem z przeglądarką. To właśnie ten element pozwala, aby wideo ze strony internetowej trafiło do Twojego katalogu domowego, a adres URL do Twojego menedżera schowka, czego zwykłe rozszerzenie samo w sobie nie potrafi zrobić.

**WhatsApp Slim** sprawia, że WhatsApp Web stosuje Twój motyw systemowy i zwija listę czatów, gdy okno jest wąskie.

Są one dostępne tylko dla rodziny Chromium. Firefox i Zen ich nie otrzymują.

## Firefox i Zen

Firefox i Zen to inna rodzina, więc są traktowane inaczej: Omarchy instaluje plik zasad z rozsądnymi ustawieniami domyślnymi i przełącza je w natywny tryb Wayland, którego potrzebujesz do skalowania ułamkowego i płynnego przewijania za pomocą gładzika.

Nie otrzymują powyższych rozszerzeń Chromium, a Omarchy nie stosuje do nich motywów, więc te części doświadczenia musisz skonfigurować samodzielnie.

## Ponowne usuwanie przeglądarki

Każdą z tych przeglądarek, łącznie z Chrome, można ponownie usunąć w sekcji _Usuń > Przeglądarka_. Linki będą wówczas trafiać do Chrome lub Chromium, jeśli druga z tych przeglądarek jest nadal zainstalowana.
