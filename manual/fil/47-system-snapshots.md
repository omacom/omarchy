# Mga snapshot ng sistema

Awtomatikong gumagawa kami ng mga snapshot sa bawat update ng Omarchy, ngunit kung gusto mong gumawa ng sarili mo, maaari mong gamitin ang `omarchy-snapshot create`.

Para mag-boot at mag-restore ng snapshot, piliin ito mula sa Limine boot loader. Nananatiling nakatago ang boot menu bilang default, kaya pindutin ang anumang key sa sandaling magsimula ang Limine para ipakita ito.

Mula sa screen na iyon, piliin ang snapshot na gusto mong i-boot batay sa petsa at bersyon. Makikita ang bersyon ng Omarchy noong ginawa ang snapshot sa kaliwang ibabang sulok.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Pagdating mo sa loob, may lalabas na notification na nagpapaalam sa iyo na nasa isang bootable na snapshot ka at kung iki-click mo ito, magsisimula ang proseso ng pag-restore. Bilang alternatibo, maaari mong gamitin ang `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Ire-restore nito ang root filesystem mo, ngunit hindi ang `/home` mo. Kaya gumagana ito para i-revert ang isang nasirang update ng sistema, ngunit hindi para mabawi ang mga nawalang personal na file.

Nangangahulugan din ito na mananatili ang `~/.config` directory mo kung ano ito. Kaya kung magro-roll back ka sa mas lumang bersyon ng isang library o application na nag-iimbak ng mga configuration file sa bagong format, kailangan mong ayusin iyon nang manu-mano.

Ganito rin ang nangyayari sa sariling talaan ng Omarchy kung aling mga migration ang naisagawa na: nasa home directory mo ito, kaya nananatili ito pagkatapos ng restore. Ang mga migration na tumakbo pagkatapos kunin ang snapshot ay mananatiling nakamarka bilang tapos na, kahit na na-roll back na ang mga pagbabagong ginawa nila sa root filesystem, at hindi na sila muling patatakbuhin ng susunod na `omarchy update`. Kaya kung mag-update ka ulit pagkatapos ng isang restore at may kulang pa ring isang bagay na itinakda ng isang naunang update, iyon ang malamang na dahilan.

_Tandaan: Available lang ang feature na ito sa mga installation na gumagamit ng Limine boot loader, na naging default mula pa noong Omarchy 2.0. Hindi ito available kung nasa GRUB o systemd-boot ka._
