# Bezpieczeństwo

Omarchy traktuje bezpieczeństwo niezwykle poważnie. To ma być system operacyjny, którego możesz używać do _Prawdziwej Pracy_ w _Prawdziwym Świecie_. Gdzie zgubienie laptopa nie może prowadzić do awaryjnej sytuacji związanej z bezpieczeństwem. Oto co robimy:

1. *Szyfrowanie całego dysku jest włączone domyślnie*: To najważniejszy krok w zabezpieczeniu fizycznej ochrony Twoich danych. Jeśli Twój komputer zostanie zgubiony lub ukradziony, dane są w pełni zaszyfrowane przy użyciu standardowego LUKS (Linux Unified Key Setup). Instalator pozwala zrezygnować z tego w przypadku maszyn przeznaczonych do wyrzucenia (zobacz [Pierwsze kroki](02-getting-started.md)); instalacja bez szyfrowania nie ma żadnej z tych zabezpieczeń i każdy, kto trzyma dysk, może go odczytać.
2. *Zapora sieciowa jest włączona domyślnie*: Cały ruch przychodzący jest domyślnie blokowany, z kilkoma wyjątkami: port 53317 dla [LocalSend](https://localsend.org/); zapytania DNS do własnego resolvera komputera pod adresem mostka Docker (172.17.0.1), przyjmowane z prywatnych zakresów adresów, które Docker przydziela swoim kontenerom; oraz multicast DNS (port 5353), który pozwala drukarkom i innym urządzeniom w Twojej sieci odnajdywać się nawzajem, a także rozgłasza tam nazwę Twojego komputera. Oprócz tego zapora zachowuje standardowe zezwolenia UFW dla pingu, pobierania adresu z routera (DHCP) oraz wykrywania UPnP. Nawet ssh jest wyłączone, dopóki nie włączysz go przez _Setup > Security > SSHD_, co otwiera port 22 (z ograniczeniem liczby prób, chroniącym przed atakami brute force) jako część konfiguracji. Ograniczamy nawet dostęp do Dockera, używając konfiguracji [ufw-docker](https://github.com/chaifeng/ufw-docker), aby zapobiec przypadkowemu wystawieniu Twoich kontenerów na świat.
3. *Arch zawsze ma najnowsze aktualizacje*: Arch, podstawowa dystrybucja, na której zbudowano Omarchy, jest dystrybucją typu rolling. Oznacza to, że każda luka w zabezpieczeniach, która zostanie odkryta i załatana w dowolnym pakiecie, jest szybko dostępna do instalacji przy użyciu `omarchy-update`. W ten sposób zawsze korzystasz z najnowszych, najbezpieczniejszych wersji wszystkiego.
4. *Omarchy utrzymuje własne pakiety i mirror*: Omarchy domyślnie polega wyłącznie na pakietach z własnych repozytoriów Arch core/extra/multilib oraz własnego Omarchy Package Repository. Możesz instalować oprogramowanie bezpośrednio z AUR, ale instalacja podstawowa tego nie robi — tylko kilka opcjonalnych instalacji, takich jak przeglądarki firm trzecich, pobiera z AUR.
5. *Cloudflare chroni nas przed DDoS*: Infrastruktura dystrybucji Omarchy — obrazy ISO, pakiety Omarchy, mirror Archa — jest chroniona za potężną tarczą anty-DDoS firmy Cloudflare i hostowana w ich CDN. Zapewnia to doskonałą dostępność.

## Zmiana haseł

W instalacji z szyfrowaniem masz dwa hasła: jedno odblokowuje dysk przy starcie, a drugie służy do logowania i `sudo`. Kreator konfiguracji ustawia je jako takie same. Oba można zmienić w menu Omarchy w _Update > Password_ — _Drive Encryption_ dla pierwszego, _User_ dla drugiego. Zmiana hasła dysku najpierw wymaga podania obecnego, więc miej je pod ręką. Jeśli zmiana zostanie przerwana, uruchom ponownie _Drive Encryption_: poprosi o hasło, które obecnie odblokowuje dysk, i dokończy zmianę.

## Przekazywanie komputera, którego już używałeś

Jeśli przekazujesz swój komputer komuś innemu, nie musisz go ponownie instalować. Uruchom _Setup > Reset Computer_ w menu Omarchy, wpisz `reset`, aby potwierdzić, i uruchom komputer ponownie. Spowoduje to usunięcie każdego konta użytkownika i wszystkiego w `/home`, odrzucenie wszystkich pakietów i zmian systemowych, które wprowadziłeś od czasu instalacji, oraz wyczyszczenie tożsamości komputera — połączeń sieciowych, kluczy hosta i wszystkiego. Po ponownym uruchomieniu pojawi się kreator konfiguracji z pierwszego uruchomienia, gotowy, aby nowy właściciel wprowadził własne imię i nazwisko, hasło oraz hasło szyfrowania.

Działa to poprzez przywrócenie migawki bazowej, którą wykonuje instalator, więc jest dostępne tylko na komputerach zainstalowanych z obrazu ISO Omarchy. A na dysku bez szyfrowania reset jest usunięciem, a nie bezpiecznym wymazaniem, więc jeśli dane były wrażliwe, zamiast tego wykonaj świeżą instalację.

## Sudo bez hasła

Czasami chcesz, aby `sudo` przestało pytać, najczęściej gdy agent AI wykonuje dla Ciebie długi odcinek pracy systemowej. _Setup > Security > Passwordless Sudo_ pyta, jak długo zezwolić na dostęp: **15 minutes**, **1 Hour**, **1 Day** lub **Permanently**. Gdy dostęp jest aktywny, obok pozostałych wskaźników paska menu pojawia się czerwona ikona ostrzeżenia. Kliknij ją lub uruchom polecenie ponownie, aby wyłączyć dostęp. Możesz także podać własną liczbę minut (od 1 do 1440) za pomocą `omarchy-sudo-passwordless 30` lub użyć `omarchy-sudo-passwordless permanent`.

Dostęp czasowy wygasa automatycznie, w tym natychmiast po wznowieniu z uśpienia, które przekroczyło termin. Ponowne uruchomienie komputera kończy go wcześniej. Dostęp stały przetrwa ponowne uruchomienia i pozostaje włączony, dopóki go nie wyłączysz.

Aktualizacja lub usunięcie pakietu ustawień Omarchy kończy każde tymczasowe przyznanie dostępu, zanim zmieni się jego obsługa wygaśnięcia. Jeśli polecenie zgłosi błąd autoryzacji lub czyszczenia, rozwiąż go przed próbą włączenia kolejnego przyznania dostępu; błąd nie oznacza, że dostęp bez hasła jest nieaktywny.

Bądź tego w pełni świadomy: gdy jest to włączone, wszystko działające jako Twój użytkownik może wykonać wszystko jako root bez pytania. To cały sens i to także całe ryzyko.

## Klucze podpisywania

Klucz publiczny dla wszystkich podpisów ISO i pakietu repozytorium Omarchy to `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([zweryfikuj na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakiet `omarchy/omarchy-keyring` również go zawiera i zostanie użyty do bezproblemowego wdrożenia wszelkich potencjalnych aktualizacji.

Podpis dla dowolnego wydania ISO znajdziesz, dodając `.sig` do jego adresu URL, na przykład `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
