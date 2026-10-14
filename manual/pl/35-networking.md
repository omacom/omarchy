# Sieć

Siecią w Omarchy zarządza NetworkManager, a sterujesz nią ikoną sieci na [pasku menu](05-the-top-bar.md) albo skrótem `Super + Ctrl + W`.

Ten panel skanuje sieci Wi-Fi, pokazuje siłę sygnału i łączy z nimi. Ethernet nie wymaga zupełnie nic — podłączasz kabel i działa. Jeśli wolisz zostać w terminalu, `nmtui` daje ci te same opcje, a jest też grupa poleceń `omarchy network`.

## Udostępnianie sieci Wi-Fi

Zamiast czytać na głos długie hasło, uruchom _Ustawienia > Sieć > Kod QR_, gdy jesteś połączony z Wi-Fi. Na ekranie pojawi się kod QR, który dowolny aparat w telefonie zeskanuje, aby dołączyć do sieci. To jedna z tych rzeczy, z których będziesz korzystać częściej, niż się spodziewasz, gdy już wiesz, że tam jest.

Jeśli faktycznie potrzebujesz samego hasła, `omarchy network password <interface>` je wypisze.

## DNS

Omarchy używa DNS-a, który twoja sieć przekazuje przez DHCP. Możesz to nadpisać dla całego komputera w _Ustawienia > Sieć > DNS_, gdzie Cloudflare i Google są o jedno kliknięcie. Wybierz _Niestandardowy_, aby wpisać własne serwery.

Z terminala `omarchy dns` wypisuje bieżącego dostawcę, a `omarchy dns Cloudflare` go ustawia.

## Przypinanie pasma Wi-Fi

Jeśli twój router wystawia 2.4GHz, 5GHz i 6GHz pod tą samą nazwą sieci, twój laptop będzie czasem trzymał się tego wolnego. `omarchy network band` pokazuje, na którym paśmie jesteś, a `omarchy network band 5` je przypina. Użyj `auto`, aby znów pozwolić mu wybierać.

Przypina to pasmo, a nie konkretny punkt dostępu, więc nadal normalnie przełączasz się między punktami dostępowymi.

## Jak szybkie jest połączenie?

_Akcje > Test prędkości > Test prędkości sieci_ mierzy twoją rzeczywistą prędkość pobierania i wysyłania parą wskaźników. Z terminala jest to `omarchy network speedtest down` albo `up`. (W tym samym menu obok siedzi test prędkości dysku, jeśli akurat mierzysz drugie wąskie gardło).

## Zapora sieciowa

Zapora jest domyślnie włączona i blokuje cały ruch przychodzący, z jednym wyjątkiem: portem 53317, dzięki czemu [LocalSend](22-guis.md) działa od razu po zainstalowaniu.

SSH jest wyłączone, dopóki nie włączysz go w _Ustawienia > Bezpieczeństwo > SSHD_, co uruchamia demon, otwiera port 22 z ograniczeniem szybkości przeciwko atakom brute force i autoryzuje klucz. Docker też jest zamknięty, więc kontenery nie mogą przypadkiem wystawić się na świat. Całą historię znajdziesz w rozdziale [o bezpieczeństwie](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) to siatkowa sieć VPN, dzięki której docieranie do wszystkich twoich komputerów i serwerów przez internet jest proste i bezpieczne. Zainstaluj ją przez _Instaluj > Usługa > Tailscale_.

Daje ci to panel Tailscale na pasku, który łączy i rozłącza tailnet, przełącza konta i wybiera węzeł wyjściowy — na liście pojawiają się zarówno twoje własne komputery, jak i regiony Mullvad. Przegląda też twoje komputery i właśnie tam mieszka Taildrop: wybierz komputer i naciśnij `s`, aby wysłać na niego pliki, albo `c`, `n` i `d`, aby skopiować jego adres IP, nazwę lub pełną nazwę DNS. Odpowiednikiem w terminalu jest `omarchy tailscale send <machine> [file...]`, a pliki wysłane do ciebie lądują automatycznie w `~/Downloads`. Powiadomienie o ich przybyciu czeka, aż je klikniesz, aby je otworzyć, albo aż je odrzucisz, więc plik, który pojawi się, gdy nie ma cię przy komputerze, nadal będzie tam czekał, gdy wrócisz.

Instalacja dodaje też aplikację webową konsoli administracyjnej Tailscale.

## Gdy przestaje działać

Zanim zrestartujesz komputer, spróbuj zrestartować sam sprawiający problemy element. _Aktualizuj > Sprzęt_ ma Wi-Fi, Bluetooth, Dźwięk i Gładzik, a ponowne załadowanie jednego z nich rozwiązuje większość sytuacji typu „przecież pięć minut temu działało”. Zobacz [rozwiązywanie problemów](45-troubleshooting.md).
