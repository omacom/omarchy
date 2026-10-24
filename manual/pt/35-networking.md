# Rede

A rede no Omarchy é gerida pelo NetworkManager, e controla-a a partir do ícone de rede na [barra superior](05-the-top-bar.md) ou com `Super + Ctrl + W`.

Esse painel procura redes Wi-Fi, mostra a intensidade do sinal e faz a ligação. A Ethernet não precisa de nada — basta ligar o cabo e funciona. Se preferir ficar no terminal, o `nmtui` dá-lhe os mesmos controlos, e há também um grupo de comandos `omarchy network`.

## Partilhar o Wi-Fi

Em vez de ler uma palavra-passe longa em voz alta, execute _Configurar > Rede > Código QR_ enquanto estiver ligado por Wi-Fi. Isso coloca um código QR no ecrã que qualquer câmara de telemóvel pode ler para entrar na rede. É uma daquelas coisas que vai usar mais do que espera, assim que souber que está ali.

Se precisar mesmo da palavra-passe em si, `omarchy network password <interface>` imprime-a.

## DNS

O Omarchy usa o DNS que a sua rede distribuir por DHCP. Pode substituí-lo para toda a máquina em _Configurar > Rede > DNS_, onde a Cloudflare e a Google estão a um clique de distância. Escolha _Personalizado_ para escrever os seus próprios servidores.

A partir do terminal, `omarchy dns` imprime o fornecedor atual e `omarchy dns Cloudflare` define um.

## Fixar a banda Wi-Fi

Se o seu router colocar 2.4GHz, 5GHz e 6GHz no mesmo nome de rede, o seu portátil por vezes agarra-se à banda lenta. `omarchy network band` mostra em que banda está, e `omarchy network band 5` fixa-a. Use `auto` para deixar voltar a escolher.

Isto fixa a banda e não um ponto de acesso específico, por isso continua a circular normalmente entre pontos de acesso.

## Quão rápido é?

_Acionar > Teste de velocidade > Velocidade da rede_ mede a sua velocidade real de receção e envio com um par de mostradores. A partir do terminal, é `omarchy network speedtest down` ou `up`. (Há um teste de velocidade do disco ao lado nesse menu, se estiver a avaliar o outro estrangulamento.)

## A firewall

A firewall está ligada por predefinição e bloqueia todo o tráfego de entrada, com uma exceção: a porta 53317, para o [LocalSend](22-guis.md) funcionar logo à partida.

O SSH está desligado até o ligar com _Configurar > Segurança > SSHD_, que arranca o daemon, abre a porta 22 com limitação de ritmo contra força bruta e autoriza uma chave. O Docker também está restringido, para os contentores não se poderem expor acidentalmente ao mundo. Veja [segurança](48-security.md) para a história completa.

## Tailscale

O [Tailscale](https://tailscale.com/) é uma VPN em malha que torna simples e seguro aceder a todos os seus computadores e servidores através da Internet. Instale-o com _Instalar > Serviço > Tailscale_.

Isso dá-lhe um painel Tailscale na barra, que liga e desliga a tailnet, muda de conta e escolhe um nó de saída — as suas próprias máquinas e as regiões Mullvad aparecem ambas na lista. Também navega pelas suas máquinas, e é aí que vive o Taildrop: selecione uma máquina e prima `s` para lhe enviar ficheiros, ou `c`, `n` e `d` para copiar o seu IP, nome ou nome DNS completo. O equivalente no terminal é `omarchy tailscale send <machine> [file...]`, e os ficheiros que lhe enviarem caem automaticamente em `~/Downloads`. A notificação que anuncia uma chegada espera até clicar para a abrir ou dispensar, por isso um ficheiro que apareça enquanto está longe da máquina continua lá à sua espera quando voltar.

A instalação também adiciona uma app web para a consola de administração do Tailscale.

## Quando deixar de funcionar

Antes de reiniciar, tente reiniciar apenas a peça problemática. _Atualizar > Hardware_ tem Wi-Fi, Bluetooth, Áudio e Painel tátil, e recarregar um deles resolve a maioria das situações do tipo «funcionava há cinco minutos». Veja [resolução de problemas](45-troubleshooting.md).
