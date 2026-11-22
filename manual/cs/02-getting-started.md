# Začínáme

Omarchy se instaluje pomocí ISO. Můžete si vybrat mezi instalací na celý disk, která převezme celý disk, nebo instalací do volného místa, která Omarchy umístí do nepřiděleného místa na disku — takhle provedete dual boot vedle Windows nebo jiného OS (viz [instalace dual bootu](50-dual-boot-install.md) — nezapomeňte, že ve Windows musíte nejprve vypnout BitLocker). Ať tak či onak, instalace ve výchozím nastavení používá plné šifrování a možnost celého disku vybraný disk vymaže, takže si před použitím stávajícího disku rozhodně udělejte zálohu!

[Stáhněte si ISO Omarchy](https://omarchy.org/) jako první, dejte ho na USB flash disk (ve Windows použijte [Rufus](https://rufus.ie/), na Macu [balenaEtcher](https://etcher.balena.io/) nebo na Linuxu [caligula](https://github.com/ifd3f/caligula)) a nabootujte z flash disku.

_Musíte v BIOSu vypnout Secure Boot a/nebo TPM. Musíte je vypnout, abyste mohli Omarchy nainstalovat. Jsou to bezpečnostní schémata Microsoftu určená pro Windows a Linuxové distribuce přidružené k Microsoftu._

Poté odpovězte na konfigurační otázky a potvrďte je takto:

 ![install-config](images/install-config.webp)

Poté vyberte disk pro instalaci, pohodlně se usaďte a sledujte instalační show. Na nejrychlejších moderních strojích to může být hotové za méně než minutu, ale ani na starším počítači by to nemělo trvat déle než 5 minut.

 ![install-done](images/install-done.webp)

Teď jste připraveni na Omarchy!

### Použijte drátovou klávesnici nebo klávesnici s 2.4ghz!

Plné šifrování disku vám nedovolí zadat heslo z Bluetooth klávesnice při spuštění. Stejně jako nemůžete použít Bluetooth klávesnici pro vstup do BIOSu na PC. Budete potřebovat klávesnici, která buď používá 2.4ghz dongle, nebo kabel (což je stejně mnohem lepší kvůli latenci!). Osobně miluji [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalace pro jiného majitele

Pokud připravujete stroj pro někoho jiného — člena rodiny, nového zaměstnance, kupujícího — neměli byste na osobní otázky odpovídat za ně. Stiskněte `Ctrl + C` na úplně první obrazovce instalátoru (výběr klávesnice) a Omarchy místo toho nabídne přípravu stroje pro jiného majitele. Systém se nainstaluje hned, ale veškeré osobní nastavení — rozložení klávesnice, uživatelské jméno, heslo — se odloží až do prvního spuštění stroje. Disk je stále ve výchozím nastavení šifrovaný a heslo, které si nový majitel zvolí při tom prvním spuštění, se stane i šifrovacím heslem. (Stroj, který jste už používali, lze předat i bez přeinstalace — viz [resetování počítače](48-security.md).)

### Bezobslužné instalace

ISO se může nainstalovat i zcela samo — bez klávesnice, bez průvodce — když dostane svou konfiguraci na druhém disku. Takhle můžete s Omarchy zacházet jako se základním obrazem pro VM a flotily strojů. Viz [bezobslužné instalace](51-unattended-installs.md).

### Instalace bez šifrování

Omarchy se ve výchozím nastavení instaluje se šifrováním. Je to bezpečná, zodpovědná volba pro jakýkoli počítač, který se může ztratit nebo být ukraden. Nechcete, aby se kdokoli s přístupem k vašemu hardwaru mohl dostat k vašim datům!

Ale za zvláštních okolností, jako jsou vzdálené instalace Omarchy na chráněných počítačích nebo pro vyhazovací instalace bez citlivých dat, můžete chtít instalovat bez šifrování. Na potvrzení formátování disku můžete stisknout `Ctrl + C` a přepnout na instalaci bez šifrování.

### Jazyk

Omarchy mluví 50 jazyky — stejnou sadou jako omarchy.org — a výchozím jazykem je angličtina. Chcete-li jazyk přepnout, otevřete nabídku Omarchy a přejděte do _Nastavení > Region > Jazyk_, nebo v terminálu spusťte `omarchy language <code>` (`omarchy language list` zobrazí kódy). Nabídka, plocha a vlastní oznámení Omarchy změní jazyk okamžitě a každá aplikace, kterou poté otevřete, je bude následovat. Aplikace, které už byly otevřené, se přepnou po jejich restartování.

Chcete-li si jazyk ponechat, ale psát data, časy, čísla, peníze, jednotky a formáty papíru tak, jak to dělá jiný region (třeba angličtinu s evropskými daty a 24hodinovým formátem času), vyberte region v _Nastavení > Region > Formáty_, kde každá volba ukazuje ukázku, nebo spusťte `omarchy region formats <code>` (`omarchy region formats list` zobrazí kódy). _Stejné jako jazyk_ se vrátí k vlastním formátům jazyka. Stejně jako přepnutí jazyka se to projeví v aplikacích, které poté otevřete.

### Pomoc, když se zaseknete

Pokud se zaseknete, obvykle najdete někoho ochotného pomoci v kanálu _#omarchy-help_ na [komunitním Discordu](https://omarchy.org/discord).
