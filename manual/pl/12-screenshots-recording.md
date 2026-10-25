# Zrzuty ekranu i nagrywanie

Wszystko, co możesz przechwycić z ekranu, wisi na klawiszu Print Screen. Sam klawisz robi zdjęcie, a modyfikatory robią nagranie, kolor albo tekst wewnątrz regionu. Jeśli twoja klawiatura w ogóle nie ma klawisza Print Screen, `Super + Ctrl + Alt + C` robi ten sam zrzut ekranu, a `Super + Ctrl + C` otwiera cały zestaw jako menu.

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | Zrzut ekranu |
| `Super + Ctrl + Alt + C` | Zrzut ekranu |
| `Alt + Print Screen` | Nagrywanie ekranu (lub zatrzymanie tego, które trwa) |
| `Super + Print Screen` | Próbnik kolorów |
| `Super + Ctrl + Print Screen` | Wyodrębnij tekst z regionu |
| `Super + Ctrl + C` | Menu przechwytywania |
| `Super + Ctrl + .` | Transkoduj zdjęcie lub wideo |

## Zrzuty ekranu

Naciśnij `Print Screen` (lub `Super + Ctrl + Alt + C`), a Omasnap przechwyci monitor z fokusem, zanim pojawi się jego nakładka, więc nic nie przesunie się pod tobą, gdy celujesz. Przeciągnij dowolny region, kliknij okno, aby je przechwycić, lub kliknij pustą przestrzeń, aby przechwycić cały monitor. Naciśnij `S` przed rysowaniem, aby przechwycić region przewijany. Zmieniłeś zdanie? Naciśnij ten sam klawisz jeszcze raz, aby zamknąć Omasnap.

Po wybraniu obszaru Omasnap zapisuje przechwycenie, kopiuje je do schowka i pokazuje podgląd przez 10 sekund. Użyj przycisku przypinania w podglądzie lub `Ctrl + P`, aby zostawić go na ekranie, albo wybierz Edit, aby dodać adnotacje.

Edytor adnotacji potrafi rysować strzałki, linie, kształty, wyróżnienia, numerowane znaczniki, tekst i bezpieczne redakcje; przycinać lub wycinać część obrazu; odczytywać jego tekst przez OCR; oraz dodawać tło. W edytorze naciśnij `Enter`, aby skopiować i zapisać gotowy PNG, `Ctrl + C`, aby skopiować go bez zapisywania, lub `Ctrl + S`, aby zapisać go bez kopiowania.

Zapisane zrzuty ekranu lądują domyślnie w `~/Pictures/Screenshots`, z nazwą taką jak `screenshot-2026-08-13_14-22-05-firefox.png`. Ustaw `OMASNAP_SCREENSHOT_DIR`, aby użyć innego katalogu — zobacz [FAQ](46-faq.md), aby dowiedzieć się, gdzie umieszczać zmienne środowiskowe sesji. Omasnap tworzy katalog, gdy zapisuje pierwszy zrzut. Ustaw `[output] autosave = false` w `~/.config/omasnap/omasnap.conf`, aby wyłączyć automatyczne zapisywanie.

Z terminala `omarchy screenshot` otwiera tę samą nakładkę, a możesz wybrać jej tryb startowy: `omarchy capture screenshot region`, `windows`, `fullscreen` lub `scroll`. Drugi argument `copy` lub `save` pomija podgląd i wysyła zrzut prosto do tego miejsca docelowego. Aby edytować przed wyjściem, użyj `omarchy screenshot --editor=overlay` dla edytora pełnoekranowego lub `omarchy screenshot --editor=window` dla osobnego okna.

### Obsługa selektora z klawiatury

Gdy zaznaczenie jest otwarte, w ogóle nie musisz używać myszy:

| Key | Function |
| --- | -------- |
| `S` | Przełącz tryb regionu przewijanego |
| `Super + Arrow keys` | Poruszaj się między oknami w trybie Window |
| `Return` | Przechwyć podświetlone okno |
| `Ctrl + A` | Przechwyć cały monitor z fokusem |
| `R` | Przywróć ostatni region narysowany w tej sesji |
| `Esc` | Zamknij Omasnap |

Te powiązania istnieją tylko, gdy Omasnap jest otwarty, więc nie mogą kolidować z niczym w twojej własnej konfiguracji.

## Nagrywanie ekranu

`Alt + Print Screen` otwiera _Trigger > Capture > Screenrecord_, które pyta, co chcesz mieć na ścieżce dźwiękowej: brak dźwięku, dźwięk pulpitu, pulpit plus mikrofon lub pulpit plus mikrofon plus kamera internetowa. Ta ostatnia opcja pojawia się tylko, jeśli faktycznie masz podłączoną kamerę. Wybierz jedną, a selektor nagrywania Omarchy pozwoli ci przeciągnąć region lub kliknąć okno albo monitor.

