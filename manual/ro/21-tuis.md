# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) este o alternativă încântătoare la ceva precum aplicația GitHub Desktop și rulează în interiorul terminalului.

Îl poți rula direct, mergând în orice director gestionat de git și rulând `lazygit`. Sau îl poți rula în interiorul Neovim, unde poate fi pornit cu `Space G G`.

Sari între diferitele panouri folosind `Tab`. În panoul Fișiere, selectezi fișierele pentru staging folosind `Space`, iar apoi poți crea un commit nou folosind `c`. Poți vedea toate comenzile disponibile folosind `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) este un manager de resurse superb care arată utilizarea memoriei, a procesorului, a discului și a rețelei. Listează, de asemenea, toate procesele active și îți permite să le gestionezi.

Omarchy îl numește Monitor de activitate și îl pornești din lansatorul de aplicații sau apăsând `Super + Shift + T`. Se deschide ca o fereastră plutitoare, pe care o poți transforma într-o dală cu `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) este un manager de spații de lucru pentru terminal care îți oferă spații de lucru, file și panouri și le menține pe toate în funcțiune într-o sesiune persistentă din care te poți detașa și la care poți reveni mai târziu.

Îl pornești (sau te reatașezi la sesiunea ta existentă) din lansatorul de aplicații sau cu `Super + Ctrl + Return`. Omarchy include o configurație Herdr care o reflectă pe cea pentru Tmux, așa că tasta prefix este `Ctrl + Space` și aici. Poți răsfoi toate combinațiile de taste cu `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) arată informații despre sistem, cum ar fi versiunea nucleului, timpul de funcționare, tema, procesorul, memoria și multe altele. Este un succesor al popularului instrument neofetch.

Omarchy l-a inclus ca _Sistem > Despre_ în meniul Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) este un player muzical retro pentru terminal, inspirat de Winamp 2.x, complet cu posturi de radio încorporate pentru ritmuri lo-fi. Lansează-l cu `Super + Shift + Alt + M` sau din meniul Omarchy, la _Aplicații_. Apasă `?` pentru lista completă de combinații de taste.

## Dar Wi-Fi și Bluetooth?

Nu vei găsi TUI-uri pentru Wi-Fi și Bluetooth — aceste sarcini aparțin shell-ului Omarchy. Fă clic pe pictograma Wi-Fi din bara de sus (sau apasă `Super + Ctrl + N`) pentru a vedea rețelele și a te conecta și fă clic pe pictograma Bluetooth (sau apasă `Super + Ctrl + B`) pentru a asocia și a conecta dispozitive. Vezi [rețele](35-networking.md) pentru povestea completă.

## Adaugă propriile TUI-uri

Orice program de terminal poate primi tratamentul complet de aplicație. Accesează _Instalează > TUI_ în meniul Omarchy (`Super + Space`), dă-i un nume, o comandă de lansare, un stil de fereastră și o pictogramă și va apărea în lansatorul de aplicații ca orice altă aplicație. Îl poți elimina din nou la _Elimină > TUI_.
