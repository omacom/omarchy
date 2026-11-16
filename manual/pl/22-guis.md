# Aplikacje graficzne

## Files

Files (Nautilus) to graficzny menedżer plików. `Super + Shift + F` go otwiera, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym znajduje się twój terminal, co oszczędza mnóstwo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku daje szybki podgląd bez otwierania czegokolwiek.

Podłącz pamięć USB lub kartę SD, a zostanie zamontowana automatycznie, więc po prostu pojawi się na pasku bocznym. Do bardziej zaawansowanych zadań — formatowania dysku, sprawdzania kondycji SMART, tworzenia partycji — uruchom _Disks_ z programu uruchamiającego aplikacje (`Super + Space`).

Dwukrotne kliknięcie działa według sensownych ustawień domyślnych: zdjęcia, filmy i muzyka otwierają się w Omaview, pliki PDF w Document Viewer, Markdown w Omawrite, a zwykły tekst w edytorze wybranym w _Setup > Default > Editor_.

## Disktree

Gdy dysk się zapełni i nie masz pojęcia, co go zjada, uruchom [Disktree](https://github.com/tobi/disktree) z programu uruchamiającego aplikacje (`Super + Space`). Pokazuje graficzną mapę drzewa twojego katalogu domowego. Większe bloki zajmują więcej miejsca; poruszaj się po katalogach za pomocą klawiatury lub myszy, zaznacz to, co ma zostać usunięte, i przejrzyj wybrane elementy przed usunięciem czegokolwiek. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) to darmowa i wysoce rozszerzalna aplikacja do robienia notatek, która do przechowywania używa prostych plików Markdown.

Obsidian jest darmowy do wszystkich celów, w tym do użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje również [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Android. (https://obsidian.md/pricing).

Obsidian uruchamiasz za pomocą `Super + Shift + O`. Aby korzystać z synchronizacji motywu, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) to własna, banalnie prosta aplikacja Omarchy do pisania w Markdown. Żadnych skarbców, żadnych wtyczek, tylko ty i słowa.

Omawrite uruchamiasz za pomocą `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) to podstawowe narzędzie do edycji obrazów, które świetnie nadaje się do przycinania, zmiany rozmiaru i innych podstawowych operacji. Tylko nie oczekuj alternatywy dla Photoshopa. Ale nadal ma Magic Wand i warstwy!

Pintę uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) to aplikacja do tworzenia motywów, która potrafi wyodrębnić kolory z obrazu tła i zamienić je w kompletny, spójny motyw. To najłatwiejszy sposób, aby [stworzyć własny motyw](43-making-your-own-theme.md).

Aether uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa ta aplikacja, podobnie jak AirDrop od Apple. Jest jednak wieloplatformowa, więc możesz wysyłać pliki do i z Windows, macOS, Android, iOS i oczywiście Linux.

Menu udostępniania możesz otworzyć za pomocą `Super + Ctrl + S` lub w _Trigger > Share_ w menu Omarchy. Daje ci cztery opcje:

- **Clipboard** wysyła wszystko, co skopiowałeś, jako plik tekstowy. Świetne, aby przesłać link lub fragment kodu na telefon bez wysyłania sobie e-maila.
- **File** otwiera selektor plików, w którym możesz wybrać kilka naraz.
- **Folder** wysyła cały katalog.
- **Receive** otwiera właściwy LocalSend, aby inne urządzenie mogło wysłać coś do ciebie.

To samo działa z terminala za pomocą `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Pomiń ścieżkę, a pojawi się selektor.

Możesz też wysyłać bezpośrednio z menedżera plików: kliknij prawym przyciskiem myszy dowolny wybór w Nautilus i wybierz _Send via LocalSend_.

Zapora sieciowa Omarchy jest domyślnie zamknięta, z wyjątkiem portu LocalSend, więc działa to od razu po świeżej instalacji. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) to kompletny pakiet biurowy z edytorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest zgodny z plikami z Microsoft Office, więc to świetny sposób, aby móc otwierać te dokumenty Word.

LibreOffice uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) to własna, banalnie prosta aplikacja Omarchy do prezentacji. Twoja prezentacja to jeden plik Markdown wraz ze znajdującymi się obok niego obrazami i filmami: pisz każdy slajd pod podglądem na żywo, przeciągaj slajdy, aby ustalić ich kolejność, a następnie prezentuj na pełnym ekranie lub eksportuj do PDF i PowerPoint. Wybiera nawet twój motyw Omarchy.

Hype uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`). Naciśnij `?` wewnątrz, aby zobaczyć każdy skrót.

## Signed

[Signed](https://github.com/omacom/signed) to własny, banalnie prosty sposób Omarchy na podpisywanie plików PDF i ich wypełnianie. Umieść zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu na stronie, a następnie zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie plików PDF](27-filling-out-pdfs.md), aby dowiedzieć się, jak to zrobić.

Signed uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`) lub otwierasz w nim plik PDF z menedżera plików.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) to własny, banalnie prosty kalkulator Omarchy, który otwiera się w pływającym oknie.

Omacalc uruchamiasz za pomocą `Super + Shift + Q` (lub klawisza kalkulatora, jeśli twoja klawiatura taki ma).

## Signal

[Signal](https://signal.org/) to pionier szyfrowanej komunikacji E2E i świetna opcja komunikacyjna dla każdego, kto wolałby nie korzystać z jednego z wielkich konglomeratów technologicznych.

Signal uruchamiasz za pomocą `Super + Shift + G`. Nie jest częścią instalacji podstawowej, więc gdy naciśniesz to po raz pierwszy, Omarchy zaproponuje zainstalowanie go za ciebie (jest też w _Install > Service_ w menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) to własna, banalnie prosta przeglądarka obrazów i odtwarzacz multimediów Omarchy: jedno okno dla twoich zdjęć, filmów i muzyki. Otwórz zdjęcie, a klawisze strzałek będą przechodzić przez resztę jego folderu, `N` i `P` robią to dla wszystkiego, a `Ctrl + M` pokazuje cały folder jako siatkę. Pokazuje też zdjęcia HEIC, AVIF i JPEG XL i wznawia odtwarzanie wszystkiego, co długie, w miejscu, w którym je przerwałeś.

Naciśnij `F`, aby włączyć pełny ekran, `E`, aby edytować zdjęcie w Omasnap lub przyciąć film w Omacut, `Ctrl + P`, aby wydrukować zdjęcie, i `Delete`, aby przenieść plik do Kosza (`Ctrl + Z` przywraca go). Naciśnij `?` wewnątrz, aby zobaczyć każdy skrót.

Omaview uruchamiasz jako _Media Viewer_ za pomocą programu uruchamiającego aplikacje (`Super + Space`) lub po prostu klikasz dwukrotnie zdjęcie, film lub piosenkę w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) to własny, banalnie prosty program Omarchy do przycinania wideo. Gdy potrzebujesz tylko odciąć początek i koniec klipu, przebija uruchamianie pełnego edytora wideo.

Omacut uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) to własna, banalnie prosta nagrywarka kamery internetowej Omarchy. Wybierz kamerę i mikrofon raz, a następnie naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo nagranie. Zawsze nagrywa w najwyższej rozdzielczości twojej kamery, z miernikiem mikrofonu na żywo, dzięki czemu możesz sprawdzić poziomy przed rozpoczęciem.

Zatrzymaj nagranie, a otworzy się od razu we wbudowanym edytorze. Kliknij dwukrotnie klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń części, których nie chcesz. Następnie zapisz go jako MP4. Twoje oryginalne nagranie jest przechowywane, dopóki go nie odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Monologue uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).
