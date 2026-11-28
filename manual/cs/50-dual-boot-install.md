# Instalace v režimu dual boot

Omarchy můžete nainstalovat na jeden oddíl vedle Windows nebo jiných instalací.

Tato metoda instalace i tak ve výchozím nastavení používá pro daný oddíl šifrování LUKS, takže se ve skutečnosti nijak neliší od instalace na celý disk a pouze vyžaduje, aby bylo na disku k dispozici volné místo.

## Uvolnění místa ve Windows

Pokud chcete instalaci provést vedle Windows, zadejte v nabídce Start `disk management` a vyberte možnost **Vytvořit a formátovat oddíly na pevném disku**.

 ![dual-boot-1](images/dual-boot-1.webp)

Najděte příslušný oddíl, klikněte na něj pravým tlačítkem a zvolte **Zmenšit svazek**.

![dual-boot-2](images/dual-boot-2.webp)

 Zadejte velikost, o kterou chcete svazek zmenšit. Mějte na paměti, že to bude velikost vaší budoucí instalace Omarchy včetně spouštěcího oddílu.

 ![dual-boot-3](images/dual-boot-3.webp)

Až budete hotovi, měli byste vidět něco podobného, kde je 50GB část v tomto příkladu místem, kam nainstalujeme Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalace Omarchy

Proces instalace Omarchy je ve skutečnosti stejný jako obvykle. Po výběru disku dostanete možnost **Free space install**. Výběrem této možnosti zabráníte vymazání celého disku.

 ![dual-boot-5](images/dual-boot-5.webp)

Zkontrolujte, že vše vypadá dobře, a počkejte na dokončení instalace jako obvykle. Stejně jako u instalace na celý disk se zde také můžete rozhodnout pro instalaci bez šifrování (nedoporučuje se).
 ![dual-boot-6](images/dual-boot-6.webp)

## Přidání dalších instalací do zavaděče

Po dokončení instalace Omarchy si všimnete, že je nyní výchozím zavaděčem Limine. Pomocí něj můžete do Limine přidat také možnosti pro další instalace, například Windows.

Chcete-li přidat další operační systémy, spusťte `limine-scan` a podle pokynů přidejte požadované položky do konfigurace Limine. Nabídka spouštění zůstává ve výchozím nastavení skrytá a Omarchy se spustí po jedné sekundě. Chcete-li vybrat Windows nebo jinou položku, stiskněte libovolnou klávesu ihned po spuštění Limine; jakmile se nabídka objeví, vyberte položku pomocí šipek a stiskněte Enter. Pokud se Omarchy spustí dříve, než stihnete klávesu stisknout, restartujte počítač a zkuste to znovu.

## Bitlocker

Je důležité upozornit, že tato metoda instalace není kompatibilní s nástrojem Bitlocker, protože ten šifruje celý disk, nejen oddíl. Pokud narazíte na chybu oznamující, že je Bitlocker povolený, spusťte Windows, přejděte do **Nastavení -> Soukromí a zabezpečení -> Šifrování zařízení** a Bitlocker vypněte. Dešifrování disku může nějakou dobu trvat.

 ![dual-boot-7](images/dual-boot-7.webp)

## Přeinstalace Windows

Pokud byl tento počítač dodán s Windows, je jeho produktový klíč uložen ve firmwaru. Spuštěním `omarchy windows key` jej zobrazíte, abyste mohli Windows znovu aktivovat, pokud je na tomto počítači někdy přeinstalujete.
