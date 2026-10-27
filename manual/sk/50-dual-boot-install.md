# Inštalácia s duálnym zavádzaním

Omarchy môžete nainštalovať na jeden oddiel vedľa Windowsu alebo iných inštalácií.

Táto metóda inštalácie predvolene stále prináša šifrovanie LUKS pre daný oddiel, takže sa v skutočnosti nelíši od inštalácie na celý disk a jednoducho si vyžaduje dostupné voľné miesto na disku.

## Uvoľnenie miesta vo Windowse

Ak chcete inštalovať vedľa Windowsu, napíšte do ponuky Štart `disk management` a vyberte možnosť **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Nájdite príslušný oddiel, kliknite naň pravým tlačidlom a vyberte **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Zadajte množstvo, o ktoré chcete zväzok zmenšiť. Upozorňujeme, že toto bude veľkosť vašej budúcej inštalácie Omarchy vrátane zavádzacieho oddielu.

 ![dual-boot-3](images/dual-boot-3.webp)

Keď skončíte, mali by ste vidieť niečo takéto, kde 50GB časť je v tomto príklade miestom, kam nainštalujeme Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Inštalácia Omarchy

Proces inštalácie Omarchy je v skutočnosti rovnaký ako zvyčajne. Po výbere disku dostanete možnosť **Free space install**. Vyberte túto možnosť, ak chcete zabrániť vymazaniu celého disku.

 ![dual-boot-5](images/dual-boot-5.webp)

Potvrďte, že všetko vyzerá dobre, a počkajte, kým sa inštalácia dokončí ako zvyčajne. Tu by ste si tiež mohli zvoliť inštaláciu bez šifrovania (neodporúča sa), rovnako ako pri inštalácii na celý disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Pridanie ďalších inštalácií do zavádzača

Keď dokončíte inštaláciu Omarchy, všimnete si, že zavádzač Limine je teraz predvolený. S ním môžete do Limine pridať aj možnosti pre ďalšie inštalácie, napríklad Windows.

Aby ste to urobili, spustite `limine-scan` a postupujte podľa výziev a pridajte do konfigurácie Limine položky, ktoré chcete. Potom, keď budete zavádzať systém, uvidíte svoje bežné možnosti pre Omarchy, ako aj Windows Boot Manager alebo iné.

## Bitlocker

Je dôležité poznamenať, že táto metóda inštalácie nie je kompatibilná s Bitlockerom, keďže ten šifruje celý disk, nie len oddiel. Ak narazíte na chybu s tvrdením, že Bitlocker je povolený, zaveďte Windows, prejdite do časti **Settings -> Privacy & Security -> Device encryption** a Bitlocker vypnite. Dešifrovanie disku môže trvať istý čas.

 ![dual-boot-7](images/dual-boot-7.webp)
