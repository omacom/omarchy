# Seguridad

Sineseryoso ng Omarchy ang seguridad nang labis. Ito ay nilalayong maging isang operating system na maaari mong gamitin para gumawa ng _Tunay na Trabaho_ sa _Tunay na Mundo_. Kung saan ang pagkawala ng laptop ay hindi maaaring humantong sa isang emergency sa seguridad. Kaya narito ang ginagawa namin:

1. *Mandatoryo ang full-disk encryption*: Ito ang pinakamahalagang hakbang para masiguro ang pisikal na proteksyon ng data mo. Kung ang computer mo ay mawala o manakaw, ang data ay ganap na naka-encrypt gamit ang standard na LUKS (Linux Unified Key Setup).
2. *Pinagana ang firewall bilang default*: Ang lahat ng paparating na trapiko ay hinaharangan bilang default maliban sa port 53317 para sa [LocalSend](https://localsend.org/). Maging ang ssh ay naka-off hanggang sa i-on mo ito sa pamamagitan ng _Pag-setup > Seguridad > SSHD_, na nagbubukas ng port 22 (naka-rate limit laban sa brute force) bilang bahagi ng setup. Pina-lock down pa nga namin ang access sa Docker gamit ang setup na [ufw-docker](https://github.com/chaifeng/ufw-docker) para maiwasang aksidenteng mailantad ang mga container mo sa mundo.
3. *Palaging may pinakabagong mga update ang Arch*: Ang Arch, ang pinagbabatayang distro na kinababatayan ng Omarchy, ay isang rolling distribution. Ibig sabihin nito na anumang kahinaan sa seguridad na matuklasan at ma-patch sa anumang pakete ay mabilis na available para i-install gamit ang `omarchy-update`. Palagi kang nagpapatakbo ng pinakabago, pinakaligtas na mga bersyon ng lahat sa ganoong paraan.
4. *Nagpapanatili ang Omarchy ng sarili nitong mga pakete at mirror*: Umaasa lang ang Omarchy sa mga pakete mula sa sariling repository ng Arch na core/extra/multilib at sa sarili nitong Omarchy Package Repository bilang default. Maaari kang mag-install ng software nang direkta mula sa AUR, pero ang base install ay hindi — iilang opsyonal na pag-install lamang, tulad ng mga third-party na browser, ang humihila mula sa AUR.
5. *Pinoprotektahan tayo ng Cloudflare laban sa DDoS*: Ang lahat ng imprastraktura ng pamamahagi ng Omarchy — ang mga ISO, ang mga pakete ng Omarchy, ang mirror ng Arch — ay protektado sa likod ng mabigat na kalasag laban sa DDoS ng Cloudflare at naka-host sa CDN nila. Nagbibigay ito ng napakahusay na availability.

## Pagpapalit ng mga password mo

May dalawa kang password sa isang naka-encrypt na pag-install: ang isa na nag-a-unlock sa drive sa boot, at ang isa na ginagamit mo para mag-login at mag-`sudo`. Ginagawa silang magkapareho ng setup. Parehong maaaring palitan sa ilalim ng _I-update > Password_ sa menu ng Omarchy — _Pag-encrypt ng Drive_ para sa una, _User_ para sa ikalawa. Ang pagpapalit ng password ng drive ay hihingi muna ng kasalukuyang password, kaya ihanda mo ito. Kung maantala ang isang pagbabago, patakbuhin ulit ang _Pag-encrypt ng Drive_: hihingin nito ang password na nag-a-unlock sa drive ngayon at tatapusin nito ang pagbabago.

## Pagpapasa ng makinang nagamit mo na

Kung ipapasa mo ang makina mo sa ibang tao, hindi mo kailangang muling i-install ito. Patakbuhin ang _Pag-setup > I-reset ang Computer_ sa menu ng Omarchy, i-type ang `reset` para kumpirmahin, at mag-reboot. Buburahin niyon ang bawat user account at lahat ng nasa `/home`, itatapon ang lahat ng pakete at pagbabago sa sistema na ginawa mo mula nang i-install, at buburahin ang pagkakakilanlan ng makina — mga koneksyon sa network, host key, at lahat. Ang babalik ay ang setup wizard mula sa unang boot, handa na para sa bagong may-ari nito na ilagay ang sarili niyang pangalan, password, at password ng pag-encrypt.

Gumagana ito sa pamamagitan ng pagbabalik ng baseline snapshot na kinukuha ng installer, kaya available lang ito sa mga makinang na-install mula sa Omarchy ISO. At sa isang drive na walang encryption, ang reset ay pagbura imbes na isang ligtas na pag-erase, kaya kung sensitibo ang data, gumawa na lang ng bagong pag-install.

## Sudo na walang password

Kung minsan ay gusto mong tumigil na sa paghingi ang `sudo`, kadalasan kapag ang isang AI agent ay gumagawa ng mahabang stretch ng trabaho sa sistema para sa iyo. Ang _Pag-setup > Seguridad > Sudo na Walang Password_ ay nagtatanong kung gaano katagal papayagan ang access: **15 minutes**, **1 Hour**, **1 Day**, o **Permanently**. Lumalabas ang isang pulang icon ng babala sa tabi ng iba pang indikator ng menu bar habang aktibo ang access. I-click ito o patakbuhin ulit ang command para i-off ang access. Maaari mo ring ipasa ang sarili mong bilang ng minuto (mula 1 hanggang 1440) gamit ang `omarchy-sudo-passwordless 30`, o gamitin ang `omarchy-sudo-passwordless permanent`.

Awtomatikong nag-e-expire ang naka-oras na access, kasama agad pagkatapos mag-resume mula sa isang suspend na lumampas sa deadline. Ang pag-restart ng computer ay nagtatapos nito nang maaga. Ang permanenteng access ay nananatili kahit mag-reboot at nananatiling pinagana hanggang sa i-disable mo ito.

Ang pag-update o pag-aalis ng pakete ng mga setting ng Omarchy ay nagtatapos ng anumang pansamantalang grant bago magbago ang suporta nito sa pag-expire. Kung mag-ulat ang command ng error sa awtorisasyon o paglilinis, lutasin ito bago subukang paganahin ang isa pang grant; ang error ay hindi nangangahulugang hindi aktibo ang access na walang password.

Maging malinaw ang mata mo tungkol dito: habang naka-on ito, anumang tumatakbo bilang user mo ay maaaring gumawa ng anuman bilang root nang hindi tinatanong. Iyon ang buong punto, at iyon din ang buong panganib.

## Mga Signing Key

Ang pampublikong key para sa lahat ng lagda ng ISO at pakete ng repo ng Omarchy ay `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([i-verify sa openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Ang pakete na `omarchy/omarchy-keyring` ay naglalaman din nito at gagamitin para ilabas ang anumang potensyal na update nang walang aberya.

Makakahanap ka ng lagda para sa anumang release ng ISO sa pamamagitan ng pagdaragdag ng .sig sa URL. Tulad ng https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
