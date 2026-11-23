# Windows VM

Nag-aalok ang Omarchy ng madaling paraan para patakbuhin ang Windows sa pamamagitan ng Docker VM sa mga makinang x86_64. Maaari mo itong i-install gamit ang _Install > Windows_ mula sa menu ng Omarchy (`Super + Space`).

Kailangan ng iyong makina ng KVM virtualization para dito, na mayroon ang karamihan — pero minsan naka-off ito sa BIOS, at sasabihin sa iyo ng installer kung ganoon nga. Kakailanganin mo rin ng espasyo sa disk: kung magkano man ang ibigay mo sa Windows, dagdagan pa ng mga 10GB para sa image mismo.

Itatanong ng installer kung gaano karaming RAM, ilang CPU cores, at gaano karaming disk ang ibibigay (64GB o higit pa ang makatwirang pinakamababa), pagkatapos ay ang username at password para sa Windows. Iwanang blangko ang mga iyon at makukuha mo ang `docker` / `admin`. Medyo matagal ang pag-download — normal ang 10-15 minuto — at maaari mong sundan ang progreso sa browser sa `http://127.0.0.1:8006`. Hihingin ng browser ang parehong username at password bago buksan ang console.

 ![windows-vm](images/windows-vm.webp)

## Paggamit nito

Sa sandaling na-install na ito, ilunsad ang _Windows_ mula sa app launcher. Sinisimulan nito ang VM kung hindi pa ito tumatakbo at ikinokonekta ka sa pamamagitan ng RDP, nang full screen. Bigyan ito ng 15-30 segundo sa cold start.

Dala ng RDP session ang tunog, ang iyong mikropono, at isang shared clipboard, kaya gumagana lang nang maayos ang pagkopya ng teksto sa pagitan ng Linux at Windows. Sumusunod ang resolution sa iyong window, at ipinapasa ng Omarchy ang display scaling mo, kaya hindi ito malabong gulo sa HiDPI screen.

Kapag isinara mo ang RDP window, awtomatikong nagsha-shut down ang VM. Kung mas gusto mong iwanang tumatakbo ito — sabihin nating may ginagawa ka roon — ilunsad ito gamit ang `omarchy windows vm launch --keep-alive` sa halip.

Ang iba pang mga kontrol ay nasa parehong command:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Pagbabahagi ng mga file

Awtomatikong ibinabahagi sa VM ang direktoryong `~/Windows` sa iyong home directory. Maglagay ng mga file doon kung gusto mong ma-access ng Windows ang mga iyon. Walang access ang VM sa anumang ibang bahagi ng iyong file system, kaya ligtas ka sa anumang masama sa panig ng Windows. Available ang sarili nitong virtual disk sa `~/.windows`.

Nananatili ang mga pamilyar na home path na iyon sa sarili nilang mga filesystem. Maaari rin silang maging mga symlink papunta sa mga direktoryong pag-aari mo, na kapaki-pakinabang kapag nasa mas malaking drive ang virtual disk. Sinusukat ng installer ang libreng espasyo sa filesystem na talagang naglalaman ng `~/.windows`, hindi kinakailangang ang filesystem na naglalaman ng iyong home directory.

Panatilihing magkahiwalay at hindi nag-o-overlap na mga direktoryo ang disk at mga shared path. Sinasadya ng pag-aalis na alisan ng laman ang direktoryo ng disk ngunit pinapanatili ang shared directory. Kaagad bago ang pag-delete, nagsasagawa ang Omarchy ng bounded containment check at tumatangging mag-alis ng anuman kung mag-time out ang check na iyon o hindi mapatunayan na magkahiwalay ang dalawang tree.

Bago magsimula ang VM, binubuksan at pini-pin ng Omarchy ang dalawang direktoryong iyon, pagkatapos ay bina-bind-mount ang eksaktong mga inode ng direktoryo sa mga private per-user anchor sa ibaba ng `/var/lib/omarchy/windows/mounts`. Tanging ang mga anchor na iyon na protektado ng root ang nakikita ng Docker. Pinapanatili nito ang mga custom na lokasyon ng disk habang pinipigilan ang ibang prosesong tumatakbo bilang ikaw na magpalit ng naka-check na path bago ito gamitin ng privileged container. Hinihigpitan sa mode na `0700` ang mga umiiral nang disk at shared directory habang nagma-migrate para hindi ma-browse ng ibang lokal na account ang mga nilalaman ng mga iyon.

Naka-bind lang sa localhost ang mga port ng VM, kaya walang anuman sa iyong network ang makakaabot sa makinang Windows. Kinakailangan din ng web console ang naka-configure na username at password ng Windows, na pumipigil sa ibang lokal na account na patakbuhin ang VM sa pamamagitan ng port 8006.

## Mga limitasyon at paglilisensya

Walang GPU passthrough sa setup na ito, kaya hindi ito angkop para sa gaming o video editing. Mahusay itong paraan para patakbuhin ang Microsoft Office o anumang iba pang talagang kailangan mo.

Ang bersyong naka-install ay Windows 11 Pro, hindi activated. Kakailanganin mo ng sarili mong license key para magamit ang mga gated feature.

Kung may kasamang Windows ang computer na ito noong binili, nasa firmware pa rin ang OEM key kahit pagkatapos i-install ang Omarchy. I-print ito gamit ang `omarchy windows key`. Nakatali ang key na iyon sa makinang ito — ia-activate nito ang Windows na muling in-install sa hardware na ito, ngunit karaniwan ay hindi nito ia-activate ang VM.

Maaari mong baguhin ang resource allocation sa ibang pagkakataon sa pamamagitan ng pagpapatakbo ng `omarchy windows vm install` sa terminal, na muling isusulat ang configuration ng VM mula sa iyong mga sagot. Ang compose file mismo ay nasa `/var/lib/omarchy/windows/docker-compose.yml` na ngayon at pag-aari ng root — sinasadya iyon, para hindi ito muling maisulat ng prosesong tumatakbo bilang ikaw at mapilitan ang privileged bring-up na i-mount ang buong disk mo sa container. Kung kailangan mong i-edit ito nang mano-mano (halimbawa para mag-mount ng USB device), i-edit ito gamit ang `sudo` at tingnan ang lahat ng opsyon sa [ang proyekto ng Dockur Windows](https://github.com/dockur/windows).

Para alisin ang lahat ng ito, gamitin ang _Remove > Windows_ mula sa menu ng Omarchy. Dine-delete nito ang disk ng VM sa `~/.windows` at lahat ng naka-install sa loob ng Windows, kaya kopyahin muna palabas ng VM ang anumang kailangan mo. Iiwanang mag-isa ang iyong shared na folder na `~/Windows`.
