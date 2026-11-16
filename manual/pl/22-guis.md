# Aplikacje graficzne

## Files

Files (Nautilus) to graficzny menedżer plików. `Super + Shift + F` go otwiera, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym znajduje się twój terminal, co oszczędza sporo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku daje ci szybki podgląd bez otwierania czegokolwiek.

Podłącz pamięć USB lub kartę SD, a zostanie zamontowana automatycznie, więc po prostu pojawi się na pasku bocznym. Do bardziej zaawansowanych rzeczy — formatowania dysku, sprawdzania stanu SMART, tworzenia partycji — uruchom _Disks_ z programu do uruchamiania aplikacji (`Super + Space`).

Dwukrotne kliknięcie działa według rozsądnych ustawień domyślnych: zdjęcia, filmy i muzyka otwierają się w Omaview, pliki PDF w Document Viewer, a zwykły tekst w Neovim.

## Disktree

Gdy dysk się zapełni i nie masz pojęcia, co go zjada, uruchom [Disktree](https://github.com/tobi/disktree) z programu do uruchamiania aplikacji (`Super + Space`). Pokazuje graficzną mapę drzewa twojego katalogu domowego. Większe bloki zajmują więcej miejsca; wchodź do katalogów za pomocą klawiatury lub myszy, oznacz to, co ma zostać usunięte, i przejrzyj swoje wybory przed usunięciem czegokolwiek. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) to darmowa i wysoce rozszerzalna aplikacja do robienia notatek, która do przechowywania używa prostych plików Markdown.

Obsidian jest darmowy do wszystkich celów, w tym do użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje również [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Androida. (https://obsidian.md/pricing).

Obsidian uruchamiasz za pomocą `Super + Shift + O`. Aby korzystać z synchronizacji motywu, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) to własna, banalnie prosta aplikacja Omarchy do pisania w Markdown. Żadnych magazynów, żadnych wtyczek, tylko ty i słowa.

Omawrite uruchamiasz za pomocą `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) to podstawowe narzędzie do edycji obrazów, świetne do przycinania, zmiany rozmiaru i innych podstawowych operacji. Tylko nie oczekuj alternatywy dla Photoshopa. Ale nadal ma Magic Wand i warstwy!

Pintę uruchamiasz za pomocą programu do uruchamiania aplikacji (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) to aplikacja do tworzenia motywów, która potrafi wyodrębnić kolory z obrazu tła i zamienić je w kompletny, spójny motyw. To najprostszy sposób, aby [stworzyć własny motyw](43-making-your-own-theme.md).

Aether uruchamiasz za pomocą programu do uruchamiania aplikacji (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa ta aplikacja, jak AirDrop od Apple. Jest jednak wieloplatformowy, więc możesz wysyłać pliki do i z systemów Windows, macOS, Android, iOS i oczywiście Linux.

Menu udostępniania możesz otworzyć za pomocą `Super + Ctrl + S` lub w menu Omarchy w sekcji _Trigger > Share_. Daje ci cztery opcje:

- **Clipboard** wysyła wszystko, co skopiowałeś, jako plik tekstowy. Świetne, aby przesłać link lub fragment na telefon bez wysyłania sobie e-maila.
- **File** otwiera selektor plików, w którym możesz wybrać kilka naraz.
- **Folder** wysyła cały katalog.
- **Receive** otwiera właściwy LocalSend, aby inne urządzenie mogło coś do ciebie wysłać.

To samo działa z terminala za pomocą `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Pomiń ścieżkę, a otrzymasz selektor.

Możesz też wysyłać bezpośrednio z menedżera plików: kliknij prawym przyciskiem myszy dowolny wybór w Nautilus i wybierz _Send via LocalSend_.

Zapora sieciowa Omarchy jest domyślnie zamknięta, z wyjątkiem portu LocalSend, więc działa to od razu po świeżej instalacji. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) to kompletny pakiet biurowy z edytorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest zgodny z plikami z Microsoft Office, więc to świetny sposób, aby móc otwierać te dokumenty Worda.

LibreOffice uruchamiasz za pomocą programu do uruchamiania aplikacji (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) to własna, banalnie prosta aplikacja Omarchy do prezentacji. Twoja prezentacja to pojedynczy plik Markdown wraz ze znajdującymi się obok niego obrazami i filmami: pisz każdy slajd pod podglądem na żywo, przeciągaj slajdy, aby ustawić ich kolejność, a następnie prezentuj na pełnym ekranie lub eksportuj do PDF i PowerPoint. Przejmuje nawet twój motyw Omarchy.

Hype uruchamiasz za pomocą programu do uruchamiania aplikacji (`Super + Space`). Naciśnij `?` wewnątrz aplikacji, aby zobaczyć wszystkie skróty.

## Signed

[Signed](https://github.com/omacom/signed) to własny, banalnie prosty sposób Omarchy na podpisywanie plików PDF i ich wypełnianie. Umieść zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu na stronie, a następnie zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie plików PDF](27-filling-out-pdfs.md), aby dowiedzieć się, jak to zrobić.

Signed uruchamiasz za pomocą programu do uruchamiania aplikacji (`Super + Space`) lub otwierasz w nim plik PDF z menedżera plików.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) to własny, banalnie prosty kalkulator Omarchy, który otwiera się w pływającym oknie.

Omacalc uruchamiasz za pomocą `Super + Shift + Q` (lub klawisza kalkulatora, jeśli twoja klawiatura takowy ma).

## Signal

[Signal](https://signal.org/) jest pionierem komunikacji szyfrowanej E2E i świetną opcją komunikacyjną dla każdego, kto wolałby nie korzystać z pośrednictwa jednego z wielkich konglomeratów technologicznych.

Signal uruchamiasz za pomocą `Super + Shift + G`. Nie jest częścią podstawowej instalacji, więc gdy naciśniesz to po raz pierwszy, Omarchy zaproponuje zainstalowanie go za ciebie (znajduje się również w menu Omarchy w sekcji _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) to własna, banalnie prosta przeglądarka obrazów i odtwarzacz multimediów Omarchy: jedno okno dla twoich zdjęć, filmów i muzyki. Otwórz zdjęcie, a klawisze strzałek będą przechodzić przez resztę jego folderu, `N` i `P` robią to dla wszystkiego, a `Ctrl + M` pokazuje cały folder jako siatkę. Pokazuje też zdjęcia HEIC, AVIF i JPEG XL oraz wznawia odtwarzanie długich materiałów w miejscu, w którym je przerwałeś.

Naciśnij `F`, aby włączyć pełny ekran, `E`, aby edytować zdjęcie w Omasnap lub przyciąć film w Omacut, `Ctrl + P`, aby wydrukować zdjęcie, oraz `Delete`, aby przenieść plik do Kosza (`Ctrl + Z` go przywraca). Naciśnij `?` wewnątrz aplikacji, aby zobaczyć wszystkie skróty.

Omaview uruchamiasz jako _Media Viewer_ za pomocą programu do uruchamiania aplikacji (`Super + Space`) lub po prostu klikając dwukrotnie zdjęcie, film lub utwór w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) to własny, banalnie prosty przycinacz wideo Omarchy. Gdy potrzebujesz jedynie odciąć początek i koniec klipu, przebija odpalanie pełnego edytora wideo.

Omacut uruchamiasz za pomocą programu do uruchamiania aplikacji (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) to własny, banalnie prosty rejestrator kamery internetowej Omarchy. Wybierz raz kamerę i mikrofon, a następnie naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo ujęcie. Zawsze nagrywa w najwyższej rozdzielczości twojej kamery, z miernikiem mikrofonu na żywo, dzięki czemu możesz sprawdzić poziomy przed rozpoczęciem.

Zatrzymaj ujęcie, a otworzy się od razu we wbudowanym edytorze. Kliknij dwukrotnie klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń partie, których nie chcesz. Następnie zapisz go jako MP4. Twoje oryginalne nagranie jest przechowywane, dopóki go nie odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Monologue uruchamiasz za pomocą programu do uruchamiania aplikacji (`Super + Space`).
