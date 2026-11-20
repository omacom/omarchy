# Začínáme

Omarchy se instaluje pomocí ISO. Můžete si vybrat mezi instalací na celý disk, která převezme celé diskové zařízení, nebo instalací do volného místa, která Omarchy umístí do nepřiděleného místa na disku — takto dual bootujete vedle Windows nebo jiného OS (viz [instalace dual bootu](50-dual-boot-install.md) — nezapomeňte, že ve Windows musíte nejprve vypnout BitLocker). V obou případech je instalace ve výchozím nastavení plně šifrovaná a možnost na celý disk vymaže vybraný disk, takže si před použitím existujícího disku nezapomeňte udělat zálohu!

Nejprve si [stáhněte Omarchy ISO](https://omarchy.org/), nahrajte ho na USB flash disk (na Windows použijte [Rufus](https://rufus.ie/), na Macu [balenaEtcher](https://etcher.balena.io/) nebo na Linuxu [caligula](https://github.com/ifd3f/caligula)) a nabootujte z flash disku.

_Musíte vypnout Secure Boot a/nebo TPM v BIOSu. Musíte je vypnout, abyste mohli Omarchy nainstalovat. Jsou to bezpečnostní schémata Microsoftu určená pro Windows a Linuxové distribuce spřízněné s Microsoftem._

Poté odpovězte na konfigurační otázky a potvrďte je takto:

 ![install-config](images/install-config.webp)

Poté vyberte disk pro instalaci a pohodlně se usaďte a sledujte instalační show. Na nejrychlejších moderních počítačích to může být hotové za méně než minutu, ale ani na starším počítači by to nemělo trvat déle než 5 minut.

 ![install-done](images/install-done.webp)

Nyní jste připraveni na Omarchy!

### Používejte kabelovou klávesnici nebo klávesnici s 2.4ghz!

Šifrování celého disku vám neumožní zadat heslo z Bluetooth klávesnice při spuštění. Stejně jako nemůžete použít Bluetooth klávesnici pro vstup do BIOSu na PC. Budete potřebovat klávesnici, která používá buď 2.4ghz dongle, nebo kabel (což je stejně mnohem lepší kvůli latenci!). Osobně miluji [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalace pro jiného vlastníka

Pokud nastavujete počítač pro někoho jiného — člena rodiny, nového zaměstnance, kupujícího — neměli byste osobní otázky zodpovídat za něj. Stiskněte `Ctrl + C` na úplně první obrazovce instalátoru (výběr klávesnice) a Omarchy nabídne, že místo toho připraví počítač pro jiného vlastníka. Systém se nainstaluje hned, ale veškeré osobní nastavení — rozložení klávesnice, uživatelské jméno, heslo — se odloží až do prvního spuštění počítače. Disk je stále ve výchozím nastavení šifrovaný a heslo, které si nový vlastník zvolí při tom prvním spuštění, se stane také šifrovacím heslem. (Počítač, který už používáte, lze předat bez přeinstalace také — viz [resetování počítače](48-security.md).)

### Bezobslužné instalace

ISO se také může nainstalovat zcela samo — bez klávesnice, bez průvodce — když dostane svou konfiguraci na druhém disku. Takto se dá Omarchy používat jako základní image pro VM a flotilové stroje. Viz [bezobslužné instalace](51-unattended-installs.md).

### Instalace bez šifrování

Omarchy se ve výchozím nastavení instaluje se šifrováním. Je to bezpečná a zodpovědná volba pro každý počítač, který může být případně ztracen nebo ukraden. Nechcete, aby kdokoli s přístupem k vašemu hardwaru mohl získat vaše data!

Ale za zvláštních okolností, jako jsou vzdálené instalace Omarchy na chráněných počítačích nebo pro jednorázové instalace bez citlivých dat, můžete chtít instalovat bez šifrování. Na potvrzení formátování disku můžete stisknout `Ctrl + C` a přepnout na instalaci bez šifrování.

### Jazyk

Omarchy mluví 50 jazyky — stejnou sadou jako omarchy.org — a výchozím jazykem je angličtina. Pro přepnutí otevřete nabídku Omarchy a přejděte do _Setup > Region > Language_, nebo v terminálu spusťte `omarchy language <code>` (`omarchy language list` zobrazí kódy). Nabídka, desktop a vlastní oznámení Omarchy se změní okamžitě a každá aplikace, kterou poté otevřete, se také přizpůsobí. Aplikace, které už byly otevřené, se přepnou, jakmile je restartujete.

Pokud chcete zachovat jazyk, ale psát data, časy, čísla, peníze, jednotky a velikosti papíru způsobem jiné oblasti (třeba angličtinu s evropskými daty a 24hodinovými hodinami), vyberte oblast v _Setup > Region > Formats_, kde každá volba ukazuje ukázku, nebo spusťte `omarchy region <code>` (`omarchy region list` zobrazí kódy). _Same as language_ se vrátí k vlastním formátům jazyka. Stejně jako přepnutí jazyka se to projeví u aplikací, které otevřete poté.

### Pomoc, když se zaseknete

Pokud se zaseknete, obvykle najdete někoho ochotného pomoci v kanálu _#omarchy-help_ na [komunitním Discordu](https://omarchy.org/discord).
