# Windows VM

Omarchy inatoa njia rahisi ya kuendesha Windows kupitia VM ya Docker. Unaweza kuisakinisha kwa kutumia _Sakinisha > Windows_ kutoka menyu ya Omarchy (`Super + Space`).

Mashine yako inahitaji uwazi wa KVM kwa hili, ambayo nyingine nyingi zinao — lakini wakati mwingine imezimwa katika BIOS, na kisakinishi kitakuambia kama ndivyo ilivyo. Utahitaji pia nafasi ya diski: chochote unachoipa Windows, pamoja na takriban 10GB kwa picha yenyewe.

Kisakinishi huuliza RAM kiasi gani, chembe ngapi za CPU, na diski kiasi gani cha kukabidhi (64GB au zaidi ndicho kiwango cha chini chenye maana), kisha jina la mtumiaji na nenosiri la Windows. Acha hizo tupu na unapata `docker` / `admin`. Upakuaji unachukua muda — dakika 10-15 ni kawaida — na unaweza kufuata maendeleo katika kivinjari kwenye `http://127.0.0.1:8006`. Kivinjari huomba jina lile lile la mtumiaji na nenosiri kabla ya kufungua dashibodi.

 ![windows-vm](images/windows-vm.webp)

## Kuitumia

Mara inaposakinishwa, zindua _Windows_ kutoka kizinduzi cha programu. Hiyo huanzisha VM kama haifanyi kazi bado na kukuunganisha kupitia RDP, skrini nzima. Ipe sekunde 15-30 kwa kuanza baridi.

Kikao cha RDP hubeba sauti, maikrofoni yako, na ubao wa kunakili ulioshirikiwa, hivyo kunakili maandishi kati ya Linux na Windows hufanya kazi tu. Ubora hufuata dirisha lako, na Omarchy hupitisha upanuzi wako wa onyesho kupitia, hivyo si fujo isiyo wazi kwenye skrini ya HiDPI.

Unapofunga dirisha la RDP, VM huzimwa kiotomatiki. Kama ungependa kuiwacha ikifanya kazi — tuseme una kitu kinachofanya kazi humo — izindue kwa `omarchy windows vm launch --keep-alive` badala yake.

Vidhibiti vingine viko kwenye amri ile ile:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Kushiriki faili

Saraka ya `~/Windows` katika saraka yako ya nyumbani hushirikiwa kiotomatiki na VM. Weka faili hapo kama unataka ziweze kufikiwa na Windows. VM haina ufikiaji wa sehemu nyingine yoyote ya mfumo wako wa faili, hivyo uko salama kutokana na chochote kibaya upande wa Windows. Diski yake pepe inapatikana katika `~/.windows`.

Njia hizo za nyumbani zinazojulikana hubakia kwenye mifumo yao ya faili. Zinaweza pia kuwa viungo vya kiishara (symlinks) kwa saraka unazozimiliki, ambalo ni muhimu wakati diski pepe hukaa kwenye hifadhi kubwa zaidi. Kisakinishi hupima nafasi ya bure kwenye mfumo wa faili ambao kwa kweli una `~/.windows`, si lazima mfumo wa faili unaokuwa na saraka yako ya nyumbani.

Weka njia za diski na zilizoshirikiwa kama saraka tofauti, zisizoingiliana. Uondoaji humwaga saraka ya diski kimakusudi lakini huhifadhi saraka iliyoshirikiwa. Mara kabla ya kufuta, Omarchy hufanya ukaguzi wa ufungaji wenye mipaka na hukataa kuondoa kitu chochote kama ukaguzi huo utakawia au hauwezi kuthibitisha kwamba miti miwili imetengana.

Kabla VM kuanza, Omarchy hufungua na kubana saraka hizo mbili, kisha hupakia-kufunga (bind-mounts) inodi kamili za saraka kwenye nanga za faragha kwa kila mtumiaji zilizo chini ya `/var/lib/omarchy/windows/mounts`. Docker huona tu nanga hizo zilizolindwa na mzizi. Hii huhifadhi maeneo maalum ya diski huku ikizuia mchakato mwingine unaoendeshwa kama wewe kubadilishana njia iliyokaguliwa kabla kipachiko chenye marupurupu kukitumia. Saraka zilizopo za diski na zilizoshirikiwa hukazwa hadi hali ya `0700` wakati wa uhamaji ili akaunti nyingine za ndani ziweze kuvinjari yaliyomo.

Milango ya VM imefungwa kwa localhost tu, hivyo hakuna kitu kwenye mtandao wako kinachoweza kufikia mashine ya Windows. Dashibodi ya wavuti pia inahitaji jina la mtumiaji na nenosiri la Windows lililosanidiwa, kuzuia akaunti nyingine ya ndani kuendesha VM kupitia mlango 8006.

## Vikomo na leseni

Hakuna upitishaji wa GPU na usanidi huu, hivyo haufai kwa michezo au uhariri wa video. Ni njia bora ya kuendesha Microsoft Office au chochote kingine ambacho lazima kabisa uwe nacho.

Toleo lililosakinishwa ni Windows 11 Pro, halijawashwa leseni. Utahitaji ufunguo wako mwenyewe wa leseni kutumia vipengele vilivyowekewa lango.

Kama kompyuta hii ilikuja na Windows, ufunguo wa OEM bado uko katika firmware hata baada ya kusakinisha Omarchy. Ichapishe kwa `omarchy windows key`. Ufunguo huo umefungwa kwa mashine hii — utawasha Windows iliyosakinishwa upya kwenye vifaa hivi, lakini kwa kawaida hautawasha VM.

Unaweza kubadilisha mgao wa rasilimali baadaye kwa kuendesha tena `omarchy-windows-vm install`, ambayo huandika upya usanidi wa VM kutoka majibu yako. Faili ya compose yenyewe sasa hukaa katika `/var/lib/omarchy/windows/docker-compose.yml` na inamilikiwa na mzizi — hiyo ni kimakusudi, hivyo mchakato unaoendeshwa kama wewe hauwezi kuiandika upya na kufanya kuanzisha chenye marupurupu kupakia diski yako nzima kwenye kipachiko. Kama unahitaji kuihariri kwa mikono (kwa mfano kupakia kifaa cha USB), ihariri kwa `sudo` na uone chaguo zote kwenye [mradi wa Dockur Windows](https://github.com/dockur/windows).

Ili kuondoa yote, tumia _Ondoa > Windows_ kutoka menyu ya Omarchy. Hiyo hufuta diski ya VM na data yake yote, hivyo hakikisha chochote unachojali kimetoka katika `~/Windows` kwanza.
