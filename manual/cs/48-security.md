# Zabezpečení

Omarchy bere zabezpečení nesmírně vážně. Má to být operační systém, který můžete používat na _Skutečnou Práci_ ve _Skutečném Světě_. Kde ztráta notebooku nemůže vést k bezpečnostní nouzi. Takže tady je, co děláme:

1. *Šifrování celého disku je povinné*: Toto je nejdůležitější krok k zabezpečení fyzické ochrany vašich dat. Pokud počítač ztratíte nebo vám ho ukradnou, data jsou plně zašifrovaná pomocí standardního LUKS (Linux Unified Key Setup).
2. *Firewall je ve výchozím nastavení zapnutý*: Veškerý příchozí provoz je ve výchozím nastavení blokován s výjimkou portu 53317 pro [LocalSend](https://localsend.org/). Dokonce i ssh je vypnuté, dokud ho nezapnete přes _Setup > Security > SSHD_, což v rámci nastavení otevře port 22 (s omezením frekvence proti útokům hrubou silou). Pomocí nastavení [ufw-docker](https://github.com/chaifeng/ufw-docker) dokonce zamykáme i přístup k Dockeru, aby vaše kontejnery nemohly být omylem vystaveny světu.
3. *Arch má vždy nejnovější aktualizace*: Arch, základní distribuce, na které je Omarchy postavené, je průběžně aktualizovaná distribuce. To znamená, že jakákoli bezpečnostní zranitelnost, která je objevena a opravena v jakémkoli balíčku, je rychle k dispozici k instalaci pomocí `omarchy-update`. Tímto způsobem vždy používáte nejnovější a nejbezpečnější verze všeho.
4. *Omarchy spravuje vlastní balíčky a mirror*: Omarchy ve výchozím nastavení spoléhá pouze na balíčky z vlastních repozitářů Archu core/extra/multilib a ze svého vlastního Omarchy Package Repository. Software můžete instalovat přímo z AUR, ale základní instalace to nedělá — z AUR čerpá jen pár volitelných instalací, například prohlížeče třetích stran.
5. *Cloudflare nás chrání před DDoS*: Distribuční infrastruktura Omarchy — ISO soubory, balíčky Omarchy, mirror Archu — je chráněna za mohutným DDoS štítem Cloudflare a hostovaná na jejich CDN. To zajišťuje vynikající dostupnost.

## Změna vašich hesel

Na zašifrované instalaci máte dvě hesla: jedno, které při spuštění odemyká disk, a druhé, kterým se přihlašujete a používáte `sudo`. Nastavení je udělá stejná. Obě lze změnit v nabídce Omarchy pod _Update > Password_ — _Drive Encryption_ pro první, _User_ pro druhé. Změna hesla disku se nejprve zeptá na to současné, takže ho mějte po ruce. Pokud se změna přeruší, spusťte _Drive Encryption_ znovu: zeptá se na heslo, které disk odemyká nyní, a změnu dokončí.

## Předání počítače, který jste už používali

Pokud svůj počítač předáváte někomu jinému, nemusíte ho přeinstalovávat. V nabídce Omarchy spusťte _Setup > Reset Computer_, pro potvrzení napište `reset` a restartujte. Tím se smaže každý uživatelský účet a vše v `/home`, zahodí se všechny balíčky a systémové změny, které jste od instalace provedli, a vymaže se identita počítače — síťová připojení, klíče hostitele, prostě všechno. Po spuštění se objeví průvodce nastavením z prvního spuštění, připravený na to, aby nový majitel zadal své vlastní jméno, heslo a šifrovací heslo.

Funguje to obnovením výchozího snímku, který instalátor pořídí, takže je to k dispozici pouze na počítačích nainstalovaných z Omarchy ISO. A na disku bez šifrování je resetováním smazání, nikoli bezpečné vymazání, takže pokud byla data citlivá, proveďte místo toho čerstvou instalaci.

## Sudo bez hesla

Někdy chcete, aby `sudo` přestalo žádat o heslo, nejčastěji když za vás AI agent dělá dlouhý úsek systémové práce. _Setup > Security > Passwordless Sudo_ se zeptá, na jak dlouho přístup povolit: **15 minut**, **1 hodina**, **1 den**, nebo **Trvale**. Dokud je přístup aktivní, vedle ostatních indikátorů v liště nabídek se zobrazuje červená varovná ikona. Kliknutím na ni nebo opětovným spuštěním příkazu přístup vypnete. Pomocí `omarchy-sudo-passwordless 30` můžete také zadat vlastní počet minut (od 1 do 1440), nebo použít `omarchy-sudo-passwordless permanent`.

Časově omezený přístup automaticky vyprší, a to i okamžitě po probuzení z uspání, během kterého lhůta uplynula. Restartování počítače ho ukončí předčasně. Trvalý přístup přežije restarty a zůstává zapnutý, dokud ho nevypnete.

Aktualizace nebo odebrání balíčku s nastavením Omarchy ukončí každé dočasné oprávnění dříve, než se změní jeho podpora vypršení. Pokud příkaz nahlásí chybu autorizace nebo čištění, vyřešte ji, než se pokusíte povolit další oprávnění; chyba neznamená, že přístup bez hesla není aktivní.

Buďte v tomhle střízliví: dokud je to zapnuté, cokoliv běžící pod vaším uživatelem může bez dotazování dělat cokoliv jako root. To je celý smysl, a zároveň celé riziko.

## Podpisové klíče

Veřejný klíč pro všechny podpisy ISO a balíček repozitáře Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ověřit na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balíček `omarchy/omarchy-keyring` ho obsahuje také a bude použit k bezproblémovému zavedení případných aktualizací.

Podpis pro jakékoli vydání ISO najdete přidáním .sig k URL. Například https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
