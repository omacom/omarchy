# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) este o alternativă încântătoare la ceva precum aplicația GitHub Desktop și rulează în interiorul terminalului.

Îl poți rula direct, mergând în orice director gestionat de git și rulând `lazygit`. Sau îl poți rula în interiorul Neovim, unde poate fi pornit cu `Space G G`.

Sari între diferitele panouri folosind `Tab`. În panoul Files, selectezi fișierele pentru staging folosind `Space`, iar apoi poți crea un commit nou folosind `c`. Poți vedea toate comenzile disponibile folosind `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) este un manager de resurse frumos care arată utilizarea memoriei, a CPU-ului, a discului și a rețelei. Listează, de asemenea, toate procesele active și îți permite să le gestionezi.

Omarchy îl numește Activity și îl pornești apăsând `Super + Shift + T`. Se deschide ca fereastră plutitoare, pe care o poți așeza în mozaic cu `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) este un manager de spații de lucru în terminal care îți oferă spații de lucru, file și panouri și le menține pe toate în funcțiune într-o sesiune persistentă de la care te poți detașa și la care poți reveni mai târziu.

Îl pornești (sau te reconectezi la sesiunea existentă) cu `Super + Ctrl + Return`. Omarchy vine cu o configurație Herdr care o oglindește pe cea de Tmux, așa că tasta prefix este `Ctrl + Space` și aici. Poți răsfoi toate combinațiile de taste cu `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) arată informații despre sistem, precum versiunea nucleului, timpul de funcționare, tema, CPU-ul, memoria și multe altele. Este succesorul popularului instrument neofetch.

Omarchy l-a inclus ca _About_ în meniul Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) este un player muzical retro pentru terminal, inspirat de Winamp 2.x, completat cu posturi de radio încorporate pentru ritmuri lo-fi. Lansează-l cu `Super + Shift + Alt + M` sau din meniul Omarchy, la _Apps_. Apasă `?` pentru lista completă de combinații de taste.

## Ce se întâmplă cu Wi-Fi și Bluetooth?

Nu vei găsi TUIs pentru Wi-Fi și Bluetooth — aceste sarcini aparțin shell-ului Omarchy. Dă clic pe pictograma Wi-Fi din bara de sus (sau apasă `Super + Ctrl + N`) pentru a vedea rețelele și a te conecta, și dă clic pe pictograma Bluetooth (sau apasă `Super + Ctrl + B`) pentru a împerechea și conecta dispozitive. Vezi [rețea](35-networking.md) pentru povestea completă.

## Adăugarea unora proprii

Orice program de terminal poate primi tratamentul complet de aplicație. Mergi la _Install > TUI_ în meniul Omarchy (`Super + Space`), dă-i un nume, o comandă de lansare, un stil de fereastră și o pictogramă, iar el va apărea în lansatorul de aplicații la fel ca orice altă aplicație. Îl poți elimina din nou de la _Remove > TUI_.
