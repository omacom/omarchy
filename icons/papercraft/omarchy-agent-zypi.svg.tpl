<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>zycode</title>
  <desc>zycode's mark, a prompt and a cursor block, in a terminal window, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="prompt" d="M8.5 10.5L15.5 16L8.5 21.5" fill="none" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
    <rect id="cursor" x="18" y="19.2" width="7.5" height="3.6"/>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window; one hard shadow, as Hype's slides. -->
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <g transform="translate(256 256) scale(14) translate(-16.25 -16)">
      <use href="#prompt" stroke="{{ icon_shadow }}" transform="translate(0 0.5714)"/>
      <use href="#cursor" fill="{{ icon_shadow }}" transform="translate(0 0.5714)"/>
      <use href="#prompt" stroke="url(#main)"/>
      <use href="#cursor" fill="{{ icon_orange }}"/>
    </g>
  </g>
</svg>
