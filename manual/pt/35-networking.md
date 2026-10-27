# Rede

A rede no Omarchy é gerida pelo NetworkManager, e controla-a a partir do ícone de rede na [barra superior](05-the-top-bar.md) ou com `Super + Ctrl + N`.

Esse painel procura redes Wi-Fi, mostra a força do sinal e faz a ligação. A Ethernet não precisa de nada de todo — é só ligar o cabo e funciona. Se preferir ficar no terminal, o `nmtui` dá-lhe os mesmos controlos, e também existe um grupo de comandos `omarchy network`.

## Partilhar o seu Wi-Fi

Em vez de ler uma palavra-passe longa em voz alta, execute _Setup > Network > QR Code_ enquanto estiver ligado ao Wi-Fi. Isso coloca um código QR no ecrã que qualquer câmara de telemóvel pode ler para entrar na rede. É uma daquelas coisas que vai usar mais do que esperaria assim que souber que está lá.

Se precisar mesmo da palavra-passe em si, `omarchy network password <interface>` mostra-a.

## DNS

O Omarchy usa o DNS que a sua rede lhe entregar por DHCP. Pode substituir isso para toda a máquina em _Setup > Network > DNS_, onde Cloudflare e Google estão a um clique de distância. Escolha _Custom_ para introduzir os seus próprios servidores.

A partir do terminal, `omarchy dns` mostra o fornecedor atual e `omarchy dns Cloudflare` define um.

## Fixar a banda do Wi-Fi

Se o seu router colocar 2.4GHz, 5GHz e 6GHz no mesmo nome de rede, o seu portátil vai por vezes agarrar-se à banda lenta. `omarchy network band` mostra em que banda está, e `omarchy network band 5` fixa-a. Use `auto` para o deixar escolher outra vez.

Isto fixa a banda e não um ponto de acesso específico, por isso continua a fazer roaming entre APs normalmente.

## Quão rápida é?

_Trigger > Speed Test > Network Speed Test_ mede a sua velocidade real de envio e receção com um par de mostradores. A partir do terminal, é `omarchy network speedtest down` ou `up`. Mede contra o próprio serviço do Omarchy e conta apenas as suas transferências de teste. Outros downloads podem competir pela largura de banda, mas não são adicionados ao resultado do teste de velocidade. (Há um teste de velocidade do disco ao lado nesse menu, se estiver a avaliar o outro estrangulamento.)

## A firewall

A firewall está ativada por omissão e bloqueia todo o tráfego de entrada, com uma exceção: a porta 53317, para que o [LocalSend](22-guis.md) funcione logo de início.

O SSH está desligado até o ativar com _Setup > Security > SSHD_, o que inicia o daemon, abre a porta 22 com limite de ritmo contra ataques de força bruta e autoriza uma chave. O Docker também está restringido, para que os contentores não se possam expor acidentalmente ao mundo. Veja [segurança](48-security.md) para a história completa.

## Tailscale

O [Tailscale](https://tailscale.com/) é uma VPN mesh que torna simples e seguro chegar a todos os seus computadores e servidores através da internet. Instale-o com _Install > Service > Tailscale_.

Isso dá-lhe um painel Tailscale na barra, que liga e desliga a tailnet, muda de conta e escolhe um nó de saída — tanto as suas próprias máquinas como as regiões Mullvad aparecem na lista. Também permite navegar pelas suas máquinas, e é aí que vive o Taildrop: selecione uma máquina e prima `s` para lhe enviar ficheiros, ou `c`, `n` e `d` para copiar o seu IP, nome ou nome DNS completo. O equivalente no terminal é `omarchy tailscale send <machine> [file...]`, e os ficheiros que lhe forem enviados vão parar automaticamente a `~/Downloads`. A notificação que anuncia uma chegada espera até clicar nela para a abrir ou a dispensar, por isso um ficheiro que apareça enquanto estiver longe da máquina continua lá à espera de resposta quando voltar.

A instalação também adiciona uma aplicação web para a consola de administração do Tailscale.

## Quando deixa de funcionar

Antes de reiniciar, tente reiniciar sozinha a peça problemática. _Update > Hardware_ tem Wi-Fi, Bluetooth, Audio e Trackpad, e recarregar um desses resolve a maior parte das situações de "funcionava há cinco minutos". Veja [resolução de problemas](45-troubleshooting.md).
