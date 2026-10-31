# Feidhmeanna Blaoisce

Tagann Omarchy le sraith feidhmeanna blaoisce chun tascanna coitianta a shimpliú agus glaonna paraiméadar casta a chuimsiú.

## Comhbhrú

- `compress [file/dir]`: Cruthaigh cartlann tar.gz ón gcomhad/eolaire.
- `decompress [file.tar.gz]`: Méadaigh comhad tar.gz.

## Tiomántáin

- `iso2sd [image.iso]`: Cruthaigh tiomántán tosaithe ar chárta SD ag úsáid an chomhaid iso luaite agus ag piocadh an tiomántáin go hidirghníomhach.
- `format-drive [device] [name]`: Formáidigh diosca iomlán le rannán exFAT amháin (a oibríonn ar Windows agus macOS freisin). Rith é gan argóintí chun na tiomántáin atá ar fáil a fheiceáil. Bí cúramach!

## Leaganacha forbartha

Leaganacha forbartha ilphána meandracha do tmux:

- `tdl [ai]`: Cruthaigh Tmux Dev Layout le d'eagarthóir, gníomhaí AI, agus teirminéal. Úsáid ailiasanna na ngníomhaithe, ar nós `tdl c` do opencode nó `tdl cx` do Claude Code, nó cuir an dara gníomhaí ar aghaidh chun an dá cheann a rith, ar nós `tdl c cx`.
- `tds`: Cruthaigh Tmux Dev Square le heagarthóir, féachaint ar dhiofraithe (trí `hunk diff --watch`), teirminéal, agus opencode.
- `tdlm [ai]`: Cruthaigh fuinneog `tdl` do gach fo-eolaire san eolaire reatha.
- `tsl [count] [command]`: Cruthaigh scaoth pánaí tílte in eangach, iad go léir ag rith an ordaithe chéanna (iontach do ghníomhaithe AI).

Tá na leaganacha céanna ar fáil do Herdr mar `hdl`, `hds`, `hdlm`, agus `hsl`.

## Crann oibre Git

- `ga [branch]`: Cruthaigh crann oibre agus craobh nua in aice leis an stóras reatha agus léim isteach ann.
- `gd`: Bain an crann oibre reatha agus a chraobh (iarrann sé deimhniú ar dtús).

## Faireirí rsync

- `rsw [source] [destination]`: Tosaigh faireoir cúlra a dhéanann rsync ón bhfoinse go dtí an ceann scríbe gach uair a athraíonn rud éigin. Is féidir leis an gceann scríbe a bheith ina óstríomhaire cianda, ar nós `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Liostaigh na faireirí gníomhacha go léir.
- `dsw`: Stop na faireirí gníomhacha go léir.

## Seoladh ar aghaidh calafoirt SSH

Idéalach chun forbairt gréasáin a dhéanamh le pribhléidí comhthéacs slán localhost in aghaidh bosca cianda.

- `fip`: Seol calafort amháin nó níos mó ó óstríomhaire cianda go localhost trí SSH.
- `dip`: Dícheangail calafort amháin nó níos mó a seoladh ar aghaidh.
- `lip`: Liostaigh gach seoladh ar aghaidh calafoirt SSH gníomhach.

Abair go dtosaíonn tú freastalaí forbartha ar chalafort `3000` ar mheaisín atá ar fáil mar `nyc-dev`, ansin is féidir leat `fip nyc-dev 3000` a rith chun an calafort sin a sheoladh ar aghaidh, ionas go sroichfidh `localhost:3000` `nyc-dev:3000` i ndáiríre, ach gan gá le teastais SSL chun an comhthéacs slán atá ag teastáil chun soicéid gréasáin nó a mhacasamhail a thástáil a bhunú.

## Athnascadh SSH

Tá `ssh` féin fillte i bhfeidhm a ghlanann an teirminéal má fhaigheann nasc bás agus tmux, Herdr, nó eagarthóir cianda tar éis é a éileamh, agus a athnascann go huathoibríoch nuair a thiteann seisiún idirghníomhach (stopann Ctrl-C an lúb athiarrachta).
