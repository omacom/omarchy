# Seatanna córais

Cruthaímid seatanna go huathoibríoch ar gach nuashonrú Omarchy, ach más mian leat do cheann féin a chruthú, is féidir leat `omarchy-snapshot create` a úsáid.

Chun seat a thosú agus a chur ar ais, roghnaíonn tú é ón luchtóir tosaithe Limine. (Má tá tú ag tosú díreach isteach sa scáileán díchriptithe Omarchy faoi láthair, beidh ort Limine a roghnú mar rogha tosaithe trí BIOS ar dtús).

Ón scáileán sin, roghnaigh an seat ar mian leat tosú isteach ann bunaithe ar an dáta agus ar an leagan. Is féidir leagan Omarchy ag am an tseat a fheiceáil sa chúinne íochtair ar chlé.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Nuair a shroicheann tú istigh, preabfaidh fógra suas ag cur in iúl duit go bhfuil tú i seat intosaithe agus má chliceálann tú air, tosóidh sé an próiseas athchóirithe. Mar mhalairt air sin, is féidir leat `omarchy-snapshot restore` a úsáid.

 ![snapshots-restore](images/snapshots-restore.webp)

Cuirfidh sé seo do chóras comhad fréimhe ar ais, ach ní do `/home`. Mar sin oibríonn sé chun nuashonrú córais briste a chealú, ach ní chun comhaid phearsanta caillte a aisghabháil.

Ciallaíonn sé seo freisin go gcoimeádtar do chomhadlann `~/.config` mar atá sí. Mar sin má tá tú ag filleadh ar leagan níos luaithe de leabharlann nó feidhmchlár a stórálann comhaid chumraíochta i bhformáid nua, beidh ort é sin a réiteach de láimh.

_Nóta: Níl an ghné seo ar fáil ach ar shuiteálacha a úsáideann an luchtóir tosaithe Limine, atá ina réamhshocrú ó Omarchy 2.0. Níl sé ar fáil má tá tú ar GRUB nó systemd-boot._

### An roghchlár tosaithe a scipeáil

Mura dteagmhaíonn tú riamh leis an roghchlár tosaithe agus gur mhaith leat go rachadh an meaisín díreach chuig an scáileán díchriptithe, rith _Socrú > Direct Boot_ sa roghchlár Omarchy. Cuireann sé sin iontráil EFI leis a dhíríonn go díreach ar Omarchy, mar sin tosóidh an dochteanna é gan stopadh ag Limine.

Is é an comhbhabhtáil an ceann a luaitear ag an mbarr: le tosú díreach ar siúl, ciallaíonn seat a bhaint amach Limine a roghnú ó do roghchlár tosaithe BIOS ar dtús. Rith _Socrú > Direct Boot_ arís chun an iontráil a bhaint agus dul ar ais go tosú trí Limine. Ní thógann roinnt dochteanna go maith le hiontrálacha EFI saincheaptha, mar sin diúltaíonn an socrú rith ar dhochteanna American Megatrends agus Apple.
