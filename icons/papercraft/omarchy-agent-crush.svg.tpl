<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Crush</title>
  <desc>Crush's mark in a terminal window, as Herdr's ram, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="logo" d="M12.984 6.023V4.5H14.062V3.047H19.336V4.5H20.977V6.023H22.5V13.547H20.977V15.844H19.336V17.812H17.086V18.891H15.258V19.805H13.828V20.953H10.172V19.805H8.742V18.891H6.914V17.812H4.664V15.844H3.023V13.547H1.5V6.023H3.023V4.5H4.664V3.047H9.938V4.5H11.016V6.023ZM14.109 12.188H15.023V9.75H14.109ZM8.977 12.188H9.891V9.75H8.977ZM11.25 13.148H12.75V12.258H11.25Z"/>
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
