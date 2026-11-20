# Aplikacje graficzne

## Files

Files (Folio) to graficzny menedżer plików. `Super + Shift + F` go otwiera, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym znajduje się Twój terminal, co oszczędza sporo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku podgląda go w pełnym rozmiarze bez otwierania go.

Podłącz pamięć USB lub kartę SD, a zostanie zamontowana automatycznie, więc po prostu pojawi się na pasku bocznym. Do wszystkiego bardziej zaawansowanego — formatowania dysku, sprawdzania stanu SMART, tworzenia partycji — uruchom _Disks_ z programu uruchamiającego aplikacje (`Super + Space`).

Dwukrotne kliknięcie działa zgodnie z rozsądnymi ustawieniami domyślnymi: zdjęcia, filmy i muzyka otwierają się w Omaview, pliki PDF w Document Viewer, Markdown w Omawrite, a zwykły tekst w Twoim edytorze, Plain, chyba że wybierzesz inny w _Setup > Defaults > Editor_.

## Disktree

Gdy dysk się zapełni i nie masz pojęcia, co go pożera, uruchom [Disktree](https://github.com/tobi/disktree) z programu uruchamiającego aplikacje (`Super + Space`). Pokazuje graficzną mapę drzewa Twojego katalogu domowego. Większe bloki zajmują więcej miejsca; wchodź do katalogów za pomocą klawiatury lub myszy, zaznacz to, co ma zostać usunięte, i przejrzyj swoje wybory przed usunięciem czegokolwiek. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) to darmowa i wysoce rozszerzalna aplikacja do robienia notatek, która do przechowywania używa prostych plików Markdown.

Obsidian jest darmowy do wszystkich celów, w tym do użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje również [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Android. (https://obsidian.md/pricing).

Obsidian uruchamiasz za pomocą `Super + Shift + O`. Aby korzystać z synchronizacji motywu, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) to własna, banalnie prosta aplikacja Omarchy do pisania w Markdown. Żadnych skarbców, żadnych wtyczek, tylko Ty i słowa.

Omawrite uruchamiasz za pomocą `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) to podstawowe narzędzie do edycji obrazów, które świetnie nadaje się do przycinania, zmiany rozmiaru i innych podstawowych manipulacji. Tylko nie oczekuj alternatywy dla Photoshopa. Ale wciąż ma Magic Wand i warstwy!

Pintę uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) to aplikacja do tworzenia motywów, która potrafi wyodrębnić kolory z obrazu tła i przekształcić je w kompletny, spójny motyw. To najłatwiejszy sposób, aby [stworzyć własny motyw](43-making-your-own-theme.md).

Aether uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa ta aplikacja, podobnie jak AirDrop od Apple. Jest jednak wieloplatformowy, więc możesz wysyłać pliki do i z Windows, macOS, Android, iOS i oczywiście Linux.

Menu Share możesz otworzyć za pomocą `Super + Ctrl + S` lub w _Trigger > Share_ w menu Omarchy. Daje Ci cztery opcje:

- **Clipboard** wysyła wszystko, co skopiowałeś, jako plik tekstowy. Świetne, aby przenieść link lub fragment na telefon bez wysyłania sobie e-maila.
- **File** otwiera selektor plików, w którym możesz wybrać kilka naraz.
- **Folder** wysyła cały katalog.
- **Receive** otwiera właściwy LocalSend, aby inne urządzenie mogło coś do Ciebie wysłać.

To samo działa z terminala za pomocą `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Pomiń ścieżkę, a otrzymasz selektor.

Możesz także wysyłać bezpośrednio z menedżera plików: kliknij prawym przyciskiem myszy dowolny wybór w Files i udostępnij go za pomocą LocalSend.

Zapora sieciowa Omarchy jest domyślnie zamknięta, z wyjątkiem portu LocalSend, więc działa to od razu po świeżej instalacji. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) to kompletny pakiet biurowy z procesorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest zgodny z plikami z Microsoft Office, więc to świetny sposób, aby móc otwierać te dokumenty Word.

LibreOffice uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) to własna, banalnie prosta aplikacja Omarchy do prezentacji. Twoja prezentacja to pojedynczy plik Markdown z obrazami i filmami obok niego: pisz każdy slajd pod podglądem na żywo, przeciągaj slajdy w odpowiedniej kolejności, a następnie prezentuj na pełnym ekranie lub eksportuj do PDF i PowerPoint. Podchwytuje nawet Twój motyw Omarchy.

