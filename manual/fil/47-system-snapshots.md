# Mga snapshot ng system

Awtomatiko kaming gumagawa ng mga snapshot sa bawat update ng Omarchy, ngunit kung gusto mong gumawa ng sarili mo, maaari mong gamitin ang `omarchy-snapshot create`.

Nakadepende sa boot loader na sinisimulan ng makina mo kung paano ka magbo-boot at magre-restore ng snapshot. Gumagamit ng systemd-boot ang mga bagong UEFI install; gumagamit ng Limine ang mga mas lumang install at mga makinang BIOS. Sasabihin sa iyo ng `omarchy-boot-backend` kung alin ang mayroon ka.

## Sa systemd-boot

Piliin ang _System > Snapshots_ sa menu ng Omarchy at piliin ang snapshot na gusto mong i-boot. Magre-restart ang makina papasok dito nang isang beses. O kaya, pindutin nang matagal ang Space habang nagsisimula ang makina upang makita ang boot menu, kung saan nakalista ang bawat snapshot, pinakabago muna, kasama ang bersyon ng Omarchy at petsa nito.

Nagbo-boot ang isang snapshot na may pansamantalang layer sa ibabaw, kaya magagamit mo ito nang normal, ngunit mawawala ang anumang babaguhin mo sa susunod na reboot. Upang mapanatili ito, gawin itong system mo: i-click ang notification na lalabas kapag nag-log in ka, piliin ang _System > Snapshots > Restore This Snapshot_, o patakbuhin ang `omarchy-snapshot restore`. Mangyayari ang restore habang nagre-restart ang makina. Mananatili sa boot menu ang system kung ano ito dati bilang _Before restore_, at ibabalik ito ng `omarchy-snapshot restore backup`.

Mula sa terminal:

- `omarchy-snapshot list` ang naglilista ng mga snapshot na maaari mong i-boot;
- `omarchy-snapshot boot 12` ang magre-restart papasok sa snapshot 12 nang isang beses;
- `omarchy-snapshot restore 12` ang gagawing system ang snapshot 12 sa susunod na restart, at `omarchy-snapshot restore --cancel` ang magpapabago sa isip mo bago ang restart na iyon.

## Sa Limine

Upang mag-boot at mag-restore ng snapshot, pipiliin mo ito mula sa Limine boot loader. Nananatiling nakatago ang boot menu bilang default, kaya pindutin ang anumang key sa sandaling magsimula ang Limine upang ilabas ito.

Mula sa screen na iyon, piliin ang snapshot na gusto mong i-boot batay sa petsa at bersyon. Makikita sa kaliwang sulok sa ibaba ang bersyon ng Omarchy noong panahon ng snapshot.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Pagdating mo sa loob, may lalabas na notification na nagsasabi sa iyo na nasa isang bootable na snapshot ka at, kung i-click mo ito, sisimulan nito ang proseso ng restoration. Bilang alternatibo, maaari mong gamitin ang `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Ano ang saklaw ng isang restore

Ibabalik ng isang restore ang root filesystem mo, ngunit hindi ang `/home` mo. Kaya gumagana ito para bawiin ang isang sirang update ng system, ngunit hindi para mabawi ang mga nawalang personal na file.

Ibig sabihin din nito na mananatiling gaya ng dati ang `~/.config` directory mo. Kaya kung babalik ka sa mas lumang bersyon ng isang library o application na nag-iimbak ng mga configuration file sa bagong format, kakailanganin mong ayusin iyon nang manu-mano.

Ganoon din ang sariling talaan ng Omarchy kung aling mga migration ang naipatupad na: nasa home directory mo ito, kaya mananatili ito pagkatapos ng restore. Mananatiling nakamarka bilang tapos na ang mga migration na tumakbo pagkatapos kunin ang snapshot, kahit na naibalik na ang mga pagbabagong ginawa nila sa root filesystem, at hindi na sila muling patatakbuhin ng susunod na `omarchy update`. Kaya kung mag-a-update ka ulit pagkatapos ng isang restore at may kulang pa ring isang bagay na itinakda ng isang naunang update, iyon ang malamang na dahilan.
