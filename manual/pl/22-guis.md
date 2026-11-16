# Aplikacje graficzne

## Pliki

Pliki (Nautilus) to graficzny menedżer plików. `Super + Shift + F` go otwiera, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym znajduje się twój terminal, co oszczędza mnóstwo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku daje szybki podgląd bez otwierania czegokolwiek.

Podłącz pendrive USB albo kartę SD, a zostanie zamontowana automatycznie, więc po prostu pojawi się na pasku bocznym. Do wszystkiego, co wymaga czegoś więcej — formatowania dysku, sprawdzania stanu SMART, tworzenia partycji — uruchom _Disks_ z launchera aplikacji (`Super + Space`).

Dwukrotne kliknięcie działa według rozsądnych ustawień domyślnych: zdjęcia, wideo i muzyka otwierają się w Omaview, pliki PDF w Document Viewer, Markdown w Omawrite, a zwykły tekst w edytorze wybranym w _Setup > Default > Editor_.

## Disktree

Gdy dysk się zapełni, a ty nie masz pojęcia, co go zjada, uruchom [Disktree](https://github.com/tobi/disktree) z launchera aplikacji (`Super + Space`). Pokazuje graficzną mapę drzewa twojego katalogu domowego. Większe bloki zajmują więcej miejsca; wchodź do katalogów za pomocą klawiatury lub myszy, zaznacz to, co ma zniknąć, i przejrzyj wybrane elementy, zanim cokolwiek usuniesz. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) to darmowa i wysoce rozszerzalna aplikacja do robienia notatek, która do przechowywania używa prostych plików Markdown.

Obsidian jest darmowy do wszystkich celów, w tym do użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje też [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Android. (https://obsidian.md/pricing).

Obsidian uruchamiasz za pomocą `Super + Shift + O`. Aby korzystać z synchronizacji motywów, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) to własna, śmiertelnie prosta aplikacja Omarchy do pisania w Markdown. Żadnych skarbców, żadnych wtyczek, tylko ty i słowa.

Omawrite uruchamiasz za pomocą `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) to podstawowe narzędzie do edycji obrazów, które świetnie sprawdza się przy przycinaniu, zmianie rozmiaru i innych podstawowych manipulacjach. Tylko nie oczekuj alternatywy dla Photoshopa. Ale Magic Wand i warstwy wciąż ma!

Pintę uruchamiasz przez launcher aplikacji (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) to aplikacja do motywów, która potrafi wyciągnąć kolory z obrazu tła i zamienić je w kompletny, spójny motyw. To najprostszy sposób, aby [stworzyć własny motyw](43-making-your-own-theme.md).

Aether uruchamiasz przez launcher aplikacji (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa ta aplikacja, jak AirDrop od Apple. Jest jednak wieloplatformowy, więc możesz wysyłać pliki do i z Windows, macOS, Android, iOS i oczywiście Linux.

Menu Share możesz otworzyć za pomocą `Super + Ctrl + S` albo w _Trigger > Share_ w menu Omarchy. Daje ci cztery opcje:

- **Clipboard** wysyła wszystko, co skopiowałeś, jako plik tekstowy. Świetne, aby przenieść link albo fragment na telefon bez wysyłania sobie e-maila.
- **File** otwiera wybór plików, w którym możesz wybrać kilka naraz.
- **Folder** wysyła cały katalog.
- **Receive** otwiera właściwy LocalSend, aby inne urządzenie mogło coś wysłać do ciebie.

To samo działa z terminala za pomocą `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Pomiń ścieżkę, a dostaniesz wybór plików.

Możesz też wysyłać wprost z menedżera plików: kliknij prawym przyciskiem dowolny wybór w Nautilus i wybierz _Send via LocalSend_.

Zapora Omarchy jest domyślnie zamknięta z wyjątkiem portu LocalSend, więc działa to od razu po świeżej instalacji. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) to kompletny pakiet biurowy z edytorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest zgodny z plikami z Microsoft Office, więc to świetny sposób, aby móc otwierać te dokumenty Worda.

LibreOffice uruchamiasz przez launcher aplikacji (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) to własna, śmiertelnie prosta aplikacja Omarchy do prezentacji. Twoja prezentacja to jeden plik Markdown z obrazami i wideo obok niego: pisz każdy slajd pod podglądem na żywo, przeciągaj slajdy we właściwej kolejności, a potem prezentuj na pełnym ekranie albo eksportuj do PDF i PowerPoint. Przeejmuje nawet twój motyw Omarchy.

Hype uruchamiasz przez launcher aplikacji (`Super + Space`). Naciśnij `?` w środku, aby zobaczyć każdy skrót.

## Signed

[Signed](https://github.com/omacom/signed) to własny, śmiertelnie prosty sposób Omarchy na podpisywanie plików PDF i ich wypełnianie. Umieść zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu strony, a potem zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie plików PDF](27-filling-out-pdfs.md), aby dowiedzieć się, jak to zrobić.

Signed uruchamiasz przez launcher aplikacji (`Super + Space`) albo otwierasz w nim plik PDF z menedżera plików.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) to własna gra w szachy 3D Omarchy. Graj ze znajomym na tym samym komputerze albo z wbudowanym przeciwnikiem na trzech poziomach, na czterech rzeźbionych zestawach, z których każdy porusza się na swój własny sposób: pojazdy orbitalne, rzeźbione drewno i kość słoniowa, leśne stworzenia oraz cukierki. Gry nie mają zegara i zapisują się po każdym ruchu.

Checkmate uruchamiasz przez launcher aplikacji (`Super + Space`), gdzie jest wymieniony jako Chess. Naciśnij `?` w środku, aby zobaczyć każdy skrót.

## Cards

[Cards](https://github.com/omacom/cards) to własny pasjans Klondike Omarchy. Dobieraj po trzy, bez limitu przejść, w czterech seriach kart: jednej narysowanej w kolorach twojego motywu i trzech o własnym wyglądzie. Kliknij kartę, a potem miejsce, dokąd ma trafić, przeciągnij ją albo kliknij dwukrotnie, aby wysłać ją w najlepsze miejsce. Gry zapisują się po każdym ruchu.

Cards uruchamiasz przez launcher aplikacji (`Super + Space`). Kliknij jego nazwę albo naciśnij `?`, aby zobaczyć każdy skrót.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) to własny, śmiertelnie prosty kalkulator Omarchy, który otwiera się w pływającym oknie.

Omacalc uruchamiasz za pomocą `Super + Shift + Q` (albo klawiszem kalkulatora, jeśli twoja klawiatura go ma).

## Signal

[Signal](https://signal.org/) to pionier komunikatorów z szyfrowaniem E2E i świetna opcja komunikacyjna dla każdego, kto wolałby nie przechodzić przez jeden z wielkich konglomeratów technologicznych.

Signal uruchamiasz za pomocą `Super + Shift + G`. Nie jest częścią podstawowej instalacji, więc gdy naciśniesz to po raz pierwszy, Omarchy zaproponuje, że zainstaluje go za ciebie (jest też w _Install > Service_ w menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) to własna, śmiertelnie prosta przeglądarka zdjęć i odtwarzacz multimediów Omarchy: jedno okno na zdjęcia, wideo i muzykę. Otwórz zdjęcie, a klawisze strzałek przechodzą przez resztę jego folderu, `N` i `P` robią to dla czegokolwiek, a `Ctrl + M` pokazuje cały folder jako siatkę. Pokazuje też zdjęcia HEIC, AVIF i JPEG XL i podejmuje od miejsca, w którym skończyłeś, w czymkolwiek długim.

Naciśnij `F`, aby włączyć pełny ekran, `E`, aby edytować zdjęcie w Omasnap albo przyciąć wideo w Omacut, `Ctrl + P`, aby wydrukować zdjęcie, i `Delete`, aby przenieść plik do Trash (`Ctrl + Z` go przywraca). Naciśnij `?` w środku, aby zobaczyć każdy skrót.

Omaview uruchamiasz jako _Media Viewer_ przez launcher aplikacji (`Super + Space`) albo po prostu klikasz dwukrotnie zdjęcie, wideo lub piosenkę w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) to własny, śmiertelnie prosty przycinacz wideo Omarchy. Gdy potrzebujesz tylko odciąć początek i koniec klipu, przebija odpalanie pełnego edytora wideo.

Omacut uruchamiasz przez launcher aplikacji (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) to własny, śmiertelnie prosty rejestrator kamery internetowej Omarchy. Wybierz kamerę i mikrofon raz, a potem naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo ujęcie. Zawsze nagrywa w najwyższej rozdzielczości twojej kamery, z miernikiem mikrofonu na żywo, abyś mógł sprawdzić poziomy, zanim zaczniesz.

Zatrzymaj ujęcie, a otworzy się od razu we wbudowanym edytorze. Kliknij dwukrotnie klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń części, których nie chcesz. Potem zapisz go jako MP4. Twoje oryginalne nagranie jest przechowywane, dopóki go nie odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Monologue uruchamiasz przez launcher aplikacji (`Super + Space`).
