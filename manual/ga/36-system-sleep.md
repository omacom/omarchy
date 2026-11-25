# Codladh an chórais

Cumasaíonn Omarchy cur ar fionraí de réir réamhshocraithe, agus geimhriú a luaithe a bheidh sé socraithe, ach má bhíonn fadhbanna agat le ceachtar acu ar do mheaisín, is féidir leat iad a mhúchadh.

Ar mheaisíní NVIDIA GB10, amhail an DGX Spark agus an ASUS Ascent GX10, tá cur ar fionraí agus geimhriú múchta, mar atá siad in DGX OS de chuid NVIDIA, mar nach bhfuil sé léirithe fós go n-oibríonn codladh ar na crua-earraí sin. Tá an rud céanna fíor i gcás an ASUS Zenbook A16 (UX3607OA), áit nach gcuireann cur ar fionraí an tslis ina codladh go hiomlán fós agus gur féidir leis crochadh thar oíche. Ní bhaineann an scorán curtha ar fionraí agus socrú an gheimhrithe leis ansin. Chun codladh a chasadh air arís, bain `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` le `sudo rm`; fillfidh Cur ar Fionraí ar an roghchlár ansin, agus is féidir geimhriú a shocrú mar is féidir ar mheaisíní eile. Cuireann rith `sudo omarchy apply hardware --install-user "$USER"` an comhad ar ais.

### Próifílí cumhachta

Ar ríomhaire glúine, cuimhníonn Omarchy ar do phróifíl chumhachta ar leithligh agus tú plugáilte isteach agus agus tú ag rith ar cheallra, agus aistríonn sé idir an dá cheann de réir mar a phlugálann agus a dhíphlugálann tú. As an mbosca, ciallaíonn sé sin feidhmíocht ar AC agus cothromaíocht ar cheallra.

Is féidir leat a fheiceáil cad a thairgeann do mheaisín le `omarchy powerprofiles list`, agus an ceann atá uait a shocrú don staid ina bhfuil tú faoi láthair le `omarchy powerprofiles set autodetect power-saver`. Chun an staid eile a shocrú gan aon rud a dhíphlugáil, ainmnigh go díreach í: `omarchy powerprofiles set battery power-saver`. Cibé rud a roghnaíonn tú, is é a gheobhaidh tú ar ais an chéad uair eile a bheidh tú sa staid sin.

### Scoránaigh cur ar fionraí

Scoránaíonn tú cur ar fionraí trí `omarchy toggle suspend` a rith ón teirminéal. Ní dhéanann sé sin ach an rogha a nochtadh/a cheilt faoi _Córas_ (nó `Super + Esc`), agus ansin is féidir leat a fheiceáil an n-oibríonn sé go comhsheasmhach ar do chóras. Mura n-oibríonn, is féidir leat é a cheilt arís leis an ordú céanna.

### Scoránaigh geimhriú

Socraíonn tú geimhriú trí `omarchy hibernation setup` a rith ón teirminéal (níl sé ar fáil ar Mhacs Apple Silicon). Cruthaíonn geimhriú fo-imleabhar /swap ar do thiomántán tosaithe ar mhéid do leithdháilte RAM fhisiciúil, mar sin déan cinnte go bhfuil neart spáis le spáráil agat. Ar mheaisín 32GB, beidh 32GB+ saor in aisce uait i gcónaí don imleabhar seo. Éilíonn geimhriú an lódálaí tosaithe réamhshocraithe Limine freisin.

Nuair a bheidh sé socraithe, feicfidh tú an rogha geimhrithe faoi _Córas_ (nó `Super + Esc`), agus ansin is féidir leat a fheiceáil an n-oibríonn sé go comhsheasmhach ar do chóras. Mura n-oibríonn, is féidir leat é a bhaint arís trí `omarchy hibernation remove` a rith.
