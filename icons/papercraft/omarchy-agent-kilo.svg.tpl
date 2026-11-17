<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Kilo</title>
  <desc>Kilo's mark in a terminal window, as Herdr's ram, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="logo" d="M22.5 1.5V22.5H1.5V1.5ZM20.953 3.047H3.047V20.953H20.953ZM14.344 14.648H12.773V17.109L13.828 18.164H16.289V16.594H14.344ZM17.836 14.156 16.781 13.102H14.344V14.648H16.289V16.594H17.836ZM11.227 12.773H9.656V14.344H11.227ZM6.164 16.781 7.219 17.836H11.227V16.289H7.711V12.773H6.164ZM16.078 9.656V7.219L15.023 6.164H12.773V7.711H14.508V9.656H12.773V11.227H17.836V9.656ZM7.711 6.164H6.164V11.227H7.711V9.469H9.656V11.227H11.227V9.469L9.656 7.922H7.711ZM11.227 6.164H9.656V7.922H11.227Z"/>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window; one hard shadow, as Hype's slides. -->
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <g transform="translate(124 124) scale(11)">
      <use href="#logo" fill="{{ icon_shadow }}" transform="translate(0 0.7273)"/>
      <use href="#logo" fill="url(#main)"/>
    </g>
  </g>
</svg>
