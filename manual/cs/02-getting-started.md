# Začínáme

Omarchy se instaluje pomocí ISO. Můžete si vybrat mezi instalací na celý disk, která zabere celý disk, nebo instalací do volného místa, která Omarchy umístí do nepřiděleného místa na disku — takto můžete dual bootovat vedle Windows nebo jiného OS (viz [instalace pro dual boot](50-dual-boot-install.md) — mějte na paměti, že ve Windows musíte nejprve vypnout BitLocker). V obou případech instalace ve výchozím nastavení používá plné šifrování a možnost instalace na celý disk vybraný disk vymaže, takže pokud používáte stávající disk, určitě si ho nejprve zazálohujte!

Na Macu s Apple Silicon instalujete místo toho z macOS, bez ISO nebo USB disku. Viz [Omarchy pro Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

Nejprve si [stáhněte ISO Omarchy](https://omarchy.org/), nahrajte ho na USB disk (ve Windows použijte [Rufus](https://rufus.ie/), na Macu [balenaEtcher](https://etcher.balena.io/), na Linuxu [caligula](https://github.com/ifd3f/caligula)) a nabootujte z něj.

_Musíte v BIOSu vypnout Secure Boot a/nebo TPM. Musíte je vypnout, abyste mohli Omarchy nainstalovat. Jsou to bezpečnostní schémata Microsoftu určená pro Windows a Linuxové distribuce spřízněné s Microsoftem._

Pak odpovězte na konfigurační otázky a potvrďte je takto:

 ![install-config](images/install-config.webp)

Pak vyberte disk pro instalaci a pohodlně se usaďte a sledujte instalační show. Na nejrychlejších moderních strojích to může být hotové za méně než minutu, ale ani na starším počítači by to nemělo trvat déle než 5 minut.

 ![install-done](images/install-done.webp)

Teď jste připraveni na Omarchy!

### Používejte kabelovou klávesnici nebo klávesnici s 2.4ghz připojením!

Šifrování celého disku vám při startu neumožní zadat heslo z Bluetooth klávesnice. Stejně jako nemůžete Bluetooth klávesnici použít pro vstup do BIOSu na PC. Budete potřebovat klávesnici, která používá buď 2.4ghz dongle, nebo kabel (což je stejně mnohem lepší kvůli latenci!). Osobně miluji [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalace pro jiného vlastníka

Pokud nastavujete stroj pro někoho jiného — člena rodiny, nového zaměstnance, kupujícího — neměli byste osobní otázky odpovídat za něj. Stiskněte `Ctrl + C` hned na první obrazovce instalátoru (výběr klávesnice) a Omarchy nabídne, že stroj místo toho připraví pro jiného vlastníka. Systém se nainstaluje hned, ale veškeré osobní nastavení — rozložení klávesnice, uživatelské jméno, heslo — se odloží až do prvního spuštění stroje. Disk je i nadále ve výchozím nastavení šifrovaný a heslo, které si nový vlastník při tom prvním spuštění zvolí, se stane i šifrovacím heslem. (Stroj, který už používáte, můžete předat i bez přeinstalace — viz [resetování počítače](48-security.md).)

### Instalace bez obsluhy

ISO se dokáže nainstalovat i zcela samo — bez klávesnice, bez průvodce — když mu předáte jeho konfiguraci na druhém disku. Takto můžete Omarchy používat jako základní image pro VM a flotily strojů. Viz [instalace bez obsluhy](51-unattended-installs.md).

### Instalace bez šifrování

Omarchy se ve výchozím nastavení instaluje se šifrováním. Je to bezpečná, zodpovědná volba pro každý počítač, který se může ztratit nebo být ukraden. Nechcete, aby kdokoli s přístupem k vašemu hardwaru mohl získat vaše data!

Ale za zvláštních okolností, jako jsou vzdálené instalace Omarchy na chráněných počítačích nebo jednorázové instalace bez citlivých dat, můžete chtít instalovat bez šifrování. Stisknutím `Ctrl + C` při potvrzení formátování disku můžete přepnout na instalaci bez šifrování.

### Jazyk

Omarchy mluví 50 jazyky — stejnou sadou jako omarchy.org — a výchozím jazykem je angličtina. Chcete-li jazyk přepnout, otevřete nabídku Omarchy a přejděte do _Nastavení > Region > Jazyk_, nebo v terminálu spusťte `omarchy language <code>` (`omarchy language list` zobrazí kódy). Nabídka, desktop a vlastní oznámení Omarchy změní jazyk okamžitě a každá aplikace, kterou poté otevřete, ho bude následovat také. Aplikace, které už byly otevřené, se přepnou, jakmile je restartujete.

Chcete-li si jazyk ponechat, ale chcete, aby se datumy, časy, čísla, peníze, jednotky a velikosti papíru zapisovaly tak, jak je to zvykem v jiném regionu (například angličtina s evropskými datumy a 24hodinovým formátem času), vyberte region v části _Nastavení > Region > Formáty_, kde každá volba zobrazuje ukázku, nebo spusťte `omarchy region formats <code>` (`omarchy region formats list` zobrazí kódy). Možnost _Stejné jako jazyk_ se vrátí k vlastním formátům daného jazyka. Stejně jako přepnutí jazyka se to projeví u aplikací, které otevřete poté.

### Pomoc, když se zaseknete

Pokud se zaseknete, obvykle najdete někoho ochotného pomoci v kanálu _#omarchy-help_ na [komunitním Discordu](https://omarchy.org/discord).
