# Wsparcie dla komputerów Mac

## Omarchy dla Apple Silicon

Omarchy dla Apple Silicon to oficjalne rozwiązanie Omacom, wydane po raz pierwszy wraz z Omarchy 4.5. Instaluje się obok macOS, a przy uruchamianiu Maca wybierasz między tymi dwoma systemami.

Dostałeś powiadomienie o Omarchy Mac? Przejdź do [Przejście z Omarchy Mac](#coming-from-omarchy-mac).

Działa na tych Macach:

| Mac | Chipy |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Maki z M4 i nowsze nie są jeszcze obsługiwane. Obsługa M4 jest testowana na kanale edge i pojawi się jako następna. Instalator sprawdza Twojego Maca, zanim cokolwiek zmieni.

Na dowolnym Macu z Apple Silicon, w tym z M4 i nowszym, możesz uruchomić Omarchy w maszynie wirtualnej za pomocą [Try Omarchy](https://github.com/omacom/try-omarchy).

### Czego potrzebujesz

- macOS 15 Sequoia lub nowszy oraz konto administratora
- Wolne miejsce na dysku dla Omarchy. Instalator sugeruje rozmiar i pozwala go zmienić.
- Kopia zapasowa Maca, zasilanie i połączenie z internetem. Instalacja pobiera kilka gigabajtów.

### Instalacja

Instalujesz z poziomu macOS. Zainstaluj Omarchy Installer za pomocą [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Albo pobierz najnowszy Omarchy Installer z jego [strony wydań](https://github.com/omacom/omarchy-mac-installer/releases) i otwórz go.

Instalator sprawdza Twojego Maca, pokazuje plan i robi miejsce dla Omarchy, zmniejszając partycję macOS. macOS zostaje na dysku i nie jest potrzebny żaden dysk USB. Po zakończeniu pierwszego etapu instalator prowadzi Cię przez dokończenie konfiguracji w macOS Recovery: wyłącz komputer, przytrzymaj przycisk zasilania, aż pojawi się „Loading startup options”, wybierz Omarchy i wykonaj kolejne kroki.

Przy pierwszym uruchomieniu Omarchy pyta o hasło, które szyfruje jego dysk. Nie ma klucza odzyskiwania: jeśli zapomnisz hasła, plików Omarchy nie da się odzyskać.

Aby później przełączać się między Omarchy a macOS, wyłącz komputer, a następnie przytrzymaj przycisk zasilania, aż pojawią się opcje uruchamiania, i wybierz jeden z systemów.

### Przejście z Omarchy Mac

Omarchy Mac jest teraz częścią Omarchy dla Apple Silicon, a każdy Mac, na którym działało, jest obsługiwany. Twoja obecna instalacja nadal działa, a jej pakiety systemowe wciąż się aktualizują, ale nie otrzymuje już aktualizacji Omarchy. Nie ma terminu ostatecznego ani aktualizacji w miejscu: robisz kopię zapasową, usuwasz starą instalację, instalujesz od nowa i przywracasz dane. Kroki od 2 do 5 odbywają się w macOS, więc otwórz tę stronę na telefonie, zanim uruchomisz komputer ponownie.

1. **Zrób kopię zapasową z Omarchy, poza Makiem.** Usunięcie starej instalacji ją wymaże, a macOS nie potrafi odczytać dysku Omarchy. Skopiuj folder domowy na dysk zewnętrzny lub inny komputer, w tym klucze SSH i GPG, profile przeglądarki oraz niewypchniętą pracę. Zapisz listę pakietów poleceniem `pacman -Qqe > ~/packages.txt`. Zrób też kopię zapasową macOS, ponieważ zarówno usuwanie, jak i instalowanie zmieniają rozmiar jego dysku.
2. **Uruchom Maca w macOS.** Wyłącz komputer, przytrzymaj przycisk zasilania, aż pojawią się opcje uruchamiania, i wybierz macOS.
3. **Zainstaluj Omarchy Installer** w sposób pokazany w sekcji [Instalacja](#installing).
4. **Usuń starą instalację.** Otwórz Omarchy Installer i wybierz Installation > Remove Omarchy. Pokaże, co usunie, i zwróci miejsce do macOS. Jeśli nie rozpozna Twojej instalacji, zatrzyma się bez zmieniania dysku. Poproś o pomoc na [Discordzie](https://discord.gg/tXFUdasqhY), zamiast ręcznie usuwać partycje, co może wymazać macOS.
5. **Zainstaluj Omarchy dla Apple Silicon** za pomocą instalatora.
6. **Przywróć pliki.** Przywracaj ustawienia po kawałku, zamiast kopiować całe `~/.config` na nowe ustawienia domyślne, ponieważ stare ustawienia mogą je nadpisać.

### Warto wiedzieć

- Na MacBookach z M1 i M2 wybudzaj ze snu, otwierając pokrywę lub naciskając przycisk zasilania.
- Pytania lub problemy: pytaj na naszym [Discordzie](https://discord.gg/tXFUdasqhY).

[README instalatora](https://github.com/omacom/omarchy-mac-installer#readme) opisuje kanały wydań, aktualizowanie instalatora i usuwanie Omarchy.

## Maki z Intelem

W prostym teście udało nam się uzyskać 36% wzrost wydajności na MacBooku Pro z 2019 roku już przez samo zainstalowanie Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalowanie Omarchy na Macu

Omarchy na razie obsługuje tylko sytuację, w której jest **jedynym** zainstalowanym systemem operacyjnym. Podczas instalacji dysk zostanie wyczyszczony, a MacOS nie będzie już mógł się uruchamiać.

Jeśli chcesz, nadal możesz go później przywrócić za pomocą Internet Recovery.

W tej części przyjmiemy, że zapoznałeś się już z [Pierwszymi krokami](02-getting-started.md) i masz gotowy dysk USB. Jeśli nie, zrób to teraz.

#### Wyłącz Secure Boot

Aby uruchomić startowy dysk USB, a także system operacyjny, konieczne jest wyłączenie Apple Secure Boot. Aby je wyłączyć, wykonaj następujące czynności:

1. Wyłącz Maca
2. Włącz go i _natychmiast_ naciśnij i przytrzymaj Command-R, aż zobaczysz ekran ładowania
3. Wybierz swojego użytkownika i wprowadź hasło, jeśli pojawi się taki monit
4. Gdy znajdziesz się na ekranie odzyskiwania, wybierz z paska menu **Utilities > Startup Security Utility**
5. Wprowadź hasło, gdy pojawi się monit o uwierzytelnienie
6. Wybierz „No Security” spośród opcji Secure Boot
7. Wybierz „Allow booting from external or removable media” spośród opcji External Boot

#### Rozpocznij instalację

1. Włóż dysk USB
2. Uruchom Maca ponownie i _natychmiast_ naciśnij i przytrzymaj Option, aż zobaczysz ekran urządzeń startowych
3. Wybierz pomarańczowe urządzenie EFI Boot
4. Kontynuuj [instalację jak zwykle](02-getting-started.md)

Instalator wykrywa sprzęt Maca i automatycznie stosuje potrzebne poprawki: sterowniki i firmware Broadcom Wi-Fi, sterownik kamery FaceTime HD na komputerach z Broadcom 1570 (jego firmware jest pobierane od Apple, gdy Mac znajdzie się online, ponieważ instalator działa offline), sterownik klawiatury SPI na modelach MacBooka, które go potrzebują, oraz poprawkę zawieszania NVMe dla tych samych modeli.

### Znane ograniczenia

Członkowie społeczności stale pracują nad rozwiązaniami tych problemów, więc jeśli są one dla Ciebie kłopotliwe, dołącz do #omarchy-on-other na naszym [Discordzie](https://discord.gg/tXFUdasqhY) i sprawdź, czy istnieją aktualne metody ich rozwiązania.

#### Kamera FaceTime HD

Sterownik kamery zawiesza komputer, jeśli jest załadowany, gdy Mac przechodzi w hibernację, więc jest wcześniej rozładowywany. Nie można go rozładować, gdy aplikacja ma otwartą kamerę, więc hibernacja jest anulowana powiadomieniem z nazwą aplikacji: zamknij ją i spróbuj hibernacji ponownie. Dotyczy to także automatycznej hibernacji przy krytycznym poziomie baterii oraz suspend-then-hibernate, które jest odrzucane, zanim komputer się zawiesi. Zwykłe zawieszanie jest odrzucane przez sam sterownik, gdy kamera jest otwarta, bez powiadomienia.

Firmware kamery jest pobierane od Apple, więc kamera działa dopiero, gdy Mac był online. Pobieranie rozpoczyna się przy uruchomieniu i jest ponawiane co 15 minut, dopóki problemem jest sieć; jeśli plik Apple się zmienił, pobieranie się zatrzymuje i czeka na aktualizację Omarchy. Jeśli kamera się nie pojawia, `journalctl -u facetimehd-firmware-fetcher` mówi dlaczego, `sudo systemctl restart facetimehd-firmware-fetcher` próbuje ponownie, a ponowne uruchomienie ładuje sterownik, jeśli pobieranie się zakończyło, ale kamery nadal nie ma.

#### Urządzenia z chipem T1

Chip Apple T1 został wprowadzony pod koniec 2016 roku i był używany wyłącznie w modelach MacBook Pro pierwszej generacji z Touch Bar.
- MacBook Pro 13-calowy (2016, dwa porty Thunderbolt 3) – Model: A1706
- MacBook Pro 13-calowy (2016, cztery porty Thunderbolt 3) – Model: A1708
- MacBook Pro 15-calowy (2016) – Model: A1707

#### Znane problemy

- Touch Bar nie działa
- Dźwięk nie działa

#### Urządzenia z chipem T2

Chip Apple T2 Security Chip został wprowadzony w 2017 roku. Chip T2 został wycofany wraz z przejściem na Apple Silicon (chipy z serii M), które rozpoczęło się w 2020 roku.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-calowy (2018, cztery porty Thunderbolt 3) – Model: A1989
- MacBook Pro 15-calowy (2018) – Model: A1990
- MacBook Air (Retina, 13-calowy, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-calowy (2019, dwa porty Thunderbolt 3) – Model: A2159
- MacBook Pro 13-calowy (2019, cztery porty Thunderbolt 3) – Model: A2178
- MacBook Pro 15-calowy (2019) – Model: A1990
- iMac (Retina 5K, 27-calowy, 2020) – Model: A2115 (iMac20,1 i iMac20,2)
- MacBook Pro 13-calowy (2020, dwa porty Thunderbolt 3) – Model: A2265
- MacBook Pro 15-calowy (2020) – Model: A1990

Na tych modelach instalator automatycznie konfiguruje załatane jądro `linux-t2`, konfigurację dźwięku T2, firmware Broadcom Wi-Fi/Bluetooth od Apple oraz sterowanie wentylatorami za pomocą `t2fanrd`. Touch Bar działa na wbudowanej w jądro obsłudze w stylu Boot Camp.

#### iMac Retina 5K (2017)

27-calowy iMac z 2017 roku nie ma chipu T2, więc instalator konfiguruje go tak jak pozostałe Maki z Intelem.

- iMac (Retina 5K, 27-calowy, 2017) – Model: A1419

#### Znane problemy

- Wyświetlacz nie działa w natywnej rozdzielczości 5120×2880: panel składa się z dwóch kafelków, a standardowy sterownik podświetla tylko jeden
- Dźwięk nie działa
- Regulacja jasności nie ma żadnego efektu
- Uśpienie zawiesza komputer; przywraca go tylko wyłączenie i ponowne włączenie zasilania

Łatka społeczności dla tego modelu naprawia wyświetlacz, dźwięk i jasność: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
