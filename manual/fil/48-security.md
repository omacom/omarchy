# Seguridad

Sineseryoso nang husto ng Omarchy ang seguridad. Layunin nitong maging isang operating system na magagamit mo para sa _Tunay na Trabaho_ sa _Tunay na Mundo_. Kung saan ang pagkawala ng laptop ay hindi maaaring mauwi sa isang emergency sa seguridad. Kaya narito ang ginagawa namin:

1. *Mandatoryo ang full-disk encryption*: Ito ang pinakamahalagang hakbang para sa pisikal na proteksyon ng iyong data. Kung mawala o manakaw ang iyong computer, ganap na naka-encrypt ang data gamit ang karaniwang LUKS (Linux Unified Key Setup).
2. *Naka-enable ang firewall bilang default*: Naka-block ang lahat ng papasok na traffic bilang default maliban sa port 53317 para sa [LocalSend](https://localsend.org/). Maging ang ssh ay naka-off hanggang i-on mo ito sa pamamagitan ng _Setup > Seguridad > SSHD_, na nagbubukas sa port 22 (may rate limit laban sa brute force) bilang bahagi ng setup. Ikinakandado pa namin ang access sa Docker gamit ang setup ng [ufw-docker](https://github.com/chaifeng/ufw-docker) para maiwasang aksidenteng malantad sa mundo ang iyong mga container.
3. *Palaging may pinakabagong mga update ang Arch*: Ang Arch, ang pinagbatayang distro ng Omarchy, ay isang rolling distribution. Ibig sabihin, anumang kahinaan sa seguridad na matuklasan at ma-patch sa anumang package ay mabilis na magiging available para i-install gamit ang `omarchy-update`. Sa ganoong paraan, palagi mong pinapatakbo ang pinakabago at pinakaligtas na mga bersyon ng lahat.
4. *Ang Omarchy ang nagpapanatili ng sarili nitong mga package at mirror*: Umaasa lamang ang Omarchy bilang default sa mga package mula sa sariling core/extra/multilib repositories ng Arch at sa sarili nitong Omarchy Package Repository. Maaari kang mag-install ng software nang direkta mula sa AUR, pero hindi iyon ginagawa ng base install — iilang opsyonal na install lamang, tulad ng mga third-party browser, ang kumukuha mula sa AUR.
5. *Pinoprotektahan kami ng Cloudflare laban sa DDoS*: Ang imprastraktura ng distribusyon ng Omarchy — ang mga ISO, ang mga package ng Omarchy, ang mirror ng Arch — ay protektado sa likod ng mabigat na DDoS shield ng Cloudflare at naka-host sa kanilang CDN. Nagbibigay ito ng napakahusay na availability.

## Pagpapalit ng iyong mga password

May dalawa kang password sa isang naka-encrypt na install: ang nag-a-unlock sa drive sa boot, at ang ginagamit mo sa pag-log in at sa `sudo`. Ginagawa ng Setup na magkapareho ang mga ito. Maaaring palitan ang dalawa sa ilalim ng _Update > Password_ sa menu ng Omarchy — _Drive Encryption_ para sa una, _User_ para sa pangalawa. Hihingin muna ng pagpapalit ng password ng drive ang kasalukuyang password, kaya ihanda mo ito. Kung maantala ang isang pagpapalit, patakbuhin ulit ang _Drive Encryption_: hihingin nito ang password na nag-a-unlock sa drive ngayon at tatapusin ang pagpapalit.

## Pagpapasa ng makinang nagamit mo na

Kung ibibigay mo ang iyong makina sa ibang tao, hindi mo kailangang i-reinstall ito. Patakbuhin ang _Setup > Reset Computer_ sa menu ng Omarchy, i-type ang `reset` para kumpirmahin, at mag-reboot. Buburahin nito ang bawat user account at lahat ng nasa `/home`, itatapon ang lahat ng package at pagbabago sa system na ginawa mo mula noong installation, at lilinisin ang identity ng makina — mga koneksyon sa network, host keys, at lahat. Ang babalik ay ang setup wizard mula sa unang boot, handa para ilagay ng bagong may-ari ang sarili niyang pangalan, password, at encryption password.

Gumagana ito sa pamamagitan ng pagpapanumbalik ng baseline snapshot na kinukuha ng installer, kaya available lamang ito sa mga makinang na-install mula sa Omarchy ISO. At sa drive na walang encryption, ang reset ay pagbura sa halip na secure erase, kaya kung sensitibo ang data, magsagawa na lang ng fresh install.

## Sudo nang walang password

Minsan gusto mong tumigil na sa pagtatanong ang `sudo`, kadalasan kapag may AI agent na gumagawa ng mahabang trabaho sa system para sa iyo. Itinatanong ng _Setup > Seguridad > Passwordless Sudo_ kung gaano katagal papayagan ang access: **15 minuto**, **1 Oras**, **1 Araw**, o **Permanente**. May pulang warning icon na lilitaw sa tabi ng iba pang indicator sa menu bar habang aktibo ang access. I-click ito o patakbuhin ulit ang command para i-off ang access. Maaari ka ring magpasa ng sarili mong bilang ng minuto (mula 1 hanggang 1440) gamit ang `omarchy-sudo-passwordless 30`, o gamitin ang `omarchy-sudo-passwordless permanent`.

Awtomatikong nag-e-expire ang may takdang oras na access, kabilang kaagad pagkatapos mag-resume mula sa isang suspend na lumampas sa deadline. Tinatapos ito nang maaga ng pag-restart ng computer. Nananatili ang permanenteng access sa mga reboot at mananatiling naka-enable hanggang i-disable mo ito.

Tinatapos ng pag-update o pag-alis sa settings package ng Omarchy ang anumang pansamantalang grant bago magbago ang suporta nito sa expiry. Kung mag-ulat ang command ng error sa authorization o cleanup, resolbahin ito bago subukang mag-enable ng isa pang grant; hindi nangangahulugang hindi aktibo ang passwordless access ang isang error.

Maging malinaw ang iyong pananaw tungkol dito: habang naka-on ito, anumang tumatakbo bilang iyong user ay maaaring gawin ang anuman bilang root nang hindi tinatanong. Iyan ang buong punto, at iyan din ang buong panganib.

## Mga Signing Key

Ang public key para sa lahat ng pirma sa ISO at package ng Omarchy repo ay `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([beripikahin sa openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Nilalaman din ito ng package na `omarchy/omarchy-keyring` at gagamitin ito para maayos na mai-roll out ang anumang posibleng update.

Mahahanap mo ang pirma para sa anumang release ng ISO sa pamamagitan ng pagdaragdag ng .sig sa URL. Tulad ng https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
