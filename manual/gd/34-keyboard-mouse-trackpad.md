# Meur-chlàr, luchag, pada-suathaidh

Leigidh Hyprland leat na h-uidheaman ion-chuir agad uile a rèiteachadh gu mionaideach. 'S urrainn dhut ath-dhèanamh nan iuchraichean a dhèanamh cho luath ri peilear no toirt air a' phada-suathaidh sgroladh nàdarra a chleachdadh. Atharraichidh tu seo uile ann an `~/.config/hypr/input.lua`, as urrainn dhut ruigsinn cuideachd le _Suidheachadh > Ion-chur_ ann an clàr-taice Omarchy (`Super + Space`). Thèid rud sam bith a shuidhicheas tu an-sin an àite bun-roghainnean Omarchy.

Seo eisimpleir:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

'S urrainn dhut [na roghainnean ion-chuir uile fhaicinn](https://wiki.hypr.land/Configuring/Basics/Variables/#input) air uicipeid Hyprland mu ion-chur.

Obraichidh CapsLock mar Caps Lock àbhaisteach, agus 's e `Shift + CapsLock` an iuchair compose airson [emoji luath](07-hotkeys.md#quick-emojis) agus [coileanaidhean eile](07-hotkeys.md#quick-completions). Nam b' fheàrr leat an iuchair compose a bhith an àiteigin eile, cuir rud eile an àite `omarchy:shift_caps_compose` ann an `kb_options`. Mar eisimpleir, gluaisidh seo an iuchair compose gu Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gluasadan-làimhe a' phada-suathaidh

'S urrainn dhut [gluasadan-làimhe a' phada-suathaidh](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) a chur air cuideachd, mar shlaighdeadh le trì corragan gus rumannan-obrach atharrachadh:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Air laptops Dell XPS le pada-suathaidh haptaig, 's urrainn dhut neart a' bhriogaidh a shuidheachadh gu ìosal, meadhanach no àrd fo _Cuir gu dol > Bathar-cruaidh > Haptaig a' phada-suathaidh_.

### Sgrìobhadh ann an Sìnis, Seapanais is cànanan eile

Tagh Seapanais, Coirèanais, Sìnis (Shimplichte, Pinyin), Taidh-Bhàn (Zhuyin) no Hong Kong (Cangjie) nuair a dh'iarras an stàlaichear do mheur-chlàr. Rèitichidh Omarchy am meur-chlàr agus an t-einnsean ion-chuir a fhreagras ris gu fèin-obrachail, fiù 's rè suidheachadh a' chiad bhùtaidh far loidhne. Cleachdaidh Seapanais Mozc, Coirèanais Hangul àbhaisteach dà-sheata, Sìnis Shimplichte Pinyin, Taidh-Bhàn rèiteachadh Zhuyin àbhaisteach Chewing, agus Hong Kong Cangjie le cruthan charactaran Hong Kong. Bheir Seapanais (meur-chlàr US) Mozc dhut le co-dhealbhachd meur-chlàir US. Fanaidh iuchraichean Hangul, Zhuyin agus Cangjie nan àiteachan àbhaisteach fiù 's nuair a sgrìobhas tu litrichean Laideann le Dvorak, Colemak no AZERTY. Ma chuir thu Hangul no Chewing ris ron seo, dì-thagh agus ath-thagh e fo _Suidheachadh > Clò-sgrìobhadh > Dòighean ion-chuir_ gus na h-iuchraichean aige a ghluasad an-sin; fàgaidh Omarchy einnsean leis a bheil thu a' sgrìobhadh mu thràth mar a tha e.

Tòisichidh an sgrìobhadh sa mhodh Laideann. Brùth `Super + I` gus cuairteachadh tro na dòighean ion-chuir rèitichte, agus `Super + Shift + I` gus cuairteachadh air ais. Thoir gnogag air `Shift` leis fhèin gus ceum a-mach à dòigh ion-chuir mar Pinyin gu litrichean Laideann, agus thoir gnogag eile air gus tilleadh, mar a nì Sogou, Microsoft Pinyin agus macOS; sgrìobhaidh `Shift` le litir litir mhòr fhathast. Air meur-chlàran Seapanach, toglaichidh 全角/半角 an t-ion-chur, cuiridh 変換 air e, agus cuiridh 無変換 dheth e. Le Coirèanais, atharraichidh 한/영 Hangul agus iompaichidh 한자 gu Hanja, ge b' e a bheil iuchraichean sònraichte air a' mheur-chlàr agad no an cuir e Right Alt agus Right Ctrl air an son, mar a nì iomadh laptop, mar sin chan e atharraichearan àbhaisteach a th' ann an Right Alt agus Right Ctrl an-sin; fanaidh brùth-gus-bruidhinn an deachdaidh air F9. Bidh `Ctrl + Space` ri fhaighinn fhathast do Tmux agus Herdr; fanaidh `Shift + CapsLock` na iuchair compose.