Nagrywanie działa na gpu-screen-recorder, który koduje na GPU przy 60fps i w razie potrzeby przechodzi na CPU. Wynikiem jest MP4 w `~/Videos`, o nazwie `screenrecording-2026-08-13_14-22-05.mp4`. Ustaw `OMARCHY_SCREENRECORD_DIR`, aby to zmienić — ale pamiętaj, że w przeciwieństwie do katalogu zrzutów ekranu ten musi już istnieć, inaczej nagrywanie odmówi startu.

Podczas nagrywania w pasku pojawia się mały wskaźnik. Kliknij go, aby zatrzymać. Możesz też zatrzymać ponownie przez `Alt + Print Screen` albo przez pozycję _Stop Screenrecording_ w _Trigger > Capture > Screenrecord_, która pojawia się tylko, gdy coś faktycznie się nagrywa.

Zatrzymanie robi trochę porządków, zanim odda ci plik: pierwsza klatka jest przycinana, a jeśli jest dźwięk, jest normalizowany do -14 LUFS, z wyciszonym trzaskiem przechwytywania PipeWire na samym początku. Potem pojawia się powiadomienie z miniaturą z nagrania. Kliknij je, aby odtworzyć plik w mpv.

### Nakładka kamery internetowej

Gdy nagrywasz z kamerą internetową, kamera pojawia się jako przypięte, przycięte okno portretowe w prawym dolnym rogu tego, co nagrywasz. Jeśli leży na czymś, czego potrzebujesz, zmień jej rozmiar w locie:

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | Zmniejsz nakładkę kamery internetowej |
| `Super + Alt + ]` | Powiększ nakładkę kamery internetowej |

Są trzy rozmiary — mały, średni i duży — a skróty klawiszowe przechodzą między nimi. Średni jest domyślny. Są proporcjonalne do nagrania, więc kamera zajmuje tę samą część kadru, niezależnie od tego, czy nagrywasz monitor 1080p, czy 6K. A jeśli nagrałeś region, a nie cały ekran, nakładka kotwiczy się do rogu tego regionu, a nie monitora, więc zostaje wewnątrz ujęcia.

Możesz też wywołać to bezpośrednio przez `omarchy-capture-webcam-resize small` lub `reset`, aby wrócić do średniego.

## Tekst, kody QR i kolory

`Super + Ctrl + Print Screen` zaznacza region i odczytuje go przez OCR do schowka. Jest to porządnie opisane w [Wyodrębnianie tekstu i dyktowanie](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ robi tę samą sztuczkę dla kodów QR. Zaznacz region z kodem, a zdekodowana wartość trafi do schowka. Szuka tylko kodów QR — gęsta treść ekranu ma zwyczaj fałszywie wychodzić jako kod kreskowy w przeciwnym razie. Warto wiedzieć: zdekodowana wartość trafia do schowka i nigdzie indziej. Nie jest wypisywana, nie ma jej w powiadomieniu i jest oznaczona jako wrażliwa, więc nie zostaje w [historii schowka](08-unified-clipboard-history.md). Kody QR rutynowo niosą sekrety — na przykład URI `otpauth://` stojące za kodem konfiguracji 2FA — a nie chcesz tego w logu. Wklejanie nadal działa bez problemu.

`Super + Print Screen` (lub _Trigger > Capture > Color_) zamienia kursor w kroplomierz. Kliknij cokolwiek na ekranie, a kolor wyląduje w schowku. Naciśnij skrót jeszcze raz, aby wycofać się bez wybierania.

## Transkodowanie przed udostępnieniem

Nagranie ekranu 4K albo surowy HEIC z telefonu jest często zbyt duże, aby po prostu je wysłać. `Super + Ctrl + .` (lub _Trigger > Transcode_) to naprawia. Oferuje rozmyty selektor plików po `~/Pictures` i `~/Videos`, a potem pyta o format i rozmiar.

Zdjęcia idą do jpg lub png w jakości wysokiej, średniej lub niskiej, które ograniczają szerokość do 3160, 2160 i 1080 pikseli. Wideo idzie do mp4 lub animowanego gif w 4k, 1080p lub 720p. Przekonwertowany plik jest zapisywany obok oryginału, z rozdzielczością w nazwie — `demo-1080p.mp4` — a ścieżka jest kopiowana do schowka jako URI pliku, więc możesz wkleić ją bezpośrednio do aplikacji przyjmującej upuszczanie plików.

Działa to też z terminala, jeśli już wiesz, czego chcesz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Jest też `omarchy transcode ascii`, które zamienia obraz w sztukę ASCII — to jest głównie do [brandingu](41-branding.md).

## Wysyłanie tego gdzieś

Gdy już masz plik, `Super + Ctrl + S` otwiera menu Share i wysyła go do innego urządzenia w twojej sieci przez LocalSend. Zobacz [GUIs](22-guis.md) w tej sprawie.
