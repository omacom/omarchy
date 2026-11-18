# Aplikacje internetowe

Możesz dodać własne aplikacje internetowe za pomocą _Zainstaluj > Aplikacja internetowa_ w menu Omarchy (`Super + Space`). Poprosi Cię o nazwę aplikacji, adres URL aplikacji oraz adres URL ikony, jeśli nie będzie mogło pobrać jej za pomocą favicon. Świetne ikony PNG dla wielu popularnych aplikacji internetowych znajdziesz na [Dashboard Icons](https://dashboardicons.com).

Będą one następnie dostępne za pośrednictwem launchera aplikacji (`Super + Space`) i będą używać pięknego, pozbawionego ramek okna aplikacji internetowej.

Jeśli chcesz usunąć aplikację internetową, po prostu przejdź do _Usuń > Aplikacja internetowa_ w menu Omarchy.

Najlepiej jest zalogować się na wszystkie swoje konta za pomocą zwykłej przeglądarki przed użyciem skrótów do aplikacji internetowych. Cienka ramka opakowująca nie współpracuje dobrze z 1password, więc po prostu łatwiej jest zalogować się bezpośrednio wcześniej.

Wszystkie skróty klawiaturowe dla tych aplikacji internetowych można zmienić w `~/.config/hypr/bindings.lua`.

Gdy jesteś w aplikacji internetowej, możesz skopiować bieżący adres URL do schowka za pomocą `Shift + Alt + L`.

Domyślnie Omarchy jest już dostarczane z zestawem domyślnych aplikacji:

## HEY

[HEY](https://www.hey.com/) to usługa poczty e-mail i kalendarza, która stanowi świetną alternatywę dla osób zmęczonych Gmailem, Outlookiem lub Apple Mail. Tworzy ją [37signals](https://37signals.com/), skąd pochodzi Omarchy.

Możesz uruchomić HEY Email za pomocą `Super + Shift + E`, przejść od razu do tworzenia nowej wiadomości e-mail za pomocą `Super + Shift + Alt + E` i uruchomić HEY Calendar za pomocą `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) to usługa zarządzania projektami, która pomaga małym zespołom działać szybciej i robić większe postępy. Zamiast łatać ze sobą mieszankę Trello, Slack, Asana, Notion czy czegokolwiek innego, możesz mieć to wszystko w jednym miejscu z Basecamp. Tworzy ją [37signals](https://37signals.com/), skąd pochodzi Omarchy.

Możesz uruchomić Basecamp za pomocą launchera aplikacji (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) to najpopularniejszy czatbot AI na świecie.

Możesz uruchomić ChatGPT za pomocą `Super + Shift + A`.

## Grok

[Grok](https://grok.com) to czatbot xAI.

Możesz uruchomić Grok za pomocą `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) to jedna z najpopularniejszych usług komunikacyjnych na świecie, a wersja internetowa to świetna opcja dla systemu Linux.

Możesz uruchomić WhatsApp za pomocą `Super + Shift + Alt + G`.

## Aplikacje Google

Google Messages, Google Photos, Google Maps i Google Contacts są również dołączone jako aplikacje internetowe.

Możesz uruchomić Google Messages za pomocą `Super + Shift + Ctrl + G`, Google Photos za pomocą `Super + Shift + P`, a Google Maps za pomocą `Super + Shift + S`. Google Contacts jest dostępny za pośrednictwem launchera aplikacji (`Super + Space`).

## X

X to miejsce, w którym pojawiają się najnowsze wiadomości.

Możesz uruchomić X za pomocą `Super + Shift + X` i przejść od razu do pisania nowego posta za pomocą `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) to najpopularniejsza platforma wideo na świecie.

Możesz uruchomić YouTube za pomocą `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) to najpopularniejszy system wideoczatów używany w USA. Świetne połączenia na całym świecie. A 40-minutowe spotkania można prowadzić bez płatnego konta. Omarchy opakowuje klienta internetowego Zoom, a linki do spotkań Zoom będą otwierać się bezpośrednio w nim.

Zoom uruchomisz za pomocą launchera aplikacji (`Super + Space`).

## Discord

[Discord](https://discord.com/) to miejsce, w którym przesiaduje większość społeczności gamingowych i open source, w tym [społeczność Omarchy](https://discord.gg/tXFUdasqhY).

Discord uruchomisz za pomocą launchera aplikacji (`Super + Space`).

## Aplikacje Microsoft

Wybierz _Zainstaluj > Usługa > Microsoft_, aby dodać Outlook, Word, Excel, PowerPoint, Teams i OneDrive jako aplikacje internetowe. Każda aplikacja ma własny launcher i otwiera się bezpośrednio, używając komercyjnych adresów URL Microsoft 365 i Twojego istniejącego profilu przeglądarki. Otwierają się w tych samych oknach aplikacji przeglądarki co inne aplikacje internetowe Omarchy; nie instalują oddzielnego klienta Teams for Linux.

Usuń pakiet za pomocą _Usuń > Usługa > Microsoft_ lub usuń pojedyncze aplikacje za pomocą _Usuń > Aplikacja internetowa_. Możesz też zainstalować tylko te aplikacje, które chcesz, za pomocą _Zainstaluj > Aplikacja internetowa_.

W przypadku chmury rządowej lub suwerennej edytuj adres URL w wierszu `Exec=` w odpowiednim launcherze w `~/.local/share/applications/`, takim jak `Microsoft Teams.desktop`, używając adresu URL dostarczonego przez Twoją organizację. Każdy dosłowny znak `%` w tym wierszu zapisz jako `%%`. Zmiany zaczną obowiązywać przy następnym uruchomieniu. Ponowne uruchomienie instalatora pakietu zastępuje jego launchery domyślnymi adresami URL.

Aby przechowywać służbowe logowania oddzielnie, dopisz katalog danych przeglądarki do wiersza `Exec=` każdego launchera:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Zastąp przykładowy katalog wybraną przez siebie ścieżką bezwzględną i używaj tej samej ścieżki dla wszystkich sześciu launcherów, aby współdzieliły między sobą służbowe logowania. Aplikacje internetowe korzystają z obsługiwanej przeglądarki wybranej w Omarchy, a gdy domyślna przeglądarka nie jest obsługiwana, wracają do Chrome.
