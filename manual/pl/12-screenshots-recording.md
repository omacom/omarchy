# Zrzuty ekranu i nagrywanie

Wszystko, co możesz przechwycić z ekranu, wisi na klawiszu Print Screen. Sam klawisz robi zdjęcie, a modyfikatory robią nagranie, kolor albo tekst wewnątrz obszaru. Jeśli Twoja klawiatura w ogóle nie ma klawisza Print Screen, `Super + Ctrl + Alt + C` robi ten sam zrzut ekranu, a `Super + Ctrl + C` otwiera cały zestaw jako menu.

| Klawisz skrótu | Funkcja |
| ------ | -------- |
| `Print Screen` | Zrzut ekranu |
| `Super + Ctrl + Alt + C` | Zrzut ekranu |
| `Alt + Print Screen` | Nagrywanie ekranu (lub zatrzymanie trwającego) |
| `Super + Print Screen` | Próbnik kolorów |
| `Super + Ctrl + Print Screen` | Wyodrębnianie tekstu z obszaru |
| `Super + Ctrl + C` | Menu przechwytywania |
| `Super + Ctrl + .` | Transkodowanie zdjęcia lub wideo |

## Zrzuty ekranu

Naciśnij `Print Screen` (lub `Super + Ctrl + Alt + C`), a Omasnap przechwytuje aktywny monitor, zanim pojawi się jego nakładka, więc nic nie przesuwa się pod Tobą, gdy celujesz. Przeciągnij dowolny obszar, kliknij okno, aby je przechwycić, lub kliknij pustą przestrzeń, aby przechwycić cały monitor. Naciśnij `S` przed rysowaniem, aby przechwycić przewijany obszar. Zmieniłeś zdanie? Naciśnij ten sam klawisz ponownie, aby zamknąć Omasnap.

Po wybraniu obszaru Omasnap zapisuje przechwycony obraz, kopiuje go do schowka i pokazuje powiadomienie z jego miniaturą, tak jak robi to zapisane nagranie ekranu. Wybierz Open, aby wyświetlić zapisany zrzut w przeglądarce obrazów, lub Edit, aby dodać do niego adnotacje.

Edytor adnotacji potrafi rysować strzałki, linie, kształty, wyróżnienia, numerowane znaczniki, tekst i bezpieczne redakcje; przycinać lub wycinać część obrazu; rozpoznawać jego tekst za pomocą OCR; oraz dodawać tło. W edytorze naciśnij `Enter`, aby skopiować i zapisać gotowy PNG, `Ctrl + C`, aby skopiować go bez zapisywania, lub `Ctrl + S`, aby zapisać go bez kopiowania.

Zapisane zrzuty ekranu trafiają domyślnie do `~/Pictures/Screenshots`, pod nazwą taką jak `screenshot-2026-08-13_14-22-05-firefox.png`. Ustaw `OMASNAP_SCREENSHOT_DIR`, aby używać innego katalogu — zobacz [FAQ](46-faq.md), aby dowiedzieć się, gdzie umieszczać zmienne środowiskowe sesji. Omasnap tworzy katalog, gdy zapisuje pierwszy zrzut. Ustaw `[output] autosave = false` w `~/.config/omasnap/omasnap.conf`, aby wyłączyć automatyczne zapisywanie; przechwycone obrazy są wtedy tylko kopiowane i pokazywane w podglądzie przez 7 sekund, który możesz utrzymać na ekranie za pomocą jego przycisku przypinania lub `Ctrl + P`.

Z terminala `omarchy screenshot` otwiera tę samą nakładkę, a Ty możesz wybrać jej tryb początkowy: `omarchy capture screenshot region`, `windows`, `fullscreen` lub `scroll`. Drugi argument `copy` lub `save` wysyła zrzut prosto do tego miejsca docelowego. Aby edytować przed wyprowadzeniem, użyj `omarchy screenshot --editor=overlay` dla edytora pełnoekranowego lub `omarchy screenshot --editor=window` dla osobnego okna.

### Sterowanie selektorem z klawiatury

Gdy selekcja jest aktywna, w ogóle nie musisz używać myszy:

| Klawisz | Funkcja |
| --- | -------- |
| `S` | Przełączanie trybu obszaru przewijanego |
| `Super + Arrow keys` | Poruszanie się między oknami w trybie Window |
| `Return` | Przechwycenie podświetlonego okna |
| `Ctrl + A` | Przechwycenie całego aktywnego monitora |
| `R` | Przywrócenie ostatniego obszaru narysowanego w tej sesji |
| `Esc` | Zamknięcie Omasnap |

Te przypisania istnieją tylko, gdy Omasnap jest otwarty, więc nie mogą kolidować z niczym w Twojej własnej konfiguracji.

## Nagrywanie ekranu

`Alt + Print Screen` otwiera _Trigger > Capture > Screenrecord_, które pyta, co chcesz mieć na ścieżce dźwiękowej: brak dźwięku, dźwięk pulpitu, pulpit plus mikrofon albo pulpit plus mikrofon plus kamera internetowa. Ta ostatnia opcja pojawia się tylko, jeśli faktycznie masz podłączoną kamerę. Wybierz jedną, a selektor nagrywania Omarchy pozwoli Ci przeciągnąć obszar lub kliknąć okno albo monitor.

