# Seguridad

Sineseryoso nang husto ng Omarchy ang seguridad. Layunin nitong maging isang operating system na magagamit mo para sa _Tunay na Trabaho_ sa _Tunay na Mundo_. Kung saan ang pagkawala ng laptop ay hindi maaaring mauwi sa isang emergency sa seguridad. Kaya narito ang ginagawa namin:

1. *Mandatoryo ang full-disk encryption*: Ito ang pinakamahalagang hakbang sa pagprotekta nang pisikal sa iyong data. Kung mawala o manakaw ang computer mo, ganap na naka-encrypt ang data gamit ang karaniwang LUKS (Linux Unified Key Setup).
2. *Naka-enable ang firewall bilang default*: Naka-block ang lahat ng papasok na traffic bilang default maliban sa port 53317 para sa [LocalSend](https://localsend.org/). Naka-off pa nga ang ssh hangga't hindi mo ito binubuksan sa pamamagitan ng _Setup > Security > SSHD_, na nagbubukas ng port 22 (may rate limit laban sa brute force) bilang bahagi ng setup. Hinihigpitan pa namin ang access ng Docker gamit ang setup ng [ufw-docker](https://github.com/chaifeng/ufw-docker) upang hindi aksidenteng malantad sa mundo ang iyong mga container.
3. *Palaging may pinakabagong mga update ang Arch*: Ang Arch, ang pinagbabatayang distro ng Omarchy, ay isang rolling distribution. Ibig sabihin, ang anumang kahinaan sa seguridad na matuklasan at ma-patch sa anumang package ay mabilis na makukuha para ma-install gamit ang `omarchy-update`. Sa ganoong paraan, palagi mong ginagamit ang pinakabago at pinakaligtas na bersyon ng lahat.
4. *Pinapanatili ng Omarchy ang sarili nitong mga package at mirror*: Umaasa lamang ang Omarchy sa mga package mula sa sariling core/extra/multilib repositories ng Arch at sa sarili nitong Omarchy Package Repository bilang default. Maaari kang mag-install ng software nang direkta mula sa AUR, ngunit hindi iyon ginagawa ng base install — iilang opsyonal na install lamang, tulad ng mga third-party na browser, ang kumukuha mula sa AUR.
5. *Pinoprotektahan tayo ng Cloudflare laban sa DDoS*: Ang distribution infrastructure ng Omarchy — ang mga ISO, ang mga package ng Omarchy, ang mirror ng Arch — ay protektado sa likod ng mabigat na DDoS shield ng Cloudflare at naka-host sa kanilang CDN. Nagbibigay ito ng napakahusay na availability.

## Pagpapalit ng iyong mga password

May dalawa kang password sa isang naka-encrypt na install: ang nag-a-unlock ng drive sa boot, at ang ginagamit mo sa pag-log in at sa `sudo`. Ginagawang magkapareho ang mga ito ng Setup. Maaaring palitan ang dalawa sa ilalim ng _Update > Password_ sa menu ng Omarchy — _Drive Encryption_ para sa una, _User_ para sa ikalawa. Hihingin muna ng pagpapalit ng password ng drive ang kasalukuyang password, kaya ihanda mo ito. Kung maantala ang isang pagpapalit, patakbuhin muli ang _Drive Encryption_: hihingin nito ang password na nag-a-unlock ng drive ngayon at tatapusin ang pagpapalit.

## Pagpapasa ng makinang nagamit mo na

Kung ibibigay mo ang makina mo sa ibang tao, hindi mo kailangang i-reinstall ito. Patakbuhin ang _Setup > Reset Computer_ sa menu ng Omarchy, i-type ang `reset` para kumpirmahin, at mag-reboot. Buburahin nito ang bawat user account at lahat ng nasa `/home`, aalisin ang lahat ng package at pagbabago sa system na ginawa mo mula noong installation, at lilinisin ang identity ng makina — mga koneksyon sa network, mga host key, at lahat. Ang babalik ay ang setup wizard mula sa unang boot, handa para ilagay ng bagong may-ari ang sarili niyang pangalan, password, at password sa encryption.

Gumagana ito sa pamamagitan ng pagpapanumbalik ng baseline snapshot na kinukuha ng installer, kaya available lamang ito sa mga makinang na-install mula sa Omarchy ISO. At sa isang drive na walang encryption, ang reset ay pagbura sa halip na secure erase, kaya kung sensitibo ang data, magsagawa na lang ng bagong install.

## Sudo na walang password

Minsan gusto mong tumigil ang `sudo` sa pagtatanong, kadalasan kapag isang AI agent ang gumagawa ng mahabang trabaho sa system para sa iyo. Tatanungin ng _Setup > Security > Passwordless Sudo_ kung gaano katagal papayagan ang access: **15 minuto**, **1 Oras**, **1 Araw**, o **Permanente**. May pulang warning icon na lalabas sa tabi ng iba pang indicator sa menu bar habang aktibo ang access. I-click ito o patakbuhin muli ang command para i-off ang access. Maaari ka ring magpasa ng sarili mong bilang ng minuto (mula 1 hanggang 1440) gamit ang `omarchy-sudo-passwordless 30`, o gamitin ang `omarchy-sudo-passwordless permanent`.

Awtomatikong mag-e-expire ang may takdang access, kabilang ang kaagad pagkatapos mag-resume mula sa suspend na lumagpas na sa deadline. Maagang tatapusin ito ng pag-restart ng computer. Mananatili ang permanenteng access kahit mag-reboot at mananatiling naka-enable hangga't hindi mo ito dini-disable.

Tatapusin ng pag-update o pag-alis ng settings package ng Omarchy ang anumang pansamantalang grant bago magbago ang suporta nito sa pag-expire. Kung mag-ulat ang command ng error sa authorization o cleanup, ayusin ito bago subukang mag-enable ng isa pang grant; hindi nangangahulugan ang isang error na hindi aktibo ang passwordless access.

Maging malinaw ang pananaw tungkol dito: habang naka-on ito, ang anumang tumatakbo bilang user mo ay maaaring gumawa ng kahit ano bilang root nang hindi tinatanong. Iyon ang buong punto, at iyon din ang buong panganib.

## Mga Signing Key

Ang public key para sa lahat ng ISO signature at package ng Omarchy repo ay `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([i-verify sa openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Nasa package na `omarchy/omarchy-keyring` din ito at gagamitin upang maayos na mai-roll out ang anumang posibleng update.

Mahahanap mo ang signature para sa anumang ISO release sa pamamagitan ng pagdaragdag ng `.sig` sa URL nito, tulad ng `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
