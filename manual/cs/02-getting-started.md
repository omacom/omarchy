# Začínáme

Omarchy se instaluje pomocí ISO. Můžete si vybrat mezi instalací na celý disk, která převezme celé úložiště, nebo instalací do volného místa, která Omarchy umístí do nepřiděleného prostoru na disku — tak získáte dual boot vedle Windows nebo jiného OS (viz [instalace dual bootu](50-dual-boot-install.md) — mějte na paměti, že ve Windows budete muset nejprve vypnout BitLocker). V obou případech instalace ve výchozím nastavení používá úplné šifrování a instalace na celý disk vybraný disk vymaže, takže si před použitím stávajícího disku nezapomeňte vytvořit zálohu!

Nejprve si [stáhněte ISO Omarchy](https://omarchy.org/), zapište ho na USB klíčenku (ve Windows použijte [Rufus](https://rufus.ie/), na Macu [balenaEtcher](https://etcher.balena.io/) nebo na Linuxu [caligula](https://github.com/ifd3f/caligula)) a z klíčenky nabootujte.

_V BIOS musíte vypnout Secure Boot a/nebo TPM. Abyste mohli Omarchy nainstalovat, musíte je vypnout. Jsou to bezpečnostní schémata Microsoftu určená pro Windows a linuxové distribuce spolupracující s Microsoftem._

Potom odpovězte na otázky ke konfiguraci a potvrďte je takto:

 ![install-config](images/install-config.webp)

Pak vyberte disk pro instalaci, pohodlně se usaďte a sledujte instalační show. Na nejrychlejších moderních počítačích to může být hotové za méně než minutu, ale ani na starším počítači by to nemělo trvat déle než 5 minut.

 ![install-done](images/install-done.webp)

Teď jste připraveni používat Omarchy!

### Používejte kabelovou klávesnici nebo klávesnici s 2.4ghz!

Úplné šifrování disku vám při spuštění neumožní zadat heslo z Bluetooth klávesnice. Stejně jako na PC nemůžete Bluetooth klávesnici použít pro vstup do BIOS. Budete potřebovat klávesnici, která používá buď 2.4ghz dongle, nebo kabel (což je kvůli latenci stejně mnohem příjemnější!). Osobně miluji [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalace pro jiného vlastníka

Pokud počítač nastavujete pro někoho jiného — člena rodiny, nového zaměstnance, kupujícího — neměli byste osobní otázky zodpovídat za něj. Na úplně první obrazovce instalátoru (výběr klávesnice) stiskněte `Ctrl + C` a Omarchy místo toho nabídne přípravu počítače pro jiného vlastníka. Systém se nainstaluje okamžitě, ale veškeré osobní nastavení — rozložení klávesnice, uživatelské jméno, heslo — se odloží až na první spuštění počítače. Disk je i nadále ve výchozím nastavení šifrovaný a heslo, které si nový vlastník při prvním spuštění zvolí, se stane také heslem k šifrování. (Počítač, který jste už používali, můžete předat i bez přeinstalace — viz [resetování počítače](48-security.md).)

### Bezobslužné instalace

ISO se umí nainstalovat i zcela samo — bez klávesnice, bez průvodce — když mu předáte konfiguraci na druhém disku. Právě tak můžete Omarchy používat jako základní obraz pro VM a celé flotily počítačů. Viz [bezobslužné instalace](51-unattended-installs.md).

### Instalace bez šifrování

Omarchy se ve výchozím nastavení instaluje se šifrováním. Je to bezpečná a zodpovědná volba pro každý počítač, který se může ztratit nebo být ukraden. Nechcete přece, aby se kdokoli s přístupem k vašemu hardwaru dostal k vašim datům!

Za zvláštních okolností, například při vzdálených instalacích Omarchy na chráněných počítačích nebo u instalací na jedno použití bez citlivých dat, ale můžete chtít instalovat bez šifrování. Na obrazovce potvrzení formátování disku můžete stisknutím `Ctrl + C` přepnout na instalaci bez šifrování.

### Jazyk

Omarchy mluví 50 jazyky — stejnou sadou jako omarchy.org — a výchozím jazykem je angličtina. Chcete-li jazyk změnit, otevřete nabídku Omarchy a přejděte do _Nastavení > Jazyk_, nebo v terminálu spusťte `omarchy language <code>` (příkaz `omarchy language list` zobrazí jednotlivé kódy). Nabídka, plocha i vlastní oznámení Omarchy se přepnou okamžitě a každá aplikace, kterou poté otevřete, je bude následovat. Aplikace, které už byly otevřené, se přepnou po restartování.

### Pomoc, pokud se zaseknete

Pokud se zaseknete, obvykle najdete někoho ochotného pomoci v kanálu _#omarchy-help_ na [komunitním Discordu](https://omarchy.org/discord).
