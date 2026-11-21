# Seguridad

Seryosong-seryoso ang Omarchy pagdating sa seguridad. Layunin nitong maging isang operating system na magagamit mo para gumawa ng _Tunay na Trabaho_ sa _Tunay na Mundo_. Kung saan ang pagkawala ng laptop ay hindi mauuwi sa isang emergency sa seguridad. Kaya narito ang ginagawa namin:

1. *Naka-on ang full-disk encryption bilang default*: Ito ang pinakamahalagang hakbang para siguruhin ang pisikal na proteksyon ng data mo. Kung mawala o manakaw ang computer mo, ganap na naka-encrypt ang data gamit ang karaniwang LUKS (Linux Unified Key Setup). Hinahayaan ka ng installer na huwag itong gamitin para sa mga makinang pang-isahan lang (tingnan ang [Pagsisimula](02-getting-started.md)); ang install na walang encryption ay wala ni isa man sa proteksiyong ito, at sinumang may hawak ng drive ay mababasa ito.
2. *Naka-enable ang firewall bilang default*: Naka-block ang lahat ng papasok na trapiko bilang default, maliban sa iilang eksepsiyon: port 53317 para sa [LocalSend](https://localsend.org/); mga DNS query papunta sa sariling resolver ng computer sa Docker bridge address (172.17.0.1), na tinatanggap mula sa mga private address range na ibinibigay ng Docker sa mga container nito; at multicast DNS (port 5353), na hinahayaan ang mga printer at iba pang device sa network mo na mahanap ang isa't isa at nag-aanunsyo rin doon ng pangalan ng computer mo. Bukod pa roon, pinapanatili ng firewall ang mga karaniwang allowance ng UFW para sa ping, pagkuha ng address mula sa router mo (DHCP), at UPnP discovery. Kahit ang ssh ay naka-off hanggang sa i-on mo ito sa pamamagitan ng _Setup > Security > SSHD_, na nag-o-authorize sa SSH key mo, nag-o-off ng mga password login, at saka pa lamang binubuksan ang port 22 (naka-rate limit laban sa brute force). Ni-lock down pa nga namin ang access sa Docker gamit ang setup ng [ufw-docker](https://github.com/chaifeng/ufw-docker) upang pigilan ang mga container mo na aksidenteng ma-expose sa mundo.
3. *Palaging may pinakabagong mga update ang Arch*: Ang Arch, ang pinagbabatayang distro ng Omarchy, ay isang rolling distribution. Ibig sabihin nito, ang anumang kahinaan sa seguridad na matuklasan at ma-patch sa anumang package ay mabilis na magiging available para i-install gamit ang `omarchy-update`. Sa ganoong paraan, palagi mong pinapatakbo ang pinakabago at pinakaligtas na mga bersyon ng lahat.
4. *Pinapanatili ng Omarchy ang sarili nitong mga package at mirror*: Umaasa lang ang Omarchy bilang default sa mga package mula sa sariling core/extra/multilib repository ng Arch (sa Arch Linux ARM sa mga ARM machine, pati na rin ang Asahi ALARM sa Apple Silicon) at sa sarili nitong Omarchy Package Repository. Maaari kang mag-install ng software nang direkta mula sa AUR, ngunit hindi iyon ginagawa ng base install — iilang opsyonal na install lang, tulad ng mga third-party browser, ang kumukuha mula sa AUR.
5. *Pinoprotektahan kami ng Cloudflare mula sa DDoS*: Ang imprastraktura ng pamamahagi ng Omarchy — ang mga ISO, ang mga package ng Omarchy, ang Arch mirror — ay protektado sa likod ng mabigat na DDoS shield ng Cloudflare at naka-host sa CDN nila. Nagbibigay ito ng napakahusay na availability.

## Pagpapalit ng mga password mo

May dalawang password ka sa isang encrypted na install: ang nag-a-unlock ng drive sa boot, at ang ginagamit mo sa pag-log in at sa `sudo`. Ginagawa ng Setup na pareho ang mga ito. Maaaring palitan ang dalawa sa ilalim ng _Update > Password_ sa menu ng Omarchy — _Drive Encryption_ para sa una, _User_ para sa pangalawa. Hihingin muna ng pagpapalit ng drive password ang kasalukuyang password, kaya ihanda mo ito. Kung maantala ang isang pagpapalit, patakbuhin ulit ang _Drive Encryption_: hihingin nito ang password na nag-a-unlock ng drive ngayon at tatapusin ang pagpapalit.

## Pagpapasa ng makinang nagamit mo na

Kung ibibigay mo ang makina mo sa ibang tao, hindi mo na kailangang i-reinstall ito. Patakbuhin ang _Remove > Factory Reset_ sa menu ng Omarchy, i-type ang `reset` para kumpirmahin, ilagay ang drive encryption password mo kung hingin, at mag-reboot. Binubura nito ang bawat user account at lahat ng nasa `/home`, tinatapon ang lahat ng package at pagbabago sa system na ginawa mo mula noong installation, at nililinis ang pagkakakilanlan ng makina — mga network connection, host key, at lahat. Ang babalik ay ang setup wizard mula sa unang boot, handa nang ilagay ng bagong may-ari ang sarili niyang pangalan, password, at encryption password.

Gumagana ito sa pamamagitan ng pag-restore ng baseline snapshot na kinukuha ng installer, kaya available lang ito sa mga makinang na-install mula sa Omarchy ISO. At sa isang drive na walang encryption, ang reset ay pagbura lamang sa halip na secure erase, kaya kung sensitibo ang data, magsagawa na lang ng fresh install.

## sudo na Walang Password

Minsan gusto mong tumigil na ang `sudo` sa pagtatanong, kadalasan kapag ang isang AI agent ay gumagawa ng mahabang trabaho sa system para sa iyo. Itatanong ng _Setup > Security > Passwordless Sudo_ kung gaano katagal papayagan ang access: **15 minuto**, **1 Oras**, **1 Araw**, o **Permanente**. May lalabas na pulang warning icon sa tabi ng iba pang indicator sa menu bar habang aktibo ang access. I-click ito o patakbuhin ulit ang command para i-off ang access. Maaari ka ring magpasa ng sarili mong bilang ng minuto (mula 1 hanggang 1440) gamit ang `omarchy-sudo-passwordless 30`, o gamitin ang `omarchy-sudo-passwordless permanent`.

Awtomatikong nag-e-expire ang naka-time na access, kabilang ang kaagad pagkatapos mag-resume mula sa isang suspend na lumampas sa deadline. Tinatapos ito nang maaga ng pag-restart ng computer. Nakakaligtas ang permanenteng access sa mga reboot at nananatiling naka-enable hanggang sa i-disable mo ito.

Tinatapos ng pag-update o pag-alis ng settings package ng Omarchy ang anumang pansamantalang grant bago magbago ang suporta nito sa expiry. Kung mag-ulat ang command ng error sa authorization o cleanup, ayusin ito bago subukang mag-enable ng isa pang grant; ang error ay hindi nangangahulugang hindi aktibo ang passwordless access.

Maging malinaw ang mata mo tungkol dito: habang naka-on ito, anumang tumatakbo bilang user mo ay maaaring gumawa ng kahit ano bilang root nang hindi tinatanong. Iyon ang buong punto, at iyon din ang buong panganib.

## Mga Signing Key

Ang public key para sa lahat ng ISO signature at Omarchy repo package ay `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([i-verify sa openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Nilalaman din ito ng package na `omarchy/omarchy-keyring` at gagamitin ito para ma-rollout nang walang aberya ang anumang posibleng update.

Mahahanap mo ang signature para sa anumang ISO release sa pamamagitan ng pagdaragdag ng `.sig` sa URL nito, tulad ng `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
