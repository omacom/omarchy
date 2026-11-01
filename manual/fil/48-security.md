# Seguridad

Lubos na seryoso ang Omarchy sa seguridad. Dinisenyo ito bilang isang operating system na magagamit mo para gumawa ng _Tunay na Trabaho_ sa _Tunay na Mundo_. Kung saan ang pagkawala ng isang laptop ay hindi maaaring mauwi sa isang emergency sa seguridad. Kaya ito ang ginagawa namin:

1. *Naka-on bilang default ang full-disk encryption*: Ito ang pinakamahalagang hakbang sa pagprotekta sa pisikal na seguridad ng iyong data. Kung mawala o manakaw ang iyong computer, ganap na naka-encrypt ang data gamit ang karaniwang LUKS (Linux Unified Key Setup). Hinahayaan ka ng installer na huwag itong gamitin para sa mga throw-away na makina (tingnan ang [Pagsisimula](02-getting-started.md)); ang isang install na walang encryption ay wala ng proteksyong ito, at sinumang may hawak ng drive ay maaaring basahin ito.
2. *Naka-enable bilang default ang firewall*: Naka-block bilang default ang lahat ng papasok na traffic, na may ilang eksepsiyon: port 53317 para sa [LocalSend](https://localsend.org/); mga DNS query sa sariling resolver ng computer sa Docker bridge address (172.17.0.1), na tinatanggap mula sa mga private address range na ibinibigay ng Docker sa mga container nito; at multicast DNS (port 5353), na hinahayaan ang mga printer at iba pang device sa iyong network na mahanap ang isa't isa at inaanunsyo rin doon ang pangalan ng iyong computer. Bukod pa roon, pinapanatili ng firewall ang mga karaniwang pinapayagan ng UFW para sa ping, pagkuha ng address mula sa iyong router (DHCP), at UPnP discovery. Naka-off pa nga ang ssh hangga't hindi mo ito binubuksan sa pamamagitan ng _Setup > Security > SSHD_, na nagbubukas ng port 22 (rate limited laban sa brute force) bilang bahagi ng setup. Ni-lock down pa namin ang access sa Docker gamit ang setup ng [ufw-docker](https://github.com/chaifeng/ufw-docker) para maiwasang aksidenteng malantad sa mundo ang iyong mga container.
3. *Palaging nasa Arch ang pinakabagong mga update*: Ang Arch, ang pinagbabatayang distro na pinagtayuan ng Omarchy, ay isang rolling distribution. Ibig sabihin, ang anumang kahinaan sa seguridad na matuklasan at ma-patch sa anumang package ay mabilis na magiging available para i-install gamit ang `omarchy-update`. Sa ganoong paraan, palagi mong pinapatakbo ang pinakabago at pinakaligtas na mga bersyon ng lahat.
4. *Pinapanatili ng Omarchy ang sarili nitong mga package at mirror*: Umaasa lamang bilang default ang Omarchy sa mga package mula sa sariling core/extra/multilib repositories ng Arch at sa sarili nitong Omarchy Package Repository. Maaari kang mag-install ng software nang direkta mula sa AUR, pero hindi iyon ginagawa ng base install — iilang opsyonal na install lamang, tulad ng mga third-party browser, ang kumukuha mula sa AUR.
5. *Pinoprotektahan kami ng Cloudflare mula sa DDoS*: Ang imprastraktura ng distribusyon ng Omarchy — ang mga ISO, ang mga Omarchy package, ang Arch mirror — ay protektado sa likod ng mabigat na DDoS shield ng Cloudflare at naka-host sa kanilang CDN. Nagbibigay ito ng napakahusay na availability.

## Pagpalit ng iyong mga password

Mayroon kang dalawang password sa isang naka-encrypt na install: ang nag-a-unlock sa drive sa boot, at ang ginagamit mo sa pag-log in at sa `sudo`. Ginagawa ng Setup na pareho sila. Maaaring palitan ang dalawa sa ilalim ng _Update > Password_ sa Omarchy menu — _Drive Encryption_ para sa una, _User_ para sa pangalawa. Hihingin muna ng pagpapalit ng drive password ang kasalukuyang password, kaya ihanda mo ito. Kung maantala ang isang pagpapalit, patakbuhin muli ang _Drive Encryption_: hihingin nito ang password na nag-a-unlock sa drive ngayon at tatapusin ang pagpapalit.

## Pagpasa ng makinang nagamit mo na

Kung ibibigay mo ang iyong makina sa ibang tao, hindi mo kailangang i-reinstall ito. Patakbuhin ang _Setup > Reset Computer_ sa Omarchy menu, i-type ang `reset` para kumpirmahin, at mag-reboot. Buburahin nito ang bawat user account at lahat ng nasa `/home`, itatapon ang lahat ng package at pagbabago sa system na ginawa mo mula noong installation, at lilinisin ang pagkakakilanlan ng makina — mga network connection, host key, at lahat. Ang babalik ay ang setup wizard mula sa unang boot, handa para sa bagong may-ari nito na ilagay ang sarili nilang pangalan, password, at encryption password.

Gumagana ito sa pamamagitan ng pag-restore ng baseline snapshot na kinukuha ng installer, kaya available lamang ito sa mga makinang na-install mula sa Omarchy ISO. At sa isang drive na walang encryption, ang pag-reset ay pagbura sa halip na secure erase, kaya kung sensitibo ang data, gumawa na lang ng fresh install.

## sudo na walang password

Minsan gusto mong tumigil na sa paghingi ang `sudo`, kadalasan kapag isang AI agent ang gumagawa ng mahabang trabaho sa system para sa iyo. Itatanong ng _Setup > Security > Passwordless Sudo_ kung gaano katagal papayagan ang access: **15 minuto**, **1 Oras**, **1 Araw**, o **Permanente**. May lalabas na pulang icon ng babala sa tabi ng iba pang indicator sa menu bar habang aktibo ang access. I-click ito o patakbuhin muli ang command para i-off ang access. Maaari ka ring magpasa ng sarili mong bilang ng minuto (mula 1 hanggang 1440) gamit ang `omarchy-sudo-passwordless 30`, o gamitin ang `omarchy-sudo-passwordless permanent`.

Awtomatikong mag-e-expire ang naka-time na access, kabilang na kaagad pagkatapos mag-resume mula sa isang suspend na lumampas sa deadline. Maaga itong tinatapos ng pag-restart ng computer. Nakakalampas ang permanenteng access sa mga reboot at nananatiling naka-enable hangga't hindi mo ito dini-disable.

Tinatapos ng pag-update o pag-alis ng settings package ng Omarchy ang anumang pansamantalang grant bago magbago ang suporta nito sa expiry. Kung mag-ulat ang command ng error sa authorization o cleanup, ayusin ito bago subukang mag-enable ng isa pang grant; hindi nangangahulugan ang isang error na hindi aktibo ang access na walang password.

Maging malinaw ang paningin mo rito: habang naka-on ito, anumang tumatakbo bilang user mo ay maaaring gumawa ng anuman bilang root nang hindi tinatanong. Iyon ang buong punto, at iyon din ang buong panganib.

## Mga Signing Key

Ang public key para sa lahat ng ISO signature at Omarchy repo package ay `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([beripikahin sa openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Nilalaman din ito ng package na `omarchy/omarchy-keyring` at gagamitin ito para maayos na mai-rollout ang anumang potensyal na mga update.

Mahahanap mo ang signature para sa anumang ISO release sa pamamagitan ng pagdagdag ng `.sig` sa URL nito, tulad ng `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
