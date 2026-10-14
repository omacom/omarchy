# TUI-uri

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) este o alternativă încântătoare la ceva precum aplicația GitHub Desktop și rulează în interiorul terminalului.

Îl poți rula direct, mergând în orice director gestionat de git și rulând `lazygit`. Sau îl poți rula în interiorul Neovim, unde poate fi pornit cu `Space G G`.

Sari între diferitele panouri folosind `Tab`. În panoul Files, selectezi fișierele pentru staging folosind `Space`, apoi poți crea un commit nou folosind `c`. Poți vedea toate comenzile disponibile folosind `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) este un manager de resurse frumos care arată utilizarea memoriei, a CPU-ului, a discului și a rețelei. Listează și toate procesele active și îți permite să le gestionezi.

Omarchy îl numește Activity și îl pornești apăsând `Super + Ctrl + T`. Se deschide ca o fereastră plutitoare, pe care o poți dispune în mozaic cu `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) este un manager de spații de lucru în terminal care îți oferă spații de lucru, file și panouri și le ține pe toate rulând într-o sesiune persistentă de la care te poți detașa și la care te poți întoarce mai târziu.

Îl pornești (sau te reatașezi la sesiunea existentă) cu `Super + Ctrl + Return`. Omarchy livrează o configurație Herdr care o oglindește pe cea Tmux, așa că tasta prefix este și aici `Ctrl + Space`. Poți răsfoi toate scurtăturile cu `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) arată informații despre sistem, cum ar fi versiunea kernelului, timpul de funcționare, tema, CPU-ul, memoria și altele. Este un succesor al popularului instrument neofetch.

Omarchy l-a împachetat ca _Despre_ în meniul Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) este un player muzical retro în terminal, inspirat de Winamp 2.x, complet cu posturi de radio încorporate pentru beat-uri lo-fi. Lansează-l cu `Super + Shift + Alt + M` sau din meniul Omarchy, sub _Apps_. Apasă `?` pentru lista completă de scurtături.

## Dar Wi-Fi și Bluetooth?

Nu vei găsi TUI-uri pentru Wi-Fi și Bluetooth — acele treburi aparțin shell-ului Omarchy. Fă clic pe pictograma Wi-Fi din bara de sus (sau apasă `Super + Ctrl + W`) ca să vezi rețelele și să te conectezi, și fă clic pe pictograma Bluetooth (sau apasă `Super + Ctrl + B`) ca să asociezi și să conectezi dispozitive. Vezi [rețeaua](35-networking.md) pentru povestea completă.

## Adaugă propriile tale

Orice program de terminal poate primi tratamentul complet de aplicație. Mergi la _Instalează > TUI_ în meniul Omarchy (`Super + Space`), dă-i un nume, o comandă de lansare, un stil de fereastră și o pictogramă, și va apărea în lansatorul de aplicații ca orice altă aplicație. Îl poți elimina din nou sub _Elimină > TUI_.
