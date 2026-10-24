# Mga snapshot ng sistema

Awtomatiko kaming gumagawa ng mga snapshot sa bawat update ng Omarchy, pero kung gusto mong gumawa ng sarili mo, maaari mong gamitin ang `omarchy-snapshot create`.

Para i-boot at ibalik ang isang snapshot, pipiliin mo ito mula sa boot loader na Limine. (Kung kasalukuyan kang dumidiretso sa screen ng pag-decrypt ng Omarchy, kakailanganin mong piliin ang Limine bilang opsyon sa pag-boot sa pamamagitan ng BIOS muna).

Mula sa screen na iyon, piliin ang snapshot na gusto mong i-boot batay sa petsa at bersyon. Ang bersyon ng Omarchy sa oras ng snapshot ay makikita sa kaliwang sulok sa ibaba.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kapag nakapasok ka na sa loob, lalabas ang isang notipikasyon na nagpapaalam sa iyo na nasa isang bootable na snapshot ka at kung i-click mo ito, sisimulan nito ang proseso ng pagbabalik. Bilang alternatibo, maaari mong gamitin ang `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Ibabalik nito ang root filesystem mo, pero hindi ang `/home` mo. Kaya gumagana ito para sa pagbabalik ng isang sirang update ng sistema, pero hindi para sa pagbawi ng nawawalang personal na file.

Ibig sabihin din nito na ang direktoryo mong `~/.config` ay pinapanatili kung ano ito. Kaya kung nagro-rollback ka sa mas naunang bersyon ng isang library o aplikasyon na nag-iimbak ng mga file ng konpigurasyon sa bagong format, kakailanganin mong ayusin iyon nang mano-mano.

_Tandaan: Ang tampok na ito ay available lang sa mga pag-install na gumagamit ng boot loader na Limine, na siyang default mula pa noong Omarchy 2.0. Hindi ito available kung nasa GRUB o systemd-boot ka._

### Paglaktaw sa menu ng boot

Kung hindi mo kailanman ginagalaw ang menu ng boot at gusto mo lang dumiretso ang makina sa screen ng pag-decrypt, patakbuhin ang _Pag-setup > Direktang Boot_ sa menu ng Omarchy. Nagdadagdag iyon ng isang entry ng EFI na direktang nakaturo sa Omarchy, kaya ibo-boot ito ng firmware nang hindi humihinto sa Limine.

Ang kapalit ay ang nabanggit sa itaas: kapag naka-on ang direktang boot, ang pagpunta sa isang snapshot ay nangangahulugang pipiliin mo muna ang Limine mula sa menu ng boot ng BIOS mo. Patakbuhin ulit ang _Pag-setup > Direktang Boot_ para alisin ang entry at bumalik sa pag-boot sa pamamagitan ng Limine. Ang ilang firmware ay hindi mahilig sa mga custom na entry ng EFI, kaya tumatanggi ang setup na tumakbo sa firmware ng American Megatrends at Apple.
