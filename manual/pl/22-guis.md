# GUI

## Pliki

Files (Nautilus) jest graficznym menedżerem plików. `Super + Shift + F` otwiera go, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym znajduje się twój terminal, co oszczędza dużo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku daje szybki podgląd bez otwierania czegokolwiek.

Podłącz pendrive USB lub kartę SD, a zostanie zamontowana automatycznie, więc po prostu pojawi się na pasku bocznym. Do wszystkiego bardziej złożonego — formatowania dysku, sprawdzania stanu SMART, tworzenia partycji — uruchom _Disks_ z launchera aplikacji (`Super + Space`).

Dwukrotne kliknięcie stosuje rozsądne ustawienia domyślne: obrazy otwierają się w imv, wideo w mpv, PDF-y w Document Viewer, a zwykły tekst w Neovim.

## Disktree

Gdy dysk się zapełni i nie masz pojęcia, co go zjada, uruchom [Disktree](https://github.com/tobi/disktree) z launchera aplikacji (`Super + Space`). Pokazuje graficzną mapę drzewa twojego katalogu domowego. Większe bloki zajmują więcej miejsca; wchodź do katalogów za pomocą klawiatury lub myszy, zaznacz, co ma zniknąć, i przejrzyj swoje wybory przed usunięciem czegokolwiek. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) jest darmową i wysoce rozszerzalną aplikacją do robienia notatek, która używa prostych plików Markdown do przechowywania.

Obsidian jest darmowy do wszystkich celów, w tym użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje również [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Android. (https://obsidian.md/pricing).

Uruchamiasz Obsidian za pomocą `Super + Shift + O`. Aby używać synchronizacji motywu, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) jest własną, banalnie prostą aplikacją Omarchy do pisania w Markdown. Żadnych vaultów, żadnych wtyczek, tylko ty i słowa.

Uruchamiasz Omawrite za pomocą `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) jest podstawowym narzędziem do edycji obrazów, które świetnie nadaje się do przycinania, zmiany rozmiaru i innych podstawowych manipulacji. Po prostu nie oczekuj alternatywy dla Photoshopa. Ale wciąż ma Magic Wand i warstwy!

Uruchamiasz Pintę za pośrednictwem launchera aplikacji (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) jest aplikacją do motywów, która potrafi wyodrębniać kolory z obrazu tła i zamieniać je w kompletny, spójny motyw. To najłatwiejszy sposób, aby [stworzyć własny motyw](43-making-your-own-theme.md).

Uruchamiasz Aether za pośrednictwem launchera aplikacji (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa aplikacja, jak AirDrop firmy Apple. Jest jednak wieloplatformowy, więc możesz wysyłać pliki do i z Windows, macOS, Android, iOS i oczywiście Linuksa.

Możesz otworzyć menu Udostępnij za pomocą `Super + Ctrl + S` lub w menu Omarchy w _Akcje > Udostępnij_. Daje ci cztery opcje:

- **Schowek** wysyła to, co skopiowałeś, jako plik tekstowy. Świetne, aby przenieść link lub fragment na telefon bez wysyłania sobie e-maila.
- **Plik** otwiera selektor plików, w którym możesz wybrać kilka naraz.
- **Folder** wysyła cały katalog.
- **Odbierz** otwiera właściwy LocalSend, aby inne urządzenie mogło wysłać coś do ciebie.

To samo działa z terminala za pomocą `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Pomiń ścieżkę, a otrzymasz selektor.

Możesz również wysyłać bezpośrednio z menedżera plików: kliknij prawym przyciskiem myszy dowolny wybór w Nautilus i wybierz _Send via LocalSend_.

Zapora sieciowa Omarchy jest domyślnie zamknięta z wyjątkiem portu LocalSend, więc działa to od razu na świeżej instalacji. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) jest kompletnym pakietem biurowym z procesorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest kompatybilny z plikami z Microsoft Office, więc jest to świetny sposób, aby móc otwierać te dokumenty Word.

Uruchamiasz LibreOffice za pośrednictwem launchera aplikacji (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) jest własną, banalnie prostą aplikacją Omarchy do prezentacji. Twoja prezentacja to pojedynczy plik Markdown z obrazami i wideo obok niego: pisz każdy slajd poniżej podglądu na żywo, przeciągaj slajdy w kolejności, a następnie prezentuj na pełnym ekranie lub eksportuj do PDF i PowerPoint. Przejmuje nawet twój motyw Omarchy.

Uruchamiasz Hype za pośrednictwem launchera aplikacji (`Super + Space`). Naciśnij `?` wewnątrz, aby zobaczyć każdy skrót.

## Signed

[Signed](https://github.com/omacom/signed) jest własnym, banalnie prostym sposobem Omarchy na podpisywanie PDF-ów i ich wypełnianie. Umieść swój zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu na stronie, a następnie zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie PDF-ów](27-filling-out-pdfs.md), aby dowiedzieć się jak.

Uruchamiasz Signed za pośrednictwem launchera aplikacji (`Super + Space`) lub otwierasz za jego pomocą PDF z menedżera plików.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) jest własnym, banalnie prostym kalkulatorem Omarchy, który otwiera się w pływającym oknie.

Uruchamiasz Omacalc za pomocą `Super + Ctrl + Q` (lub klawisza kalkulatora, jeśli twoja klawiatura go ma).

## Signal

[Signal](https://signal.org/) jest pionierem szyfrowanych wiadomości E2E i świetną opcją komunikacji dla każdego, kto wolałby nie przechodzić przez jeden z dużych konglomeratów technologicznych.

Uruchamiasz Signal za pomocą `Super + Shift + G`. Nie jest częścią podstawowej instalacji, więc za pierwszym razem, gdy naciśniesz to, Omarchy zaproponuje zainstalowanie go dla ciebie (jest również w _Instaluj > Service_ w menu Omarchy).

## mpv

[mpv](https://mpv.io/) jest prostym, szybkim odtwarzaczem multimediów, który odtworzy prawie wszystko z dowolnego źródła. Świetny do oglądania wideo.

Uruchamiasz mpv za pośrednictwem launchera aplikacji (`Super + Space`) lub po prostu dwukrotnie klikasz wideo w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) jest własnym, banalnie prostym trymerem wideo Omarchy. Gdy wszystko, czego potrzebujesz, to odciąć początek i koniec klipu, bije na głowę uruchamianie pełnego edytora wideo.

Uruchamiasz Omacut za pośrednictwem launchera aplikacji (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) jest własnym, banalnie prostym rejestratorem kamery internetowej Omarchy. Wybierz kamerę i mikrofon raz, a następnie naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo ujęcie. Zawsze nagrywa w najwyższej rozdzielczości twojej kamery, z miernikiem mikrofonu na żywo, abyś mógł sprawdzić poziomy przed rozpoczęciem.

Zatrzymaj ujęcie, a otworzy się od razu we wbudowanym edytorze. Dwukrotnie kliknij klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń części, których nie chcesz. Następnie zapisz go jako MP4. Twoje oryginalne nagranie jest zachowywane, dopóki go nie odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Uruchamiasz Monologue za pośrednictwem launchera aplikacji (`Super + Space`).
