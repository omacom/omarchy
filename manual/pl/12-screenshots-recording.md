# Zrzuty ekranu i nagrywanie

Wszystko, co możesz przechwycić z ekranu, jest przypisane do klawisza Print Screen. Sam klawisz robi zdjęcie, a modyfikatory robią nagranie, wybierają kolor albo odczytują tekst wewnątrz regionu. Jeśli twoja klawiatura w ogóle nie ma klawisza Print Screen, `Super + Ctrl + Alt + C` robi ten sam zrzut ekranu, a `Super + Ctrl + C` otwiera cały zestaw jako menu.

| Skrót klawiszowy | Funkcja |
| ------ | -------- |
| `Print Screen` | Zrzut ekranu |
| `Super + Ctrl + Alt + C` | Zrzut ekranu |
| `Alt + Print Screen` | Nagrywanie ekranu (albo zatrzymanie trwającego nagrania) |
| `Super + Print Screen` | Próbnik kolorów |
| `Super + Ctrl + Print Screen` | Wyodrębnianie tekstu z regionu |
| `Super + Ctrl + C` | Menu przechwytywania |
| `Super + Ctrl + .` | Transkodowanie obrazu lub wideo |

## Zrzuty ekranu

Naciśnij `Print Screen` (albo `Super + Ctrl + Alt + C`), a Omasnap przechwyci aktywny monitor, zanim pojawi się jego nakładka, więc nic nie przesunie się pod tobą, gdy celujesz. Przeciągnij dowolny region, kliknij okno, aby je przechwycić, albo kliknij pustą przestrzeń, aby przechwycić cały monitor. Naciśnij `S` przed rysowaniem, aby przechwycić przewijany region. Zmieniłeś zdanie? Naciśnij ten sam klawisz ponownie, aby zamknąć Omasnap.

Po wybraniu obszaru Omasnap zapisuje przechwycony obraz, kopiuje go do schowka i pokazuje powiadomienie z jego miniaturą, tak jak robi to zapisane nagranie ekranu. Wybierz Open, aby wyświetlić zapisany zrzut w przeglądarce obrazów, albo Edit, aby dodać do niego adnotacje.

Edytor adnotacji może rysować strzałki, linie, kształty, wyróżnienia, numerowane znaczniki i tekst oraz bezpieczne redakcje; przycinać lub wycinać część obrazu; wykonywać OCR jego tekstu; i dodawać tło. W edytorze naciśnij `Enter`, aby skopiować i zapisać gotowy PNG, `Ctrl + C`, aby skopiować go bez zapisywania, albo `Ctrl + S`, aby zapisać go bez kopiowania.

Zapisane zrzuty ekranu trafiają domyślnie do `~/Pictures/Screenshots`, pod nazwą taką jak `screenshot-2026-08-13_14-22-05-firefox.png`. Ustaw `OMASNAP_SCREENSHOT_DIR`, aby używać innego katalogu — zobacz [FAQ](46-faq.md), aby dowiedzieć się, gdzie umieszczać zmienne środowiskowe sesji. Omasnap tworzy katalog, gdy zapisuje pierwszy zrzut. Ustaw `[output] autosave = false` w `~/.config/omasnap/omasnap.conf`, aby wyłączyć automatyczne zapisywanie; przechwycone obrazy są wtedy tylko kopiowane i pokazywane w podglądzie przez 10 sekund, który możesz utrzymać na ekranie za pomocą jego przycisku przypinania albo `Ctrl + P`.

Z terminala `omarchy screenshot` otwiera tę samą nakładkę, a ty możesz wybrać jej tryb początkowy: `omarchy capture screenshot region`, `windows`, `fullscreen` albo `scroll`. Drugi argument `copy` albo `save` wysyła zrzut bezpośrednio do tego miejsca docelowego. Aby edytować przed wygenerowaniem wyniku, użyj `omarchy screenshot --editor=overlay` dla edytora pełnoekranowego albo `omarchy screenshot --editor=window` dla osobnego okna.

### Obsługa próbnika z klawiatury

Gdy zaznaczenie jest otwarte, w ogóle nie musisz używać myszy:

| Klawisz | Funkcja |
| --- | -------- |
| `S` | Przełączanie trybu przewijanego regionu |
| `Super + Arrow keys` | Przechodzenie między oknami w trybie Window |
| `Return` | Przechwycenie podświetlonego okna |
| `Ctrl + A` | Przechwycenie całego aktywnego monitora |
| `R` | Przywrócenie ostatniego regionu narysowanego w tej sesji |
| `Esc` | Zamknięcie Omasnap |

Te przypisania istnieją tylko, gdy Omasnap jest otwarty, więc nie mogą kolidować z niczym w twojej własnej konfiguracji.

## Nagrywanie ekranu

`Alt + Print Screen` otwiera _Trigger > Capture > Screenrecord_, które pyta, co chcesz mieć na ścieżce dźwiękowej: brak dźwięku, dźwięk pulpitu, dźwięk pulpitu plus mikrofon albo dźwięk pulpitu plus mikrofon plus kamerę internetową. Ta ostatnia opcja pokazuje się tylko, jeśli faktycznie masz podłączoną kamerę. Wybierz jedną, a próbnik nagrywania Omarchy pozwoli ci przeciągnąć region albo kliknąć okno lub monitor.

