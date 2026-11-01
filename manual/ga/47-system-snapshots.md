# Seatanna córais

Cruthaímid seatanna go huathoibríoch ar gach nuashonrú Omarchy, ach má tá tú ag iarraidh do cheann féin a chruthú, is féidir leat `omarchy-snapshot create` a úsáid.

Chun seat a thosú agus a chur ar ais, roghnaíonn tú é ó lódálaí tosaithe Limine. (Más díreach chuig scáileán díchriptithe Omarchy atá tú ag tosú faoi láthair, beidh ort Limine a roghnú mar rogha tosaithe tríd an BIOS ar dtús).

Ón scáileán sin, roghnaigh an seat ar mhaith leat tosú ann bunaithe ar an dáta agus ar an leagan. Is féidir leagan Omarchy ag am an tseata a fheiceáil sa chúinne ag bun ar chlé.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Nuair a shroicheann tú an taobh istigh, preabfaidh fógra aníos ag cur in iúl duit go bhfuil tú i seat intosaithe agus, má chliceálann tú air, cuirfidh sé tús leis an bpróiseas athchóirithe. Nó is féidir leat `omarchy-snapshot restore` a úsáid.

 ![snapshots-restore](images/snapshots-restore.webp)

Cuirfidh sé seo do chóras comhad fréimhe ar ais, ach ní chuirfidh sé do `/home` ar ais. Mar sin oibríonn sé chun nuashonrú córais briste a chur ar ceal, ach ní chun comhaid phearsanta caillte a fháil ar ais.

Ciallaíonn sé seo freisin go gcoimeádtar d'eolaire `~/.config` mar atá sé. Mar sin má tá tú ag filleadh ar leagan níos luaithe de leabharlann nó d'fheidhmchlár a stórálann comhaid chumraíochta i bhformáid nua, beidh ort é sin a réiteach de láimh tú féin.

Baineann an rud céanna le taifead Omarchy féin ar na himircí atá rite cheana: tá sé i do eolaire baile, mar sin maireann sé tar éis an athchóirithe. Fanann imircí a ritheadh tar éis an seat a thógáil marcáilte mar déanta, cé gur cuireadh na hathruithe a rinne siad ar an gcóras comhad fréimhe ar ceal, agus ní rithfidh an chéad `omarchy update` eile iad arís. Mar sin má nuashonraíonn tú arís tar éis athchóirithe agus má tá rud éigin a bhí socraithe ag nuashonrú níos luaithe fós ar iarraidh, is dócha gurb é sin an chúis.

_Nóta: Níl an ghné seo ar fáil ach ar shuiteálacha a úsáideann lódálaí tosaithe Limine, atá ina réamhshocrú ó Omarchy 2.0. Níl sí ar fáil má tá tú ar GRUB nó ar systemd-boot._

### An roghchlár tosaithe a scipeáil

Mura dtéann tú i dteagmháil leis an roghchlár tosaithe riamh agus más mian leat go rachadh an meaisín díreach chuig an scáileán díchriptithe, rith _Setup > Direct Boot_ i roghchlár Omarchy. Cuireann sé sin iontráil EFI leis a dhíríonn díreach chuig Omarchy, mar sin tosaíonn an fhirmware é gan stopadh ag Limine.

Is é an comhréiteach an ceann a luadh ag an mbarr: agus tosú díreach ar siúl, ciallaíonn seat a bhaint amach Limine a roghnú ó roghchlár tosaithe do BIOS ar dtús. Rith _Setup > Direct Boot_ arís chun an iontráil a bhaint agus filleadh ar thosú trí Limine. Ní thaitníonn iontrálacha EFI saincheaptha le roinnt firmware, mar sin diúltaíonn an socrú rith ar fhirmware American Megatrends agus Apple.
