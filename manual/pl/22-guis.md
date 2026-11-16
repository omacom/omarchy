# Aplikacje GUI

## Files

Files (Nautilus) to graficzny menedżer plików. `Super + Shift + F` go otwiera, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym znajduje się twój terminal, co oszczędza mnóstwo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku daje szybki podgląd bez otwierania czegokolwiek.

Podłącz pendrive USB lub kartę SD, a zostanie zamontowana automatycznie, więc po prostu pojawi się na pasku bocznym. Do wszystkiego bardziej zaawansowanego — formatowania dysku, sprawdzania stanu SMART, tworzenia partycji — uruchom _Disks_ z launchera aplikacji (`Super + Space`).

Dwukrotne kliknięcie działa według rozsądnych ustawień domyślnych: zdjęcia, filmy i muzyka otwierają się w Omaview, pliki PDF w Document Viewer, Markdown w Omawrite, a zwykły tekst w edytorze wybranym w _Setup > Default > Editor_.

## Disktree

Gdy dysk się zapełni, a ty nie masz pojęcia, co go zjada, uruchom [Disktree](https://github.com/tobi/disktree) z launchera aplikacji (`Super + Space`). Pokazuje graficzną mapę drzewa twojego katalogu domowego. Większe bloki zajmują więcej miejsca; poruszaj się po katalogach za pomocą klawiatury lub myszy, zaznacz, co ma zniknąć, i przejrzyj swój wybór przed usunięciem czegokolwiek. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) to darmowa i wysoce rozszerzalna aplikacja do robienia notatek, która do przechowywania używa prostych plików Markdown.

Obsidian jest darmowy do wszystkich celów, w tym do użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje również [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Android. (https://obsidian.md/pricing).

Obsidian uruchamiasz za pomocą `Super + Shift + O`. Aby korzystać z synchronizacji motywu, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) to własna, banalnie prosta aplikacja Omarchy do pisania w Markdown. Żadnych skarbców, żadnych wtyczek, tylko ty i słowa.

Omawrite uruchamiasz za pomocą `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) to podstawowe narzędzie do edycji obrazów, które świetnie sprawdza się przy przycinaniu, zmianie rozmiaru i innych podstawowych operacjach. Tylko nie oczekuj alternatywy dla Photoshopa. Ale i tak ma Magic Wand i warstwy!

Pintę uruchamiasz przez launcher aplikacji (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) to aplikacja do tworzenia motywów, która potrafi wyciągnąć kolory z obrazu tła i zamienić je w kompletny, spójny motyw. To najprostszy sposób, aby [stworzyć własny motyw](43-making-your-own-theme.md).

Aether uruchamiasz przez launcher aplikacji (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa aplikacja, jak AirDrop od Apple. Jest jednak wieloplatformowa, więc możesz wysyłać pliki do i z Windows, macOS, Android, iOS i oczywiście Linux.

Menu Share możesz otworzyć za pomocą `Super + Ctrl + S` lub w _Trigger > Share_ w menu Omarchy. Daje ci cztery opcje:

- **Clipboard** wysyła to, co skopiowałeś, jako plik tekstowy. Świetne, aby przenieść link lub fragment na telefon bez wysyłania sobie e-maila.
- **File** otwiera selektor plików, w którym możesz wybrać kilka naraz.
- **Folder** wysyła cały katalog.
- **Receive** otwiera właściwy LocalSend, aby inne urządzenie mogło coś do ciebie wysłać.

To samo działa z terminala za pomocą `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Pomiń ścieżkę, a otrzymasz selektor.

Możesz też wysyłać prosto z menedżera plików: kliknij prawym przyciskiem myszy dowolny wybór w Nautilus i wybierz _Send via LocalSend_.

Zapora Omarchy jest domyślnie zamknięta, z wyjątkiem portu LocalSend, więc działa to od razu po świeżej instalacji. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) to kompletny pakiet biurowy z procesorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest zgodny z plikami z Microsoft Office, więc to świetny sposób, aby móc otwierać te dokumenty Word.

LibreOffice uruchamiasz przez launcher aplikacji (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) to własna, banalnie prosta aplikacja Omarchy do prezentacji. Twoja prezentacja to pojedynczy plik Markdown z obrazami i filmami obok niego: piszesz każdy slajd pod podglądem na żywo, przeciągasz slajdy we właściwej kolejności, a potem prezentujesz na pełnym ekranie lub eksportujesz do PDF i PowerPoint. Podchwytuje nawet twój motyw Omarchy.

Hype uruchamiasz przez launcher aplikacji (`Super + Space`). Naciśnij `?` w aplikacji, aby zobaczyć każdy skrót.

## Signed

[Signed](https://github.com/omacom/signed) to własny, banalnie prosty sposób Omarchy na podpisywanie plików PDF i ich wypełnianie. Umieść zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu na stronie, a potem zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie plików PDF](27-filling-out-pdfs.md), aby dowiedzieć się, jak to zrobić.

Signed uruchamiasz przez launcher aplikacji (`Super + Space`) lub otwierasz w nim PDF z menedżera plików.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) to własna gra w szachy 3D Omarchy. Zagraj ze znajomym na tym samym komputerze lub z wbudowanym przeciwnikiem na trzech poziomach, na czterech wyrzeźbionych zestawach, z których każdy porusza się na swój własny sposób: statek orbitalny, rzeźbione drewno i kość słoniowa, leśne stworzenia i cukierki. Gry nie mają zegara i zapisują się po każdym ruchu.

Checkmate uruchamiasz przez launcher aplikacji (`Super + Space`). Naciśnij `?` w aplikacji, aby zobaczyć każdy skrót.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) to własny, banalnie prosty kalkulator Omarchy, który otwiera się w pływającym oknie.

