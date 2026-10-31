# Aplikacje graficzne

## Pliki

Pliki (Nautilus) to graficzny menedżer plików. `Super + Shift + F` go otwiera, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym znajduje się twój terminal, co oszczędza sporo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku daje szybki podgląd bez otwierania czegokolwiek.

Podłącz pamięć USB lub kartę SD, a zostanie zamontowana automatycznie, więc po prostu pojawi się na pasku bocznym. Do bardziej zaawansowanych rzeczy — formatowania dysku, sprawdzania kondycji SMART, tworzenia partycji — uruchom _Disks_ z menu uruchamiania aplikacji (`Super + Space`).

Dwukrotne kliknięcie działa według rozsądnych ustawień domyślnych: obrazy otwierają się w imv, wideo w mpv, pliki PDF w Document Viewer, a zwykły tekst w Neovim.

## Disktree

Gdy dysk się zapełni i nie masz pojęcia, co go zjada, uruchom [Disktree](https://github.com/tobi/disktree) z menu uruchamiania aplikacji (`Super + Space`). Pokazuje graficzną mapę drzewa twojego katalogu domowego. Większe bloki zajmują więcej miejsca; wchodź do katalogów za pomocą klawiatury lub myszy, zaznaczaj, co ma zostać usunięte, i przeglądaj swoje wybory przed usunięciem czegokolwiek. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) to darmowa i wysoce rozszerzalna aplikacja do robienia notatek, która używa prostych plików Markdown do przechowywania danych.

Obsidian jest darmowy do wszystkich celów, w tym do użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje również [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Android. (https://obsidian.md/pricing).

Obsidian uruchamiasz za pomocą `Super + Shift + O`. Aby korzystać z synchronizacji motywu, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) to własna, banalnie prosta aplikacja Omarchy do pisania w Markdown. Żadnych skarbców, żadnych wtyczek, tylko ty i słowa.

Omawrite uruchamiasz za pomocą `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) to podstawowe narzędzie do edycji obrazów, które świetnie nadaje się do przycinania, zmiany rozmiaru i innych podstawowych manipulacji. Tylko nie oczekuj alternatywy dla Photoshopa. Ale nadal ma Magic Wand i warstwy!

Pintę uruchamiasz za pomocą menu uruchamiania aplikacji (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) to aplikacja do tworzenia motywów, która potrafi wyodrębnić kolory z obrazu tła i przekształcić je w kompletny, spójny motyw. To najłatwiejszy sposób na [stworzenie własnego motywu](43-making-your-own-theme.md).

Aether uruchamiasz za pomocą menu uruchamiania aplikacji (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa aplikacja, podobnie jak AirDrop od Apple. Jest jednak wieloplatformowy, więc możesz wysyłać pliki do i z Windows, macOS, Android, iOS i oczywiście Linux.

Menu udostępniania możesz otworzyć za pomocą `Super + Ctrl + S` lub w menu Omarchy pod _Trigger > Share_. Daje ci ono cztery opcje:

- **Clipboard** wysyła wszystko, co skopiowałeś, jako plik tekstowy. Świetne do przesyłania linku lub fragmentu na telefon bez wysyłania sobie e-maila.
- **File** otwiera selektor plików, w którym możesz wybrać kilka naraz.
- **Folder** wysyła cały katalog.
- **Receive** otwiera właściwy LocalSend, aby inne urządzenie mogło coś do ciebie wysłać.

To samo działa z terminala za pomocą `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Pomiń ścieżkę, a otrzymasz selektor.

Możesz też wysyłać bezpośrednio z menedżera plików: kliknij prawym przyciskiem myszy dowolny wybór w Nautilus i wybierz _Send via LocalSend_.

Zapora sieciowa Omarchy jest domyślnie zamknięta, z wyjątkiem portu LocalSend, więc działa to od razu po świeżej instalacji. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) to kompletny pakiet biurowy z procesorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest zgodny z plikami z Microsoft Office, więc to świetny sposób na otwieranie tych dokumentów Word.

LibreOffice uruchamiasz za pomocą menu uruchamiania aplikacji (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) to własna, banalnie prosta aplikacja Omarchy do prezentacji. Twoja prezentacja to pojedynczy plik Markdown z obrazami i filmami obok niego: piszesz każdy slajd pod podglądem na żywo, przeciągasz slajdy w odpowiedniej kolejności, a następnie prezentujesz na pełnym ekranie lub eksportujesz do PDF i PowerPoint. Podchwytuje nawet twój motyw Omarchy.

Hype uruchamiasz za pomocą menu uruchamiania aplikacji (`Super + Space`). Naciśnij `?` w aplikacji, aby zobaczyć każdy skrót.

## Signed

[Signed](https://github.com/omacom/signed) to własny, banalnie prosty sposób Omarchy na podpisywanie plików PDF i ich wypełnianie. Umieść zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu na stronie, a następnie zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie plików PDF](27-filling-out-pdfs.md), aby dowiedzieć się, jak to zrobić.

Signed uruchamiasz za pomocą menu uruchamiania aplikacji (`Super + Space`) lub otwierasz w nim plik PDF z menedżera plików.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) to własny, banalnie prosty kalkulator Omarchy, który otwiera się w pływającym oknie.

Omacalc uruchamiasz za pomocą `Super + Shift + Q` (lub klawisza kalkulatora, jeśli twoja klawiatura taki ma).

## Signal

[Signal](https://signal.org/) jest pionierem szyfrowanej komunikacji E2E i świetną opcją komunikacyjną dla każdego, kto wolałby nie korzystać z jednego z wielkich konglomeratów technologicznych.

Signal uruchamiasz za pomocą `Super + Shift + G`. Nie jest częścią podstawowej instalacji, więc za pierwszym razem, gdy to naciśniesz, Omarchy zaproponuje zainstalowanie go za ciebie (znajduje się również w menu Omarchy pod _Install > Service_). 

## mpv

[mpv](https://mpv.io/) to prosty, szybki odtwarzacz multimedialny, który odtworzy prawie wszystko z dowolnego źródła. Świetny do oglądania filmów.

mpv uruchamiasz za pomocą menu uruchamiania aplikacji (`Super + Space`) lub po prostu klikając dwukrotnie film w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) to własny, banalnie prosty przycinacz wideo Omarchy. Gdy potrzebujesz tylko przyciąć początek i koniec klipu, przebija odpalanie pełnego edytora wideo.

Omacut uruchamiasz za pomocą menu uruchamiania aplikacji (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) to własny, banalnie prosty rejestrator kamery internetowej Omarchy. Wybierz kamerę i mikrofon raz, a następnie naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo nagranie. Zawsze nagrywa w najwyższej rozdzielczości twojej kamery, z miernikiem mikrofonu na żywo, abyś mógł sprawdzić poziomy przed rozpoczęciem.

Zatrzymaj nagranie, a otworzy się od razu we wbudowanym edytorze. Kliknij dwukrotnie klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń części, których nie chcesz. Następnie zapisz go jako MP4. Twoje oryginalne nagranie jest przechowywane do momentu, aż je odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Monologue uruchamiasz za pomocą menu uruchamiania aplikacji (`Super + Space`).
