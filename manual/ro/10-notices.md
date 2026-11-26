# Notificări

Notificările ajung în colțul din dreapta sus al ecranului focalizat. Poți accesa rapid și data și ora, starea bateriei și vremea curentă folosind notificările prin taste rapide.

## Notificări

Notificările de la aceeași aplicație sau același site se stivuiesc într-un teanc, așa că un canal Slack vorbăreț nu îți împinge eșecul build-ului de pe ecran. Treci cu cursorul peste un teanc ca să-l desfaci în evantai; nimic nou nu alunecă sub cursor cât timp citești. Dă clic pe un card ca să sari la sursa lui, dă clic dreapta, clic mijlociu sau apasă ✕ ca să-l închizi.

Cardurile oferă ce conțin: _Copiază codul_ pentru codurile de verificare (ținute în afara [istoricului clipboardului](08-unified-clipboard-history.md) și șterse după un minut), plus orice butoane oferă aplicația. Linkurile din textul unei notificări se deschid la clic.

`Super + ,` închide cea mai nouă notificare sau deschide ținta ei când oferă asta, `Super + Alt + ,` închide doar ultima, `Super + Shift + ,` le închide pe toate, iar `Super + Shift + Alt + ,` deschide istoricul. Ca să le folosești fără mouse, apasă `Super + Ctrl + ,`. Cea mai nouă notificare este selectată, iar butoanele ei sunt numerotate: apasă un număr ca să folosești unul, `Enter` ca să dai clic pe notificare, `↑` și `↓` ca să te muți între notificări, `Delete` ca să închizi una și `Esc` ca să redai tastatura. Se eliberează și singură după câteva secunde fără activitate.

Dacă pui notificările pe silențios, ele sunt reținute, cu excepția confirmărilor proprii Omarchy, a alertelor de urgență și a codurilor de verificare, pe care le-ai cerut acum o clipă. Repune ultimele câteva pe ecran, reținute sau nu, cu `Super + Shift + Alt + ,`. Istoricul este păstrat o zi.

## Notificări prin taste rapide

### Data și ora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Vremea

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Locația este detectată după adresa ta IP, ceea ce de obicei este suficient de precis, dar nu întotdeauna. O poți fixa cu `omarchy weather location --set Malibu` sau poți fi exact adăugând coordonate: `omarchy weather location --set Malibu 34.0259,-118.7798`. Rulează `omarchy weather location` singur ca să vezi unde crede că ești și `--clear` ca să revii la detectarea automată.

### Baterie

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