Omacalc uruchamiasz za pomocą `Super + Shift + Q` (lub klawisza kalkulatora, jeśli twoja klawiatura taki ma).

## Signal

[Signal](https://signal.org/) to pionier szyfrowanej komunikacji E2E i świetna opcja komunikacyjna dla każdego, kto wolałby nie przechodzić przez jeden z wielkich konglomeratów technologicznych.

Signal uruchamiasz za pomocą `Super + Shift + G`. Nie jest częścią instalacji podstawowej, więc gdy naciśniesz to po raz pierwszy, Omarchy zaproponuje, że zainstaluje go za ciebie (jest też w _Install > Service_ w menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) to własna, banalnie prosta przeglądarka zdjęć i odtwarzacz multimediów Omarchy: jedno okno na twoje zdjęcia, filmy i muzykę. Otwórz zdjęcie, a klawisze strzałek przechodzą przez resztę jego folderu, `N` i `P` robią to dla wszystkiego, a `Ctrl + M` pokazuje cały folder jako siatkę. Pokazuje też zdjęcia HEIC, AVIF i JPEG XL i kontynuuje tam, gdzie skończyłeś, w przypadku wszystkiego długiego.

Naciśnij `F`, aby włączyć pełny ekran, `E`, aby edytować zdjęcie w Omasnap lub przyciąć film w Omacut, `Ctrl + P`, aby wydrukować zdjęcie, i `Delete`, aby przenieść plik do Kosza (`Ctrl + Z` go przywraca). Naciśnij `?` w aplikacji, aby zobaczyć każdy skrót.

Omaview uruchamiasz jako _Media Viewer_ przez launcher aplikacji (`Super + Space`) lub po prostu dwukrotnie klikasz zdjęcie, film lub piosenkę w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) to własny, banalnie prosty przycinacz wideo Omarchy. Gdy potrzebujesz tylko odciąć początek i koniec klipu, przebija odpalanie pełnego edytora wideo.

Omacut uruchamiasz przez launcher aplikacji (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) to własny, banalnie prosty rejestrator kamery internetowej Omarchy. Wybierz kamerę i mikrofon raz, a potem naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo ujęcie. Zawsze nagrywa w najwyższej rozdzielczości twojej kamery, z miernikiem mikrofonu na żywo, abyś mógł sprawdzić poziomy przed rozpoczęciem.

Zatrzymaj ujęcie, a otworzy się od razu we wbudowanym edytorze. Dwukrotnie kliknij klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń partie, których nie chcesz. Potem zapisz go jako MP4. Twoje oryginalne nagranie jest przechowywane, dopóki go nie odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Monologue uruchamiasz przez launcher aplikacji (`Super + Space`).
