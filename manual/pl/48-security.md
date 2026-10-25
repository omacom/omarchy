# Bezpieczeństwo

Omarchy traktuje bezpieczeństwo niezwykle poważnie. To ma być system operacyjny, którego możesz używać do _Prawdziwej Pracy_ w _Prawdziwym Świecie_. Taki, w którym zgubienie laptopa nie może prowadzić do awaryjnej sytuacji związanej z bezpieczeństwem. Oto więc, co robimy:

1. *Szyfrowanie całego dysku jest obowiązkowe*: To najważniejszy krok w celu zapewnienia fizycznej ochrony Twoich danych. Jeśli Twój komputer zostanie zgubiony lub ukradziony, dane są w pełni zaszyfrowane przy użyciu standardowego LUKS (Linux Unified Key Setup).
2. *Zapora sieciowa jest domyślnie włączona*: Cały ruch przychodzący jest domyślnie blokowany, z wyjątkiem portu 53317 dla [LocalSend](https://localsend.org/). Nawet ssh jest wyłączone, dopóki nie włączysz go przez _Konfiguracja > Bezpieczeństwo > SSHD_, co w ramach konfiguracji otwiera port 22 (z ograniczeniem liczby prób, aby chronić przed atakami brute force). Blokujemy nawet dostęp do Dockera, używając konfiguracji [ufw-docker](https://github.com/chaifeng/ufw-docker), aby zapobiec przypadkowemu wystawieniu Twoich kontenerów na świat.
3. *Arch zawsze ma najnowsze aktualizacje*: Arch, bazowa dystrybucja, na której zbudowano Omarchy, jest dystrybucją typu rolling release. Oznacza to, że każda luka bezpieczeństwa, która zostanie odkryta i załatana w dowolnym pakiecie, jest szybko dostępna do zainstalowania przy użyciu `omarchy-update`. W ten sposób zawsze używasz najnowszych, najbezpieczniejszych wersji wszystkiego.
4. *Omarchy utrzymuje własne pakiety i mirror*: Omarchy domyślnie polega wyłącznie na pakietach z własnych repozytoriów Archa core/extra/multilib oraz na własnym repozytorium pakietów Omarchy. Możesz instalować oprogramowanie bezpośrednio z AUR, ale instalacja bazowa tego nie robi — tylko kilka opcjonalnych instalacji, takich jak przeglądarki firm trzecich, pobiera pakiety z AUR.
5. *Cloudflare chroni nas przed DDoS*: Infrastruktura dystrybucji Omarchy — obrazy ISO, pakiety Omarchy, mirror Archa — jest chroniona za potężną tarczą anty-DDoS Cloudflare i hostowana w ich CDN. Zapewnia to doskonałą dostępność.

## Zmiana haseł

W zaszyfrowanej instalacji masz dwa hasła: jedno, które odblokowuje dysk przy starcie, oraz drugie, którym logujesz się i używasz z `sudo`. Konfiguracja ustawia je jako takie same. Oba można zmienić w _Aktualizacja > Hasło_ w menu Omarchy — _Szyfrowanie dysku_ dla pierwszego, _Użytkownik_ dla drugiego. Zmiana hasła dysku najpierw prosi o podanie bieżącego, więc miej je pod ręką. Jeśli zmiana zostanie przerwana, uruchom ponownie _Szyfrowanie dysku_: zapyta o hasło, które obecnie odblokowuje dysk, i dokończy zmianę.

## Przekazywanie komputera, którego już używałeś

Jeśli przekazujesz swój komputer komuś innemu, nie musisz instalować go ponownie. Uruchom _Konfiguracja > Resetuj komputer_ w menu Omarchy, wpisz `reset`, aby potwierdzić, i uruchom komputer ponownie. Spowoduje to usunięcie każdego konta użytkownika i wszystkiego w `/home`, odrzucenie wszystkich pakietów i zmian systemowych wprowadzonych od instalacji oraz wyczyszczenie tożsamości komputera — połączeń sieciowych, kluczy hosta i wszystkiego. Po ponownym uruchomieniu pojawi się kreator konfiguracji z pierwszego uruchomienia, gotowy, aby nowy właściciel wprowadził własną nazwę, hasło oraz hasło szyfrowania.

Działa to poprzez przywrócenie migawki bazowej wykonanej przez instalator, więc jest dostępne tylko na komputerach zainstalowanych z obrazu ISO Omarchy. A na dysku bez szyfrowania reset jest usunięciem, a nie bezpiecznym wymazaniem, więc jeśli dane były wrażliwe, zamiast tego wykonaj świeżą instalację.

## Sudo bez hasła

Czasami chcesz, aby `sudo` przestało pytać o hasło, najczęściej gdy agent AI wykonuje za Ciebie długi odcinek pracy systemowej. _Konfiguracja > Bezpieczeństwo > Sudo bez hasła_ pyta, jak długo zezwolić na dostęp: **15 minut**, **1 godzina**, **1 dzień** lub **Na stałe**. Czerwona ikona ostrzeżenia pojawia się obok pozostałych wskaźników paska menu, gdy dostęp jest aktywny. Kliknij ją lub ponownie uruchom polecenie, aby wyłączyć dostęp. Możesz także podać własną liczbę minut (od 1 do 1440) za pomocą `omarchy-sudo-passwordless 30` lub użyć `omarchy-sudo-passwordless permanent`.

Dostęp ograniczony czasowo wygasa automatycznie, w tym natychmiast po wznowieniu z uśpienia, które przekroczyło termin. Ponowne uruchomienie komputera kończy go wcześniej. Dostęp stały przetrwa ponowne uruchomienia i pozostaje włączony, dopóki go nie wyłączysz.

Aktualizacja lub usunięcie pakietu ustawień Omarchy kończy każde tymczasowe przyznanie dostępu, zanim zmieni się jego obsługa wygasania. Jeśli polecenie zgłosi błąd autoryzacji lub czyszczenia, rozwiąż go przed próbą włączenia kolejnego przyznania; błąd nie oznacza, że dostęp bez hasła jest nieaktywny.

Miej co do tego jasność: gdy jest to włączone, wszystko działające jako Twój użytkownik może zrobić wszystko jako root bez pytania. To jest cały sens i to jest też całe ryzyko.

## Klucze podpisywania

Klucz publiczny dla wszystkich podpisów ISO i pakietu repozytorium Omarchy to `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([sprawdź na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakiet `omarchy/omarchy-keyring` również go zawiera i będzie używany do płynnego wdrażania wszelkich potencjalnych aktualizacji.

Podpis dla każdego wydania ISO znajdziesz, dodając .sig do adresu URL. Na przykład https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
