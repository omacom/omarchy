<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Cursor CLI</title>
  <desc>Cursor CLI's mark in a terminal window, as Herdr's ram, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="logo" d="M12.445 1.617 20.836 6.469Q21.188 6.68 21.211 7.102V16.898Q21.188 17.297 20.836 17.531L12.445 22.383Q12 22.617 11.555 22.383L3.164 17.531Q2.812 17.32 2.789 16.898V7.102Q2.812 6.68 3.164 6.469L11.555 1.617Q12 1.383 12.445 1.617ZM3.773 7.242 11.742 11.836Q12 12 12 12.305V21.492Q12.07 21.68 12.211 21.562L20.32 7.5Q20.391 7.336 20.32 7.195Q20.227 7.055 20.062 7.055H3.82Q3.656 7.102 3.773 7.242Z"/>
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
