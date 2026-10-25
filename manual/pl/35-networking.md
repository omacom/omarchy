# Sieć

Siecią w Omarchy zarządza NetworkManager, a obsługujesz ją za pomocą ikony sieci na [górnym pasku](05-the-top-bar.md) lub skrótu `Super + Ctrl + N`.

Ten panel wyszukuje sieci Wi-Fi, pokazuje siłę sygnału i łączy z nimi. Ethernet nie wymaga absolutnie niczego — podłączasz kabel i działa. Jeśli wolisz zostać w terminalu, `nmtui` daje ci te same możliwości, a do tego istnieje grupa poleceń `omarchy network`.

## Udostępnianie Wi-Fi

Zamiast czytać długie hasło na głos, uruchom _Konfiguracja > Sieć > Kod QR_, gdy jesteś połączony z Wi-Fi. Na ekranie pojawi się kod QR, który można zeskanować aparatem dowolnego telefonu, aby dołączyć do sieci. To jedna z tych rzeczy, z których będziesz korzystać częściej, niż się spodziewasz, gdy już wiesz, że tam jest.

Jeśli faktycznie potrzebujesz samego hasła, polecenie `omarchy network password <interface>` je wypisze.

## DNS

Omarchy używa DNS, który twoja sieć przydziela przez DHCP. Możesz to nadpisać dla całej maszyny w _Konfiguracja > Sieć > DNS_, gdzie Cloudflare i Google są oddalone o jedno kliknięcie. Wybierz _Własny_, aby wpisać własne serwery.

Z terminala `omarchy dns` wypisuje bieżącego dostawcę, a `omarchy dns Cloudflare` ustawia wybranego.

## Przypinanie pasma Wi-Fi

Jeśli router umieszcza 2.4GHz, 5GHz i 6GHz pod tą samą nazwą sieci, twój laptop czasem będzie kurczowo trzymał się tego wolnego. `omarchy network band` pokazuje, z którego pasma korzystasz, a `omarchy network band 5` je przypina. Użyj `auto`, aby znów pozwolić mu wybierać samodzielnie.

Przypina to pasmo, a nie konkretny punkt dostępu, więc nadal normalnie przemieszczasz się między punktami dostępowymi.

## Jak szybkie jest połączenie?

_Wyzwalacz > Test szybkości > Test szybkości sieci_ mierzy rzeczywistą prędkość pobierania i wysyłania za pomocą pary wskaźników. Z terminala jest to `omarchy network speedtest down` lub `up`. (Obok w tym menu znajduje się test szybkości dysku, jeśli chcesz przetestować inne wąskie gardło.)

## Zapora

Zapora jest włączona domyślnie i blokuje cały ruch przychodzący, z jednym wyjątkiem: port 53317, dzięki czemu [LocalSend](22-guis.md) działa od razu po instalacji.

SSH jest wyłączone, dopóki nie włączysz go w _Konfiguracja > Bezpieczeństwo > SSHD_, co uruchamia demona, otwiera port 22 z ograniczeniem liczby prób w celu ochrony przed atakami brute force i autoryzuje klucz. Docker też jest zabezpieczony, więc kontenery nie mogą przypadkowo wystawić się na świat. Zobacz [bezpieczeństwo](48-security.md), aby poznać całość.

## Tailscale

[Tailscale](https://tailscale.com/) to siatkowa sieć VPN, dzięki której docieranie do wszystkich twoich komputerów i serwerów przez internet jest proste i bezpieczne. Zainstaluj ją przez _Instalacja > Usługa > Tailscale_.

Daje ci to panel Tailscale na pasku, który łączy i rozłącza tailnet, przełącza konta i wybiera węzeł wyjściowy — na liście pojawiają się zarówno twoje własne maszyny, jak i regiony Mullvad. Pozwala też przeglądać twoje maszyny i to tam mieszka Taildrop: wybierz maszynę i naciśnij `s`, aby wysłać jej pliki, albo `c`, `n` i `d`, aby skopiować jej adres IP, nazwę lub pełną nazwę DNS. Odpowiednikiem w terminalu jest `omarchy tailscale send <machine> [file...]`, a pliki wysłane do ciebie automatycznie lądują w `~/Downloads`. Powiadomienie informujące o nadejściu pliku czeka, aż klikniesz, aby je otworzyć, lub je odrzucisz, więc plik, który pojawi się, gdy nie ma cię przy maszynie, nadal będzie tam, abyś mógł zareagować po powrocie.

Instalacja dodaje również aplikację internetową konsoli administracyjnej Tailscale.

## Gdy przestaje działać

Zanim uruchomisz komputer ponownie, spróbuj zrestartować tylko wadliwy element. _Aktualizacja > Sprzęt_ zawiera Wi-Fi, Bluetooth, Audio i Trackpad, a ponowne załadowanie jednego z nich rozwiązuje większość sytuacji typu „działało pięć minut temu”. Zobacz [rozwiązywanie problemów](45-troubleshooting.md).
