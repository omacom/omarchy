# Rede

A rede no Omarchy é gerenciada pelo NetworkManager, e você a controla pelo ícone de rede na [barra superior](05-the-top-bar.md) ou com `Super + Ctrl + N`.

Esse painel procura redes Wi-Fi, mostra a intensidade do sinal e conecta. Ethernet não precisa de nada — basta plugar e funciona. Se você preferir ficar no terminal, o `nmtui` oferece os mesmos controles, e também há um grupo de comandos `omarchy network`.

## Compartilhando seu Wi-Fi

Em vez de ler uma senha longa em voz alta, execute _Configuração > Rede > Código QR_ enquanto estiver conectado ao Wi-Fi. Isso coloca um código QR na tela que qualquer câmera de celular pode escanear para entrar na rede. É uma daquelas coisas que você vai usar mais do que imagina depois que souber que ela existe.

Se você realmente precisar da senha em si, `omarchy network password <interface>` a exibe.

## DNS

O Omarchy usa o DNS que a sua rede fornece via DHCP. Você pode substituir isso para toda a máquina em _Configuração > Rede > DNS_, onde Cloudflare e Google estão a um clique de distância. Escolha _Personalizado_ para digitar seus próprios servidores.

Pelo terminal, `omarchy dns` exibe o provedor atual e `omarchy dns Cloudflare` define um.

## Fixando a banda do Wi-Fi

Se o seu roteador coloca 2.4GHz, 5GHz e 6GHz no mesmo nome de rede, seu laptop às vezes vai insistir em ficar na banda lenta. `omarchy network band` mostra em qual banda você está, e `omarchy network band 5` fixa essa banda. Use `auto` para deixar que ele escolha novamente.

Isso fixa a banda, e não um ponto de acesso específico, então você continua alternando entre APs normalmente.

## Quão rápido é?

_Acionador > Teste de Velocidade > Teste de Velocidade de Rede_ mede sua velocidade real de download e upload com um par de mostradores. Pelo terminal, é `omarchy network speedtest down` ou `up`. Ele mede usando o próprio serviço do Omarchy e conta apenas suas transferências de teste. Outros downloads podem competir pela largura de banda, mas não são somados ao resultado do teste de velocidade. (Há um teste de velocidade de disco logo ao lado nesse menu, caso você esteja avaliando o outro gargalo.)

## O firewall

O firewall vem ativado por padrão e bloqueia todo o tráfego de entrada, com uma exceção: a porta 53317, para que o [LocalSend](22-guis.md) funcione imediatamente.

O SSH fica desligado até você ativá-lo em _Configuração > Segurança > SSHD_, o que inicia o daemon, abre a porta 22 com limitação de taxa contra ataques de força bruta e autoriza uma chave. O Docker também é restrito, para que os contêineres não possam se expor acidentalmente ao mundo. Veja [segurança](48-security.md) para saber de tudo.

## Tailscale

O [Tailscale](https://tailscale.com/) é uma VPN mesh que torna simples e seguro acessar todos os seus computadores e servidores pela internet. Instale-o em _Instalar > Serviço > Tailscale_.

Isso coloca um painel do Tailscale na barra, que conecta e desconecta da tailnet, alterna contas e escolhe um nó de saída — suas próprias máquinas e as regiões do Mullvad aparecem na lista. Ele também permite navegar pelas suas máquinas, e é aí que fica o Taildrop: selecione uma máquina e pressione `s` para enviar arquivos para ela, ou `c`, `n` e `d` para copiar seu IP, nome ou nome DNS completo. O equivalente no terminal é `omarchy tailscale send <machine> [file...]`, e os arquivos enviados para você vão parar automaticamente em `~/Downloads`. A notificação que anuncia uma chegada espera até você clicar nela para abrir ou dispensá-la, então um arquivo que chega enquanto você está longe da máquina ainda estará lá esperando quando você voltar.

A instalação também adiciona um aplicativo web para o console de administração do Tailscale.

## Quando para de funcionar

Antes de reiniciar a máquina, tente reiniciar sozinho apenas o componente problemático. _Atualizar > Hardware_ tem Wi-Fi, Bluetooth, Áudio e Trackpad, e recarregar um deles resolve a maioria das situações do tipo "funcionava há cinco minutos". Veja [solução de problemas](45-troubleshooting.md).
