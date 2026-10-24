# Rede

A rede no Omarchy é gerenciada pelo NetworkManager, e você a controla pelo ícone de rede na [barra superior](05-the-top-bar.md) ou com `Super + Ctrl + W`.

Esse painel procura redes Wi-Fi, mostra a intensidade do sinal e conecta. Ethernet não precisa de nada — é só plugar e funciona. Se você prefere ficar no terminal, o `nmtui` oferece os mesmos controles, e também há um grupo de comandos `omarchy network`.

## Compartilhando seu Wi-Fi

Em vez de ler uma senha longa em voz alta, execute _Configuração > Rede > Código QR_ enquanto estiver conectado ao Wi-Fi. Isso coloca na tela um código QR que qualquer câmera de celular pode escanear para entrar na rede. É uma daquelas coisas que você vai usar mais do que imagina depois que descobre que ela existe.

Se você realmente precisa da senha em si, `omarchy network password <interface>` a imprime.

## DNS

O Omarchy usa o DNS que a sua rede distribui via DHCP. Você pode substituir isso para a máquina inteira em _Configuração > Rede > DNS_, onde Cloudflare e Google estão a um clique de distância. Escolha _Personalizado_ para digitar seus próprios servidores.

No terminal, `omarchy dns` imprime o provedor atual e `omarchy dns Cloudflare` define um.

## Fixando a banda do Wi-Fi

Se o seu roteador coloca 2,4GHz, 5GHz e 6GHz com o mesmo nome de rede, seu notebook às vezes vai se agarrar à banda lenta. `omarchy network band` mostra em qual banda você está, e `omarchy network band 5` a fixa. Use `auto` para deixar ele escolher de novo.

Isso fixa a banda, e não um ponto de acesso específico, então você continua alternando entre APs normalmente.

## Quão rápido é?

_Acionar > Teste de velocidade > Teste de velocidade da rede_ mede sua velocidade real de download e upload com um par de medidores. No terminal, é `omarchy network speedtest down` ou `up`. (Há um teste de velocidade do disco logo ao lado nesse menu, caso você esteja avaliando o outro gargalo.)

## O firewall

O firewall vem ativado por padrão e bloqueia todo o tráfego de entrada, com uma exceção: a porta 53317, para que o [LocalSend](22-guis.md) funcione de imediato.

O SSH fica desligado até você ativá-lo em _Configuração > Segurança > SSHD_, que inicia o daemon, abre a porta 22 com limitação de taxa contra força bruta e autoriza uma chave. O Docker também fica restrito, para que os contêineres não se exponham acidentalmente para o mundo. Veja [segurança](48-security.md) para a história completa.

## Tailscale

O [Tailscale](https://tailscale.com/) é uma VPN em malha que torna simples e seguro acessar todos os seus computadores e servidores pela internet. Instale-o em _Instalar > Serviço > Tailscale_.

Isso coloca um painel do Tailscale na barra, que conecta e desconecta da tailnet, alterna contas e escolhe um nó de saída — suas próprias máquinas e as regiões da Mullvad aparecem na lista. Ele também navega pelas suas máquinas, e é lá que fica o Taildrop: selecione uma máquina e pressione `s` para enviar arquivos para ela, ou `c`, `n` e `d` para copiar seu IP, nome ou nome DNS completo. O equivalente no terminal é `omarchy tailscale send <machine> [file...]`, e os arquivos enviados para você caem automaticamente em `~/Downloads`. A notificação anunciando uma chegada espera até você clicar para abrir ou dispensá-la, então um arquivo que chega enquanto você está longe da máquina ainda está lá esperando quando você volta.

Instalá-lo também adiciona um aplicativo web para o console de administração do Tailscale.

## Quando para de funcionar

Antes de reiniciar, tente reiniciar só a peça problemática. _Atualizar > Hardware_ tem Wi-Fi, Bluetooth, Áudio e Trackpad, e recarregar um deles resolve a maioria das situações do tipo "funcionava há cinco minutos". Veja [solução de problemas](45-troubleshooting.md).
