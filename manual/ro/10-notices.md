# Notificări

Notificările ajung în colțul din dreapta sus al ecranului focalizat. Poți accesa rapid și data și ora, starea bateriei și vremea curentă folosind notificările prin combinații de taste.

## Notificări

Notificările de la aceeași aplicație sau același site se strâng într-un teanc, ca un canal Slack vorbăreț să nu-ți împingă eșecul build-ului de pe ecran. Trece cu mouse-ul peste un teanc ca să-l desfaci; nimic nou nu alunecă sub cursor cât timp citești. Fă clic pe un card ca să sari de unde a venit, fă clic dreapta, clic mijlociu sau apasă ✕ ca să-l închizi.

Cardurile oferă ce conțin: _Copiază codul_ pentru codurile de verificare (păstrate în afara [istoricului clipboardului](08-unified-clipboard-history.md) și șterse după un minut), plus orice butoane oferă aplicația. Linkurile din textul unei notificări se deschid la clic.

Ca să le folosești fără mouse, apasă `Super + Ctrl + ,`. Cea mai nouă notificare este selectată, iar butoanele ei sunt numerotate: apasă un număr ca să folosești unul, `Enter` ca să faci clic pe notificare, `↑` și `↓` ca să te muți între notificări, `Delete` ca să închizi una și `Esc` ca să eliberezi tastatura. Se eliberează și singură după câteva secunde de inactivitate.

Dacă reduci notificările la tăcere, ele sunt reținute, cu excepția confirmărilor proprii ale Omarchy, a alertelor de urgență și a codurilor de verificare, pe care le-ai cerut acum un moment. Pune ultimele câteva înapoi pe ecran, reținute sau nu, cu `Super + Shift + Alt + ,`. Istoricul este păstrat o zi.

## Notificări prin combinații de taste

### Data și ora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Vremea

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Locația este detectată după adresa IP, ceea ce de obicei este suficient de aproape, dar nu întotdeauna. O poți fixa cu `omarchy weather location --set Malibu` sau poți fi exact adăugând coordonate: `omarchy weather location --set Malibu 34.0259,-118.7798`. Rulează `omarchy weather location` singur ca să vezi unde crede că ești și `--clear` ca să revii la detectarea automată.

### Bateria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
