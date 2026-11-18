# Mga snapshot ng sistema

Awtomatiko kaming gumagawa ng mga snapshot sa bawat update ng Omarchy, pero kung gusto mong gumawa ng sarili mo, maaari mong gamitin ang `omarchy-snapshot create`.

Para mag-boot at mag-restore ng snapshot, pipiliin mo ito mula sa Limine boot loader. (Kung kasalukuyang dumidiretso ka sa pag-boot sa decryption screen ng Omarchy, kailangan mo munang piliin ang Limine bilang boot option sa pamamagitan ng BIOS).

Mula sa screen na iyon, piliin ang snapshot na gusto mong i-boot batay sa petsa at bersyon. Makikita ang bersyon ng Omarchy noong ginawa ang snapshot sa ibabang kaliwang sulok.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Pagdating mo sa loob, may lalabas na notification na magsasabi sa iyo na nasa isang bootable na snapshot ka at kung iki-click mo ito, sisimulan nito ang proseso ng restoration. Bilang alternatibo, maaari mong gamitin ang `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Ire-restore nito ang iyong root filesystem, pero hindi ang iyong `/home`. Kaya gumagana ito para ibalik ang isang sirang update ng sistema, pero hindi para mabawi ang mga nawalang personal na file.

Ibig sabihin din nito na mananatili ang iyong `~/.config` directory kung ano ito. Kaya kung babalik ka sa mas lumang bersyon ng isang library o application na nag-iimbak ng mga configuration file sa bagong format, ikaw mismo ang kailangang umayos niyon nang manu-mano.

Ganoon din ang record mismo ng Omarchy kung aling mga migration ang tumakbo na: nasa iyong home directory ito, kaya nananatili ito pagkatapos ng restore. Ang mga migration na tumakbo pagkatapos kunin ang snapshot ay mananatiling nakamarka bilang tapos na, kahit naibalik na ang mga pagbabagong ginawa nila sa root filesystem, at hindi na sila muling patatakbuhin ng susunod na `omarchy update`. Kaya kung mag-a-update ka ulit pagkatapos ng isang restore at may kulang pa ring isang bagay na na-set up ng naunang update, iyon ang malamang na dahilan.

_Tandaan: Available lang ang feature na ito sa mga installation na gumagamit ng Limine boot loader, na naging default mula pa noong Omarchy 2.0. Hindi ito available kung nasa GRUB o systemd-boot ka._

### Paglaktaw sa boot menu

Kung hindi mo kailanman ginagalaw ang boot menu at gusto mo lang dumiretso ang machine sa decryption screen, patakbuhin ang _Setup > Direct Boot_ sa menu ng Omarchy. Nagdaragdag iyon ng EFI entry na direktang nakaturo sa Omarchy, kaya ibo-boot ito ng firmware nang hindi humihinto sa Limine.

Ang kapalit nito ay ang nabanggit sa itaas: kapag naka-on ang direct boot, para makapunta sa isang snapshot ay kailangan mo munang piliin ang Limine mula sa boot menu ng iyong BIOS. Patakbuhin ulit ang _Setup > Direct Boot_ para alisin ang entry at bumalik sa pag-boot sa pamamagitan ng Limine. Hindi gusto ng ilang firmware ang mga custom na EFI entry, kaya tumatangging tumakbo ang setup sa American Megatrends at Apple firmware.
