# Bezpieczeństwo

Omarchy traktuje bezpieczeństwo niezwykle poważnie. To ma być system operacyjny, którego możesz używać do _Prawdziwej Pracy_ w _Prawdziwym Świecie_. W którym zgubienie laptopa nie może prowadzić do kryzysu bezpieczeństwa. Oto co robimy:

1. *Szyfrowanie całego dysku jest domyślnie włączone*: To najważniejszy krok w zapewnieniu fizycznej ochrony Twoich danych. Jeśli Twój komputer zostanie zgubiony lub ukradziony, dane są w pełni zaszyfrowane przy użyciu standardowego LUKS (Linux Unified Key Setup). Instalator pozwala z tego zrezygnować w przypadku maszyn jednorazowych (zobacz [Pierwsze kroki](02-getting-started.md)); instalacja bez szyfrowania nie ma żadnej z tej ochrony, a każdy, kto trzyma dysk, może go odczytać.
2. *Zapora jest domyślnie włączona*: Cały ruch przychodzący jest domyślnie blokowany, z kilkoma wyjątkami: port 53317 dla [LocalSend](https://localsend.org/); zapytania DNS do własnego resolvera komputera pod adresem mostka Docker (172.17.0.1), akceptowane z zakresów adresów prywatnych, które Docker przydziela swoim kontenerom; oraz multicast DNS (port 5353), który pozwala drukarkom i innym urządzeniom w Twojej sieci znajdować się nawzajem, a także rozgłasza tam nazwę Twojego komputera. Poza tym zapora zachowuje standardowe zezwolenia UFW dla ping, pobierania adresu z Twojego routera (DHCP) i wykrywania UPnP. Nawet ssh jest wyłączone, dopóki nie włączysz go przez _Setup > Security > SSHD_, co w ramach konfiguracji otwiera port 22 (z ograniczeniem liczby prób przeciwko brute force). Blokujemy nawet dostęp do Dockera przy użyciu konfiguracji [ufw-docker](https://github.com/chaifeng/ufw-docker), aby zapobiec przypadkowemu wystawieniu Twoich kontenerów na świat.
3. *Arch zawsze ma najnowsze aktualizacje*: Arch, dystrybucja bazowa, na której zbudowane jest Omarchy, jest dystrybucją typu rolling. Oznacza to, że każda luka w zabezpieczeniach, która zostanie odkryta i załatana w dowolnym pakiecie, jest szybko dostępna do zainstalowania przy użyciu `omarchy-update`. W ten sposób zawsze używasz najnowszych, najbezpieczniejszych wersji wszystkiego.
4. *Omarchy utrzymuje własne pakiety i mirror*: Omarchy domyślnie opiera się wyłącznie na pakietach z repozytoriów core/extra/multilib samego Arch oraz z własnego Omarchy Package Repository. Możesz instalować oprogramowanie bezpośrednio z AUR, ale instalacja bazowa tego nie robi — tylko kilka opcjonalnych instalacji, takich jak przeglądarki innych firm, pobiera oprogramowanie z AUR.
5. *Cloudflare chroni nas przed DDoS*: Infrastruktura dystrybucji Omarchy — obrazy ISO, pakiety Omarchy, mirror Arch — jest chroniona za potężną tarczą przeciw DDoS firmy Cloudflare i hostowana w jej CDN. Zapewnia to doskonałą dostępność.

## Zmiana haseł

Na zaszyfrowanej instalacji masz dwa hasła: jedno, które odblokowuje dysk przy starcie, i drugie, którym się logujesz i używasz z `sudo`. Instalator ustawia je na takie same. Oba można zmienić w _Update > Password_ w menu Omarchy — _Drive Encryption_ dla pierwszego, _User_ dla drugiego. Zmiana hasła dysku najpierw wymaga podania obecnego, więc miej je pod ręką. Jeśli zmiana zostanie przerwana, uruchom ponownie _Drive Encryption_: poprosi o hasło, które obecnie odblokowuje dysk, i dokończy zmianę.

## Przekazywanie komputera, którego już używałeś

Jeśli przekazujesz swój komputer komuś innemu, nie musisz go ponownie instalować. Uruchom _Remove > Factory Reset_ w menu Omarchy, wpisz `reset`, aby potwierdzić, i uruchom ponownie. To usuwa każde konto użytkownika i wszystko w `/home`, odrzuca wszystkie pakiety i zmiany systemowe, które wprowadziłeś od instalacji, oraz czyści tożsamość komputera — połączenia sieciowe, klucze hosta i wszystko. To, co się uruchomi, to kreator konfiguracji z pierwszego uruchomienia, gotowy, aby nowy właściciel wprowadził własne imię i nazwisko, hasło oraz hasło szyfrowania.

Działa to poprzez przywrócenie migawki bazowej, którą wykonuje instalator, więc jest dostępne tylko na komputerach zainstalowanych z obrazu ISO Omarchy. A na dysku bez szyfrowania reset jest usunięciem, a nie bezpiecznym wymazaniem, więc jeśli dane były wrażliwe, zamiast tego wykonaj świeżą instalację.

## Sudo bez hasła

Czasami chcesz, aby `sudo` przestało pytać, najczęściej gdy agent AI wykonuje dla Ciebie długi fragment pracy systemowej. _Setup > Security > Passwordless Sudo_ pyta, jak długo zezwolić na dostęp: **15 minut**, **1 godzina**, **1 dzień** lub **Na stałe**. Czerwona ikona ostrzegawcza pojawia się obok pozostałych wskaźników paska menu, gdy dostęp jest aktywny. Kliknij ją lub uruchom polecenie ponownie, aby wyłączyć dostęp. Możesz także podać własną liczbę minut (od 1 do 1440) za pomocą `omarchy-sudo-passwordless 30` lub użyć `omarchy-sudo-passwordless permanent`.

Dostęp czasowy wygasa automatycznie, w tym natychmiast po wznowieniu z uśpienia, które przekroczyło termin. Ponowne uruchomienie komputera kończy go wcześniej. Dostęp stały przetrwa ponowne uruchomienia i pozostaje włączony, dopóki go nie wyłączysz.

Aktualizacja lub usunięcie pakietu ustawień Omarchy kończy każde tymczasowe zezwolenie, zanim zmieni się jego obsługa wygasania. Jeśli polecenie zgłosi błąd autoryzacji lub czyszczenia, rozwiąż go przed próbą włączenia kolejnego zezwolenia; błąd nie oznacza, że dostęp bez hasła jest nieaktywny.

Miej co do tego jasność: gdy jest włączone, wszystko działające jako Twój użytkownik może zrobić wszystko jako root bez pytania. To jest cały sens i to jest też całe ryzyko.

## Klucze podpisywania

Klucz publiczny dla wszystkich podpisów ISO i pakietu repozytorium Omarchy to `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([zweryfikuj na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakiet `omarchy/omarchy-keyring` również go zawiera i będzie używany do bezproblemowego wdrażania wszelkich potencjalnych aktualizacji.

Podpis dla dowolnego wydania ISO znajdziesz, dodając `.sig` do jego adresu URL, na przykład `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
