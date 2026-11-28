# Bezpieczeństwo

Omarchy traktuje bezpieczeństwo niezwykle poważnie. Ma to być system operacyjny, którego możesz używać do _Prawdziwej Pracy_ w _Prawdziwym Świecie_. W którym zgubienie laptopa nie może prowadzić do kryzysu bezpieczeństwa. Oto więc, co robimy:

1. *Szyfrowanie całego dysku jest domyślnie włączone*: To najważniejszy krok w zabezpieczaniu fizycznej ochrony Twoich danych. Jeśli komputer zostanie zgubiony lub ukradziony, dane są w pełni zaszyfrowane przy użyciu standardowego LUKS (Linux Unified Key Setup). Instalator pozwala zrezygnować z tego w przypadku maszyn jednorazowych (zobacz [Pierwsze kroki](02-getting-started.md)); instalacja bez szyfrowania nie ma żadnej z tych zabezpieczeń, a każdy, kto ma dysk w rękach, może go odczytać.
2. *Zapora sieciowa jest domyślnie włączona*: Cały ruch przychodzący jest domyślnie blokowany, z kilkoma wyjątkami: port 53317 dla [LocalSend](https://localsend.org/); zapytania DNS do własnego resolvera komputera pod adresem mostka Docker (172.17.0.1), przyjmowane z prywatnych zakresów adresów, które Docker przydziela swoim kontenerom; oraz multicast DNS (port 5353), który pozwala drukarkom i innym urządzeniom w Twojej sieci odnajdywać się nawzajem, a także rozgłasza tam nazwę Twojego komputera. Poza tym zapora zachowuje standardowe zezwolenia UFW dla ping, pobierania adresu z routera (DHCP) oraz wykrywania UPnP. Nawet ssh jest wyłączone, dopóki nie włączysz go przez _Konfiguracja > Bezpieczeństwo > SSHD_, co autoryzuje Twój klucz SSH, wyłącza logowanie hasłem i dopiero wtedy otwiera port 22 (z ograniczeniem szybkości przeciwko atakom brute force). Blokujemy nawet dostęp do Docker przy użyciu konfiguracji [ufw-docker](https://github.com/chaifeng/ufw-docker), aby zapobiec przypadkowemu wystawieniu Twoich kontenerów na świat.
3. *Arch zawsze ma najnowsze aktualizacje*: Arch, bazowa dystrybucja, na której zbudowano Omarchy, jest dystrybucją typu rolling release. Oznacza to, że każda luka bezpieczeństwa, która zostanie odkryta i załatana w dowolnym pakiecie, jest szybko dostępna do instalacji przy użyciu `omarchy-update`. W ten sposób zawsze używasz najnowszych, najbezpieczniejszych wersji wszystkiego.
4. *Omarchy utrzymuje własne pakiety i mirror*: Omarchy domyślnie polega wyłącznie na pakietach z własnych repozytoriów Arch core/extra/multilib (Arch Linux ARM na maszynach ARM oraz Asahi ALARM na Apple Silicon) oraz własnego Omarchy Package Repository. Możesz instalować oprogramowanie bezpośrednio z AUR, ale instalacja bazowa tego nie robi — tylko kilka opcjonalnych instalacji, takich jak przeglądarki firm trzecich, pobiera z AUR.
5. *Cloudflare chroni nas przed DDoS*: Infrastruktura dystrybucji Omarchy — obrazy ISO, pakiety Omarchy, mirror Arch — jest chroniona za potężną tarczą anty-DDoS Cloudflare i hostowana w ich CDN. Zapewnia to doskonałą dostępność.

## Zmiana haseł

Masz dwa hasła w instalacji z szyfrowaniem: jedno, które odblokowuje dysk przy starcie, i drugie, którym się logujesz i używasz z `sudo`. Konfigurator ustawia je jako takie same. _Aktualizacja > Hasło_ w menu Omarchy zmienia oba naraz, więc pozostają takie same: pyta o bieżące hasło dysku, potem o nowe, zmienia hasło dysku, a następnie ustawia Twoje hasło logowania tak, aby pasowało. Bez szyfrowania dysku zmienia tylko Twoje hasło logowania. Jeśli zmiana zostanie przerwana, uruchom ponownie _Aktualizacja > Hasło_: zapyta o hasło, które obecnie odblokowuje dysk, dokończy zmianę i ustawi Twoje hasło logowania na to hasło. Aby zmienić hasło innego zaszyfrowanego dysku, uruchom `omarchy-drive-password` w terminalu.

## Przekazywanie komputera, którego już używałeś

Jeśli przekazujesz swój komputer komuś innemu, nie musisz go ponownie instalować. Uruchom _Usuń > Przywrócenie ustawień fabrycznych_ w menu Omarchy, wpisz `reset`, aby potwierdzić, wprowadź hasło szyfrowania dysku, jeśli zostaniesz o to poproszony, i uruchom ponownie komputer. Spowoduje to usunięcie każdego konta użytkownika i wszystkiego w `/home`, odrzucenie wszystkich pakietów i zmian systemowych wprowadzonych od instalacji oraz wyczyszczenie tożsamości komputera — połączeń sieciowych, kluczy hosta i wszystkiego. To, co się uruchomi, to kreator konfiguracji z pierwszego uruchomienia, gotowy, aby nowy właściciel wprowadził własne imię i nazwisko, hasło oraz hasło szyfrowania.

Działa to poprzez przywrócenie bazowej migawki wykonanej przez instalator, więc jest dostępne tylko na komputerach zainstalowanych z obrazu ISO Omarchy. A na dysku bez szyfrowania reset jest usunięciem danych, a nie bezpiecznym wymazaniem, więc jeśli dane były wrażliwe, zamiast tego wykonaj świeżą instalację.

## Sudo bez hasła

Czasami chcesz, aby `sudo` przestało pytać, najczęściej gdy agent AI wykonuje dla Ciebie długi odcinek pracy systemowej. _Konfiguracja > Bezpieczeństwo > Sudo bez hasła_ pyta, na jak długo zezwolić na dostęp: **15 minut**, **1 godzina**, **1 dzień** lub **na stałe**. Czerwona ikona ostrzegawcza pojawia się obok pozostałych wskaźników paska menu, gdy dostęp jest aktywny. Kliknij ją lub uruchom polecenie ponownie, aby wyłączyć dostęp. Możesz także podać własną liczbę minut (od 1 do 1440) za pomocą `omarchy-sudo-passwordless 30` lub użyć `omarchy-sudo-passwordless permanent`.

Dostęp czasowy wygasa automatycznie, w tym natychmiast po wznowieniu z uśpienia, które przekroczyło termin. Ponowne uruchomienie komputera kończy go wcześniej. Dostęp stały przetrwa ponowne uruchomienia i pozostaje włączony, dopóki go nie wyłączysz.

Aktualizacja lub usunięcie pakietu ustawień Omarchy kończy każde tymczasowe przyznanie dostępu, zanim zmieni się obsługa jego wygaśnięcia. Jeśli polecenie zgłosi błąd autoryzacji lub czyszczenia, rozwiąż go przed próbą włączenia kolejnego przyznania; błąd nie oznacza, że dostęp bez hasła jest nieaktywny.

Bądź tego w pełni świadomy: gdy jest włączone, wszystko działające jako Twój użytkownik może zrobić wszystko jako root bez pytania. To jest cały sens i to jest też całe ryzyko.

## Klucze podpisywania

Klucz publiczny dla wszystkich podpisów ISO i pakietów repozytorium Omarchy to `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([zweryfikuj na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakiet `omarchy/omarchy-keyring` również go zawiera i będzie używany do bezproblemowego wdrażania wszelkich potencjalnych aktualizacji.

Podpis dla dowolnego wydania ISO znajdziesz, dodając `.sig` do jego adresu URL, np. `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
