# Zrzuty ekranu i nagrywanie

Wszystko, co możesz przechwycić z ekranu, wisi na klawiszu Print Screen. Sam klawisz robi zdjęcie, a modyfikatory robią nagranie, pobierają kolor albo wydobywają tekst z wnętrza regionu. Jeśli twoja klawiatura w ogóle nie ma klawisza Print Screen, `Super + Ctrl + Alt + C` robi ten sam zrzut ekranu, a `Super + Ctrl + C` otwiera cały zestaw jako menu.

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

Naciśnij `Print Screen` (albo `Super + Ctrl + Alt + C`), a Omasnap przechwyci aktywny monitor, zanim pojawi się jego nakładka, więc nic nie przesunie się pod tobą, gdy celujesz. Przeciągnij dowolny region, kliknij okno, aby je przechwycić, albo kliknij pustą przestrzeń, aby przechwycić cały monitor. Naciśnij `S` przed rysowaniem, aby przechwycić region przewijany. Zmieniłeś zdanie? Naciśnij ten sam klawisz ponownie, aby zamknąć Omasnap.

Po wybraniu obszaru Omasnap zapisuje przechwycony obraz, kopiuje go do schowka i pokazuje powiadomienie z jego miniaturą, tak jak dzieje się przy zapisanym nagraniu ekranu. Wybierz Open, aby obejrzeć zapisany zrzut w przeglądarce obrazów, albo Edit, aby dodać do niego adnotacje.

Edytor adnotacji potrafi rysować strzałki, linie, kształty, wyróżnienia, numerowane znaczniki i tekst oraz trwale zakrywać wrażliwe fragmenty; przycinać obraz albo wycinać jego część; rozpoznawać jego tekst za pomocą OCR; oraz dodawać tło. W edytorze naciśnij `Enter`, aby skopiować i zapisać gotowy plik PNG, `Ctrl + C`, aby skopiować go bez zapisywania, albo `Ctrl + S`, aby zapisać go bez kopiowania.

Zapisane zrzuty ekranu trafiają domyślnie do `~/Pictures/Screenshots`, pod nazwą taką jak `screenshot-2026-08-13_14-22-05-firefox.png`. Ustaw `OMASNAP_SCREENSHOT_DIR`, aby użyć innego katalogu — zobacz [FAQ](46-faq.md), aby dowiedzieć się, gdzie umieszczać zmienne środowiskowe sesji. Omasnap tworzy ten katalog, gdy zapisuje pierwszy zrzut. Ustaw `[output] autosave = false` w `~/.config/omasnap/omasnap.conf`, aby wyłączyć automatyczne zapisywanie; przechwycone obrazy są wtedy tylko kopiowane i pokazywane przez 10 sekund w podglądzie, który możesz utrzymać na ekranie za pomocą jego przycisku przypinania albo `Ctrl + P`.

Z terminala `omarchy screenshot` otwiera tę samą nakładkę, a jej tryb początkowy możesz wybrać: `omarchy capture screenshot region`, `windows`, `fullscreen` albo `scroll`. Drugi argument `copy` albo `save` wysyła zrzut od razu do tego miejsca docelowego. Aby edytować przed wysłaniem, użyj `omarchy screenshot --editor=overlay` dla edytora pełnoekranowego albo `omarchy screenshot --editor=window` dla osobnego okna.

### Obsługa selektora z klawiatury

Gdy zaznaczenie jest otwarte, w ogóle nie musisz używać myszy:

| Klawisz | Funkcja |
| --- | -------- |
| `S` | Przełączenie trybu regionu przewijanego |
| `Super + Arrow keys` | Poruszanie się między oknami w trybie Window |
| `Return` | Przechwycenie podświetlonego okna |
| `Ctrl + A` | Przechwycenie całego aktywnego monitora |
| `R` | Przywrócenie ostatniego regionu narysowanego w tej sesji |
| `Esc` | Zamknięcie Omasnap |

Te skróty istnieją tylko, gdy Omasnap jest otwarty, więc nie mogą kolidować z niczym w twojej własnej konfiguracji.

## Nagrywanie ekranu

`Alt + Print Screen` otwiera _Trigger > Capture > Screenrecord_, który pyta, co chcesz mieć na ścieżce dźwiękowej: brak dźwięku, dźwięk pulpitu, dźwięk pulpitu plus mikrofon albo dźwięk pulpitu plus mikrofon plus kamerę internetową. Ta ostatnia opcja pojawia się tylko, jeśli faktycznie masz podłączoną kamerę. Wybierz jedną, a selektor nagrywania Omarchy pozwoli ci przeciągnąć region albo kliknąć okno lub monitor.

Nagrywanie działa na gpu-screen-recorder, który koduje na GPU przy 60fps i w razie potrzeby przechodzi na CPU. Efekt to plik MP4 w `~/Videos`, o nazwie `screenrecording-2026-08-13_14-22-05.mp4`. Ustaw `OMARCHY_SCREENRECORD_DIR`, aby to zmienić — ale pamiętaj, że w przeciwieństwie do katalogu zrzutów ekranu ten musi już istnieć, inaczej nagrywanie odmówi rozpoczęcia.