Nagrywanie działa na gpu-screen-recorder, który koduje na GPU przy 60fps i w razie potrzeby wraca do CPU; na GPU, których nie obsługuje, takich jak Apple Silicon, Omarchy nagrywa zamiast tego za pomocą wf-recorder. Rezultatem jest plik MP4 w `~/Videos` o nazwie `screenrecording-2026-08-13_14-22-05.mp4`. Ustaw `OMARCHY_SCREENRECORD_DIR`, aby to zmienić — ale pamiętaj, że w przeciwieństwie do katalogu zrzutów ekranu ten musi już istnieć, inaczej nagrywanie odmówi rozpoczęcia.

Gdy nagrywasz, na pasku pojawia się mały wskaźnik. Kliknij go, aby zatrzymać. Możesz też zatrzymać ponownie za pomocą `Alt + Print Screen` albo wpisu _Stop Screenrecording_ w _Trigger > Capture > Screenrecord_, który pojawia się tylko, gdy coś faktycznie się nagrywa.

Zatrzymanie robi trochę porządków, zanim odda Ci plik: pierwsza klatka jest przycinana, a jeśli jest dźwięk, jest on normalizowany do -14 LUFS, przy czym trzask przechwytywania PipeWire na samym początku jest wyciszany. Następnie pojawia się powiadomienie z miniaturą z nagrania. Wybierz _Open_, aby odtworzyć plik w Omaview, lub _Cut_, aby przyciąć go w Omacut.

### Nakładka kamery internetowej

Gdy nagrywasz z kamerą internetową, kamera pojawia się jako przypięte, przycięte okno portretowe w prawym dolnym rogu tego, co nagrywasz. Jeśli leży na czymś, czego potrzebujesz, zmień jej rozmiar w locie:

| Klawisz skrótu | Funkcja |
| ------ | -------- |
| `Super + Alt + [` | Zmniejszenie nakładki kamery internetowej |
| `Super + Alt + ]` | Zwiększenie nakładki kamery internetowej |

Są trzy rozmiary — mały, średni i duży — a klawisze skrótu przechodzą między nimi. Średni jest domyślny. Są proporcjonalne do nagrania, więc kamera zajmuje tę samą część kadru, niezależnie od tego, czy nagrywasz monitor 1080p, czy 6K. A jeśli nagrałeś obszar, a nie cały ekran, nakładka kotwiczy się do rogu tego obszaru, a nie monitora, więc zostaje wewnątrz ujęcia.

Możesz też wywołać to bezpośrednio za pomocą `omarchy-capture-webcam-resize small` lub `reset`, aby wrócić do średniego.

## Tekst, kody QR i kolory

`Super + Ctrl + Print Screen` zaznacza obszar i rozpoznaje jego tekst za pomocą OCR do schowka. Jest to porządnie opisane w [Wyodrębnianie tekstu i dyktowanie](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ robi tę samą sztuczkę dla kodów QR. Zaznacz obszar z kodem, a zdekodowana wartość trafi do schowka. Szuka tylko kodów QR — gęsta treść ekranu ma zwyczaj w przeciwnym razie fałszywie wychodzić jako kod kreskowy. Warto wiedzieć: zdekodowana wartość trafia do schowka i nigdzie indziej. Nie jest wypisywana, nie ma jej w powiadomieniu i jest oznaczona jako wrażliwa, więc nie zostaje w [historii schowka](08-unified-clipboard-history.md). Kody QR rutynowo niosą sekrety — na przykład URI `otpauth://` stojący za kodem konfiguracji 2FA — a tego nie chcesz mieć w logu. Wklejanie nadal działa bez problemu.

`Super + Print Screen` (lub _Trigger > Capture > Color_) zamienia kursor w pipetę. Kliknij cokolwiek na ekranie, a kolor trafi do schowka. Naciśnij klawisz skrótu ponownie, aby wycofać się bez wybierania.

## Transkodowanie przed udostępnieniem

Nagranie ekranu 4K albo surowy HEIC z telefonu jest często zbyt duży, aby po prostu go wysłać. `Super + Ctrl + .` (lub _Trigger > Transcode_) to naprawia. Oferuje Ci selektor plików z wyszukiwaniem rozmytym po `~/Pictures` i `~/Videos`, a następnie pyta o format i rozmiar.

Zdjęcia trafiają do jpg lub png w jakości wysokiej, średniej lub niskiej, które ograniczają szerokość do 3160, 2160 i 1080 pikseli. Wideo trafia do mp4 lub animowanego gif w 4k, 1080p lub 720p. Przekonwertowany plik jest zapisywany obok oryginału z rozdzielczością w nazwie — `demo-1080p.mp4` — a ścieżka jest kopiowana do schowka jako URI pliku, więc możesz wkleić ją bezpośrednio do aplikacji, która przyjmuje upuszczanie plików.

Działa to też z terminala, jeśli już wiesz, czego chcesz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Jest też `omarchy transcode ascii`, które zamienia obraz w grafikę ASCII — to głównie do [brandingu](41-branding.md).

## Wysyłanie tego gdzieś

Gdy już masz plik, `Super + Ctrl + S` otwiera menu Share i wysyła go do innego urządzenia w Twojej sieci przez LocalSend. Zobacz [GUIs](22-guis.md), aby dowiedzieć się więcej na ten temat.
