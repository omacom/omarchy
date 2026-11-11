# Obsługa komputerów Mac

Omarchy ma wbudowaną obsługę **komputerów Mac z procesorami Intel**. Obecnie istnieje kilka znanych ograniczeń, ale jeśli jesteś ich świadomy i Ci odpowiadają, możesz tchnąć nowe życie w swoje stare Maki, instalując na nich Omarchy.

Pamiętaj, że instalacja na Macu z chipem z serii M nie jest obecnie bezpośrednio obsługiwana. Więcej informacji o stanie prac w tym zakresie znajdziesz na kanale #omarchy-on-other na naszym [Discord](https://discord.gg/tXFUdasqhY).

W prostym teście udało nam się osiągnąć 36% wzrost wydajności na MacBooku Pro z 2019 roku już przez samo zainstalowanie Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalowanie Omarchy na Macu

Omarchy obecnie obsługuje wyłącznie instalację jako **jedyny** system operacyjny. Podczas instalacji dysk zostanie wyczyszczony, a MacOS nie będzie już mógł się uruchamiać.

Jeśli zechcesz, możesz go później nadal przywrócić za pomocą Internet Recovery.

Na potrzeby tej części zakładamy, że zapoznałeś się już z [Pierwszymi krokami](02-getting-started.md) i masz gotowy dysk USB. Jeśli nie, zrób to teraz.

#### Wyłącz Secure Boot

Aby uruchomić rozruchowy dysk USB, a także system operacyjny, konieczne jest wyłączenie funkcji Secure Boot firmy Apple. Aby ją wyłączyć, wykonaj następujące czynności:

1. Wyłącz Maca
2. Włącz go i _natychmiast_ naciśnij i przytrzymaj Command-R, aż zobaczysz ekran ładowania
3. Wybierz swojego użytkownika i w razie potrzeby wprowadź hasło
4. Na ekranie odzyskiwania wybierz z paska menu **Utilities > Startup Security Utility**
5. Po wyświetleniu monitu wprowadź hasło, aby się uwierzytelnić
6. Wybierz "No Security" spośród opcji Secure Boot
7. Wybierz "Allow booting from external or removable media" spośród opcji External Boot

#### Rozpocznij instalację

1. Włóż dysk USB
2. Uruchom ponownie Maca i _natychmiast_ naciśnij i przytrzymaj Option, aż zobaczysz ekran urządzeń rozruchowych
3. Wybierz pomarańczowe urządzenie EFI Boot
4. Kontynuuj [instalację jak zwykle](02-getting-started.md)

Instalator wykrywa sprzęt Maca i automatycznie stosuje potrzebne poprawki: sterowniki i oprogramowanie układowe Broadcom Wi-Fi, sterownik klawiatury SPI w modelach MacBook, które go potrzebują, oraz poprawkę usypiania NVMe dla tych samych modeli.

### Znane ograniczenia

Członkowie społeczności nieustannie pracują nad rozwiązaniami tych problemów, więc jeśli są one dla Ciebie kłopotliwe, dołącz do #omarchy-on-other na naszym [Discord](https://discord.gg/tXFUdasqhY) i sprawdź, czy istnieją jakieś aktualne metody ich rozwiązania.

#### Urządzenia z chipem T1

Chip Apple T1 został wprowadzony pod koniec 2016 roku i był używany wyłącznie w modelach MacBook Pro pierwszej generacji z paskiem Touch Bar.
- MacBook Pro 13-calowy (2016, dwa porty Thunderbolt 3) – Model: A1706
- MacBook Pro 13-calowy (2016, cztery porty Thunderbolt 3) – Model: A1708
- MacBook Pro 15-calowy (2016) – Model: A1707

#### Znane problemy

- Touch Bar nie działa
- Dźwięk nie działa

#### Urządzenia z chipem T2

Chip Apple T2 Security Chip został wprowadzony w 2017 roku. Zaprzestano jego stosowania wraz z przejściem na Apple silicon (chipy z serii M), które rozpoczęło się w 2020 roku.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-calowy (2018, cztery porty Thunderbolt 3) – Model: A1989
- MacBook Pro 15-calowy (2018) – Model: A1990
- MacBook Air (Retina, 13-calowy, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-calowy (2019, dwa porty Thunderbolt 3) – Model: A2159
- MacBook Pro 13-calowy (2019, cztery porty Thunderbolt 3) – Model: A2178
- MacBook Pro 15-calowy (2019) – Model: A1990
- iMac (Retina 5K, 27-calowy, 2020) – Model: A2115 (iMac20,1 oraz iMac20,2)
- MacBook Pro 13-calowy (2020, dwa porty Thunderbolt 3) – Model: A2265
- MacBook Pro 15-calowy (2020) – Model: A1990

Na tych modelach instalator automatycznie konfiguruje załatane jądro `linux-t2`, konfigurację dźwięku T2, oprogramowanie układowe Broadcom Wi-Fi/Bluetooth firmy Apple oraz sterowanie wentylatorami za pomocą `t2fanrd`. Touch Bar działa dzięki wbudowanej w jądro obsłudze w stylu Boot Camp.

#### iMac Retina 5K (2017)

27-calowy iMac z 2017 roku nie ma chipa T2, więc instalator konfiguruje go tak jak pozostałe Maki z procesorami Intel.

- iMac (Retina 5K, 27-calowy, 2017) – Model: A1419

#### Znane problemy

- Wyświetlacz nie działa w natywnej rozdzielczości 5120×2880: panel składa się z dwóch kafelków, a standardowy sterownik podświetla tylko jeden
- Dźwięk nie działa
- Regulacja jasności nie działa
- Usypianie zawiesza komputer; przywrócić go można tylko przez wyłączenie i ponowne włączenie zasilania

Społecznościowy patcher dla tego modelu naprawia wyświetlacz, dźwięk i jasność: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