Podczas nagrywania na pasku pojawia się mały wskaźnik. Kliknij go, aby zatrzymać. Możesz też zatrzymać za pomocą `Alt + Print Screen` ponownie albo wpisu _Stop Screenrecording_ w _Trigger > Capture > Screenrecord_, który pojawia się tylko, gdy coś faktycznie się nagrywa.

Zatrzymanie robi trochę porządków, zanim odda ci plik: pierwsza klatka jest przycinana, a jeśli jest dźwięk, jest on normalizowany do -14 LUFS, z wyciszonym trzaskiem przechwytywania PipeWire na samym początku. Potem pojawia się powiadomienie z miniaturą z nagrania. Kliknij je, aby odtworzyć plik w Omaview.

### Nakładka kamery internetowej

Gdy nagrywasz z kamerą internetową, obraz z kamery pojawia się jako przypięte, przycięte okno w orientacji pionowej w prawym dolnym rogu tego, co nagrywasz. Jeśli leży na czymś, czego potrzebujesz, zmień jego rozmiar w locie:

| Skrót klawiszowy | Funkcja |
| ------ | -------- |
| `Super + Alt + [` | Zmniejszenie nakładki kamery internetowej |
| `Super + Alt + ]` | Powiększenie nakładki kamery internetowej |

Są trzy rozmiary — mały, średni i duży — a skróty klawiszowe przechodzą między nimi. Średni jest domyślny. Są one proporcjonalne do nagrania, więc kamera zajmuje tę samą część klatki, niezależnie od tego, czy nagrywasz monitor 1080p, czy 6K. A jeśli nagrałeś region zamiast całego ekranu, nakładka kotwiczy się do rogu tego regionu zamiast monitora, więc zostaje wewnątrz ujęcia.

Możesz też wywołać to bezpośrednio za pomocą `omarchy-capture-webcam-resize small` albo `reset`, aby wrócić do rozmiaru średniego.

## Tekst, kody QR i kolory

`Super + Ctrl + Print Screen` zaznacza region i rozpoznaje jego tekst za pomocą OCR do schowka. Jest to porządnie omówione w [Wyodrębnianie tekstu i dyktowanie](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ robi tę samą sztuczkę dla kodów QR. Zaznacz region z kodem, a zdekodowana wartość trafi do schowka. Szuka wyłącznie kodów QR — gęsta treść ekranu ma w przeciwnym razie zwyczaj fałszywie wychodzić jako kod kreskowy. Warto wiedzieć: zdekodowana wartość trafia do schowka i nigdzie indziej. Nie jest wypisywana, nie ma jej w powiadomieniu i jest oznaczona jako wrażliwa, więc nie zostaje w [historii schowka](08-unified-clipboard-history.md). Kody QR rutynowo niosą sekrety — na przykład URI `otpauth://` kryjący się za kodem konfiguracji 2FA — a tego nie chcesz mieć w logu. Wklejanie nadal działa bez problemu.

`Super + Print Screen` (albo _Trigger > Capture > Color_) zmienia kursor w pipetę. Kliknij cokolwiek na ekranie, a kolor trafi do schowka. Naciśnij skrót ponownie, aby wycofać się bez wybierania.

## Transkodowanie, zanim udostępnisz

Nagranie ekranu 4K albo surowy plik HEIC z telefonu jest często zbyt duży, aby po prostu go wysłać. `Super + Ctrl + .` (albo _Trigger > Transcode_) to naprawia. Udostępnia selektor plików z wyszukiwaniem rozmytym dla `~/Pictures` i `~/Videos`, a następnie pyta o format i rozmiar.

Obrazy trafiają do formatu jpg albo png w jakości wysokiej, średniej albo niskiej, które ograniczają szerokość odpowiednio do 3160, 2160 i 1080 pikseli. Wideo trafia do formatu mp4 albo animowanego gif w rozdzielczości 4k, 1080p albo 720p. Przekonwertowany plik jest zapisywany obok oryginału, z rozdzielczością w nazwie — `demo-1080p.mp4` — a ścieżka jest kopiowana do schowka jako URI pliku, więc możesz wkleić ją bezpośrednio do aplikacji przyjmującej upuszczane pliki.

Działa to także z terminala, jeśli już wiesz, czego chcesz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Jest też `omarchy transcode ascii`, które zamienia obraz w grafikę ASCII — to służy głównie do [brandingu](41-branding.md).

## Wysyłanie gdzieś

Gdy już masz plik, `Super + Ctrl + S` otwiera menu Share i wysyła go do innego urządzenia w twojej sieci przez LocalSend. Zobacz [GUIs](22-guis.md), aby dowiedzieć się więcej.
