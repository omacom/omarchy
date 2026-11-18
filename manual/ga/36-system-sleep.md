# Codladh an chórais

Cumasaíonn Omarchy fionraí agus geimhriú de réir réamhshocraithe, ach má bhíonn fadhbanna agat le ceachtar acu ar do mheaisín, is féidir leat iad a scoránú as.

Ar mheaisíní NVIDIA GB10, cosúil leis an DGX Spark agus an ASUS Ascent GX10, tá fionraí agus geimhriú múchta, mar atá siad in DGX OS de chuid NVIDIA, mar nach bhfuil sé léirithe fós go n-oibríonn codladh ar na crua-earraí sin. Baineann an rud céanna leis an ASUS Zenbook A16 (UX3607OA), áit nach gcuireann fionraí an tslis ina codladh go hiomlán fós agus gur féidir leis crochadh thar oíche. Ní bhaineann scoránú an fhionraí ná socrú an gheimhrithe le hábhar ansin. Chun codladh a chur ar ais air, bain `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` le `sudo rm`; fillfidh Fionraí ar an roghchlár ansin, agus is féidir geimhriú a shocrú mar is féidir ar mheaisíní eile. Má ritheann tú `sudo omarchy apply hardware --install-user "$USER"` cuirfear an comhad ar ais.

### Próifílí cumhachta

Ar ríomhaire glúine, cuimhníonn Omarchy do phróifíl cumhachta ar leithligh don staid plugáilte isteach agus don staid ag rith ar cheallra, agus aistríonn sé idir an dá cheann de réir mar a phlugálann agus a dhíphlugálann tú. As an mbosca, ciallaíonn sé sin feidhmíocht ar AC agus cothrom ar cheallra.

Is féidir leat a fheiceáil cad a thairgeann do mheaisín le `omarchy powerprofiles list`, agus an ceann atá uait don staid ina bhfuil tú faoi láthair a shocrú le `omarchy powerprofiles set autodetect power-saver`. Chun an staid eile a shocrú gan aon rud a dhíphlugáil, ainmnigh go díreach í: `omarchy powerprofiles set battery power-saver`. Cibé rud a roghnaíonn tú, is é sin a gheobhaidh tú ar ais an chéad uair eile a bheidh tú sa staid sin.

### Scoránaigh fionraí

Scoránaíonn tú fionraí trí `omarchy toggle suspend` a rith ón teirminéal. Ní dhéanann sé sin ach an rogha faoi _Córas_ (nó `Super + Esc`) a thaispeáint/a cheilt, agus ansin is féidir leat a fheiceáil an n-oibríonn sé go comhsheasmhach ar do chóras. Mura n-oibríonn, is féidir leat é a cheilt arís leis an ordú céanna.

### Scoránaigh geimhriú

Socraíonn tú geimhriú trí `omarchy hibernation setup` a rith ón teirminéal. Cruthaíonn geimhriú fothomhas /swap ar do thiomántán tosaithe ar cóimhéid le leithdháileadh do RAM fhisiciúil, mar sin déan cinnte go bhfuil neart spáis le spáráil agat. Ar mheaisín 32GB, beidh 32GB+ saor uait i gcónaí don tomhas seo. Éilíonn geimhriú an lódálaí tosaithe réamhshocraithe Limine freisin.

Nuair atá sé socraithe, feicfidh tú an rogha geimhrithe faoi _Córas_ (nó `Super + Esc`), agus ansin is féidir leat a fheiceáil an n-oibríonn sé go comhsheasmhach ar do chóras. Mura n-oibríonn, is féidir leat é a bhaint arís trí `omarchy hibernation remove` a rith.
