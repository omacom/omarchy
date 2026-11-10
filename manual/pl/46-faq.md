# Często zadawane pytania

### Jak przełączać się między układami klawiatury?

Wyedytuj plik `~/.config/hypr/input.lua` i dodaj to, aby przełączać się między układami skrótem `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Pasek będzie automatycznie pokazywał twój bieżący układ klawiatury, gdy tylko skonfigurujesz wiele układów (i możesz też go kliknąć, aby się przełączyć).

### Jak zmienić format zegara na 12-godzinny?

Kliknij zegar na pasku prawym przyciskiem myszy, aby przełączać się między typowymi formatami, w tym 12-godzinnymi. Możesz też ustawić format wprost:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Wyświetli to Sunday 10:55 AM.

### Jak zmienić strefę czasową?

Uruchom _Aktualizuj > Strefa czasowa_ w menu Omarchy i wybierz z listy. Jeśli strefa czasowa jest dobra, ale sam zegar się rozregulował, _Aktualizuj > Czas_ zrestartuje za ciebie synchronizację czasu.

### Jak zmienić DNS, udostępnić Wi-Fi albo sprawdzić prędkość połączenia?

Wszystko to mieszka w rozdziale [o sieci](35-networking.md).

### Jak sprawdzić, jak szybki jest mój dysk?

_Akcje > Test prędkości > Test prędkości dysku_ mierzy bieżącą prędkość odczytu i zapisu na twoim dysku, albo `omarchy disk speedtest` z terminala.

### Dlaczego nie mogę zalogować się na konto Google w Chromium?

Zwykła, otwarta kompilacja Chromium nie dostarcza danych uwierzytelniających OAuth, których Google wymaga do logowania na konto. Uruchom _Instaluj > Usługa > Konto Chromium_ w menu Omarchy, aby je dodać, zrestartuj przeglądarkę i logowanie przejdzie.

### Jak dodać drukarkę?

Drukowanie jest skonfigurowane i działa od razu po zainstalowaniu, a każdą drukarkę dodajesz sam w _Print Settings_ w programie uruchamiającym aplikacje (`Super + Space`).

Wybierz _Add_ i daj mu chwilę na szukanie: drukarka podłączona przez USB oraz większość drukarek sieciowych zostanie znaleziona za ciebie. Jeśli twojej nie ma na liście, wybierz _Network Printer > Internet Printing Protocol (ipp)_ i wprowadź jej adres — wyświetlacz samej drukarki albo jej strona webowa powie ci, jaki to jest, zwykle coś w rodzaju `192.168.1.50` z kolejką `ipp/print`. _Forward_ zaproponuje potem sterownik; nowoczesna drukarka działa najlepiej na bezsterownikowym profilu _IPP Everywhere_, a starsza chce własnego sterownika modelu.

Kliknij drukarkę prawym przyciskiem myszy i wybierz _Set as Default_, aby wybrać, po którą aplikacje sięgają najpierw, oraz _Properties_, aby ustawić rozmiar papieru, druk dwustronny i jakość.

Automatyczne wykrywanie, w którym drukarki w sieci pojawiają się bez dodawania, jest tymczasowo wyłączone na czas jego przebudowy, dlatego pierwszy krok powyżej należy do ciebie, a nie dzieje się automatycznie. Drukowanie do pliku PDF działa bez żadnej drukarki.

### Jak zmienić miejsce zapisywania zrzutów ekranu albo nagrań ekranu?

Zapisywane zrzuty ekranu trafiają domyślnie do `~/Pictures/Screenshots`. Aby użyć innego katalogu, dodaj to do pliku w `~/.config/uwsm/env.d/` (np. `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

To samo możesz zrobić dla nagrań ekranu, używając `OMARCHY_SCREENRECORD_DIR`.

Omasnap tworzy swój katalog zrzutów ekranu automatycznie. Katalog nagrań ekranu utwórz sam, a potem zrestartuj Omarchy, aby którakolwiek zmiana środowiska zaczęła obowiązywać.

### Jak sprawić, by głośniki i kamera internetowa działały na moim Apple Studio Display?

Można by pomyśleć, że wszystko powinno działać po samym podłączeniu USB C, ale niestety tak nie jest. Rozwiązaniem, które u mnie działa niezawodnie, jest użycie [kabla WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Wtedy głośniki i kamera internetowa działają jak marzenie.

Pamiętaj, że masz wbudowaną w Omarchy regulację jasności dla wyświetlaczy Apple (zarówno Studio, jak i XDR) zwykłymi klawiszami jasności na klawiaturze.

### Jak pozbyć się całego dodatkowego oprogramowania?

Jeśli nie chcesz programów takich jak Obsidian, LibreOffice ani żadnej innej preinstalowanej rzeczy, możesz je bardzo łatwo usunąć.

Uruchom _Usuń > Pakiet_, aby zobaczyć każdy zainstalowany pakiet. Potem możesz klawiszem Tab zaznaczać pakiety, które chcesz usunąć, i rozpocząć usuwanie wszystkiego, co zaznaczyłeś, klawiszem Return.

Możesz też użyć _Usuń > Aplikacja webowa_ z menu Omarchy, aby usunąć preinstalowane aplikacje webowe, których nie chcesz.

Albo uruchom _Usuń > Preinstalowane_, aby jednym ruchem wymieść wszystkie preinstalowane dodatki — aplikacje webowe, aplikacje TUI i aplikacje opcjonalne. Skróty, które je uruchamiały, znikają razem z nimi, więc zostaje ci czysta karta skrótów, które możesz wypełnić własnymi w `~/.config/hypr/bindings.lua`.

---

W przypadku błędów i zepsutych rzeczy zobacz [sekcję Rozwiązywanie problemów](45-troubleshooting.md).
