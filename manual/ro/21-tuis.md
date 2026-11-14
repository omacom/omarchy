# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) este o alternativă încântătoare la ceva precum aplicația GitHub Desktop și rulează în interiorul terminalului.

Poți să îl rulezi direct, mergând în orice director gestionat de git și rulând `lazygit`. Sau îl poți rula în interiorul Neovim, unde poate fi pornit cu `Space G G`.

Sari între diferitele panouri folosind `Tab`. În panoul Files, selectezi fișiere pentru staging folosind `Space`, iar apoi poți crea un commit nou folosind `c`. Poți vedea toate comenzile disponibile folosind `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) este un manager de resurse frumos care arată utilizarea memoriei, CPU, discului și rețelei. De asemenea, listează toate procesele active și îți permite să le gestionezi.

Omarchy îl numește Activity Monitor și îl pornești din lansatorul de aplicații sau apăsând `Super + Shift + T`. Se deschide ca o fereastră flotantă, pe care o poți aduce în tiling cu `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) este un manager de spații de lucru în terminal care îți oferă workspaces, taburi și panouri și le menține pe toate în funcțiune într-o sesiune persistentă de la care te poți detașa și la care poți reveni mai târziu.

Îl pornești (sau te reconectezi la sesiunea ta existentă) cu `Super + Ctrl + Return`. Omarchy livrează o configurație Herdr care o reflectă pe cea din Tmux, așa că tasta prefix este și aici `Ctrl + Space`. Poți răsfoi toate combinațiile de taste cu `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) arată informații despre sistem, cum ar fi versiunea kernelului, uptime, tema, CPU, memoria și multe altele. Este un succesor al popularului instrument neofetch.

Omarchy l-a împachetat ca _About_ în meniul Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) este un player muzical retro pentru terminal inspirat de Winamp 2.x, complet cu posturi de radio încorporate pentru lo-fi beats. Îl lansezi cu `Super + Shift + Alt + M` sau din meniul Omarchy sub _Apps_. Apasă `?` pentru lista completă de combinații de taste.

## Ce-i cu Wi-Fi și Bluetooth?

Nu vei găsi TUI-uri pentru Wi-Fi și Bluetooth — treburile astea aparțin shell-ului Omarchy. Dă clic pe pictograma Wi-Fi din bara de sus (sau apasă `Super + Ctrl + N`) pentru a vedea rețelele și a te conecta și dă clic pe pictograma Bluetooth (sau apasă `Super + Ctrl + B`) pentru a împerechea și conecta dispozitive. Vezi [rețele](35-networking.md) pentru povestea completă.

## Adăugarea propriilor tale

Orice program de terminal poate primi tratamentul complet de aplicație. Mergi la _Install > TUI_ în meniul Omarchy (`Super + Space`), dă-i un nume, o comandă de lansare, un stil de fereastră și o pictogramă și va apărea în lansatorul de aplicații ca orice altă aplicație. Îl poți elimina din nou sub _Remove > TUI_.
