# Suiteáil Tosaithe Dé

Tá tú in ann Omarchy a shuiteáil ar dheighilt amháin taobh le Windows nó suiteálacha eile.

Tagann an modh suiteála seo fós le criptiú LUKS don dheighilt de réir réamhshocraithe mar sin go héifeachtach níl aon difríocht idir é agus an tiomáint iomlán agus ní theastaíonn ach spás saor a bheith ar fáil ar an diosca.

## Spás a Dhénanamh ar Windows

Chun suiteáil taobh le Windows, clóscríobh `disk management` sa roghchlár tosaigh agus roghnaigh an rogha do **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Aimsigh an dheighilt chuí, cliceáil ar dheis, agus roghnaigh **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Iontráil an méid ar mian leat an t-imleabhar a chrapadh faoi. Tabhair faoi deara gurb é seo méid do shuiteála Omarchy amach anseo lena n-áirítear an deighilt tosaithe.

 ![dual-boot-3](images/dual-boot-3.webp)

Nuair atá tú críochnaithe, ba chóir duit rud éigin mar seo a fheiceáil áit a bhfuil an chuid 50GB mar a shuiteálfaimid Omarchy sa sampla seo.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy a Shuiteáil

Go héifeachtach is é próiseas suiteála Omarchy mar a chéile leis an ngnáthcheann. Tar éis duit do dhiosca a roghnú, tabharfar an rogha **Free space install** duit. Roghnaigh an rogha sin chun cosc a chur ar an diosca iomlán a ghlanadh.

 ![dual-boot-5](images/dual-boot-5.webp)

Deimhnigh go bhfuil cuma mhaith ar gach rud agus fan go gcríochnóidh an tsuiteáil mar is gnách. Seo é freisin an áit a bhféadfá rogha a dhéanamh suiteáil neamhchriptithe a dhéanamh (ní mholtar) díreach mar atá ar shuiteáil lántiománaithe.
 ![dual-boot-6](images/dual-boot-6.webp)

## Suiteálacha Eile a Chur leis an Luchtóir Tosaithe

Nuair a chríochnaíonn tú do shuiteáil Omarchy, tabharfaidh tú faoi deara gurb é an luchtóir tosaithe Limine an réamhshocrú anois. Leis seo, is féidir leat roghanna a chur le Limine freisin do do shuiteálacha eile cosúil le Windows.

Chun é sin a dhéanamh, rith `limine-scan` agus lean na leideanna chun cibé míreanna is mian leat a chur le do chumraíocht limine. Ansin nuair a thosaíonn tú, feicfidh tú do ghnáthro ghanna do Omarchy, chomh maith le Windows Boot Manager nó daoine eile.

## Bitlocker

Tá sé tábhachtach a thabhairt faoi deara nach bhfuil an modh suiteála seo comhoiriúnach le Bitlocker toisc go gcripteann sé an tiomáint ar fad, ní hamháin an dheighilt. Má thagann tú ar earráid ag rá go bhfuil Bitlocker cumasaithe, tosaigh isteach i Windows, téigh go **Settings -> Privacy & Security -> Device encryption** agus scoránaigh Bitlocker as. Féadfaidh sé roinnt ama a thógáil chun an tiomáint a dhíchriptiú.

 ![dual-boot-7](images/dual-boot-7.webp)
