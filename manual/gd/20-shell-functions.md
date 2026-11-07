# Foincseanan na slige

Thig Omarchy le seata de dh'fhoincseanan slige a nì gnìomhan cumanta nas sìmplidhe agus a chuireas paramadairean toinnte am falach.

## Dùmhlachadh

- `compress [file/dir]`: Cruthaich tasglann tar.gz on fhaidhle/phasgan.
- `decompress [file.tar.gz]`: Dì-dhùmhlaich faidhle tar.gz.

## Draibhean

- `iso2sd [image.iso]`: Cruthaich draibh a ghabhas bùtadh air cairt SD leis an fhaidhle iso a dh'ainmich thu, a' taghadh an draibh gu h-eadar-ghnìomhach.
- `format-drive [device] [name]`: Fòrmataich diosga slàn le aon phàirteachadh exFAT (a dh'obraicheas air Windows is macOS cuideachd). Ruith e gun argamaid airson na draibhean a tha ri làimh fhaicinn. Bi faiceallach!

## Co-dhealbhachdan leasachaidh

Co-dhealbhachdan leasachaidh ioma-phana sa bhad airson tmux:

- `tdl [ai]`: Cruthaich Tmux Dev Layout leis an deasaiche agad, àidseant AI agus tèirmineal. Cleachd na h-aliasan àidseant, mar `tdl c` airson opencode no `tdl cx` airson Claude Code, no thoir seachad dàrna àidseant gus an dà dhiubh a ruith, mar `tdl c cx`.
- `tds`: Cruthaich Tmux Dev Square le deasaiche, sùil air diffs (le `hunk diff --watch`), tèirmineal agus opencode.
- `tdlm [ai]`: Cruthaich uinneag `tdl` airson gach fo-phasgan sa phasgan làithreach.
- `tsl [count] [command]`: Cruthaich sgaoth de phanaichean ann an griod leacach, iad uile a' ruith na h-aon àithne (sgoinneil airson àidseantan AI).

Tha na h-aon cho-dhealbhachdan ri làimh airson Herdr mar `hdl`, `hds`, `hdlm` agus `hsl`.

## Craobhan-obrach Git

- `ga [branch]`: Cruthaich craobh-obrach is meur ùr ri taobh an ionad-tasgaidh làithrich agus leum a-steach innte.
- `gd`: Thoir air falbh an craobh-obrach làithreach agus a meur (iarraidh e dearbhadh an toiseach).

## Freiceadain rsync

- `rsw [source] [destination]`: Tòisich freiceadan sa chùlaibh a nì rsync on tùs dhan cheann-uidhe gach turas a dh'atharraicheas rud sam bith. Faodaidh an ceann-uidhe a bhith na òstair cèin, mar `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Seall liosta de gach freiceadan gnìomhach.
- `dsw`: Cuir stad air gach freiceadan gnìomhach.

## Sìneadh air adhart phortan SSH

Air leth math airson leasachadh-lìn a dhèanamh le sochairean secure-context localhost an aghaidh bogsa cèin.

- `fip`: Sìn air adhart aon phort no barrachd o òstair cèin gu localhost thar SSH.
- `dip`: Dì-cheangail aon phort no barrachd a chaidh a shìneadh air adhart.
- `lip`: Seall liosta de gach sìneadh air adhart SSH gnìomhach.

Abair gun tòisich thu frithealaiche leasachaidh air port `3000` air inneal ris an canar `nyc-dev`; an uairsin 's urrainn dhut `fip nyc-dev 3000` a ruith gus am port sin a shìneadh air adhart, ach an ruig `localhost:3000` `nyc-dev:3000` dha-rìribh, ach gun fheum air teisteanasan SSL airson an secure context a stèidheachadh a tha a dhìth airson web sockets is a leithid a dhearbhadh.

## Ath-cheangal SSH

Tha `ssh` fhèin air a phasgadh ann am foincsean a ghlanas an tèirmineal ma bhàsaicheas ceangal fhad 's a tha tmux, Herdr no deasaiche cèin air grèim fhaighinn air, agus an uairsin ath-cheanglaidh e gu fèin-obrachail nuair a thuiteas seisean eadar-ghnìomhach (cuiridh Ctrl-C stad air a' chuairt ath-fheuchainn).
