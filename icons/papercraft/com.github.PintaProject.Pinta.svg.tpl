<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Pinta</title>
  <desc>A painting seen from the front: a pale canvas with a stroke of paint in the main color, two dabs of red and orange, and the brush that made the stroke in the highlight, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The canvas; one hard shadow, as Hype's slides. -->
    <rect x="72" y="112" width="368" height="288" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="72" y="112" width="368" height="288" rx="20" fill="{{ icon_paper }}"/>
    <!-- Dabs of paint. -->
    <circle cx="128" cy="168" r="22" fill="{{ icon_red }}"/>
    <circle cx="188" cy="168" r="22" fill="{{ icon_orange }}"/>
    <!-- The stroke, ending under the brush. -->
    <path d="M120 316C144 244 184 240 208 286C232 332 270 330 296 272" fill="none" stroke="url(#main)" stroke-width="40" stroke-linecap="round" stroke-linejoin="round"/>
    <!-- The brush: a ferrule, and a handle reaching past the canvas. -->
    <g transform="translate(0 8)" fill="none" stroke="{{ icon_shadow }}" stroke-width="30" stroke-linecap="round">
      <path d="M312 250L420 126"/>
    </g>
    <path d="M306 257L338 220" fill="none" stroke="{{ icon_ink }}" stroke-width="30"/>
    <path d="M338 220L420 126" fill="none" stroke="{{ icon_mark }}" stroke-width="30" stroke-linecap="round"/>
  </g>
</svg>
