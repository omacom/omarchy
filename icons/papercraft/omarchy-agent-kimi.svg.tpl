<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Kimi</title>
  <desc>Kimi's mark in a terminal window, as Herdr's ram, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="logo" d="M19.172 2.391Q18.609 2.93 18.586 3.773V5.484Q18.609 5.695 18.82 5.719H20.555Q21.375 5.695 21.938 5.156Q22.477 4.594 22.5 3.773Q22.477 2.93 21.938 2.391Q21.375 1.828 20.555 1.805Q19.711 1.828 19.172 2.391ZM9.75 13.594 15.469 17.742Q16.406 18.375 17.531 18.562Q17.695 18.586 17.695 18.797V21.914Q17.672 22.148 17.508 22.148Q15.586 21.914 13.992 20.836L7.383 15.984Q7.266 15.914 7.172 16.008L4.711 18.469Q4.641 18.539 4.641 18.633V21.961Q4.617 22.172 4.43 22.195H1.688Q1.523 22.172 1.5 21.961V5.719Q1.523 5.484 1.688 5.461H4.43Q4.617 5.484 4.641 5.719V13.242Q4.688 13.57 4.945 13.43L12.891 5.531Q12.984 5.461 13.031 5.461H16.992Q17.133 5.484 17.18 5.625Q17.227 5.766 17.133 5.883L9.727 13.219Q9.586 13.43 9.75 13.594Z"/>
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
