# Windows VM

Nag-aalok ang Omarchy ng madaling paraan para patakbuhin ang Windows sa pamamagitan ng isang Docker VM. Maaari mo itong i-install gamit ang _Install > Windows_ mula sa Omarchy menu (`Super + Space`).

Kailangan ng makina mo ng KVM virtualization para dito, na mayroon ang karamihan — pero minsan naka-off ito sa BIOS, at sasabihin sa iyo ng installer kung ganoon nga. Gusto mo rin ng espasyo sa disk: anumang ibibigay mo sa Windows, kasama ang humigit-kumulang 10GB para sa image mismo.

Itinatanong ng installer kung gaano karaming RAM, ilang CPU core, at gaano karaming disk ang ibibigay (64GB o higit pa ang makatwirang minimum), pagkatapos ay para sa isang Windows username at password. Iwanang blangko ang mga iyon at makakakuha ka ng `docker` / `admin`. Matagal ang download — normal ang 10-15 minuto — at maaari mong sundan ang progress sa browser sa `http://127.0.0.1:8006`. Hihingin ng browser ang parehong username at password bago buksan ang console.

 ![windows-vm](images/windows-vm.webp)

## Paggamit nito

Kapag na-install na ito, ilunsad ang _Windows_ mula sa app launcher. Sinisimulan niyon ang VM kung hindi pa ito tumatakbo at ikinokonekta ka sa RDP, full screen. Bigyan ito ng 15-30 segundo sa isang cold start.

Dala ng RDP session ang tunog, ang mikropono mo, at isang shared clipboard, kaya gumagana lang ang pagkopya ng teksto sa pagitan ng Linux at Windows. Sumusunod ang resolution sa window mo, at ipinapasa ng Omarchy ang display scaling mo, kaya hindi ito malabong gulo sa isang HiDPI screen.

Kapag isinara mo ang RDP window, awtomatikong nagsasara ang VM. Kung mas gusto mong iwan itong tumatakbo — sabihin nating mayroon kang isang bagay na gumagawa roon — ilunsad ito gamit ang `omarchy windows vm launch --keep-alive` sa halip.

Ang natitirang mga kontrol ay nasa parehong command:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Pagbabahagi ng mga file

Ang direktoryong `~/Windows` sa iyong home directory ay awtomatikong ibinabahagi sa VM. Ilagay ang mga file roon kung gusto mong ma-access ng Windows ang mga ito. Walang access ang VM sa anumang iba pang bahagi ng iyong file system, kaya ligtas ka mula sa anumang masama sa panig ng Windows. Ang sarili nitong virtual disk ay magagamit sa `~/.windows`.

Nananatili ang mga pamilyar na home path na iyon sa sarili nilang mga filesystem. Maaari rin silang maging symlink sa mga direktoryong pagmamay-ari mo, na kapaki-pakinabang kapag nakatira ang virtual disk sa isang mas malaking drive. Sinusukat ng installer ang libreng espasyo sa filesystem na talagang naglalaman ng `~/.windows`, hindi palaging ang filesystem na naglalaman ng iyong home directory.

Panatilihin ang disk at shared path bilang magkahiwalay at hindi nagsasapawang mga direktoryo. Sadyang inaalisan ng laman ng pag-alis ang disk directory pero pinapanatili ang shared directory. Kaagad bago ang pagtanggal, nagsasagawa ang Omarchy ng isang bounded containment check at tumatangging magtanggal ng anuman kung mag-time out ang check na iyon o hindi mapatunayan na magkahiwalay ang dalawang tree.

Bago magsimula ang VM, binubuksan at ini-pin ng Omarchy ang dalawang direktoryong iyon, pagkatapos ay bina-bind-mount ang eksaktong mga directory inode sa mga pribadong per-user anchor sa ibaba ng `/var/lib/omarchy/windows/mounts`. Nakikita lang ng Docker ang mga root-protected anchor na iyon. Pinapanatili nito ang mga custom na lokasyon ng disk habang pinipigilan ang isa pang prosesong tumatakbo bilang ikaw na magpalit ng isang nasuring path bago ito gamitin ng privileged container. Ang mga kasalukuyang disk at shared directory ay hinahigpitan sa mode na `0700` sa panahon ng migration para hindi ma-browse ng iba pang lokal na account ang kanilang mga nilalaman.

Nakatali lang sa localhost ang mga port ng VM, kaya walang makakaabot sa Windows machine mula sa network mo. Nangangailangan din ang web console ng naka-configure na Windows username at password, na pinipigilan ang isa pang lokal na account na patakbuhin ang VM sa pamamagitan ng port 8006.

## Mga limitasyon at paglisensya

Walang GPU passthrough sa setup na ito, kaya hindi ito angkop para sa paglalaro o pag-edit ng video. Ito ay isang mahusay na paraan para patakbuhin ang Microsoft Office o anumang iba pang talagang kailangan mo.

Ang bersyong na-install ay Windows 11 Pro, hindi pa naka-activate. Kakailanganin mo ang sarili mong license key para gamitin ang mga gated feature.

Kung ang computer na ito ay may kasamang Windows, nasa firmware pa rin ang OEM key kahit pagkatapos i-install ang Omarchy. I-print ito gamit ang `omarchy windows key`. Nakatali ang key na iyon sa makinang ito — ia-activate nito ang Windows na muling na-install sa hardware na ito, pero kadalasan ay hindi nito ia-activate ang VM.

Maaari mong baguhin ang resource allocation mamaya sa pamamagitan ng muling pagpapatakbo ng `omarchy-windows-vm install`, na muling isinusulat ang configuration ng VM mula sa iyong mga sagot. Ang compose file mismo ay nakatira na ngayon sa `/var/lib/omarchy/windows/docker-compose.yml` at pagmamay-ari ng root — sadya iyon, kaya hindi maaaring muling isulat ng isang prosesong tumatakbo bilang ikaw ito at pagawain ang privileged bring-up na i-mount ang buong disk mo sa container. Kung kailangan mong i-edit ito nang mano-mano (halimbawa para mag-mount ng USB device), i-edit ito gamit ang `sudo` at tingnan ang lahat ng pagpipilian sa [Dockur Windows project](https://github.com/dockur/windows).

Para alisin ang buong bagay, gamitin ang _Remove > Windows_ mula sa Omarchy menu. Tinatanggal niyon ang disk ng VM at lahat ng data nito, kaya tiyakin na anumang pinahahalagahan mo ay wala na muna sa `~/Windows`.
