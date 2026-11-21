# Bezpieczeństwo

Omarchy traktuje bezpieczeństwo niezwykle poważnie. Ma to być system operacyjny, którego możesz używać do _Prawdziwej Pracy_ w _Prawdziwym Świecie_. Gdzie utrata laptopa nie może prowadzić do kryzysu bezpieczeństwa. Oto co robimy:

1. *Szyfrowanie całego dysku jest domyślnie włączone*: To najważniejszy krok w zapewnieniu fizycznej ochrony Twoich danych. Jeśli Twój komputer zostanie zgubiony lub ukradziony, dane są w pełni zaszyfrowane przy użyciu standardowego LUKS (Linux Unified Key Setup). Instalator pozwala zrezygnować z tego w przypadku maszyn jednorazowych (zobacz [Pierwsze kroki](02-getting-started.md)); instalacja bez szyfrowania nie zapewnia żadnej z tej ochrony, a każdy, kto ma dysk, może go odczytać.
2. *Zapora sieciowa jest domyślnie włączona*: Cały ruch przychodzący jest domyślnie blokowany, z kilkoma wyjątkami: port 53317 dla [LocalSend](https://localsend.org/); zapytania DNS do własnego resolvera komputera pod adresem mostu Docker (172.17.0.1), akceptowane z prywatnych zakresów adresów, które Docker przydziela swoim kontenerom; oraz multicast DNS (port 5353), który pozwala drukarkom i innym urządzeniom w Twojej sieci odnajdywać się nawzajem, a także rozgłasza tam nazwę Twojego komputera. Oprócz tego zapora sieciowa zachowuje standardowe zezwolenia UFW dla ping, uzyskiwania adresu z routera (DHCP) oraz wykrywania UPnP. Nawet ssh jest wyłączone, dopóki nie włączysz go przez _Setup > Security > SSHD_, co autoryzuje Twój klucz SSH, wyłącza logowanie hasłem i dopiero wtedy otwiera port 22 (z ograniczeniem szybkości przeciwko brute force). Blokujemy nawet dostęp do Docker przy użyciu konfiguracji [ufw-docker](https://github.com/chaifeng/ufw-docker), aby zapobiec przypadkowemu wystawieniu Twoich kontenerów na świat.
3. *Arch zawsze ma najnowsze aktualizacje*: Arch, podstawowa dystrybucja, na której zbudowano Omarchy, jest dystrybucją rolling. Oznacza to, że każda luka bezpieczeństwa, która zostanie odkryta i załatana w dowolnym pakiecie, jest szybko dostępna do zainstalowania przy użyciu `omarchy-update`. W ten sposób zawsze używasz najnowszych, najbezpieczniejszych wersji wszystkiego.
4. *Omarchy utrzymuje własne pakiety i mirror*: Omarchy domyślnie polega wyłącznie na pakietach z własnych repozytoriów Arch core/extra/multilib (repozytoriów Arch Linux ARM na maszynach ARM oraz Asahi ALARM na Apple Silicon) oraz własnego Omarchy Package Repository. Możesz instalować oprogramowanie bezpośrednio z AUR, ale instalacja podstawowa tego nie robi — tylko kilka opcjonalnych instalacji, takich jak przeglądarki firm trzecich, pobiera z AUR.
5. *Cloudflare chroni nas przed DDoS*: Infrastruktura dystrybucji Omarchy — pliki ISO, pakiety Omarchy, mirror Arch — jest chroniona za potężną tarczą DDoS Cloudflare i hostowana w ich sieci CDN. Zapewnia to doskonałą dostępność.

## Zmiana haseł

W instalacji z szyfrowaniem masz dwa hasła: jedno, które odblokowuje dysk podczas uruchamiania, oraz drugie, którym się logujesz i używasz z `sudo`. Kreator konfiguracji ustawia je jako takie same. Oba można zmienić w sekcji _Update > Password_ w menu Omarchy — _Drive Encryption_ dla pierwszego, _User_ dla drugiego. Zmiana hasła dysku najpierw wymaga podania bieżącego, więc miej je pod ręką. Jeśli zmiana zostanie przerwana, uruchom _Drive Encryption_ ponownie: zapyta o hasło, które obecnie odblokowuje dysk, i dokończy zmianę.

## Przekazywanie maszyny, której już używałeś

Jeśli przekazujesz swoją maszynę komuś innemu, nie musisz jej ponownie instalować. Uruchom _Remove > Factory Reset_ w menu Omarchy, wpisz `reset`, aby potwierdzić, wprowadź hasło szyfrowania dysku, jeśli zostaniesz o to poproszony, i uruchom ponownie. Spowoduje to usunięcie każdego konta użytkownika i wszystkiego w `/home`, odrzucenie wszystkich pakietów i zmian systemowych wprowadzonych od instalacji oraz wyczyszczenie tożsamości maszyny — połączeń sieciowych, kluczy hosta i wszystkiego. Po ponownym uruchomieniu pojawi się kreator konfiguracji z pierwszego uruchomienia, gotowy, aby nowy właściciel wprowadził własne imię i nazwisko, hasło i hasło szyfrowania.

Działa to poprzez przywrócenie podstawowej migawki wykonanej przez instalator, więc jest dostępne tylko na maszynach zainstalowanych z Omarchy ISO. A na dysku bez szyfrowania reset jest usunięciem, a nie bezpiecznym wymazaniem, więc jeśli dane były wrażliwe, wykonaj zamiast tego czystą instalację.

## Sudo bez hasła

Czasami chcesz, aby `sudo` przestało pytać, najczęściej gdy agent AI wykonuje dla Ciebie długi odcinek pracy systemowej. _Setup > Security > Passwordless Sudo_ pyta, jak długo zezwolić na dostęp: **15 minut**, **1 Godzina**, **1 Dzień** lub **Na stałe**. Czerwona ikona ostrzeżenia pojawia się obok innych wskaźników paska menu, gdy dostęp jest aktywny. Kliknij ją lub ponownie uruchom polecenie, aby wyłączyć dostęp. Możesz także podać własną liczbę minut (od 1 do 1440) za pomocą `omarchy-sudo-passwordless 30` lub użyć `omarchy-sudo-passwordless permanent`.

Dostęp czasowy wygasa automatycznie, w tym natychmiast po wznowieniu z uśpienia, które przekroczyło termin. Ponowne uruchomienie komputera kończy go wcześniej. Dostęp stały przetrwa ponowne uruchomienia i pozostanie włączony, dopóki go nie wyłączysz.

Aktualizacja lub usunięcie pakietu ustawień Omarchy kończy każde tymczasowe przyznanie dostępu, zanim zmieni się obsługa jego wygasania. Jeśli polecenie zgłosi błąd autoryzacji lub czyszczenia, rozwiąż go przed próbą włączenia kolejnego przyznania; błąd nie oznacza, że dostęp bez hasła jest nieaktywny.

Miej co do tego jasność: gdy jest włączony, wszystko, co działa jako Twój użytkownik, może zrobić wszystko jako root bez pytania. To cały sens i to także całe ryzyko.

## Klucze podpisywania

Klucz publiczny dla wszystkich podpisów ISO i pakietów repozytorium Omarchy to `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([zweryfikuj na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakiet `omarchy/omarchy-keyring` również go zawiera i będzie używany do bezproblemowego wdrażania wszelkich potencjalnych aktualizacji.

Podpis dla dowolnego wydania ISO znajdziesz, dodając `.sig` do jego adresu URL, na przykład `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
