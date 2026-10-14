# Pierwsze kroki

Omarchy instaluje się przy użyciu obrazu ISO. Możesz wybrać między instalacją na całym dysku, która przejmuje cały dysk, a instalacją w wolnym miejscu, która umieszcza Omarchy w nieprzydzielonym miejscu na dysku — w ten właśnie sposób używasz dual boot obok Windows lub innego systemu operacyjnego (zobacz [instalację dual-boot](50-dual-boot-install.md) — pamiętaj, że najpierw będziesz musiał wyłączyć BitLocker w Windows). Tak czy inaczej instalacja domyślnie obejmuje pełne szyfrowanie, a opcja całego dysku wyczyści wybrany dysk, więc koniecznie zrób kopię zapasową, zanim użyjesz dysku, na którym już coś jest!

Najpierw [pobierz obraz ISO Omarchy](https://omarchy.org/), umieść go na pendrive'ie USB (użyj [balenaEtcher](https://etcher.balena.io/) na Mac/Windows lub [caligula](https://github.com/ifd3f/caligula) na Linuxie) i uruchom komputer z pendrive'a.

_Musisz wyłączyć Secure Boot i/lub TPM w BIOS-ie. Musisz je wyłączyć, żeby móc zainstalować Omarchy. To schematy bezpieczeństwa Microsoftu przeznaczone dla Windows i powiązanych z Microsoftem dystrybucji Linuxa._

Następnie odpowiedz na pytania konfiguracyjne i potwierdź je w ten sposób:

 ![install-config](images/install-config.webp)

Następnie wybierz dysk do instalacji, usiądź wygodnie i oglądaj pokaz instalacji. Na najszybszych nowoczesnych maszynach może się ona skończyć w mniej niż minutę, ale nawet na starszym komputerze nie powinna trwać dłużej niż 5 minut.

 ![install-done](images/install-done.webp)

Teraz jesteś gotowy na Omarchy!

### Używaj klawiatury przewodowej lub 2.4ghz!

Szyfrowanie całego dysku nie pozwoli Ci wpisać hasła z klawiatury Bluetooth przy starcie. Tak samo jak nie możesz użyć klawiatury Bluetooth, żeby wejść do BIOS-u na PC. Będziesz potrzebować klawiatury, która korzysta z odbiornika 2.4ghz albo z kabla (co i tak jest znacznie lepsze pod względem opóźnienia!). Osobiście uwielbiam [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalacja dla innego właściciela

Jeśli przygotowujesz maszynę dla kogoś innego — członka rodziny, nowego pracownika, kupującego — nie powinieneś odpowiadać na osobiste pytania w jej lub jego imieniu. Naciśnij `Ctrl + C` na samym pierwszym ekranie instalatora (wybór klawiatury), a Omarchy zaproponuje przygotowanie maszyny dla innego właściciela. System instaluje się od razu, ale cała osobista konfiguracja — układ klawiatury, nazwa użytkownika, hasło — jest odkładana do pierwszego uruchomienia maszyny. Dysk nadal jest domyślnie szyfrowany, a hasło, które nowy właściciel wybierze przy tym pierwszym uruchomieniu, staje się również hasłem szyfrowania. (Maszynę, której już używałeś, też można przekazać bez ponownej instalacji — zobacz [resetowanie komputera](48-security.md).)

### Instalacje nienadzorowane

Obraz ISO może też zainstalować się całkowicie samodzielnie — bez klawiatury, bez kreatora — gdy dostanie swoją konfigurację na drugim dysku. W ten sposób traktuje się Omarchy jako obraz bazowy dla VM i maszyn we flocie. Zobacz [instalacje nienadzorowane](51-unattended-installs.md).

### Instalacje bez szyfrowania

Omarchy jest domyślnie instalowane z szyfrowaniem. To bezpieczny, odpowiedzialny wybór dla każdego komputera, który może ewentualnie zostać zgubiony lub skradziony. Nie chcesz, żeby ktokolwiek z dostępem do Twojego sprzętu mógł dostać się do Twoich danych!

Ale w szczególnych okolicznościach, takich jak zdalne instalacje Omarchy na chronionych komputerach lub instalacje jednorazowe bez wrażliwych danych, możesz chcieć zainstalować system bez szyfrowania. Możesz nacisnąć `Ctrl + C` na ekranie potwierdzenia formatowania dysku, żeby przełączyć się na instalację bez szyfrowania.

### Język

Omarchy mówi w 50 językach — w tym samym zestawie co omarchy.org — a domyślny jest angielski. Żeby przełączyć język, otwórz menu Omarchy i przejdź do _Setup > Language_ albo uruchom `omarchy language <code>` w terminalu (`omarchy language list` pokazuje kody). Menu, pulpit i własne powiadomienia Omarchy zmieniają język natychmiast, a każda aplikacja, którą otworzysz później, również się do niego dostosowuje. Aplikacje, które były już otwarte, przełączają się po ich ponownym uruchomieniu.

### Pomoc, jeśli utkniesz

Jeśli utkniesz, zazwyczaj znajdziesz kogoś chętnego do pomocy na kanale _#omarchy-help_ na [Discordzie społeczności](https://omarchy.org/discord).
