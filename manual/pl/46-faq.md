# FAQ

### Jak przełączać się między układami klawiatury?

Edytuj plik `~/.config/hypr/input.lua` i dodaj to, aby przełączać się między układami za pomocą `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Pasek automatycznie pokaże Twój bieżący układ klawiatury, gdy tylko skonfigurujesz wiele układów (i możesz też kliknąć go, aby się przełączyć).

### Jak zmienić format zegara na 12-godzinny?

Kliknij zegar na pasku prawym przyciskiem myszy, aby przechodzić między popularnymi formatami, w tym 12-godzinnymi. Możesz też ustawić format bezpośrednio:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Wyświetli to Niedziela 10:55 AM.

### Jak zmienić moją strefę czasową?

Uruchom _Aktualizacja > Strefa czasowa_ w menu Omarchy i wybierz z listy. Jeśli strefa czasowa jest prawidłowa, ale sam zegar się rozjechał, _Aktualizacja > Czas_ uruchomi dla Ciebie ponownie synchronizację czasu.

### Jak zmienić mój DNS, udostępnić moje Wi-Fi lub sprawdzić prędkość mojego połączenia?

To wszystko znajduje się w [sieci](35-networking.md).

### Jak sprawdzić, jak szybki jest mój dysk?

_Wyzwalacz > Test prędkości > Test prędkości dysku_ mierzy na żywo prędkość odczytu i zapisu na Twoim dysku, albo `omarchy disk speedtest` z terminala.

### Jak dodać drukarkę?

Drukowanie jest skonfigurowane i działa od razu po instalacji, a każdą drukarkę dodajesz samodzielnie z _Ustawienia drukowania_ w programie uruchamiającym aplikacje (`Super + Space`).

Wybierz _Dodaj_ i daj mu chwilę na wyszukanie: drukarka podłączona przez USB oraz większość drukarek sieciowych zostaną znalezione za Ciebie. Jeśli Twojej nie ma na liście, wybierz _Drukarka sieciowa > Internet Printing Protocol (ipp)_ i wpisz jej adres — własny wyświetlacz drukarki lub jej strona internetowa powie Ci, jaki to adres, zwykle coś w rodzaju `192.168.1.50` z kolejką `ipp/print`. _Dalej_ zaproponuje następnie sterownik, przy czym nowoczesna drukarka działa najlepiej na bezsterownikowym profilu _IPP Everywhere_, a starsza chce własnego sterownika modelu.

Kliknij drukarkę prawym przyciskiem myszy i wybierz _Ustaw jako domyślną_, aby wybrać, po którą Twoje aplikacje sięgają najpierw, oraz _Właściwości_, aby ustawić rozmiar papieru, druk dwustronny i jakość.

Automatyczne wykrywanie, w którym drukarki w sieci pojawiają się bez dodawania, jest tymczasowo wyłączone na czas jego przebudowy, dlatego pierwszy krok powyżej należy do Ciebie, a nie dzieje się automatycznie. Drukowanie do pliku PDF działa w ogóle bez żadnej drukarki.

### Jak zmienić miejsce zapisywania zrzutów ekranu lub nagrań ekranu?

Zapisane zrzuty ekranu trafiają domyślnie do `~/Pictures/Screenshots`. Aby użyć innego katalogu, dodaj to do pliku w `~/.config/uwsm/env.d/` (na przykład `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Możesz zrobić to samo dla nagrań ekranu, używając `OMARCHY_SCREENRECORD_DIR`.

Omasnap tworzy swój katalog zrzutów ekranu automatycznie. Katalog nagrań ekranu utwórz samodzielnie, a następnie uruchom ponownie Omarchy, aby dowolna zmiana środowiska weszła w życie.

### Jak sprawić, by głośniki + kamera internetowa działały na moim Apple Studio Display?

Można by pomyśleć, że wszystko powinno działać po prostu po podłączeniu USB C, ale niestety tak nie jest. Rozwiązaniem, które znalazłem, aby działało to niezawodnie, jest użycie [kabla WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Wtedy głośniki i kamera internetowa działają jak marzenie.

Pamiętaj, że w Omarchy masz wbudowaną regulację jasności dla monitorów Apple (zarówno Studio, jak i XDR) za pomocą zwykłych klawiszy jasności na klawiaturze.

### Jak pozbyć się całego dodatkowego oprogramowania?

Jeśli nie chcesz programów takich jak Obsidian czy LibreOffice ani żadnego innego preinstalowanego oprogramowania, możesz je bardzo łatwo usunąć.

Uruchom _Usuń > Pakiet_, aby zobaczyć każdy zainstalowany pakiet. Następnie możesz wybrać za pomocą tab dowolny pakiet, który chcesz usunąć, i rozpocząć usuwanie wszystkiego, co wybrałeś, za pomocą return.

A możesz użyć _Usuń > Aplikacja internetowa_ z menu Omarchy, aby usunąć dowolne preinstalowane aplikacje internetowe, których nie chcesz.

Albo uruchom _Usuń > Preinstalowane_, aby za jednym razem wymieść wszystkie preinstalowane dodatki — aplikacje internetowe, TUI i opcjonalne aplikacje. Skróty klawiszowe, które je uruchamiały, znikają wraz z nimi, więc zostaje Ci czysta karta powiązań do wypełnienia własnymi w `~/.config/hypr/bindings.lua`.

---

W sprawie błędów i zepsutych rzeczy zobacz [sekcję Rozwiązywanie problemów](45-troubleshooting.md).
