# Aplikacje graficzne

## Pliki

Pliki (Nautilus) to graficzny menedżer plików. `Super + Shift + F` go otwiera, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym aktualnie znajduje się twój terminal, co oszczędza sporo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku pokazuje szybki podgląd bez otwierania czegokolwiek.

Podłącz pamięć USB lub kartę SD, a zostanie zamontowana automatycznie, więc po prostu pojawi się na pasku bocznym. Do bardziej zaawansowanych zadań — formatowania dysku, sprawdzania stanu SMART, tworzenia partycji — uruchom _Disks_ z launchera aplikacji (`Super + Space`).

Dwukrotne kliknięcie działa według rozsądnych ustawień domyślnych: zdjęcia, filmy i muzyka otwierają się w Omaview, pliki PDF w Document Viewer, Markdown w Omawrite, a zwykły tekst w edytorze wybranym w _Setup > Default > Editor_.

## Disktree

Gdy dysk się zapełni i nie masz pojęcia, co go zjada, uruchom [Disktree](https://github.com/tobi/disktree) z launchera aplikacji (`Super + Space`). Pokazuje graficzną treemapę twojego katalogu domowego. Większe bloki zajmują więcej miejsca; wchodź do katalogów za pomocą klawiatury lub myszy, zaznacz to, co ma zniknąć, i przejrzyj swój wybór przed usunięciem czegokolwiek. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) to darmowa i wysoce rozszerzalna aplikacja do robienia notatek, która do przechowywania używa prostych plików Markdown.

Obsidian jest darmowy do wszystkich celów, w tym do użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje również [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Android. (https://obsidian.md/pricing).

Obsidian uruchamiasz za pomocą `Super + Shift + O`. Aby korzystać z synchronizacji motywu, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) to własna, banalnie prosta aplikacja Omarchy do pisania w Markdown. Żadnych vaultów, żadnych wtyczek, tylko ty i słowa.

Omawrite uruchamiasz za pomocą `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) to podstawowe narzędzie do edycji obrazów, które świetnie sprawdza się do przycinania, zmiany rozmiaru i innych podstawowych operacji. Tylko nie oczekuj alternatywy dla Photoshopa. Ale i tak ma Magic Wand i warstwy!

Pintę uruchamiasz z launchera aplikacji (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) to aplikacja do tworzenia motywów, która potrafi wyodrębnić kolory z obrazu tła i zamienić je w kompletny, spójny motyw. To najprostszy sposób, aby [stworzyć własny motyw](43-making-your-own-theme.md).

Aether uruchamiasz z launchera aplikacji (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa ta aplikacja, jak AirDrop od Apple. Jest jednak wieloplatformowa, więc możesz wysyłać pliki do i z systemów Windows, macOS, Android, iOS i oczywiście Linux.

Menu Share możesz otworzyć za pomocą `Super + Ctrl + S` lub w menu Omarchy, w _Trigger > Share_. Daje ci cztery opcje:

- **Clipboard** wysyła wszystko, co skopiowałeś, jako plik tekstowy. Świetne, aby przenieść link lub fragment tekstu na telefon bez wysyłania sobie e-maila.
- **File** otwiera selektor plików, w którym możesz wybrać kilka naraz.
- **Folder** wysyła cały katalog.
- **Receive** otwiera właściwy LocalSend, aby inne urządzenie mogło coś do ciebie wysłać.

To samo działa z terminala za pomocą `omarchy share clipboard`, `omarchy share file [path]` oraz `omarchy share folder [path]`. Pomiń ścieżkę, a pojawi się selektor.

Możesz też wysyłać bezpośrednio z menedżera plików: kliknij prawym przyciskiem myszy dowolny wybór w Nautilus i wybierz _Send via LocalSend_.

Zapora sieciowa Omarchy jest domyślnie zamknięta, z wyjątkiem portu LocalSend, więc działa to od razu po świeżej instalacji. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) to kompletny pakiet biurowy z edytorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest zgodny z plikami z Microsoft Office, więc to świetny sposób na otwieranie tych dokumentów Worda.

LibreOffice uruchamiasz z launchera aplikacji (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) to własna, banalnie prosta aplikacja Omarchy do prezentacji. Twoja prezentacja to pojedynczy plik Markdown wraz ze znajdującymi się obok niego obrazami i filmami: pisz każdy slajd pod podglądem na żywo, przeciągaj slajdy, aby je uporządkować, a potem prezentuj na pełnym ekranie lub eksportuj do PDF i PowerPoint. Przejmuje nawet twój motyw Omarchy.

Hype uruchamiasz z launchera aplikacji (`Super + Space`). Naciśnij `?` wewnątrz aplikacji, aby zobaczyć wszystkie skróty.

## Signed

[Signed](https://github.com/omacom/signed) to własny, banalnie prosty sposób Omarchy na podpisywanie plików PDF i ich wypełnianie. Umieść zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu na stronie, a potem zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie plików PDF](27-filling-out-pdfs.md), aby dowiedzieć się, jak to zrobić.

Signed uruchamiasz z launchera aplikacji (`Super + Space`) lub otwierasz w nim plik PDF z menedżera plików.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) to własna gra szachowa 3D Omarchy. Zagraj ze znajomym na tym samym komputerze lub z wbudowanym przeciwnikiem na trzech poziomach, czterema rzeźbionymi zestawami figur, z których każdy porusza się na swój sposób: statkami orbitalnymi, rzeźbionym drewnem i kością słoniową, leśnymi stworzeniami i cukierkami. Partie nie mają zegara i są zapisywane po każdym ruchu.

Checkmate uruchamiasz z launchera aplikacji (`Super + Space`), gdzie jest wymieniony jako Chess. Naciśnij `?` wewnątrz aplikacji, aby zobaczyć wszystkie skróty.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) to własny, banalnie prosty kalkulator Omarchy, który otwiera się w pływającym oknie.

Omacalc uruchamiasz za pomocą `Super + Shift + Q` (lub klawisza kalkulatora, jeśli twoja klawiatura taki ma).

## Signal

[Signal](https://signal.org/) to pionier wiadomości szyfrowanych E2E i świetna opcja komunikacji dla każdego, kto wolałby nie korzystać z jednego z wielkich konglomeratów technologicznych.

Signal uruchamiasz za pomocą `Super + Shift + G`. Nie jest częścią instalacji podstawowej, więc gdy naciśniesz to po raz pierwszy, Omarchy zaproponuje zainstalowanie go za ciebie (znajduje się również w menu Omarchy, w _Install > Service_). 

## Omaview

[Omaview](https://github.com/omacom/omaview) to własna, banalnie prosta przeglądarka zdjęć i odtwarzacz multimediów Omarchy: jedno okno dla twoich zdjęć, filmów i muzyki. Otwórz zdjęcie, a klawisze strzałek będą przechodzić przez resztę jego folderu, `N` i `P` robią to dla wszystkiego, a `Ctrl + M` pokazuje cały folder jako siatkę. Wyświetla też zdjęcia HEIC, AVIF i JPEG XL oraz wznawia odtwarzanie długich materiałów w miejscu, w którym przerwałeś.

Naciśnij `F`, aby włączyć pełny ekran, `E`, aby edytować zdjęcie w Omasnap lub przyciąć film w Omacut, `Ctrl + P`, aby wydrukować zdjęcie, oraz `Delete`, aby przenieść plik do Kosza (`Ctrl + Z` go przywraca). Naciśnij `?` wewnątrz aplikacji, aby zobaczyć wszystkie skróty.

Omaview uruchamiasz jako _Media Viewer_ z launchera aplikacji (`Super + Space`) lub po prostu klikasz dwukrotnie zdjęcie, film lub piosenkę w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) to własne, banalnie proste narzędzie Omarchy do przycinania filmów. Gdy potrzebujesz tylko odciąć początek i koniec klipu, przebija uruchamianie pełnego edytora wideo.

Omacut uruchamiasz z launchera aplikacji (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) to własny, banalnie prosty rejestrator kamery internetowej Omarchy. Wybierz kamerę i mikrofon raz, a potem naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo nagranie. Zawsze nagrywa w najwyższej rozdzielczości twojej kamery, z miernikiem mikrofonu na żywo, abyś mógł sprawdzić poziomy przed rozpoczęciem.

Zatrzymaj nagranie, a otworzy się od razu we wbudowanym edytorze. Kliknij dwukrotnie klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń części, których nie chcesz. Następnie zapisz go jako MP4. Twoje oryginalne nagranie jest przechowywane, dopóki go nie odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Monologue uruchamiasz z launchera aplikacji (`Super + Space`).
