# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je příjemná alternativa k něčemu jako aplikace GitHub Desktop a běží uvnitř terminálu.

Můžete ho spustit přímo tak, že přejdete do libovolného adresáře spravovaného gitem a spustíte `lazygit`. Nebo ho můžete spustit uvnitř Neovim, kde ho lze otevřít pomocí `Space G G`.

Mezi různými panely přeskakujete pomocí `Tab`. V panelu Files vybíráte soubory pro staging pomocí `Space` a pak můžete vytvořit nový commit pomocí `c`. Všechny dostupné příkazy uvidíte pomocí `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je krásný správce prostředků, který ukazuje využití paměti, CPU, disku a sítě. Také vypisuje všechny aktivní procesy a umožňuje vám je spravovat.

Omarchy ho nazývá Activity a spustíte ho stisknutím `Super + Shift + T`. Otevře se jako plovoucí okno, které můžete přepnout do dlaždic pomocí `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je správce pracovních prostorů pro terminál, který vám dává pracovní prostory, karty a panely a nechává je všechny běžet v trvalé relaci, od které se můžete odpojit a později se k ní vrátit.

Spustíte ho (nebo se znovu připojíte ke své existující relaci) pomocí `Super + Ctrl + Return`. Omarchy dodává konfiguraci Herdr, která zrcadlí její konfiguraci Tmux, takže klávesa prefixu je i tady `Ctrl + Space`. Všechna přiřazení kláves můžete procházet pomocí `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) ukazuje informace o systému, jako je verze kernelu, doba provozu, téma, CPU, paměť a další. Je nástupcem oblíbeného nástroje neofetch.

Omarchy to zabalila jako _About_ v nabídce Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro hudební přehrávač pro terminál inspirovaný Winamp 2.x, včetně vestavěných rozhlasových stanic pro lo-fi beaty. Spustíte ho pomocí `Super + Shift + Alt + M` nebo z nabídky Omarchy pod položkou _Apps_. Úplný seznam přiřazení kláves zobrazíte stisknutím `?`.

## A co Wi-Fi a Bluetooth?

TUIs pro Wi-Fi a Bluetooth nenajdete — tyhle úkoly patří shellu Omarchy. Klikněte na ikonu Wi-Fi v horní liště (nebo stiskněte `Super + Ctrl + N`), abyste viděli sítě a mohli se připojit, a klikněte na ikonu Bluetooth (nebo stiskněte `Super + Ctrl + B`), abyste spárovali a připojili zařízení. Celý příběh najdete v části [sítě](35-networking.md).

## Přidání vlastní

Každý terminálový program může dostat plné zacházení jako aplikace. Přejděte do _Install > TUI_ v nabídce Omarchy (`Super + Space`), dejte mu název, příkaz pro spuštění, styl okna a ikonu a objeví se ve spouštěči aplikací jako každá jiná aplikace. Znovu ho můžete odstranit pod položkou _Remove > TUI_.
