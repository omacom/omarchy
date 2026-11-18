# Instalace Dual Boot

Omarchy můžete nainstalovat na jeden oddíl vedle Windows nebo jiných instalací.

Tento způsob instalace i tak ve výchozím nastavení zahrnuje šifrování oddílu pomocí LUKS, takže se v podstatě nijak neliší od instalace na celý disk a jednoduše jen vyžaduje, aby bylo na disku k dispozici volné místo.

## Uvolnění místa ve Windows

Pokud chcete instalovat vedle Windows, zadejte do nabídky Start `disk management` a vyberte možnost **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Najděte příslušný oddíl, klikněte na něj pravým tlačítkem a zvolte **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Zadejte velikost, o kterou chcete svazek zmenšit. Upozorňujeme, že to bude velikost vaší budoucí instalace Omarchy včetně spouštěcího oddílu.

 ![dual-boot-3](images/dual-boot-3.webp)

Až budete hotovi, měli byste vidět něco takového, kde část o velikosti 50 GB je v tomto příkladu místem, kam nainstalujeme Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalace Omarchy

Proces instalace Omarchy je v podstatě stejný jako obvykle. Po výběru disku dostanete možnost **Free space install**. Tuto možnost vyberte, abyste zabránili vymazání celého disku.

 ![dual-boot-5](images/dual-boot-5.webp)

Zkontrolujte, že vše vypadá dobře, a stejně jako obvykle počkejte na dokončení instalace. Zde se také můžete rozhodnout pro instalaci bez šifrování (nedoporučuje se), stejně jako při instalaci na celý disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Přidání dalších instalací do bootloaderu

Po dokončení instalace Omarchy si všimnete, že je nyní výchozím bootloaderem Limine. Pomocí něj můžete do Limine přidat také možnosti pro své další instalace, například Windows.

Chcete-li přidat další operační systémy, spusťte `limine-scan` a podle pokynů přidejte požadované položky do konfigurace Limine. Nabídka při spouštění zůstává ve výchozím nastavení skrytá a Omarchy se spustí po jedné sekundě. Chcete-li zvolit Windows nebo jinou položku, stiskněte libovolnou klávesu, jakmile se Limine spustí; po zobrazení nabídky vyberte položku pomocí kláves se šipkami a stiskněte Enter. Pokud se Omarchy spustí dříve, než stihnete klávesu stisknout, restartujte počítač a zkuste to znovu. Pokud jste zapnuli _Setup > Direct Boot_, firmware Limine zcela přeskočí, takže vyberte Limine z nabídky spouštění BIOSu, nebo znovu spusťte _Setup > Direct Boot_ a položku odeberte.

## Bitlocker

Je důležité upozornit, že tento způsob instalace není kompatibilní s Bitlockerem, protože ten šifruje celý disk, nejen oddíl. Pokud narazíte na chybu oznamující, že je Bitlocker povolený, spusťte Windows, přejděte do **Settings -> Privacy & Security -> Device encryption** a Bitlocker vypněte. Dešifrování disku může chvíli trvat.

 ![dual-boot-7](images/dual-boot-7.webp)
