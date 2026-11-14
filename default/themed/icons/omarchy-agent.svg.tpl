<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Agent</title>
  <desc>A terminal window seen from the front with a big spark where the work happens and a small one beside it, over a prompt, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="spark" d="M0 -100C9 -40 40 -9 100 0C40 9 9 40 0 100C-9 40 -40 9 -100 0C-40 -9 -9 -40 0 -100Z"/>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window, as the Terminal's; one hard shadow, as Hype's slides. -->
    <rect x="76" y="100" width="360" height="312" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="100" width="360" height="312" rx="20" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The prompt the agent answers. -->
    <path d="M118 340L146 362L118 384" fill="none" stroke="{{ icon_edge }}" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"/>
    <rect x="166" y="355" width="120" height="14" rx="7" fill="{{ icon_edge }}"/>
    <!-- The sparks. -->
    <use href="#spark" fill="{{ icon_shadow }}" transform="translate(236 230) scale(1.05) translate(0 8)"/>
    <use href="#spark" fill="url(#main)" transform="translate(236 230) scale(1.05)"/>
    <use href="#spark" fill="{{ icon_shadow }}" transform="translate(360 166) scale(.42) translate(0 16)"/>
    <use href="#spark" fill="{{ icon_mark }}" transform="translate(360 166) scale(.42)"/>
  </g>
</svg>
