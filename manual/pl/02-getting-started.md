# Pierwsze kroki

Omarchy instaluje się za pomocą ISO. Możesz wybrać instalację na całym dysku, która przejmuje cały dysk, albo instalację w wolnym miejscu, która umieszcza Omarchy w nieprzydzielonym miejscu na dysku — tak właśnie robi się dual boot obok Windowsa lub innego systemu operacyjnego (zobacz [instalacja dual boot](50-dual-boot-install.md) — pamiętaj, że najpierw musisz wyłączyć BitLocker w Windowsie). Tak czy inaczej, instalacja domyślnie stosuje pełne szyfrowanie, a opcja całego dysku wyczyści wybrany dysk, więc koniecznie zrób kopię zapasową, zanim użyjesz istniejącego dysku!

Najpierw [pobierz ISO Omarchy](https://omarchy.org/), nagraj je na pendrive (użyj [Rufus](https://rufus.ie/) w Windowsie, [balenaEtcher](https://etcher.balena.io/) na Macu albo [caligula](https://github.com/ifd3f/caligula) w Linuksie) i uruchom komputer z pendrive'a.

_Musisz wyłączyć Secure Boot i/lub TPM w BIOS-ie. Musisz je wyłączyć, żeby móc zainstalować Omarchy. To mechanizmy bezpieczeństwa Microsoftu przeznaczone dla Windowsa i powiązanych z Microsoftem dystrybucji Linuksa._

Następnie odpowiedz na pytania konfiguracyjne i potwierdź je w ten sposób:

 ![install-config](images/install-config.webp)

Potem wybierz dysk do instalacji, usiądź wygodnie i oglądaj pokaz instalacji. Na najszybszych nowoczesnych maszynach da się to zrobić w mniej niż minutę, ale nawet na starszym komputerze nie powinno to zająć więcej niż 5 minut.

 ![install-done](images/install-done.webp)

Teraz jesteś gotowy na Omarchy!

### Używaj klawiatury przewodowej lub 2.4ghz!

Pełne szyfrowanie dysku nie pozwoli Ci wpisać hasła z klawiatury Bluetooth przy starcie. Tak samo jak nie możesz użyć klawiatury Bluetooth, żeby wejść do BIOS-u na PC. Będziesz potrzebować klawiatury, która używa odbiornika 2.4ghz albo kabla (co i tak jest dużo lepsze pod względem opóźnień!). Osobiście uwielbiam [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalacja dla innego właściciela

Jeśli przygotowujesz maszynę dla kogoś innego — członka rodziny, nowego pracownika, kupującego — nie powinieneś odpowiadać na osobiste pytania w jego imieniu. Naciśnij `Ctrl + C` na samym pierwszym ekranie instalatora (wybór klawiatury), a Omarchy zaproponuje przygotowanie maszyny dla innego właściciela. System zainstaluje się od razu, ale cała osobista konfiguracja — układ klawiatury, nazwa użytkownika, hasło — zostanie odłożona do pierwszego uruchomienia maszyny. Dysk nadal jest domyślnie szyfrowany, a hasło, które nowy właściciel wybierze przy tym pierwszym uruchomieniu, stanie się też hasłem szyfrowania. (Komputer, którego już używałeś, też można przekazać bez ponownej instalacji — zobacz [resetowanie komputera](48-security.md).)

### Instalacje nienadzorowane

ISO może też zainstalować się całkowicie samodzielnie — bez klawiatury, bez kreatora — gdy otrzyma swoją konfigurację na drugim dysku. To sposób, żeby traktować Omarchy jako obraz bazowy dla VM i flot maszyn. Zobacz [instalacje nienadzorowane](51-unattended-installs.md).

### Instalacje bez szyfrowania

Omarchy instaluje się domyślnie z szyfrowaniem. To bezpieczny, odpowiedzialny wybór dla każdego komputera, który może zostać zgubiony lub ukradziony. Nie chcesz, żeby ktokolwiek z dostępem do Twojego sprzętu mógł dostać się do Twoich danych!

Ale w szczególnych okolicznościach, takich jak zdalne instalacje Omarchy na chronionych komputerach albo instalacje jednorazowe bez wrażliwych danych, możesz chcieć zainstalować system bez szyfrowania. Możesz nacisnąć `Ctrl + C` na potwierdzeniu formatowania dysku, żeby przełączyć się na instalację bez szyfrowania.

### Język

Omarchy mówi w 50 językach — tym samym zestawie co omarchy.org — a angielski jest domyślny. Żeby przełączyć język, otwórz menu Omarchy i przejdź do _Setup > Region > Language_, albo uruchom `omarchy language <code>` w terminalu (`omarchy language list` pokazuje kody). Menu, pulpit i własne powiadomienia Omarchy zmienią język natychmiast, a każda aplikacja, którą otworzysz potem, też za tym pójdzie. Aplikacje, które były już otwarte, przełączą się po ich ponownym uruchomieniu.

Żeby zachować język, ale zapisywać daty, godziny, liczby, pieniądze, jednostki i rozmiary papieru tak, jak robi to inny region (powiedzmy angielski z europejskimi datami i zegarem 24-godzinnym), wybierz region w _Setup > Region > Formats_, gdzie każdy wybór pokazuje przykład, albo uruchom `omarchy region formats <code>` (`omarchy region formats list` pokazuje kody). _Same as language_ wraca do formatów właściwych dla języka. Podobnie jak przełączenie języka, działa to w aplikacjach, które otworzysz potem.

### Pomoc, gdy utkniesz

Jeśli utkniesz, zazwyczaj znajdziesz kogoś chętnego do pomocy na kanale _#omarchy-help_ na [społecznościowym Discordzie](https://omarchy.org/discord).
