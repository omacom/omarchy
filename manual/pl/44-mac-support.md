# Wsparcie dla Maców

Omarchy ma wbudowane wsparcie dla **Maców z procesorami Intel**. W tej chwili jest kilka znanych ograniczeń, ale o ile masz ich świadomość i ci nie przeszkadzają, możesz tchnąć nowe życie w swoje stare Maki, instalując na nich Omarchy.

Pamiętaj, że instalacja na Macu z serii M nie jest w tej chwili bezpośrednio wspierana. Więcej o stanie tych prac dowiesz się na kanale #omarchy-on-other na naszym [Discordzie](https://discord.gg/tXFUdasqhY).

W prostym teście udało nam się osiągnąć 36% wzrost wydajności na MacBooku Pro z 2019 roku już samą instalacją Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalacja Omarchy na Macu

Omarchy wspiera w tej chwili tylko bycie **jedynym** zainstalowanym systemem operacyjnym. Podczas instalacji dysk zostanie wyczyszczony, a MacOS nie będzie już można uruchomić.

Później nadal możesz go przywrócić przez Internet Recovery, jeśli zechcesz.

Na potrzeby tej części przyjmiemy, że zapoznałeś się już z [Wprowadzeniem](02-getting-started.md) i masz gotowy dysk USB. Jeśli nie, zrób to teraz.

#### Wyłączanie Secure Boot

Aby uruchomić startowy dysk USB, a także sam system, konieczne jest wyłączenie Secure Boot firmy Apple. Aby to wyłączyć, wykonaj następujące kroki:

1. Wyłącz swojego Maca
2. Włącz go i _natychmiast_ naciśnij i przytrzymaj Command-R, aż zobaczysz ekran ładowania
3. Wybierz swojego użytkownika i wprowadź hasło, jeśli pojawi się monit
4. Na ekranie odzyskiwania wybierz z paska menu **Utilities > Startup Security Utility**
5. Wprowadź hasło, gdy pojawi się monit o uwierzytelnienie
6. Wybierz „No Security” spośród opcji Secure Boot
7. Wybierz „Allow booting from external or removable media” spośród opcji External Boot

#### Rozpoczęcie instalacji

1. Włóż dysk USB
2. Zrestartuj Maca i _natychmiast_ naciśnij i przytrzymaj Option, aż zobaczysz ekran urządzeń rozruchowych
3. Wybierz pomarańczowe urządzenie EFI Boot
4. Kontynuuj [instalację jak zwykle](02-getting-started.md)

Instalator wykrywa sprzęt Maca i automatycznie stosuje potrzebne poprawki: sterowniki i oprogramowanie sprzętowe Wi-Fi Broadcom, sterownik klawiatury SPI w modelach MacBooka, które go potrzebują, oraz poprawkę wstrzymania NVMe dla tych samych modeli.

### Znane ograniczenia

Członkowie społeczności stale pracują nad rozwiązaniami tych wyzwań, więc jeśli są one dla ciebie problematyczne, dołącz do kanału #omarchy-on-other na naszym [Discordzie](https://discord.gg/tXFUdasqhY) i zobacz, czy są jakieś aktualne sposoby ich rozwiązania.

#### Urządzenia z układem T1

Układ Apple T1 wprowadzono pod koniec 2016 roku i używano go wyłącznie w modelach MacBooka Pro pierwszej generacji z paskiem Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Znane problemy

- Touch Bar nie działa
- Dźwięk nie działa

#### Urządzenia z układem T2

Układ zabezpieczeń Apple T2 wprowadzono w 2017 roku. Układu T2 zaprzestano używać wraz z przejściem na Apple silicon (układy serii M), począwszy od 2020 roku.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

W tych modelach instalator automatycznie konfiguruje poprawione jądro `linux-t2`, konfigurację dźwięku T2, oprogramowanie sprzętowe Wi-Fi/Bluetooth Broadcom firmy Apple oraz sterowanie wentylatorami przez `t2fanrd`. Touch Bar działa na wbudowanym w jądro wsparciu w stylu Boot Camp.
