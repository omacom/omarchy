# Zrzuty ekranu i nagrywanie

Wszystko, co da się zgarnąć z ekranu, wisi na klawiszu Print Screen. Sam klawisz robi zrzut, a modyfikatory robią nagranie, pobierają kolor albo tekst wewnątrz obszaru. Jeśli twoja klawiatura w ogóle nie ma klawisza Print Screen, `Super + Ctrl + C` otwiera ten sam zestaw jako menu.

| Skrót | Funkcja |
| ------ | -------- |
| `Print Screen` | Zrzut ekranu |
| `Alt + Print Screen` | Nagrywanie ekranu (albo zatrzymanie trwającego) |
| `Super + Print Screen` | Wybór koloru |
| `Super + Ctrl + Print Screen` | Wyciąganie tekstu z obszaru |
| `Super + Ctrl + C` | Menu przechwytywania |
| `Super + Ctrl + .` | Transkodowanie obrazu lub wideo |

## Zrzuty ekranu

Naciśnij `Print Screen`, a Omasnap przechwytuje skupiony monitor, zanim pojawi się jego nakładka, więc nic nie przesuwa się pod tobą, gdy celujesz. Przeciągnij dowolny obszar, kliknij okno, żeby je przechwycić, albo kliknij otwartą przestrzeń, żeby przechwycić cały monitor. Naciśnij `S` przed rysowaniem, żeby przechwycić przewijany obszar. Zmieniłeś zdanie? Naciśnij `Print Screen` ponownie, żeby odrzucić Omasnap.

Po wybraniu obszaru Omasnap zapisuje zrzut, kopiuje go do schowka i pokazuje podgląd na 10 sekund. Użyj przycisku przypinania podglądu lub `Ctrl + P`, żeby trzymać go na ekranie, albo wybierz Edit, żeby go opatrzeć adnotacjami.

Edytor adnotacji może rysować strzałki, linie, kształty, podświetlenia, numerowane znaczniki, tekst oraz bezpieczne anonimizacje; przycinać lub wycinać część obrazu; OCR-ować jego tekst; oraz dodawać tło. W edytorze naciśnij `Enter`, żeby skopiować i zapisać gotowy PNG, `Ctrl + C`, żeby skopiować bez zapisywania, albo `Ctrl + S`, żeby zapisać bez kopiowania.

Zapisane zrzuty ekranu trafiają domyślnie do `~/Pictures/Screenshots`, z nazwą taką jak `screenshot-2026-08-13_14-22-05-firefox.png`. Ustaw `OMASNAP_SCREENSHOT_DIR`, żeby użyć innego katalogu — zob. [FAQ](46-faq.md), gdzie umieszczać zmienne środowiskowe sesji. Omasnap tworzy katalog, gdy zapisuje pierwszy zrzut. Ustaw `[output] autosave = false` w `~/.config/omasnap/omasnap.conf`, żeby wyłączyć automatyczne zapisywanie.

Z terminala `omarchy screenshot` otwiera tę samą nakładkę i możesz wybrać jej tryb startowy: `omarchy capture screenshot region`, `windows`, `fullscreen` albo `scroll`. Drugi argument `copy` lub `save` pomija podgląd i wysyła zrzut prosto do tego miejsca. Aby edytować przed wyjściem, użyj `omarchy screenshot --editor=overlay` dla edytora pełnoekranowego albo `omarchy screenshot --editor=window` dla osobnego okna.

### Sterowanie selektorem z klawiatury

Gdy wybór jest aktywny, wcale nie musisz używać myszy:

| Klawisz | Funkcja |
| --- | -------- |
| `S` | Przewijany tryb obszaru |
| `Super + Arrow keys` | Poruszanie się między oknami w trybie okna |
| `Return` | Przechwycenie podświetlonego okna |
| `Ctrl + A` | Przechwycenie pełnego skupionego monitora |
| `R` | Przywrócenie ostatniego obszaru narysowanego w tej sesji |
| `Esc` | Odrzucenie Omasnap |

Przypisania te istnieją tylko, gdy Omasnap jest otwarty, więc nie mogą kolidować z niczym w twojej własnej konfiguracji.

## Nagrywanie ekranu

`Alt + Print Screen` otwiera _Akcje > Przechwyć > Nagraj ekran_, który pyta, co ma trafić na ścieżkę dźwiękową: brak dźwięku, dźwięk pulpitu, dźwięk pulpitu z mikrofonem albo dźwięk pulpitu z mikrofonem i kamerą internetową. Ta ostatnia opcja pokazuje się tylko, gdy faktycznie masz podłączoną kamerę. Wybierasz jedną, a selektor nagrywania Omarchy pozwala ci przeciągnąć obszar albo kliknąć okno lub monitor.

