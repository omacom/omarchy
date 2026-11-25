# Aplikacje internetowe

Możesz dodać własne aplikacje internetowe za pomocą _Install > Web App_ w menu Omarchy (`Super + Space`). Zapyta Cię o nazwę aplikacji, adres URL aplikacji oraz adres URL ikony, jeśli nie uda mu się pobrać jej za pomocą faviconu. Świetne ikony PNG dla wielu popularnych aplikacji internetowych znajdziesz na [Dashboard Icons](https://dashboardicons.com).

Będą one następnie dostępne za pośrednictwem programu uruchamiającego aplikacje (`Super + Space`) i będą korzystać z pięknego okna aplikacji internetowej bez ramek.

Jeśli chcesz usunąć aplikację internetową, po prostu przejdź do _Remove > Web App_ w menu Omarchy.

Najlepiej zalogować się na wszystkie konta za pomocą zwykłej przeglądarki przed użyciem skrótów aplikacji internetowych. Cienka ramka otaczająca aplikację nie działa dobrze z 1password, więc łatwiej jest po prostu zalogować się bezpośrednio wcześniej.

Wszystkie skróty klawiaturowe dla tych aplikacji internetowych można zmienić w `~/.config/hypr/bindings.lua`.

Gdy jesteś w aplikacji internetowej, możesz skopiować bieżący adres URL do schowka za pomocą `Shift + Alt + L`.

Domyślnie Omarchy jest już dostarczany z zestawem domyślnych aplikacji:

## HEY

[HEY](https://www.hey.com/) to usługa poczty e-mail i kalendarza, która stanowi świetną alternatywę dla osób zmęczonych Gmailem, Outlookiem lub Apple Mail. Została stworzona przez [37signals](https://37signals.com/), gdzie powstało Omarchy.

Możesz uruchomić HEY Email za pomocą `Super + Shift + E`, przejść od razu do tworzenia nowej wiadomości e-mail za pomocą `Super + Shift + Alt + E` i uruchomić HEY Calendar za pomocą `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) to usługa zarządzania projektami, która pomaga małym zespołom działać szybciej i robić większe postępy. Zamiast łączyć ze sobą miszmasz Trello, Slacka, Asany, Notion czy czegokolwiek innego, możesz mieć to wszystko w jednym miejscu dzięki Basecamp. Została stworzona przez [37signals](https://37signals.com/), gdzie powstało Omarchy.

Możesz uruchomić Basecamp za pomocą programu uruchamiającego aplikacje (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) to najpopularniejszy czatbot AI na świecie.

Możesz uruchomić ChatGPT za pomocą `Super + Shift + A`.

## Grok

[Grok](https://grok.com) to czatbot xAI.

Możesz uruchomić Grok za pomocą `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) to jedna z najpopularniejszych usług komunikacyjnych na świecie, a wersja internetowa to świetna opcja dla systemu Linux.

Możesz uruchomić WhatsApp za pomocą `Super + Shift + Alt + G`. Otwiera się z rozszerzeniem WhatsApp Slim od Omarchy, które sprawia, że dopasowuje się do Twojego motywu i zwija listę czatów, gdy okno jest wąskie.

## Aplikacje Google

Google Messages, Google Photos, Google Maps i Google Contacts są również dołączone jako aplikacje internetowe.

Możesz uruchomić Google Messages za pomocą `Super + Shift + Ctrl + G`, Google Photos za pomocą `Super + Shift + P`, a Google Maps za pomocą `Super + Shift + S`. Google Contacts jest dostępny za pośrednictwem programu uruchamiającego aplikacje (`Super + Space`).

## X

X to miejsce, gdzie pojawiają się najnowsze wiadomości.

Możesz uruchomić X za pomocą `Super + Shift + X` i przejść od razu do pisania nowego posta za pomocą `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) to najpopularniejsza platforma wideo na świecie.

Możesz uruchomić YouTube za pomocą `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) jest dołączony jako aplikacja internetowa w nowych instalacjach.

Netflix uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) to najpopularniejszy system wideoczatów używany w USA. Świetne połączenia na całym świecie. A 40-minutowe spotkania można prowadzić bez płatnego konta. Omarchy opakowuje klienta internetowego Zooma, a linki do spotkań Zoom będą otwierać się bezpośrednio w nim.

Zoom uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Discord

[Discord](https://discord.com/) to miejsce, w którym przesiaduje większość społeczności gamingowych i open source, w tym [własna społeczność Omarchy](https://discord.gg/tXFUdasqhY).

Discord uruchamiasz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Aplikacje Microsoft

Wybierz _Install > Service > Microsoft_, aby dodać Outlook, Word, Excel, PowerPoint, Teams i OneDrive jako aplikacje internetowe. Każda aplikacja ma własny program uruchamiający i otwiera się bezpośrednio, korzystając z komercyjnych adresów URL Microsoft 365 i Twojego istniejącego profilu przeglądarki. Otwierają się w tych samych oknach aplikacji przeglądarki co inne aplikacje internetowe Omarchy; nie instalują oddzielnego klienta Teams for Linux.

Usuń pakiet za pomocą _Remove > Services > Microsoft_ lub usuń pojedyncze aplikacje za pomocą _Remove > Web App_. Możesz również zainstalować tylko te aplikacje, które chcesz, za pomocą _Install > Web App_.

W przypadku chmury rządowej lub suwerennej edytuj adres URL w linii `Exec=` w odpowiednim programie uruchamiającym w `~/.local/share/applications/`, takim jak `Microsoft Teams.desktop`, używając adresu URL dostarczonego przez Twoją organizację. Każdy dosłowny znak `%` w tej linii zapisz jako `%%`. Zmiany zaczną obowiązywać przy następnym uruchomieniu. Ponowne uruchomienie instalatora pakietu zastąpi jego programy uruchamiające domyślnymi adresami URL.

Aby oddzielić logowania służbowe, dopisz katalog danych przeglądarki do linii `Exec=` każdego programu uruchamiającego:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Zastąp przykładowy katalog wybraną przez siebie ścieżką bezwzględną i używaj tej samej ścieżki dla wszystkich sześciu programów uruchamiających, aby współdzielić między nimi logowania służbowe. Aplikacje internetowe korzystają z wybranej obsługiwanej przeglądarki Omarchy, a gdy domyślna przeglądarka nie jest obsługiwana, wracają do Chrome.