Hype uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`). Naciśnij `?` w środku, aby zobaczyć każdy skrót.

## Signed

[Signed](https://github.com/omacom/signed) to własny, banalnie prosty sposób Omarchy na podpisywanie plików PDF i ich wypełnianie. Umieść swój zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu na stronie, a następnie zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie plików PDF](27-filling-out-pdfs.md), aby dowiedzieć się, jak to zrobić.

Signed uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`) lub otwórz nim plik PDF z menedżera plików.

## Game Vibes

Game Vibes, w programie uruchamiającym aplikacje (`Super + Space`), to miejsce, w którym żyją małe gry Omarchy: Checkmate, trójwymiarowa gra w szachy przeciwko znajomemu lub wbudowanemu przeciwnikowi; Cards, pasjans Klondike; Death Wish, precyzyjny co do piksela platformer składający się z dziesięciu pokojów pełnych kolców i pił; oraz Neon Swarm, zręcznościowa strzelanka. Każda to pojedyncza strona internetowa, która podąża za Twoim motywem. Wybierz jedną strzałkami i `Enter`, a do listy wróć za pomocą `Esc` z ekranu tytułowego gry lub `Q`, gdy jest wstrzymana. Otwiera się na pełnym ekranie: `Super + F` zamienia ją w okno, a `Super + W` ją zamyka.

Gry, które tworzysz z agentem, również pojawiają się tutaj: wybierz _Make something cool → Game_ w panelu agentów i opisz jedną, lub nazwij grę już znajdującą się w Game Vibes, aby dalej nad nią pracować. Agent kopiuje ją do `~/Games/vibes`, gdzie należy do Ciebie i możesz ją zmieniać, i otwiera ją, gdy skończy. Tę kopię możesz wykonać samodzielnie za pomocą `omarchy games vibes copy <game>`. Gra udostępniona przez kogoś innego instaluje się jak motyw: wybierz _Install > Gaming > Game Vibes_ i wklej jej adres git, lub uruchom `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ usuwa ją ponownie, a _Update > Game Vibes Games_ pobiera nowe wersje. Gry ładują three.js z sieci, więc do uruchomienia potrzebują połączenia.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) to własny, banalnie prosty kalkulator Omarchy, który otwiera się w pływającym oknie.

Omacalc uruchamiasz za pomocą `Super + Shift + Q` (lub klawisza kalkulatora, jeśli Twoja klawiatura taki ma).

## Signal

[Signal](https://signal.org/) to pionier szyfrowanej komunikacji E2E i świetna opcja komunikacyjna dla każdego, kto wolałby nie przechodzić przez jeden z wielkich konglomeratów technologicznych.

Signal uruchamiasz za pomocą `Super + Shift + G`. Nie jest częścią instalacji podstawowej, więc za pierwszym razem, gdy to naciśniesz, Omarchy zaproponuje zainstalowanie go dla Ciebie (znajduje się również w _Install > Service_ w menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) to własna, banalnie prosta przeglądarka obrazów i odtwarzacz multimediów Omarchy: jedno okno dla Twoich zdjęć, filmów i muzyki. Otwórz zdjęcie, a klawisze strzałek przeglądają resztę jego folderu, `N` i `P` robią to dla wszystkiego, a `Ctrl + M` pokazuje cały folder jako siatkę. Pokazuje także zdjęcia HEIC, AVIF i JPEG XL i wznawia odtwarzanie wszystkiego długiego od miejsca, w którym skończyłeś.

Naciśnij `F`, aby uzyskać pełny ekran, `E`, aby edytować zdjęcie w Omasnap lub przyciąć film w Omacut, `Ctrl + P`, aby wydrukować zdjęcie, a `Delete`, aby przenieść plik do Kosza (`Ctrl + Z` go przywraca). Naciśnij `?` w środku, aby zobaczyć każdy skrót.

Omaview uruchamiasz jako _Media Viewer_ za pomocą programu uruchamiającego aplikacje (`Super + Space`) lub po prostu kliknij dwukrotnie zdjęcie, film lub piosenkę w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) to własny, banalnie prosty przycinacz wideo Omarchy. Gdy wszystko, czego potrzebujesz, to odcięcie początku i końca klipu, przebija odpalanie pełnego edytora wideo.

Omacut uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) to własny, banalnie prosty rejestrator kamery internetowej Omarchy. Wybierz kamerę i mikrofon raz, a następnie naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo ujęcie. Zawsze nagrywa w najwyższej rozdzielczości Twojej kamery, z miernikiem mikrofonu na żywo, abyś mógł sprawdzić poziomy przed rozpoczęciem.

Zatrzymaj ujęcie, a otworzy się od razu we wbudowanym edytorze. Kliknij dwukrotnie klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń części, których nie chcesz. Następnie zapisz go jako MP4. Twoje oryginalne nagranie jest przechowywane, dopóki go nie odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Monologue uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).
