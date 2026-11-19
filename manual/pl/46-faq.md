# FAQ

### Jak przełączać się między układami klawiatury?

Edytuj plik `~/.config/hypr/input.lua` i dodaj poniższy fragment, aby przełączać się między układami za pomocą `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Pasek automatycznie pokaże Twój bieżący układ klawiatury, gdy tylko skonfigurujesz kilka układów (i możesz też kliknąć go, aby się przełączyć).

### Jak zmienić format zegara na 12-godzinny?

Kliknij zegar na pasku prawym przyciskiem myszy, aby przechodzić kolejno przez popularne formaty, w tym te 12-godzinne. Format możesz też ustawić bezpośrednio:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Wyświetli się Niedziela 10:55 AM.

### Jak zmienić strefę czasową?

Uruchom _Konfiguracja > Region > Strefa czasowa_ w menu Omarchy i wybierz z listy. Jeśli strefa czasowa jest prawidłowa, ale sam zegar się rozjechał, _Aktualizacja > Czas_ zrestartuje za Ciebie synchronizację czasu.

### Jak zmienić DNS, udostępnić Wi-Fi lub sprawdzić prędkość połączenia?

Wszystko to znajdziesz w [sieci](35-networking.md).

### Jak sprawdzić, jak szybki jest mój dysk?

_Wyzwalacz > Test prędkości > Test prędkości dysku_ mierzy na żywo prędkość odczytu i zapisu Twojego dysku, albo użyj `omarchy disk speedtest` w terminalu.

### Jak dodać drukarkę?

Drukowanie jest skonfigurowane i działa od razu po instalacji, a każdą drukarkę dodajesz samodzielnie w _Ustawieniach drukowania_ w programie uruchamiającym aplikacje (`Super + Space`).

Wybierz _Dodaj_ i daj mu chwilę na wyszukanie: drukarka podłączona przez USB oraz większość drukarek sieciowych zostaną znalezione za Ciebie. Jeśli Twojej nie ma na liście, wybierz _Drukarka sieciowa > Internet Printing Protocol (ipp)_ i wpisz jej adres — własny wyświetlacz drukarki lub jej strona internetowa powiedzą Ci, jaki to adres, zwykle coś w rodzaju `192.168.1.50` z kolejką `ipp/print`. _Dalej_ zaproponuje następnie sterownik — nowoczesna drukarka najlepiej działa na bezsterownikowym profilu _IPP Everywhere_, a starsza będzie chciała własnego sterownika danego modelu.

Kliknij drukarkę prawym przyciskiem myszy i wybierz _Ustaw jako domyślną_, aby określić, po którą Twoje aplikacje sięgną w pierwszej kolejności, oraz _Właściwości_, aby ustawić rozmiar papieru, druk dwustronny i jakość.

Automatyczne wykrywanie, dzięki któremu drukarki w sieci pojawiają się bez dodawania, jest tymczasowo wyłączone na czas przeróbek, dlatego pierwszy krok powyżej należy do Ciebie, a nie dzieje się automatycznie. Drukowanie do pliku PDF działa bez żadnej drukarki.

### Jak zmienić miejsce zapisywania zrzutów ekranu lub nagrań ekranu?

Zapisane zrzuty ekranu trafiają domyślnie do `~/Pictures/Screenshots`. Aby użyć innego katalogu, dodaj poniższe do pliku w `~/.config/uwsm/env.d/` (na przykład `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

To samo możesz zrobić dla nagrań ekranu, używając `OMARCHY_SCREENRECORD_DIR`.

Omasnap tworzy swój katalog zrzutów ekranu automatycznie. Katalog nagrań ekranu utwórz samodzielnie, a następnie zrestartuj Omarchy, aby którakolwiek zmiana środowiska weszła w życie.

### Jak sprawić, aby głośniki + kamera internetowa działały na moim Apple Studio Display?

Można by pomyśleć, że wszystko powinno działać po prostu po podłączeniu USB C, ale niestety tak nie jest. Rozwiązanie, które znalazłem i dzięki któremu wszystko działa niezawodnie, to użycie [kabla WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Wtedy głośniki i kamera internetowa działają jak marzenie.

Pamiętaj, że w Omarchy masz wbudowaną kontrolę jasności dla wyświetlaczy Apple (zarówno Studio, jak i XDR), obsługiwaną zwykłymi przyciskami jasności na klawiaturze.

### Jak pozbyć się całego dodatkowego oprogramowania?

Jeśli nie chcesz programów takich jak Obsidian czy LibreOffice ani żadnego innego preinstalowanego oprogramowania, możesz je bardzo łatwo usunąć.

Uruchom _Usuń > Pakiet_, aby zobaczyć każdy zainstalowany pakiet. Potem możesz zaznaczyć dowolny pakiet, który chcesz usunąć, za pomocą tab i zacząć usuwać wszystko, co zaznaczyłeś, za pomocą return.

A w menu Omarchy możesz użyć _Usuń > Aplikacja webowa_, aby usunąć dowolne preinstalowane aplikacje webowe, których nie chcesz.

Albo uruchom _Usuń > Preinstalowane dodatki_, aby za jednym zamachem wymieść wszystkie preinstalowane dodatki — aplikacje webowe, TUIs i opcjonalne aplikacje. Skróty klawiszowe, które je uruchamiały, znikną razem z nimi, więc zostanie Ci czysta karta skrótów do wypełnienia własnymi w `~/.config/hypr/bindings.lua`.

---

W sprawie błędów i niedziałających rzeczy zobacz [sekcję Rozwiązywanie problemów](45-troubleshooting.md).
