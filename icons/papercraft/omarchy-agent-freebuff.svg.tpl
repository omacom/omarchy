<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Freebuff</title>
  <desc>Freebuff's mark in a terminal window, as Herdr's ram, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="logo" d="M5.414 1.5H18.586Q20.25 1.547 21.352 2.648Q22.453 3.75 22.5 5.414V18.586Q22.453 20.25 21.352 21.352Q20.25 22.453 18.586 22.5H5.414Q3.75 22.453 2.648 21.352Q1.547 20.25 1.5 18.586V5.414Q1.547 3.75 2.648 2.648Q3.75 1.547 5.414 1.5ZM6.844 17.156H9.422V9.422H17.156V6.844H6.844ZM10.195 17.156H12.773V12.75H15.328V10.172H10.195Z"/>
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
