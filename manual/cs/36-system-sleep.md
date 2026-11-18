# Uspání systému

Omarchy ve výchozím nastavení povoluje uspání i hibernaci, ale pokud vám na vašem počítači jedno z toho dělá problémy, můžete je vypnout.

Na počítačích s NVIDIA GB10, jako jsou DGX Spark a ASUS Ascent GX10, jsou uspání a hibernace vypnuté, stejně jako v DGX OS od NVIDIA, protože se zatím neukázalo, že by spánek na tomto hardwaru fungoval. Totéž platí pro ASUS Zenbook A16 (UX3607OA), kde uspání zatím čip plně neuspí a počítač může přes noc zatuhnout. Přepnutí uspání ani nastavení hibernace se tam neuplatní. Chcete-li spánek znovu zapnout, odstraňte pomocí `sudo rm` soubor `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`; možnost uspání se pak vrátí do nabídky a hibernaci půjde nastavit stejně jako na ostatních počítačích. Spuštěním `sudo omarchy apply hardware --install-user "$USER"` soubor vrátíte zpět.

### Profily napájení

Na notebooku si Omarchy pamatuje profil napájení zvlášť pro napájení ze sítě a zvlášť pro provoz na baterii a přepíná mezi nimi podle toho, jak počítač připojujete a odpojujete. Ve výchozím nastavení to znamená výkon na AC a vyvážený režim na baterii.

Co váš počítač nabízí, zjistíte pomocí `omarchy powerprofiles list` a profil, který chcete pro stav, v němž se právě nacházíte, nastavíte pomocí `omarchy powerprofiles set autodetect power-saver`. Chcete-li nastavit druhý stav, aniž byste cokoliv odpojovali, pojmenujte ho přímo: `omarchy powerprofiles set battery power-saver`. Ať vyberete cokoliv, přesně to dostanete zpět, až se příště ocitnete v daném stavu.

### Přepnutí uspání

Uspání přepnete spuštěním `omarchy toggle suspend` z terminálu. Tím jen zobrazíte/skryjete možnost v nabídce _Systém_ (nebo `Super + Esc`) a pak můžete zjistit, jestli na vašem systému funguje spolehlivě. Pokud ne, stejným příkazem ji můžete zase skrýt.

### Přepnutí hibernace

Hibernaci nastavíte spuštěním `omarchy hibernation setup` z terminálu. Hibernace vytvoří na vašem zaváděcím disku podsvazek /swap o velikosti vaší fyzické paměti RAM, takže se ujistěte, že máte dostatek volného místa. Na počítači s 32GB pamětí budete pro tento svazek vždy potřebovat 32GB+ volného místa. Hibernace také vyžaduje výchozí zavaděč Limine.

Po nastavení uvidíte možnost hibernace v nabídce _Systém_ (nebo `Super + Esc`) a pak můžete zjistit, jestli na vašem systému funguje spolehlivě. Pokud ne, můžete ji zase odstranit spuštěním `omarchy hibernation remove`.
