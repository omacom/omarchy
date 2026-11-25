# Pierwsze kroki

Omarchy instaluje się przy użyciu ISO. Możesz wybrać instalację na całym dysku, która przejmuje cały dysk, albo instalację w wolnym miejscu, która umieszcza Omarchy w nieprzydzielonym miejscu na dysku — w ten sposób uruchomisz ją w trybie dual boot obok Windowsa lub innego systemu operacyjnego (zobacz [instalacja dual boot](50-dual-boot-install.md) — pamiętaj, że najpierw musisz wyłączyć BitLocker w Windowsie). Tak czy inaczej, instalacja domyślnie stosuje pełne szyfrowanie, a opcja całego dysku wyczyści wybrany dysk, więc przed użyciem istniejącego dysku koniecznie zrób kopię zapasową!

Na Macu z Apple Silicon instalujesz zamiast tego z poziomu macOS, bez ISO ani pamięci USB. Zobacz [Omarchy dla Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

Najpierw [pobierz ISO Omarchy](https://omarchy.org/), umieść je na pamięci USB (użyj [Rufus](https://rufus.ie/) w Windowsie, [balenaEtcher](https://etcher.balena.io/) na Macu albo [caligula](https://github.com/ifd3f/caligula) w Linuksie) i uruchom komputer z tej pamięci.

_Musisz wyłączyć Secure Boot i/lub TPM w BIOS-ie. Musisz je wyłączyć, żeby móc zainstalować Omarchy. To schematy bezpieczeństwa Microsoftu, przeznaczone dla Windowsa i dystrybucji Linuksa powiązanych z Microsoftem._

Następnie odpowiedz na pytania konfiguracyjne i potwierdź je w ten sposób:

 ![install-config](images/install-config.webp)

Następnie wybierz dysk do instalacji, usiądź wygodnie i oglądaj widowisko instalacji. Na najszybszych nowoczesnych maszynach może to potrwać mniej niż minutę, ale nawet na starszym komputerze nie powinno zająć więcej niż 5 minut.

 ![install-done](images/install-done.webp)

Teraz jesteś gotowy na Omarchy!

### Używaj klawiatury przewodowej albo 2.4ghz!

Pełne szyfrowanie dysku nie pozwoli Ci wpisać hasła z klawiatury Bluetooth podczas uruchamiania. Tak samo jak nie możesz użyć klawiatury Bluetooth, żeby wejść do BIOS-u na PC. Będziesz potrzebować klawiatury, która używa dongle'a 2.4ghz albo kabla (co i tak jest znacznie przyjemniejsze ze względu na opóźnienia!). Osobiście uwielbiam [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalowanie dla innego właściciela

Jeśli przygotowujesz maszynę dla kogoś innego — członka rodziny, nowego pracownika, kupującego — nie powinieneś odpowiadać na osobiste pytania w jego imieniu. Naciśnij `Ctrl + C` na samym pierwszym ekranie instalatora (wybór klawiatury), a Omarchy zaproponuje zamiast tego przygotowanie maszyny dla innego właściciela. System zainstaluje się od razu, ale cała osobista konfiguracja — układ klawiatury, nazwa użytkownika, hasło — zostanie odłożona do momentu, aż maszyna uruchomi się po raz pierwszy. Dysk nadal jest domyślnie szyfrowany, a hasło, które nowy właściciel wybierze przy tym pierwszym uruchomieniu, stanie się również hasłem szyfrowania. (Maszynę, której już używałeś, też można przekazać bez ponownej instalacji — zobacz [resetowanie komputera](48-security.md).)

### Instalacje nienadzorowane

ISO może też zainstalować się całkowicie samodzielnie — bez klawiatury, bez kreatora — gdy otrzyma swoją konfigurację na drugim dysku. W ten sposób możesz traktować Omarchy jako obraz bazowy dla VM i flot maszyn. Zobacz [instalacje nienadzorowane](51-unattended-installs.md).

### Instalacje bez szyfrowania

Omarchy jest domyślnie instalowane z szyfrowaniem. To bezpieczny, odpowiedzialny wybór dla każdego komputera, który może zostać zgubiony lub ukradziony. Nie chcesz, żeby ktokolwiek z dostępem do Twojego sprzętu mógł dostać się do Twoich danych!

Ale w szczególnych okolicznościach, takich jak zdalne instalacje Omarchy na chronionych komputerach albo instalacje jednorazowe bez wrażliwych danych, możesz chcieć zainstalować system bez szyfrowania. Możesz nacisnąć `Ctrl + C` na ekranie potwierdzenia formatowania dysku, żeby przełączyć się na instalację bez szyfrowania.

### Język

Omarchy mówi w 50 językach — w tym samym zestawie co omarchy.org — a angielski jest językiem domyślnym. Aby go zmienić, otwórz menu Omarchy i przejdź do _Konfiguracja > Region > Język_ albo uruchom w terminalu `omarchy language <code>` (`omarchy language list` pokazuje kody). Menu, pulpit i własne powiadomienia Omarchy zmienią język od razu, a każda aplikacja otwarta później też się do niego dostosuje. Aplikacje, które były już otwarte, zmienią język po ich ponownym uruchomieniu.

Aby zachować język, ale zapisywać daty, godziny, liczby, kwoty, jednostki i rozmiary papieru tak, jak robi to inny region (powiedzmy: angielski z europejskimi datami i zegarem 24-godzinnym), wybierz region w _Konfiguracja > Region > Formaty_, gdzie każda opcja pokazuje próbkę, albo uruchom `omarchy region formats <code>` (`omarchy region formats list` pokazuje kody). Opcja _Tak samo jak język_ wraca do formatów właściwych dla danego języka. Podobnie jak w przypadku zmiany języka, dotyczy to aplikacji otwieranych później.

### Pomoc, jeśli utkniesz

Jeśli utkniesz, zazwyczaj znajdziesz kogoś chętnego do pomocy na kanale _#omarchy-help_ na [społecznościowym Discordzie](https://omarchy.org/discord).
