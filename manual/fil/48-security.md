# Seguridad

Sineseryoso nang husto ng Omarchy ang seguridad. Layunin nitong maging isang operating system na magagamit mo para sa _Tunay na Trabaho_ sa _Tunay na Mundo_. Kung saan ang pagkawala ng laptop ay hindi maaaring humantong sa isang emergency sa seguridad. Kaya narito ang ginagawa namin:

1. *Naka-on bilang default ang full-disk encryption*: Ito ang pinakamahalagang hakbang para sa pisikal na proteksyon ng iyong data. Kung mawala o manakaw ang iyong computer, ganap na naka-encrypt ang data gamit ang karaniwang LUKS (Linux Unified Key Setup). Hinahayaan ka ng installer na mag-opt out para sa mga makinang pansamantala lang (tingnan ang [Pagsisimula](02-getting-started.md)); ang install na walang encryption ay wala ng proteksyong ito, at sinumang may hawak ng drive ay makakabasa nito.
2. *Naka-enable bilang default ang firewall*: Naka-block bilang default ang lahat ng papasok na traffic, na may ilang eksepsyon: port 53317 para sa [LocalSend](https://localsend.org/); mga DNS query sa sariling resolver ng computer sa Docker bridge address (172.17.0.1), na tinatanggap mula sa mga private address range na ibinibigay ng Docker sa mga container nito; at multicast DNS (port 5353), na nagbibigay-daan sa mga printer at iba pang device sa iyong network na mahanap ang isa't isa at nag-aanunsyo rin ng pangalan ng iyong computer doon. Bukod sa mga iyon, pinapanatili ng firewall ang mga karaniwang pahintulot ng UFW para sa ping, pagkuha ng address mula sa iyong router (DHCP), at UPnP discovery. Maging ang ssh ay naka-off hanggang i-on mo ito sa pamamagitan ng _Setup > Security > SSHD_, na nagbubukas ng port 22 (may rate limit laban sa brute force) bilang bahagi ng setup. Ikinakandado pa namin ang access sa Docker gamit ang [ufw-docker](https://github.com/chaifeng/ufw-docker) setup para maiwasang aksidenteng mailantad sa mundo ang iyong mga container.
3. *Palaging may pinakabagong mga update ang Arch*: Ang Arch, ang pinagbatayang distro ng Omarchy, ay isang rolling distribution. Ibig sabihin, ang anumang kahinaan sa seguridad na matuklasan at ma-patch sa anumang package ay mabilis na makukuha para ma-install gamit ang `omarchy-update`. Sa ganoong paraan, palagi mong pinapatakbo ang pinakabago at pinakaligtas na mga bersyon ng lahat.
4. *Pinapanatili ng Omarchy ang sarili nitong mga package at mirror*: Umaasa lang ang Omarchy bilang default sa mga package mula sa sariling core/extra/multilib repository ng Arch at sa sarili nitong Omarchy Package Repository. Maaari kang mag-install ng software nang direkta mula sa AUR, pero hindi ginagawa iyon ng base install — iilang opsyonal na install lang, tulad ng mga third-party browser, ang kumukuha mula sa AUR.
5. *Pinoprotektahan tayo ng Cloudflare laban sa DDoS*: Ang imprastraktura ng distribusyon ng Omarchy — ang mga ISO, ang mga package ng Omarchy, ang Arch mirror — ay protektado sa likod ng mabigat na DDoS shield ng Cloudflare at naka-host sa kanilang CDN. Nagbibigay ito ng napakahusay na availability.

## Pagpapalit ng iyong mga password

May dalawa kang password sa isang naka-encrypt na install: ang nag-a-unlock ng drive sa boot, at ang ginagamit mo sa pag-log in at sa `sudo`. Ginagawa ng Setup na pareho ang mga ito. Maaaring palitan ang dalawa sa ilalim ng _Update > Password_ sa menu ng Omarchy — _Drive Encryption_ para sa una, _User_ para sa ikalawa. Hihingin muna ng pagpapalit ng password ng drive ang kasalukuyang password, kaya ihanda mo ito. Kung maantala ang isang pagpapalit, patakbuhin ulit ang _Drive Encryption_: hihingin nito ang password na nag-a-unlock ng drive ngayon at tatapusin ang pagpapalit.

## Pagpapasa ng makinang nagamit mo na

Kung ibibigay mo ang iyong makina sa ibang tao, hindi mo kailangang i-reinstall ito. Patakbuhin ang _Remove > Factory Reset_ sa menu ng Omarchy, i-type ang `reset` para kumpirmahin, at mag-reboot. Buburahin nito ang bawat user account at lahat ng nasa `/home`, itatapon ang lahat ng package at pagbabago sa system na ginawa mo mula nang i-install, at lilinisin ang pagkakakilanlan ng makina — mga koneksyon sa network, host key, at lahat. Ang babalik ay ang setup wizard mula sa unang boot, handa para ilagay ng bagong may-ari ang sarili niyang pangalan, password, at encryption password.

Gumagana ito sa pamamagitan ng pagpapanumbalik ng baseline snapshot na kinukuha ng installer, kaya available lang ito sa mga makinang na-install mula sa Omarchy ISO. At sa isang drive na walang encryption, ang reset ay pagbura sa halip na secure erase, kaya kung sensitibo ang data, magsagawa na lang ng fresh install.

## Passwordless sudo

Minsan gusto mong tumigil na sa paghingi ang `sudo`, kadalasan kapag isang AI agent ang gumagawa ng mahabang trabaho sa system para sa iyo. Itatanong ng _Setup > Security > Passwordless Sudo_ kung gaano katagal papayagan ang access: **15 minuto**, **1 Oras**, **1 Araw**, o **Permanente**. May lalabas na pulang warning icon sa tabi ng iba pang indicator sa menu bar habang aktibo ang access. I-click ito o patakbuhin ulit ang command para i-off ang access. Maaari ka ring magpasa ng sarili mong bilang ng minuto (mula 1 hanggang 1440) gamit ang `omarchy-sudo-passwordless 30`, o gamitin ang `omarchy-sudo-passwordless permanent`.

Awtomatikong mag-e-expire ang may takdang access, kabilang na kaagad pagkatapos mag-resume mula sa isang suspend na lumampas sa deadline. Maagang tatapusin ito ng pag-restart ng computer. Ang permanenteng access ay mananatili kahit mag-reboot at mananatiling naka-enable hanggang i-disable mo ito.

Tinatapos ng pag-update o pag-alis ng settings package ng Omarchy ang anumang pansamantalang grant bago magbago ang suporta nito sa expiry. Kung mag-ulat ang command ng error sa authorization o cleanup, ayusin ito bago subukang mag-enable ng isa pang grant; ang error ay hindi nangangahulugang hindi aktibo ang passwordless access.

Maging malinaw ang pananaw mo rito: habang naka-on ito, anumang tumatakbo bilang iyong user ay makakagawa ng kahit ano bilang root nang hindi tinatanong. Iyon ang buong layunin, at iyon din ang buong panganib.

## Mga Signing Key

Ang public key para sa lahat ng lagda ng ISO at package ng Omarchy repo ay `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([beripikahin sa openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Nilalaman din ito ng package na `omarchy/omarchy-keyring` at gagamitin ito para maayos na mailunsad ang anumang posibleng update.

Mahahanap mo ang lagda para sa anumang release ng ISO sa pamamagitan ng pagdagdag ng `.sig` sa URL nito, tulad ng `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
