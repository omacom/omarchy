# Windows VM

Omarchy inatoa njia rahisi ya kuendesha Windows kupitia Docker VM kwenye mashine za x86_64. Unaweza kuisakinisha kwa kutumia _Install > Windows_ kutoka kwenye menyu ya Omarchy (`Super + Space`).

Mashine yako inahitaji upepe wa KVM kwa hili, ambao mashine nyingi zinao — lakini wakati mwingine umezimwa kwenye BIOS, na kisakinishi kitakuambia ikiwa ndivyo ilivyo. Pia utahitaji nafasi ya diski: kiasi chochote unachoipa Windows, pamoja na takriban 10GB kwa ajili ya taswira yenyewe.

Kisakinishi kinauliza kiasi gani cha RAM, cores ngapi za CPU, na nafasi ngapi ya diski ya kutoa (64GB au zaidi ndio kiwango cha chini kinachofaa), kisha jina la mtumiaji na nenosiri la Windows. Viache wazi na utapata `docker` / `admin`. Upakuaji huchukua muda — dakika 10-15 ni kawaida — na unaweza kufuatilia maendeleo kwenye kivinjari katika `http://127.0.0.1:8006`. Kivinjari kinaomba jina la mtumiaji na nenosiri sawa kabla ya kufungua konsoli.

 ![windows-vm](images/windows-vm.webp)

## Kuitumia

Ikishasakinishwa, zindua _Windows_ kutoka kwenye kizindua programu. Hiyo huianzisha VM ikiwa bado haifanyi kazi na kukuunganisha kupitia RDP, skrini nzima. Ipe sekunde 15-30 kwenye uanzishaji baridi.

Kipindi cha RDP hubeba sauti, maikrofoni yako, na ubao wa kunakili ulioshirikiwa, kwa hivyo kunakili maandishi kati ya Linux na Windows hufanya kazi tu. Ubora wa picha hufuata dirisha lako, na Omarchy hupitisha upanuzi wa onyesho lako, kwa hivyo si fujo yenye ukungu kwenye skrini ya HiDPI.

Unapofunga dirisha la RDP, VM hujizima yenyewe kiotomatiki. Ikiwa ungependa kuiwacha ikiendelea kufanya kazi — tuseme una kitu kinachofanya kazi humo ndani — izindue kwa `omarchy windows vm launch --keep-alive` badala yake.

Vidhibiti vingine viko kwenye amri hiyohiyo:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Kushiriki faili

Saraka ya `~/Windows` katika saraka yako ya nyumbani hushirikiwa kiotomatiki na VM. Weka faili hapo ikiwa unataka zifikike na Windows. VM haina ufikiaji kwa sehemu yoyote nyingine ya mfumo wako wa faili, kwa hivyo uko salama dhidi ya chochote kibaya upande wa Windows. Diski yake pepe yenyewe inapatikana katika `~/.windows`.

Njia hizo zinazojulikana za nyumbani hubaki kwenye mifumo yao ya faili. Zinaweza pia kuwa symlinks kwa saraka unazomiliki, jambo ambalo ni muhimu wakati diski pepe iko kwenye hifadhi kubwa zaidi. Kisakinishi hupima nafasi iliyo wazi kwenye mfumo wa faili ambao kwa hakika una `~/.windows`, si lazima mfumo wa faili ulio na saraka yako ya nyumbani.

Weka njia za diski na zilizoshirikiwa kama saraka tofauti, zisizoingiliana. Uondoaji huifanya saraka ya diski kuwa tupu kwa makusudi lakini huhifadhi saraka iliyoshirikiwa. Mara moja kabla ya kufuta, Omarchy hufanya ukaguzi wa kuzuia wenye mipaka na hukataa kuondoa chochote ikiwa ukaguzi huo utaisha muda au hauwezi kuthibitisha kuwa miti miwili ni tofauti.

Kabla VM haijaanza, Omarchy hufungua na kubandika saraka hizo mbili, kisha huunganisha inodes halisi za saraka kwenye nanga za faragha za kila mtumiaji zilizo chini ya `/var/lib/omarchy/windows/mounts`. Docker huona tu nanga hizo zilizolindwa na root. Hii huhifadhi maeneo maalum ya diski huku ikizuia mchakato mwingine unaofanya kazi kama wewe kubadilisha njia iliyokaguliwa kabla ya kontena yenye upendeleo kuitumia. Saraka zilizopo za diski na zilizoshirikiwa huimarishwa hadi hali ya `0700` wakati wa uhamiaji ili akaunti nyingine za ndani zisiweze kuvinjari yaliyomo.

Milango ya VM imefungwa kwa localhost pekee, kwa hivyo hakuna chochote kwenye mtandao wako kinachoweza kufikia mashine ya Windows. Konsoli ya wavuti pia huhitaji jina la mtumiaji na nenosiri la Windows vilivyosanidiwa, na kuzuia akaunti nyingine ya ndani kuendesha VM kupitia mlango 8006.

## Vikomo na utoaji leseni

Hakuna upitishaji wa GPU katika usanidi huu, kwa hivyo haufai kwa michezo au uhariri wa video. Ni njia bora ya kuendesha Microsoft Office au chochote kingine ambacho lazima uwe nacho kabisa.

Toleo lililosakinishwa ni Windows 11 Pro, halijaamilishwa. Utahitaji ufunguo wako mwenyewe wa leseni ili kutumia vipengele vilivyofungwa.

Ikiwa kompyuta hii ilikuja na Windows, ufunguo wa OEM bado uko kwenye firmware hata baada ya kusakinisha Omarchy. Ichapishe kwa `omarchy windows key`. Ufunguo huo umefungwa kwa mashine hii — utaamilisha Windows iliyosakinishwa upya kwenye maunzi haya, lakini kwa kawaida hautaamilisha VM.

Unaweza kubadilisha ugawaji wa rasilimali baadaye kwa kuendesha `omarchy windows vm install` kwenye terminali, ambayo huandika upya usanidi wa VM kutoka kwa majibu yako. Faili ya compose yenyewe sasa iko katika `/var/lib/omarchy/windows/docker-compose.yml` na inamilikiwa na root — hiyo ni kwa makusudi, ili mchakato unaofanya kazi kama wewe usiweze kuiandika upya na kufanya uanzishaji wenye upendeleo kuunganisha diski yako yote kwenye kontena. Ikiwa unahitaji kuihariri mwenyewe (kwa mfano kuunganisha kifaa cha USB), ihariri kwa `sudo` na uone chaguo zote kwenye [mradi wa Dockur Windows](https://github.com/dockur/windows).

Ili kuiondoa kabisa, tumia _Remove > Windows_ kutoka kwenye menyu ya Omarchy. Hiyo hufuta diski ya VM katika `~/.windows` na kila kitu kilichosakinishwa ndani ya Windows, kwa hivyo nakili chochote unachohitaji kutoka kwenye VM kwanza. Folda yako iliyoshirikiwa ya `~/Windows` inaachwa kama ilivyo.
