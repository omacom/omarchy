# Bezpieczeństwo

Omarchy traktuje bezpieczeństwo niezwykle poważnie. To ma być system operacyjny, którego możesz używać do _Prawdziwej Pracy_ w _Prawdziwym Świecie_. Gdzie zgubienie laptopa nie może prowadzić do kryzysu bezpieczeństwa. Oto więc, co robimy:

1. *Szyfrowanie całego dysku jest obowiązkowe*: To najważniejszy krok ku fizycznej ochronie twoich danych. Jeśli twój komputer zostanie zgubiony albo skradziony, dane są w pełni zaszyfrowane standardowym LUKS (Linux Unified Key Setup).
2. *Zapora jest domyślnie włączona*: Cały ruch przychodzący jest domyślnie zablokowany z wyjątkiem portu 53317 dla [LocalSend](https://localsend.org/). Nawet ssh jest wyłączone, dopóki nie włączysz go przez _Ustawienia > Bezpieczeństwo > SSHD_, co w ramach konfiguracji otwiera port 22 (z ograniczeniem szybkości przeciwko atakom brute force). Blokujemy nawet dostęp do Dockera konfiguracją [ufw-docker](https://github.com/chaifeng/ufw-docker), aby zapobiec przypadkowemu wystawieniu twoich kontenerów na świat.
3. *Arch ma zawsze najnowsze aktualizacje*: Arch, dystrybucja, na której zbudowane jest Omarchy, jest dystrybucją kroczącą. Oznacza to, że każda luka bezpieczeństwa odkryta i załatana w dowolnym pakiecie jest szybko dostępna do zainstalowania poleceniem `omarchy-update`. Dzięki temu zawsze używasz najnowszych, najbezpieczniejszych wersji wszystkiego.
4. *Omarchy utrzymuje własne pakiety i serwer lustrzany*: Omarchy polega domyślnie tylko na pakietach z własnych repozytoriów Archa core/extra/multilib oraz własnego repozytorium pakietów Omarchy. Oprogramowanie możesz instalować wprost z AUR, ale instalacja podstawowa tego nie robi — tylko kilka opcjonalnych instalacji, jak przeglądarki firm trzecich, ciągnie z AUR.
5. *Cloudflare chroni nas przed DDoS*: Cała infrastruktura dystrybucji Omarchy — obrazy ISO, pakiety Omarchy, serwer lustrzany Archa — jest chroniona za potężną tarczą anty-DDoS Cloudflare i hostowana w ich sieci CDN. Zapewnia to znakomitą dostępność.

## Zmiana haseł

W instalacji zaszyfrowanej masz dwa hasła: to, które odblokowuje dysk przy rozruchu, i to, którym się logujesz i używasz `sudo`. Konfiguracja początkowa sprawia, że są takie same. Oba możesz zmienić w _Aktualizuj > Hasło_ w menu Omarchy — _Szyfrowanie dysku_ dla pierwszego, _Użytkownik_ dla drugiego. Zmiana hasła dysku najpierw pyta o bieżące, więc miej je pod ręką. Jeśli zmiana zostanie przerwana, uruchom _Szyfrowanie dysku_ ponownie: zapyta o hasło, które odblokowuje dysk teraz, i dokończy zmianę.

## Przekazywanie dalej komputera, którego już używałeś

Jeśli przekazujesz swój komputer komuś innemu, nie musisz go instalować od nowa. Uruchom _Ustawienia > Resetuj komputer_ w menu Omarchy, wpisz `reset`, aby potwierdzić, i zrestartuj komputer. To wymazuje każde konto użytkownika i wszystko w `/home`, wyrzuca wszystkie pakiety i zmiany systemu, które wprowadziłeś od instalacji, i czyści tożsamość komputera — połączenia sieciowe, klucze hosta i wszystko. To, co wraca, to kreator pierwszej konfiguracji z pierwszego rozruchu, gotowy, aby jego nowy właściciel wprowadził własne imię, hasło i hasło szyfrowania.

Działa to przez przywrócenie bazowej migawki, którą robi instalator, więc jest dostępne tylko na komputerach zainstalowanych z obrazu ISO Omarchy. A na dysku bez szyfrowania reset jest usunięciem, a nie bezpiecznym wymazaniem, więc jeśli dane były wrażliwe, zrób zamiast tego świeżą instalację.

## Sudo bez hasła

Czasem chcesz, aby `sudo` przestało pytać, najczęściej gdy agent AI wykonuje za ciebie długi odcinek pracy systemowej. _Ustawienia > Bezpieczeństwo > Sudo bez hasła_ pyta, jak długo zezwolić na dostęp: **15 minutes**, **1 Hour**, **1 Day** albo **Permanently**. Czerwona ikona ostrzeżenia pojawia się obok innych wskaźników paska menu, gdy dostęp jest aktywny. Kliknij ją albo uruchom polecenie ponownie, aby wyłączyć dostęp. Możesz też przekazać własną liczbę minut (od 1 do 1440) poleceniem `omarchy-sudo-passwordless 30` albo użyć `omarchy-sudo-passwordless permanent`.

Dostęp na czas wygasa automatycznie, w tym natychmiast po wznowieniu ze wstrzymania, które przekroczyło termin. Restart komputera kończy go wcześniej. Dostęp stały przetrwa restarty i pozostaje włączony, dopóki go nie wyłączysz.

Aktualizacja albo usunięcie pakietu ustawień Omarchy kończy każde tymczasowe przyznanie, zanim zmieni się obsługa jego wygasania. Jeśli polecenie zgłosi błąd autoryzacji albo czyszczenia, rozwiąż go, zanim spróbujesz włączyć kolejne przyznanie; błąd nie oznacza, że dostęp bez hasła jest nieaktywny.

Patrz na to trzeźwo: gdy jest włączone, wszystko, co działa jako twój użytkownik, może zrobić cokolwiek jako root bez pytania. Właśnie o to chodzi i właśnie w tym tkwi całe ryzyko.

## Klucze podpisywania

Klucz publiczny dla wszystkich podpisów ISO i pakietów repozytorium Omarchy to `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([zweryfikuj na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakiet `omarchy/omarchy-keyring` również go zawiera i zostanie użyty, aby bezproblemowo wprowadzić ewentualne aktualizacje.

Podpis dla dowolnego wydania ISO znajdziesz, dodając .sig do adresu URL. Na przykład https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
