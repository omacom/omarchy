# Aplikacje webowe

Możesz dodawać własne aplikacje webowe, używając _Instaluj > Web App_ w menu Omarchy (`Super + Space`). Poprosi cię o nazwę aplikacji, URL aplikacji i URL ikony, jeśli nie może go pobrać za pośrednictwem favicon. Świetne ikony PNG dla wielu popularnych aplikacji webowych możesz znaleźć na [Dashboard Icons](https://dashboardicons.com).

Będą one następnie dostępne za pośrednictwem launchera aplikacji (`Super + Space`) i będą używać pięknego bezramkowego okna aplikacji webowej.

Jeśli chcesz usunąć aplikację webową, po prostu przejdź do _Usuń > Web App_ w menu Omarchy.

Najlepiej, jeśli zalogujesz się do wszystkich swoich kont za pomocą zwykłej przeglądarki przed użyciem skrótów aplikacji webowych. Cienka ramka-wrapper nie działa dobrze z 1password, więc po prostu łatwiej jest zalogować się bezpośrednio najpierw.

Wszystkie skróty klawiszowe dla tych aplikacji webowych można zmienić w `~/.config/hypr/bindings.lua`.

Gdy jesteś w aplikacji webowej, możesz skopiować bieżący URL do schowka za pomocą `Shift + Alt + L`.

Domyślnie Omarchy dostarcza już zestaw domyślnych aplikacji:

## HEY

[HEY](https://www.hey.com/) jest usługą poczty e-mail i kalendarza, która służy jako świetna alternatywa dla ludzi zmęczonych Gmail, Outlook lub Apple Mail. Jest tworzona przez [37signals](https://37signals.com/), skąd wywodzi się Omarchy.

Możesz uruchomić HEY Email za pomocą `Super + Shift + E`, przejść od razu do tworzenia nowego e-maila za pomocą `Super + Shift + Alt + E` i uruchomić HEY Calendar za pomocą `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) jest usługą zarządzania projektami, która pomaga małym zespołom działać szybciej i robić większe postępy. Zamiast łatać mishmash Trello, Slack, Asana, Notion czy czegokolwiek, możesz mieć to wszystko w jednym miejscu z Basecamp. Jest tworzona przez [37signals](https://37signals.com/), skąd wywodzi się Omarchy.

Możesz uruchomić Basecamp za pomocą launchera aplikacji (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) jest najpopularniejszym chatbotem AI na świecie.

Możesz uruchomić ChatGPT za pomocą `Super + Shift + A`.

## Grok

[Grok](https://grok.com) jest chatbotem xAI.

Możesz uruchomić Grok za pomocą `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) jest jedną z najpopularniejszych usług przesyłania wiadomości na świecie, a wersja webowa jest świetną opcją dla Linuksa.

Możesz uruchomić WhatsApp za pomocą `Super + Shift + Alt + G`.

## Aplikacje Google

Google Messages, Google Photos, Google Maps i Google Contacts są również zawarte jako aplikacje webowe.

Możesz uruchomić Google Messages za pomocą `Super + Shift + Ctrl + G`, Google Photos za pomocą `Super + Shift + P`, a Google Maps za pomocą `Super + Shift + S`. Google Contacts jest dostępne za pośrednictwem launchera aplikacji (`Super + Space`).

## X

X to miejsce, gdzie pojawiają się najświeższe wiadomości.

Możesz uruchomić X za pomocą `Super + Shift + X` i przejść od razu do pisania nowego posta za pomocą `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) jest najpopularniejszą platformą wideo na świecie.

Możesz uruchomić YouTube za pomocą `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) jest najpopularniejszym systemem czatu wideo używanym w USA. Świetne połączenia na całym świecie. A 40-minutowe spotkania można odbywać bez płatnego konta. Omarchy owija klienta webowego Zoom, a linki do spotkań zoom otworzą się bezpośrednio w nim.

Uruchamiasz Zoom za pomocą launchera aplikacji (`Super + Space`).

## Discord

[Discord](https://discord.com/) to miejsce, w którym przesiaduje większość społeczności gamingowych i open source, w tym [własna Omarchy](https://discord.gg/tXFUdasqhY).

Uruchamiasz Discord za pomocą launchera aplikacji (`Super + Space`).

## Aplikacje Microsoft

Wybierz _Instaluj > Service > Microsoft_, aby dodać Outlook, Word, Excel, PowerPoint, Teams i OneDrive jako aplikacje webowe. Każda aplikacja ma własny launcher i otwiera się bezpośrednio, używając komercyjnych URL-i Microsoft 365 i twojego istniejącego profilu przeglądarki. Otwierają się w tych samych oknach aplikacji przeglądarki co inne aplikacje webowe Omarchy; nie instalują oddzielnego klienta Teams for Linux.

Usuń pakiet za pomocą _Usuń > Service > Microsoft_ lub usuń poszczególne aplikacje za pomocą _Usuń > Web App_. Możesz również zainstalować tylko te aplikacje, które chcesz, za pośrednictwem _Instaluj > Web App_.

W przypadku chmury rządowej lub suwerennej edytuj URL w wierszu `Exec=` w odpowiednim launcherze w `~/.local/share/applications/`, takim jak `Microsoft Teams.desktop`, używając URL-a dostarczonego przez twoją organizację. Zapisz każdy dosłowny `%` w tym wierszu jako `%%`. Zmiany obowiązują przy następnym uruchomieniu. Ponowne uruchomienie instalatora pakietu zastępuje jego launchery domyślnymi URL-ami.

Aby oddzielić logowania służbowe, dodaj katalog danych przeglądarki do wiersza `Exec=` każdego launchera:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Zastąp przykładowy katalog wybraną przez siebie ścieżką bezwzględną i użyj tej samej ścieżki dla wszystkich sześciu launcherów, aby współdzielić między nimi logowania służbowe. Aplikacje webowe używają wybranej obsługiwanej przeglądarki Omarchy, powracając do Chromium, gdy domyślna przeglądarka nie jest obsługiwana.
