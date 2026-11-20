# Instalace typu Dual Boot

Omarchy můžete nainstalovat na jeden oddíl vedle Windows nebo jiných instalací.

Tato metoda instalace ve výchozím nastavení stále zahrnuje šifrování oddílu pomocí LUKS, takže se ve výsledku nijak neliší od instalace na celý disk a jednoduše vyžaduje, aby na disku bylo k dispozici volné místo.

## Uvolnění místa ve Windows

Chcete-li provést instalaci vedle Windows, napište do nabídky Start `disk management` a vyberte možnost **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Najděte příslušný oddíl, klikněte na něj pravým tlačítkem a zvolte **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Zadejte velikost, o kterou chcete svazek zmenšit. Upozorňujeme, že to bude velikost vaší budoucí instalace Omarchy včetně spouštěcího oddílu.

 ![dual-boot-3](images/dual-boot-3.webp)

Až budete hotovi, měli byste vidět něco podobného, kde je v tomto příkladu část o velikosti 50GB místem, kam nainstalujeme Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalace Omarchy

Proces instalace Omarchy je ve výsledku stejný jako obvykle. Po výběru disku dostanete možnost **Free space install**. Vyberte tuto možnost, abyste zabránili vymazání celého disku.

 ![dual-boot-5](images/dual-boot-5.webp)

Zkontrolujte, zda vše vypadá dobře, a počkejte, až instalace jako obvykle skončí. Právě zde se také můžete rozhodnout pro nešifrovanou instalaci (nedoporučuje se), stejně jako při instalaci na celý disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Přidání dalších instalací do zavaděče

Po dokončení instalace Omarchy si všimnete, že je nyní výchozím zavaděčem Limine. Pomocí něj můžete do Limine přidat také možnosti pro své další instalace, například Windows.

Chcete-li přidat další operační systémy, spusťte `limine-scan` a podle pokynů přidejte požadované položky do konfigurace Limine. Spouštěcí nabídka zůstává ve výchozím nastavení skrytá a Omarchy se spustí po jedné sekundě. Chcete-li vybrat Windows nebo jinou položku, stiskněte libovolnou klávesu, jakmile se Limine spustí; když se nabídka objeví, vyberte položku pomocí kláves se šipkami a stiskněte Enter. Pokud se Omarchy spustí dříve, než stihnete klávesu stisknout, restartujte počítač a zkuste to znovu.

## Bitlocker

Je důležité upozornit, že tato metoda instalace není kompatibilní s nástrojem Bitlocker, protože ten šifruje celý disk, nejen oddíl. Pokud narazíte na chybu oznamující, že je Bitlocker povolený, spusťte Windows, přejděte do **Settings -> Privacy & Security -> Device encryption** a Bitlocker vypněte. Dešifrování disku může nějakou dobu trvat.

 ![dual-boot-7](images/dual-boot-7.webp)
