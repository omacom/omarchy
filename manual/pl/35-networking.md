# Sieć

Za sieć w Omarchy odpowiada NetworkManager, a sterujesz nią z ikony sieci na [górnym pasku](05-the-top-bar.md) albo za pomocą `Super + Ctrl + N`.

Ten panel skanuje sieci Wi-Fi, pokazuje siłę sygnału i łączy. Ethernet nie potrzebuje zupełnie niczego — podłączasz kabel i działa. Jeśli wolisz zostać w terminalu, `nmtui` daje Ci te same opcje, a do tego jest jeszcze grupa poleceń `omarchy network`.

## Udostępnianie Wi-Fi

Zamiast czytać na głos długie hasło, uruchom _Setup > Network > QR Code_, gdy jesteś w sieci Wi-Fi. Na ekranie pojawi się kod QR, który może zeskanować aparat dowolnego telefonu, aby dołączyć do sieci. To jedna z tych rzeczy, z których będziesz korzystać częściej, niż Ci się wydaje, gdy już wiesz, że tam jest.

Jeśli faktycznie potrzebujesz samego hasła, wypisze je polecenie `omarchy network password <interface>`.

## DNS

Omarchy używa takiego DNS, jaki Twoja sieć przekazuje przez DHCP. Możesz to nadpisać dla całej maszyny w _Setup > Network > DNS_, gdzie Cloudflare i Google są o jedno kliknięcie stąd. Wybierz _Custom_, aby wpisać własne serwery.

Z terminala polecenie `omarchy dns` wypisuje bieżącego dostawcę, a `omarchy dns Cloudflare` ustawia wybranego.

## Przypinanie pasma Wi-Fi

Jeśli Twój router umieszcza 2.4GHz, 5GHz i 6GHz pod tą samą nazwą sieci, Twój laptop czasem będzie kurczowo trzymał się tego wolnego. Polecenie `omarchy network band` pokazuje, na jakim paśmie jesteś, a `omarchy network band 5` je przypina. Użyj `auto`, aby znów pozwolić mu wybierać.

Przypina to pasmo, a nie konkretny punkt dostępowy, więc nadal normalnie przełączasz się między APs.

## Jak szybkie jest połączenie?

_Trigger > Speed Test > Network Speed Test_ mierzy Twoją rzeczywistą prędkość pobierania i wysyłania za pomocą pary wskaźników. Z terminala służy do tego `omarchy network speedtest down` albo `up`. Pomiar odbywa się wobec własnej usługi Omarchy i liczy tylko jej transfery testowe. Inne pobierania mogą konkurować o przepustowość, ale nie są doliczane do wyniku testu prędkości. (W tym samym menu obok znajduje się test prędkości dysku, gdybyś testował drugie wąskie gardło.)

## Zapora sieciowa

Zapora jest domyślnie włączona i blokuje cały ruch przychodzący, z jednym wyjątkiem: portem 53317, dzięki czemu [LocalSend](22-guis.md) działa od razu po instalacji.

SSH jest wyłączone, dopóki nie włączysz go w _Setup > Security > SSHD_, co uruchamia demona, otwiera port 22 z ograniczaniem szybkości przeciw brute force i autoryzuje klucz. Docker też jest zabezpieczony, więc kontenery nie mogą przypadkowo wystawić się na świat. Całą historię znajdziesz w [bezpieczeństwie](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) to mesh VPN, który sprawia, że docieranie do wszystkich Twoich komputerów i serwerów przez internet jest proste i bezpieczne. Zainstaluj go przez _Install > Service > Tailscale_.

Daje Ci to panel Tailscale na pasku, który łączy i rozłącza z tailnet, przełącza konta i wybiera exit node — na liście pojawiają się zarówno Twoje własne maszyny, jak i regiony Mullvad. Przegląda też Twoje maszyny i to tam mieszka Taildrop: wybierz maszynę i naciśnij `s`, aby wysłać jej pliki, albo `c`, `n` i `d`, aby skopiować jej IP, nazwę lub pełną nazwę DNS. Odpowiednikiem w terminalu jest `omarchy tailscale send <machine> [file...]`, a pliki wysłane do Ciebie lądują automatycznie w `~/Downloads`. Powiadomienie oznajmiające przybycie pliku czeka, aż klikniesz, aby je otworzyć, lub je odrzucisz, więc plik, który pojawi się, gdy nie ma Cię przy maszynie, nadal będzie tam czekał na Twoją reakcję, gdy wrócisz.

Zainstalowanie go dodaje też aplikację webową konsoli administracyjnej Tailscale.

## Gdy przestanie działać

Zanim zrestartujesz maszynę, spróbuj zrestartować tylko wadliwy element osobno. _Update > Hardware_ zawiera Wi-Fi, Bluetooth, Audio i Trackpad, a przeładowanie jednego z nich rozwiązuje większość sytuacji „działało pięć minut temu”. Zobacz [rozwiązywanie problemów](45-troubleshooting.md).