Nochdaidh taisbeanair a' mheur-chlàir air taobh deas a' bhàir nuair a bhios iomadh co-dhealbhachd meur-chlàir no dòigh ion-chuir agad. Briog air gus cànan an ion-chuir atharrachadh; seallaidh Seapanais あ airson hiragana. Airson roghainnean charactaran Seapanach, leum gu Seapanais, sgrìobh facal mar `nihongo`, agus brùth Space dà thuras. Brùth Enter gus gabhail ris an roghainn agad. Ma tha iomadh co-dhealbhachd meur-chlàir agad cuideachd, dèan briogadh deas air an taisbeanair gus cuairteachadh tromhpa.

Cleachd _Suidheachadh > Clò-sgrìobhadh > Co-dhealbhachdan meur-chlàir_ gus co-dhealbhachdan a thaghadh, mar Bheurla agus Fraingis, o na h-aon roghainnean a chaidh a thairgsinn rè an stàlaidh. Cleachd _Suidheachadh > Clò-sgrìobhadh > Dòighean ion-chuir_ gus taghadh dè na h-einnseanan co-chur a bhios gnìomhach. Fosglaidh an dà thaghadair am broinn clàr-taice Omarchy le cromagan ris na roghainnean làithreach agad. Briog no brùth Enter gus roghainn a thoglachadh; bidh gach atharrachadh an sàs sa bhad. Ma dhì-thaghas tu dòigh ion-chuir, thèid a thoirt às a' chuairt gun a dì-stàladh; bidh am meur-chlàr ri fhaighinn fhathast.

Ruith `omarchy setup keyboard` no `omarchy setup input` gus na h-aon taghadairean fhosgladh. Gus aon chànan a chur ris on loidhne-àithne, cleachd `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` no `cangjie5`. Thig Quick, Boshiamy agus Array san aon phacaid ri Cangjie agus nochdaidh iad san taghadair Dòighean ion-chuir. Thèid na h-iuchraichean atharrachaidh gnàthaichte agad a ghlèidheadh. Airson co-dhealbhachdan no iuchraichean einnsein eile, stàlaich `fcitx5-configtool` le `omarchy pkg add fcitx5-configtool` agus cuir gu dol e o thèirmineal. Ma thaghas tu cànan ion-chuir, chan atharraich sin cànan an deasga. Ma thaghas tu Seapanais, Coirèanais no Sìnis fo _Suidheachadh > Cànan_, cuiridh sin an dòigh ion-chuir aige ris mura bheil tè agad fhathast.

Cleachd `Super + I` gus cuairteachadh tro dhòighean ion-chuir no co-dhealbhachdan meur-chlàir, agus `Super + Shift + I` gus a dhol an rathad eile, mar sin le trì dhiubh rèitichte, 's urrainn dhut gluasad eadar dà nàbaidh. Cha nochd taisbeanair an ion-chuir air taobh deas a' bhàir ach nuair a bhios barrachd air aon dòigh ion-chuir no co-dhealbhachd rèitichte. Obraichidh an ceangal deasga seo còmhla ris na h-iuchraichean atharrachaidh Fcitx a th' agad mu thràth; 's urrainn dhut sgrìobhadh thairis air ann an `~/.config/hypr/bindings.lua`. Cleachdaidh einnseanan an ion-chuir agus na sreathan compose an t-seirbheis [Fcitx5](https://fcitx-im.org/) a tha a' ruith anns gach seisean mu thràth.

### ALT a chleachdadh mar SUPER

Air cuid a mheur-chlàran, chan eil e goireasach a' phrìomh iuchair meta (iuchair Windows/cmd) a chleachdadh mar SUPER. 'S urrainn dhut ALT a chur na àite leis an atharrachadh seo:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
