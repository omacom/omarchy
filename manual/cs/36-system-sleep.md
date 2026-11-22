# Spánek systému

Omarchy ve výchozím nastavení povoluje uspání a po jejím nastavení i hibernaci, ale pokud s něčím z toho máte na svém počítači problémy, můžete to vypnout.

Na počítačích s NVIDIA GB10, jako jsou DGX Spark a ASUS Ascent GX10, jsou uspání a hibernace vypnuté, stejně jako v NVIDIA DGX OS, protože u tohoto hardwaru zatím nebylo prokázáno, že spánek funguje. Totéž platí pro ASUS Zenbook A16 (UX3607OA), kde uspání zatím čip plně neuspí a přes noc může zatuhnout. Přepínač uspání ani nastavení hibernace se tam neuplatní. Chcete-li spánek znovu zapnout, odstraňte pomocí `sudo rm` soubor `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`; možnost uspání se pak vrátí do nabídky a hibernaci lze nastavit jako na jiných počítačích. Spuštění `sudo omarchy apply hardware --install-user "$USER"` soubor vrátí zpět.

### Profily napájení

Na notebooku si Omarchy pamatuje váš profil napájení zvlášť pro napájení ze sítě a pro provoz na baterii a přepíná mezi nimi, jak zapojujete a odpojujete napájení. Ve výchozím nastavení to znamená výkon při napájení ze sítě a vyvážený režim na baterii.

Co váš počítač nabízí, zjistíte pomocí `omarchy powerprofiles list` a profil, který chcete pro stav, ve kterém se právě nacházíte, nastavíte pomocí `omarchy powerprofiles set autodetect power-saver`. Chcete-li nastavit druhý stav, aniž byste cokoli odpojovali, pojmenujte ho přímo: `omarchy powerprofiles set battery power-saver`. Ať vyberete cokoli, přesně to dostanete zpět, až se příště ocitnete v daném stavu.

### Přepnutí uspání

Uspání přepnete spuštěním `omarchy toggle suspend` z terminálu. Tím se jen zobrazí/skryje možnost pod _Systém_ (nebo `Super + Esc`) a pak můžete vyzkoušet, zda na vašem systému funguje spolehlivě. Pokud ne, můžete ji stejným příkazem znovu skrýt.

### Přepnutí hibernace

Hibernaci nastavíte spuštěním `omarchy hibernation setup` z terminálu (na počítačích Mac s Apple Silicon není k dispozici). Hibernace vytvoří na vaší spouštěcí jednotce podsvazek /swap o velikosti vaší fyzické paměti RAM, takže se ujistěte, že máte dostatek volného místa. Na počítači s 32GB budete pro tento svazek vždy potřebovat 32GB+ volného místa. Hibernace také vyžaduje výchozí zavaděč Limine.

Po nastavení uvidíte možnost hibernace pod _Systém_ (nebo `Super + Esc`) a pak můžete vyzkoušet, zda na vašem systému funguje spolehlivě. Pokud ne, můžete ji znovu odstranit spuštěním `omarchy hibernation remove`.
