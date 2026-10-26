# Instalace s duálním spouštěním

Omarchy můžete nainstalovat do jednoho oddílu vedle systému Windows nebo jiných instalací.

Tento způsob instalace je ve výchozím nastavení stále vybaven šifrováním oddílu LUKS, takže se fakticky neliší od instalace na celý disk a jednoduše vyžaduje, aby bylo na disku volné místo.

## Vytvoření místa v systému Windows

Chcete-li instalovat vedle systému Windows, zadejte do nabídky Start text `disk management` a vyberte volbu **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Najděte příslušný oddíl, klikněte pravým tlačítkem a zvolte **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Zadejte množství, o které chcete svazek zmenšit. Všimněte si, že právě to bude velikost vaší budoucí instalace Omarchy včetně spouštěcího oddílu.

 ![dual-boot-3](images/dual-boot-3.webp)

Po dokončení byste měli vidět něco jako toto, kde daných 50 GB představuje v tomto příkladu prostor, kam Omarchy nainstalujeme.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalace systému Omarchy

Postup instalace Omarchy je v podstatě stejný jako obvykle. Po výběru disku dostanete možnost **Free space install**. Vyberte tuto možnost, abyste zabránili vymazání celého disku.

 ![dual-boot-5](images/dual-boot-5.webp)

Potvrďte, že vše vypadá dobře, a počkejte na dokončení instalace jako obvykle. Zde byste se také mohli rozhodnout pro nešifrovanou instalaci (nedoporučuje se), stejně jako při instalaci na celý disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Přidání jiných instalací do zavaděče

Po dokončení instalace Omarchy si všimnete, že nyní je výchozím zavaděčem Limine. S jeho pomocí můžete do Limine přidat také možnosti pro jiné instalace, například Windows.

K tomu spusťte příkaz `limine-scan` a podle pokynů přidejte do konfigurace Limine libovolné položky. Při spouštění pak uvidíte běžné možnosti pro Omarchy i Windows Boot Manager či jiné systémy.

## Bitlocker

Je důležité poznamenat, že tento způsob instalace není kompatibilní s nástrojem Bitlocker, protože ten šifruje celou jednotku, nikoli pouze oddíl. Pokud se zobrazí chyba oznamující, že je Bitlocker zapnutý, spusťte systém Windows, přejděte do části **Settings -> Privacy & Security -> Device encryption** a Bitlocker vypněte. Dešifrování jednotky může chvíli trvat.

 ![dual-boot-7](images/dual-boot-7.webp)
