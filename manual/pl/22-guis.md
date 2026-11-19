# Aplikacje graficzne

## Files

Files (Folio) to graficzny menedżer plików. `Super + Shift + F` go otwiera, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym znajduje się Twój terminal, co oszczędza mnóstwo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku pokazuje jego podgląd w pełnym rozmiarze bez otwierania go.

Podłącz pamięć USB lub kartę SD, a zostanie zamontowana automatycznie, więc po prostu pojawi się na pasku bocznym. Do bardziej zaawansowanych zadań — formatowania dysku, sprawdzania stanu SMART, tworzenia partycji — uruchom _Disks_ z poziomu programu uruchamiającego aplikacje (`Super + Space`).

Dwukrotne kliknięcie działa według rozsądnych ustawień domyślnych: obrazy, filmy i muzyka otwierają się w Omaview, pliki PDF w Document Viewer, Markdown w Omawrite, a zwykły tekst w edytorze wybranym w _Setup > Default > Editor_.

## Disktree

Kiedy dysk się zapełnia, a Ty nie masz pojęcia, co go zjada, uruchom [Disktree](https://github.com/tobi/disktree) z poziomu programu uruchamiającego aplikacje (`Super + Space`). Pokazuje graficzną mapę drzewa Twojego katalogu domowego. Większe bloki zajmują więcej miejsca; poruszaj się po katalogach za pomocą klawiatury lub myszy, zaznacz, co ma zostać usunięte, i przejrzyj swoje wybory, zanim cokolwiek usuniesz. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) to darmowa i wysoce rozszerzalna aplikacja do robienia notatek, która do przechowywania używa prostych plików Markdown.

Obsidian jest darmowy do wszystkich celów, w tym do użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje również [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Android. (https://obsidian.md/pricing).

Uruchamiasz Obsidian za pomocą `Super + Shift + O`. Aby korzystać z synchronizacji motywu, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) to własna, banalnie prosta aplikacja Omarchy do pisania w Markdown. Żadnych sejfów, żadnych wtyczek, tylko Ty i słowa.

Uruchamiasz Omawrite za pomocą `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) to podstawowe narzędzie do edycji obrazów, które świetnie nadaje się do przycinania, zmiany rozmiaru i innych podstawowych manipulacji. Tylko nie oczekuj alternatywy dla Photoshopa. Ale nadal ma Magic Wand i warstwy!

Uruchamiasz Pinta z poziomu programu uruchamiającego aplikacje (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) to aplikacja do tworzenia motywów, która potrafi wyodrębnić kolory z obrazu tła i zamienić je w kompletny, spójny motyw. To najłatwiejszy sposób na [stworzenie własnego motywu](43-making-your-own-theme.md).

Uruchamiasz Aether z poziomu programu uruchamiającego aplikacje (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa ta aplikacja, podobnie jak AirDrop od Apple. Jest jednak wieloplatformowa, więc możesz wysyłać pliki do i z Windows, macOS, Android, iOS i oczywiście Linux.

Menu Udostępniania możesz otworzyć za pomocą `Super + Ctrl + S` lub w menu Omarchy w _Trigger > Share_. Daje Ci cztery opcje:

- **Clipboard** wysyła wszystko, co skopiowałeś, jako plik tekstowy. Świetne, aby przenieść link lub fragment kodu na telefon bez wysyłania sobie e-maila.
- **File** otwiera selektor plików, w którym możesz wybrać kilka naraz.
- **Folder** wysyła cały katalog.
- **Receive** otwiera właściwy LocalSend, aby inne urządzenie mogło wysłać coś do Ciebie.

To samo działa z terminala za pomocą `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Pomiń ścieżkę, a otrzymasz selektor.

Możesz także wysyłać bezpośrednio z menedżera plików: kliknij prawym przyciskiem myszy dowolny wybór w Files i udostępnij go za pomocą LocalSend.

Zapora sieciowa Omarchy jest domyślnie zamknięta, z wyjątkiem portu LocalSend, więc działa to od razu po świeżej instalacji. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) to kompletny pakiet biurowy z edytorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest kompatybilny z plikami z Microsoft Office, więc to świetny sposób, aby móc otworzyć te dokumenty Word.

Uruchamiasz LibreOffice z poziomu programu uruchamiającego aplikacje (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) to własna, banalnie prosta aplikacja Omarchy do prezentacji. Twoja prezentacja to pojedynczy plik Markdown wraz z obrazami i filmami obok niego: pisz każdy slajd poniżej podglądu na żywo, przeciągaj slajdy w odpowiedniej kolejności, a następnie prezentuj na pełnym ekranie lub eksportuj do PDF i PowerPoint. Przeimuje nawet Twój motyw Omarchy.

Uruchamiasz Hype z poziomu programu uruchamiającego aplikacje (`Super + Space`). Naciśnij `?` w aplikacji, aby zobaczyć każdy skrót.

## Signed

[Signed](https://github.com/omacom/signed) to własny, banalnie prosty sposób Omarchy na podpisywanie plików PDF i ich wypełnianie. Umieść zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu na stronie, a następnie zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie plików PDF](27-filling-out-pdfs.md), aby dowiedzieć się, jak to zrobić.

Uruchamiasz Signed z poziomu programu uruchamiającego aplikacje (`Super + Space`) lub otwórz z jego pomocą plik PDF z menedżera plików.

## Game Vibes

Game Vibes, w programie uruchamiającym aplikacje (`Super + Space`), to miejsce, w którym znajdują się małe gry Omarchy: Checkmate, trójwymiarowa gra w szachy przeciwko znajomemu lub wbudowanemu przeciwnikowi; Cards, pasjans Klondike; oraz Neon Swarm, zręcznościowa strzelanka. Każda z nich to pojedyncza strona internetowa, która dopasowuje się do Twojego motywu. Wybierz jedną za pomocą strzałek i `Enter`, a do listy wróć za pomocą `Esc` z ekranu tytułowego gry lub `Q`, gdy gra jest wstrzymana. Otwiera się na pełnym ekranie: `Super + F` zamienia ją w okno, a `Super + W` ją zamyka.

Gry, które tworzysz z agentem, również pojawiają się tutaj: wybierz _Make something cool → Game_ w panelu agentów i opisz jedną z nich lub wskaż grę już znajdującą się w Game Vibes, aby kontynuować nad nią pracę. Agent kopiuje ją do `~/Games/vibes`, gdzie należy do Ciebie i możesz ją zmieniać, oraz otwiera ją po zakończeniu. Możesz samodzielnie wykonać tę kopię za pomocą `omarchy games vibes copy <game>`. Gra udostępniona przez kogoś innego instaluje się jak motyw: wybierz _Install > Gaming > Game Vibes_ i wklej jej adres git, lub uruchom `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ usuwa ją ponownie, a _Update > Game Vibes Games_ pobiera nowe wersje. Gry ładują three.js z internetu, więc do uruchomienia potrzebują połączenia.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) to własny, banalnie prosty kalkulator Omarchy, który otwiera się w pływającym oknie.

Uruchamiasz Omacalc za pomocą `Super + Shift + Q` (lub klawisza kalkulatora, jeśli Twoja klawiatura go ma).

## Signal

[Signal](https://signal.org/) jest pionierem szyfrowanej komunikacji E2E i świetną opcją komunikacyjną dla każdego, kto wolałby nie korzystać z jednego z wielkich konglomeratów technologicznych.

Uruchamiasz Signal za pomocą `Super + Shift + G`. Nie jest częścią instalacji podstawowej, więc gdy naciśniesz to po raz pierwszy, Omarchy zaoferuje zainstalowanie go dla Ciebie (znajduje się również w _Install > Service_ w menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) to własna, banalnie prosta przeglądarka obrazów i odtwarzacz multimediów Omarchy: jedno okno dla Twoich zdjęć, filmów i muzyki. Otwórz zdjęcie, a klawisze strzałek będą przechodzić przez resztę jego folderu, `N` i `P` robią to dla wszystkiego, a `Ctrl + M` pokazuje cały folder jako siatkę. Wyświetla również zdjęcia HEIC, AVIF i JPEG XL oraz wznawia odtwarzanie tego, co długie, od miejsca, w którym skończyłeś.

Naciśnij `F`, aby włączyć pełny ekran, `E`, aby edytować zdjęcie w Omasnap lub przyciąć film w Omacut, `Ctrl + P`, aby wydrukować zdjęcie, oraz `Delete`, aby przenieść plik do Kosza (`Ctrl + Z` przywraca go). Naciśnij `?` w aplikacji, aby zobaczyć każdy skrót.

Uruchamiasz Omaview jako _Media Viewer_ z poziomu programu uruchamiającego aplikacje (`Super + Space`) lub po prostu kliknij dwukrotnie zdjęcie, film lub piosenkę w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) to własny, banalnie prosty przycinacz wideo Omarchy. Gdy potrzebujesz jedynie odciąć początek i koniec klipu, przebija odpalanie pełnego edytora wideo.

Uruchamiasz Omacut z poziomu programu uruchamiającego aplikacje (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) to własny, banalnie prosty rejestrator kamery internetowej Omarchy. Wybierz kamerę i mikrofon raz, a następnie naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo nagranie. Zawsze nagrywa w najwyższej rozdzielczości Twojej kamery, z miernikiem mikrofonu na żywo, dzięki czemu możesz sprawdzić poziomy głośności przed rozpoczęciem.

Zatrzymaj nagranie, a otworzy się od razu we wbudowanym edytorze. Kliknij dwukrotnie klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń części, których nie chcesz. Następnie zapisz go jako MP4. Twoje oryginalne nagranie jest przechowywane, dopóki go nie odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Uruchamiasz Monologue z poziomu programu uruchamiającego aplikacje (`Super + Space`).