Nagrywanie działa na gpu-screen-recorder, który koduje na GPU przy 60fps i w razie potrzeby przechodzi na CPU. Wynikiem jest MP4 w `~/Videos`, o nazwie `screenrecording-2026-08-13_14-22-05.mp4`. Ustaw `OMARCHY_SCREENRECORD_DIR`, aby to zmienić — ale pamiętaj, że w odróżnieniu od katalogu zrzutów ekranu ten musi już istnieć, inaczej nagrywanie odmówi rozpoczęcia.

Podczas nagrywania na pasku pojawia się mały wskaźnik. Kliknij go, aby zatrzymać. Możesz też zatrzymać ponownie za pomocą `Alt + Print Screen` albo za pomocą wpisu _Stop Screenrecording_ w _Trigger > Capture > Screenrecord_, który pojawia się tylko, gdy coś faktycznie się nagrywa.

Zatrzymanie robi trochę porządków, zanim odda ci plik: pierwsza klatka jest przycinana, a jeśli jest dźwięk, jest on normalizowany do -14 LUFS, przy czym trzask przechwytywania PipeWire na samym początku jest wyciszany. Potem pojawia się powiadomienie z miniaturą z nagrania. Kliknij je, aby odtworzyć plik w mpv.

### Nakładka kamery internetowej

Gdy nagrywasz z kamerą internetową, obraz z kamery pojawia się jako przypięte, przycięte okno portretowe w prawym dolnym rogu tego, co nagrywasz. Jeśli zasłania coś, czego potrzebujesz, zmień jego rozmiar w locie:

| Skrót klawiszowy | Funkcja |
| ------ | -------- |
| `Super + Alt + [` | Zmniejszenie nakładki kamery internetowej |
| `Super + Alt + ]` | Powiększenie nakładki kamery internetowej |

Są trzy rozmiary — mały, średni i duży — a skróty klawiszowe przechodzą między nimi. Średni jest domyślny. Są one proporcjonalne do nagrania, więc kamera zajmuje tę samą część kadru, niezależnie od tego, czy nagrywasz monitor 1080p, czy 6K. A jeśli nagrałeś region, a nie cały ekran, nakładka kotwiczy się do rogu tego regionu, a nie monitora, więc pozostaje wewnątrz ujęcia.

Możesz też wywołać to bezpośrednio za pomocą `omarchy-capture-webcam-resize small` albo `reset`, aby wrócić do rozmiaru średniego.

## Tekst, kody QR i kolory

`Super + Ctrl + Print Screen` zaznacza region i wykonuje na nim OCR do schowka. Jest to porządnie opisane w [Wyodrębnianie tekstu i dyktowanie](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ robi tę samą sztuczkę dla kodów QR. Zaznacz region z kodem, a zdekodowana wartość trafi do schowka. Szuka tylko kodów QR — gęsta zawartość ekranu ma zwyczaj być w przeciwnym razie fałszywie wykrywana jako kod kreskowy. Warto wiedzieć: zdekodowana wartość trafia do schowka i nigdzie indziej. Nie jest wypisywana, nie ma jej w powiadomieniu i jest oznaczona jako wrażliwa, więc nie zostaje w [historii schowka](08-unified-clipboard-history.md). Kody QR rutynowo niosą sekrety — na przykład URI `otpauth://` stojący za kodem konfiguracji 2FA — a nie chcesz tego w logu. Wklejanie nadal działa bez problemu.

`Super + Print Screen` (albo _Trigger > Capture > Color_) zamienia kursor w kroplomierz. Kliknij cokolwiek na ekranie, a kolor trafi do schowka. Naciśnij skrót klawiszowy ponownie, aby wycofać się bez wybierania.

## Transkodowanie przed udostępnieniem

Nagranie ekranu 4K albo surowy HEIC z telefonu jest często zbyt duży, aby po prostu go wysłać. `Super + Ctrl + .` (albo _Trigger > Transcode_) to naprawia. Oferuje ci rozmyty wybór plików z `~/Pictures` i `~/Videos`, a potem pyta o format i rozmiar.

Obrazy trafiają do jpg lub png w jakości wysokiej, średniej albo niskiej, które ograniczają szerokość odpowiednio do 3160, 2160 i 1080 pikseli. Filmy trafiają do mp4 albo animowanego gif w 4k, 1080p albo 720p. Przekonwertowany plik jest zapisywany obok oryginału z rozdzielczością w nazwie — `demo-1080p.mp4` — a ścieżka jest kopiowana do schowka jako URI pliku, więc możesz wkleić ją bezpośrednio do aplikacji, która przyjmuje upuszczane pliki.

Działa to też z terminala, jeśli już wiesz, czego chcesz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Jest też `omarchy transcode ascii`, które zamienia obraz w ASCII art — to służy głównie do [brandingu](41-branding.md).

## Wysyłanie gdzieś indziej

Gdy już masz plik, `Super + Ctrl + S` otwiera menu Share i wysyła go do innego urządzenia w twojej sieci za pośrednictwem LocalSend. Zobacz [GUI](22-guis.md), aby dowiedzieć się więcej na ten temat.
