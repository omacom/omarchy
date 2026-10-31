# Začínáme

Omarchy se instaluje pomocí ISO. Můžete si vybrat mezi instalací na celý disk, která převezme celý disk, nebo instalací do volného místa, která Omarchy umístí do nepřiděleného prostoru na disku — takhle můžete dual bootovat vedle Windows nebo jiného OS (viz [instalace v dual bootu](50-dual-boot-install.md) — mějte na paměti, že ve Windows budete muset nejprve vypnout BitLocker). V obou případech je instalace standardně plně šifrovaná a volba celého disku vybraný disk vymaže, takže si před použitím stávajícího disku určitě udělejte zálohu!

Nejprve si [stáhněte Omarchy ISO](https://omarchy.org/), nahrajte ho na USB disk (na Macu/Windows použijte [balenaEtcher](https://etcher.balena.io/), na Linuxu [caligula](https://github.com/ifd3f/caligula)) a nabootujte z USB disku.

_V BIOSu musíte vypnout Secure Boot a/nebo TPM. Abyste mohli Omarchy nainstalovat, musíte je vypnout. Jsou to bezpečnostní schémata Microsoftu určená pro Windows a linuxové distribuce přidružené k Microsoftu._

Pak odpovězte na konfigurační otázky a potvrďte je takto:

 ![install-config](images/install-config.webp)

Pak vyberte disk pro instalaci, pohodlně se usaďte a dívejte se na instalační show. Na nejrychlejších moderních strojích může být hotovo do minuty, ale ani na starším počítači by to nemělo trvat déle než 5 minut.

 ![install-done](images/install-done.webp)

Teď jste připraveni na Omarchy!

### Použijte kabelovou nebo 2.4ghz klávesnici!

Šifrování celého disku vám při spuštění nedovolí zadat heslo z Bluetooth klávesnice. Stejně jako na PC nemůžete Bluetooth klávesnici použít pro vstup do BIOSu. Budete potřebovat klávesnici, která používá buď 2.4ghz dongle, nebo kabel (což je kvůli latenci stejně mnohem příjemnější!). Já osobně miluju [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalace pro jiného majitele

Pokud stroj připravujete pro někoho jiného — rodinného příslušníka, nového zaměstnance, kupujícího — neměli byste za něj odpovídat na osobní otázky. Na úplně první obrazovce instalátoru (výběr klávesnice) stiskněte `Ctrl + C` a Omarchy vám nabídne, že stroj místo toho připraví pro jiného majitele. Systém se nainstaluje hned, ale veškeré osobní nastavení — rozložení klávesnice, uživatelské jméno, heslo — se odloží, až stroj poprvé nabootuje. Disk je nadále standardně šifrovaný a heslo, které si nový majitel při tom prvním spuštění vybere, se stane také šifrovacím heslem. (Stroj, který už sami používáte, můžete předat i bez přeinstalace — viz [resetování počítače](48-security.md).)

### Bezobslužné instalace

ISO se může nainstalovat i úplně samo — bez klávesnice, bez průvodce — když mu konfiguraci předáte na druhém disku. Tak se Omarchy dá používat jako základní image pro VMs a flotily strojů. Viz [bezobslužné instalace](51-unattended-installs.md).

### Instalace bez šifrování

Omarchy se standardně instaluje se šifrováním. Je to bezpečná a zodpovědná volba pro každý počítač, který by se mohl ztratit nebo být ukraden. Nechcete, aby se kdokoli s přístupem k vašemu hardwaru mohl dostat k vašim datům!

Za zvláštních okolností, třeba při vzdálených instalacích Omarchy na chráněné počítače nebo u instalací na jedno použití bez citlivých dat, ale můžete chtít instalovat bez šifrování. Při potvrzení formátování disku můžete stisknout `Ctrl + C` a přepnout na instalaci bez šifrování.

### Jazyk

Omarchy mluví 50 jazyky — stejnou sadou jako omarchy.org — a výchozím jazykem je angličtina. Chcete-li ho přepnout, otevřete nabídku Omarchy a přejděte do _Nastavení > Jazyk_, nebo v terminálu spusťte `omarchy language <code>` (`omarchy language list` zobrazí kódy). Nabídka, plocha a vlastní oznámení Omarchy změní jazyk okamžitě a každá aplikace, kterou poté otevřete, je následuje. Aplikace, které už byly otevřené, se přepnou, jakmile je restartujete.

### Pomoc, když se zaseknete

Pokud se zaseknete, obvykle najdete někoho ochotného pomoci v kanálu _#omarchy-help_ na [komunitním Discordu](https://omarchy.org/discord).