Nagrywanie działa na gpu-screen-recorder, który koduje na GPU w 60 fps i w razie potrzeby wraca do CPU. Wynikiem jest MP4 w `~/Videos`, o nazwie `screenrecording-2026-08-13_14-22-05.mp4`. Ustaw `OMARCHY_SCREENRECORD_DIR`, żeby to zmienić — ale zwróć uwagę, że w przeciwieństwie do katalogu zrzutów ekranu ten katalog musi już istnieć, inaczej nagrywanie nie wystartuje.

Gdy nagrywasz, na pasku pojawia się mały wskaźnik. Kliknij go, żeby zatrzymać. Możesz też zatrzymać przez ponowne `Alt + Print Screen` albo przez wpis _Zatrzymaj nagrywanie_ pod _Akcje > Przechwyć > Nagraj ekran_, który pojawia się tylko, gdy coś faktycznie się nagrywa.

Zatrzymanie robi trochę porządków, zanim wręczy ci plik: pierwsza klatka jest przycinana, a jeśli jest dźwięk, jest on normalizowany do -14 LUFS z wyciszonym trzaskiem przechwytywania PipeWire na samym początku. Potem pojawia się powiadomienie z miniaturą z nagrania. Kliknij je, żeby odtworzyć plik w mpv.

### Nakładka kamery internetowej

Gdy nagrywasz z kamerą internetową, kamera pojawia się jako przypięte, przycięte okno portretowe w prawym dolnym rogu tego, co nagrywasz. Jeśli siedzi na czymś, czego potrzebujesz, zmień jej rozmiar w locie:

| Skrót | Funkcja |
| ------ | -------- |
| `Super + Alt + [` | Zmniejszenie nakładki kamery internetowej |
| `Super + Alt + ]` | Powiększenie nakładki kamery internetowej |

Są trzy rozmiary — mały, średni i duży — a skróty przechodzą między nimi. Średni jest domyślny. Są proporcjonalne do nagrania, więc kamera zajmuje ten sam udział klatki, czy nagrywasz monitor 1080p, czy 6K. A jeśli nagrałeś obszar, a nie cały ekran, nakładka kotwiczy się w rogu tego obszaru, a nie monitora, więc pozostaje wewnątrz ujęcia.

Możesz też wywołać ją bezpośrednio przez `omarchy-capture-webcam-resize small` albo `reset`, żeby wrócić do średniego.

## Tekst, kody QR i kolory

`Super + Ctrl + Print Screen` wybiera obszar i OCR-uje go do schowka. Jest to porządnie opisane w [Wyciąganie tekstu i dyktowanie](11-text-extraction-dictation.md).

_Akcje > Przechwyć > Kod QR_ robi tę samą sztukę dla kodów QR. Wybierasz obszar z kodem, a zdekodowana wartość trafia do schowka. Szuka tylko kodów QR — gęsta treść ekranu ma w zwyczaju inaczej fałszywie udawać kod kreskowy. Warto wiedzieć: zdekodowana wartość trafia do schowka i nigdzie indziej. Nie jest drukowana, nie ma jej w powiadomieniu i jest oznaczona jako wrażliwa, więc nie zostaje w [historii schowka](08-unified-clipboard-history.md). Kody QR rutynowo niosą tajemnice — na przykład URI `otpauth://` za kodem 2FA — a nie chcesz tego w logu. Wklejanie działa normalnie.

`Super + Print Screen` (albo _Akcje > Przechwyć > Kolor_) zmienia kursor w kroplomierz. Kliknij cokolwiek na ekranie, a kolor trafi do schowka. Naciśnij skrót ponownie, żeby się wycofać bez wybierania.

## Transkodowanie przed udostępnieniem

Nagranie ekranu 4K albo surowy HEIC z telefonu często jest za duży, żeby po prostu go wysłać. `Super + Ctrl + .` (albo _Akcje > Transkoduj_) to naprawia. Oferuje ci rozmyty wybór plików w `~/Pictures` i `~/Videos`, a potem pyta o format i rozmiar.

Obrazy trafiają do jpg lub png w wariancie wysokim, średnim albo niskim, które ograniczają szerokość odpowiednio do 3160, 2160 i 1080 pikseli. Wideo trafiają do mp4 albo animowanego gifa w rozdzielczości 4k, 1080p albo 720p. Skonwertowany plik jest zapisywany obok oryginału z rozdzielczością w nazwie — `demo-1080p.mp4` — a ścieżka jest kopiowana do schowka jako file URI, więc możesz wkleić ją bezpośrednio do aplikacji przyjmującej przeciągane pliki.

Działa też z terminala, jeśli już wiesz, czego chcesz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Jest też `omarchy transcode ascii`, które zmienia obraz w sztukę ASCII — służy głównie do [brandingu](41-branding.md).

## Wysyłanie gdzieś dalej

Gdy masz już plik, `Super + Ctrl + S` otwiera menu Udostępnij i wysyła go na inne urządzenie w twojej sieci przez LocalSend. Zob. [GUIs](22-guis.md) w tej sprawie.
