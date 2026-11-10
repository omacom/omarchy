# Pierwsze kroki

Omarchy instaluje się przy użyciu ISO. Możesz wybrać między instalacją na całym dysku, która przejmuje cały dysk, a instalacją w wolnym miejscu, która umieszcza Omarchy w nieprzydzielonym miejscu na dysku — tak właśnie działa dual boot obok Windows lub innego systemu operacyjnego (zobacz [instalacja dual-boot](50-dual-boot-install.md) — pamiętaj, że najpierw musisz wyłączyć BitLocker w Windows). Tak czy inaczej, instalacja domyślnie obejmuje pełne szyfrowanie, a opcja całego dysku wyczyści wybrany dysk, więc koniecznie zrób kopię zapasową przed użyciem istniejącego dysku!

Najpierw [pobierz ISO Omarchy](https://omarchy.org/), umieść je na pamięci USB (użyj [Rufus](https://rufus.ie/) w Windows, [balenaEtcher](https://etcher.balena.io/) na Macu lub [caligula](https://github.com/ifd3f/caligula) w Linuxie) i uruchom komputer z tej pamięci.

_Musisz wyłączyć Secure Boot i/lub TPM w BIOS. Musisz je wyłączyć, aby móc zainstalować Omarchy. To microsoftowe mechanizmy bezpieczeństwa przeznaczone dla Windows i powiązanych z Microsoft dystrybucji Linuxa._

Następnie odpowiedz na pytania konfiguracyjne i potwierdź je w ten sposób:

 ![install-config](images/install-config.webp)

Następnie wybierz dysk do instalacji, usiądź wygodnie i oglądaj pokaz instalacji. Na najszybszych nowoczesnych maszynach może to zająć mniej niż minutę, ale nawet na starszym komputerze nie powinno to trwać dłużej niż 5 minut.

 ![install-done](images/install-done.webp)

Teraz jesteś gotowy na Omarchy!

### Używaj klawiatury przewodowej lub 2.4ghz!

Pełne szyfrowanie dysku nie pozwoli Ci wpisać hasła z klawiatury Bluetooth podczas uruchamiania. Tak samo jak nie możesz użyć klawiatury Bluetooth, aby wejść do BIOS na PC. Będziesz potrzebować klawiatury, która używa odbiornika 2.4ghz albo kabla (co i tak jest znacznie lepsze pod względem opóźnień!). Osobiście uwielbiam [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalacja dla innego właściciela

Jeśli konfigurujesz maszynę dla kogoś innego — członka rodziny, nowego pracownika, kupującego — nie powinieneś odpowiadać na osobiste pytania w jego imieniu. Naciśnij `Ctrl + C` na samym pierwszym ekranie instalatora (wybór klawiatury), a Omarchy zaproponuje przygotowanie maszyny dla innego właściciela. System instaluje się od razu, ale cała osobista konfiguracja — układ klawiatury, nazwa użytkownika, hasło — zostaje odłożona do pierwszego uruchomienia maszyny. Dysk nadal jest domyślnie szyfrowany, a hasło, które nowy właściciel wybierze przy tym pierwszym uruchomieniu, staje się również hasłem szyfrowania. (Maszynę, której już używałeś, można również przekazać bez ponownej instalacji — zobacz [resetowanie komputera](48-security.md).)

### Instalacje nienadzorowane

ISO może również zainstalować się całkowicie samodzielnie — bez klawiatury, bez kreatora — gdy otrzyma swoją konfigurację na drugim dysku. To sposób na traktowanie Omarchy jako obrazu bazowego dla VM i maszyn flotowych. Zobacz [instalacje nienadzorowane](51-unattended-installs.md).

### Instalacje bez szyfrowania

Omarchy jest domyślnie instalowane z szyfrowaniem. To bezpieczny, odpowiedzialny wybór dla każdego komputera, który może zostać zgubiony lub ukradziony. Nie chcesz, aby ktokolwiek z dostępem do Twojego sprzętu mógł dostać się do Twoich danych!

Ale w szczególnych okolicznościach, takich jak zdalne instalacje Omarchy na chronionych komputerach lub jednorazowe instalacje bez wrażliwych danych, możesz chcieć zainstalować system bez szyfrowania. Możesz nacisnąć `Ctrl + C` na potwierdzeniu formatowania dysku, aby przełączyć się na instalację bez szyfrowania.

### Język

Omarchy mówi w 50 językach — tym samym zestawie co omarchy.org — a angielski jest domyślny. Aby przełączyć język, otwórz menu Omarchy i przejdź do _Konfiguracja > Język_ lub uruchom `omarchy language <code>` w terminalu (`omarchy language list` pokazuje kody). Menu, pulpit i własne powiadomienia Omarchy zmieniają język natychmiast, a każda aplikacja otwarta później również się dostosowuje. Aplikacje, które były już otwarte, przełączą się po ich ponownym uruchomieniu.

### Pomoc, jeśli utkniesz

Jeśli utkniesz, zazwyczaj możesz znaleźć kogoś chętnego do pomocy na kanale _#omarchy-help_ na [społecznościowym Discordzie](https://omarchy.org/discord).
