# Pierwsze kroki

Omarchy instaluje się przy użyciu ISO. Możesz wybrać między instalacją na całym dysku, która przejmuje cały dysk, a instalacją w wolnym miejscu, która umieszcza Omarchy w nieprzydzielonym miejscu na dysku — w ten sposób uruchamiasz dual boot obok Windows lub innego OS (zobacz [instalacja dual-boot](50-dual-boot-install.md) — pamiętaj, że najpierw będziesz musiał wyłączyć BitLocker w Windows). Tak czy inaczej, instalacja domyślnie obejmuje pełne szyfrowanie, a opcja całego dysku wyczyści wybrany dysk, więc koniecznie zrób kopię zapasową, zanim użyjesz istniejącego dysku!

Najpierw [pobierz ISO Omarchy](https://omarchy.org/), umieść je na pamięci USB (użyj [Rufus](https://rufus.ie/) w Windows, [balenaEtcher](https://etcher.balena.io/) na Macu lub [caligula](https://github.com/ifd3f/caligula) w Linuxie) i uruchom komputer z tej pamięci.

_Musisz wyłączyć Secure Boot i/lub TPM w BIOS. Musisz je wyłączyć, aby móc zainstalować Omarchy. To schematy zabezpieczeń Microsoft przeznaczone dla Windows i dystrybucji Linux powiązanych z Microsoft._

Następnie odpowiedz na pytania dotyczące konfiguracji i potwierdź je w ten sposób:

 ![install-config](images/install-config.webp)

Następnie wybierz dysk do instalacji i usiądź wygodnie, aby obejrzeć pokaz instalacji. Na najszybszych nowoczesnych maszynach może to zająć mniej niż minutę, ale nawet na starszym komputerze nie powinno to potrwać dłużej niż 5 minut.

 ![install-done](images/install-done.webp)

Teraz jesteś gotowy na Omarchy!

### Używaj klawiatury przewodowej lub 2.4ghz!

Szyfrowanie całego dysku nie pozwoli ci wpisać hasła z klawiatury Bluetooth przy starcie. Tak samo jak nie możesz użyć klawiatury Bluetooth, aby wejść do BIOS na PC. Będziesz potrzebować klawiatury, która używa albo odbiornika 2.4ghz, albo kabla (co i tak jest znacznie lepsze pod względem opóźnień!). Osobiście uwielbiam [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalowanie dla innego właściciela

Jeśli przygotowujesz maszynę dla kogoś innego — członka rodziny, nowego pracownika, kupującego — nie powinieneś odpowiadać na osobiste pytania w jego imieniu. Naciśnij `Ctrl + C` na samym pierwszym ekranie instalatora (wybór klawiatury), a Omarchy zamiast tego zaproponuje przygotowanie maszyny dla innego właściciela. System instaluje się od razu, ale cała osobista konfiguracja — układ klawiatury, nazwa użytkownika, hasło — jest odkładana do pierwszego uruchomienia maszyny. Dysk nadal jest domyślnie szyfrowany, a hasło, które nowy właściciel wybierze przy tym pierwszym uruchomieniu, staje się również hasłem szyfrowania. (Maszynę, której już używałeś, można również przekazać bez ponownej instalacji — zobacz [resetowanie komputera](48-security.md).)

### Instalacje nienadzorowane

ISO może również zainstalować się całkowicie samodzielnie — bez klawiatury, bez kreatora — gdy otrzyma swoją konfigurację na drugim dysku. W ten sposób traktujesz Omarchy jako obraz bazowy dla VM i maszyn flotowych. Zobacz [instalacje nienadzorowane](51-unattended-installs.md).

### Instalacje bez szyfrowania

Omarchy jest domyślnie instalowane z szyfrowaniem. To bezpieczny, odpowiedzialny wybór dla każdego komputera, który może zostać zgubiony lub ukradziony. Nie chcesz, aby ktokolwiek z dostępem do twojego sprzętu mógł dostać się do twoich danych!

Ale w szczególnych okolicznościach, takich jak zdalne instalacje Omarchy na chronionych komputerach lub instalacje jednorazowe bez wrażliwych danych, możesz chcieć zainstalować bez szyfrowania. Możesz nacisnąć `Ctrl + C` na potwierdzeniu formatowania dysku, aby przełączyć się na instalację bez szyfrowania.

### Język

Omarchy mówi w 50 językach — tym samym zestawie co omarchy.org — a domyślny jest angielski. Aby przełączyć, otwórz menu Omarchy i przejdź do _Ustawienia > Region > Język_ lub uruchom `omarchy language <code>` w terminalu (`omarchy language list` pokazuje kody). Menu, pulpit i własne powiadomienia Omarchy zmieniają język natychmiast, a każda aplikacja, którą otworzysz później, również. Aplikacje, które były już otwarte, przełączą się po ich ponownym uruchomieniu.

Aby zachować język, ale zapisywać daty, godziny, liczby, pieniądze, jednostki i rozmiary papieru tak, jak robi to inny region (powiedzmy angielski z europejskimi datami i zegarem 24-godzinnym), wybierz region w _Ustawienia > Region > Formaty_, gdzie każdy wybór pokazuje przykład, lub uruchom `omarchy region <code>` (`omarchy region list` pokazuje kody). _Tak samo jak język_ wraca do formatów właściwych dla języka. Podobnie jak przełączenie języka, dotyczy to aplikacji, które otworzysz później.

### Pomoc, jeśli utkniesz

Jeśli utkniesz, zwykle znajdziesz kogoś chętnego do pomocy na kanale _#omarchy-help_ na [Discordzie społeczności](https://omarchy.org/discord).
