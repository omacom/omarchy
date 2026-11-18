<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Ori</title>
  <desc>Ori's mark in a terminal window, as Herdr's ram, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="logo" d="M17.391 5.227Q19.125 5.25 20.273 6.398Q21.422 7.547 21.445 9.281Q21.422 10.992 20.273 12.141Q19.125 13.289 17.391 13.336L21.422 17.344Q21.797 17.766 21.609 18.234Q21.398 18.703 20.859 18.727H9.305Q7.875 18.727 6.656 18.211Q5.438 17.672 4.523 16.758Q3.586 15.82 3.07 14.602Q2.555 13.383 2.531 11.977Q2.555 10.57 3.07 9.352Q3.586 8.133 4.523 7.195Q5.438 6.281 6.656 5.742Q7.875 5.227 9.305 5.227ZM9.305 7.922Q7.57 7.969 6.422 9.117Q5.273 10.242 5.25 11.977Q5.273 13.688 6.422 14.836Q7.57 15.984 9.305 16.031Q11.016 15.984 12.164 14.836Q13.312 13.688 13.336 11.977Q13.312 10.242 12.164 9.117Q11.016 7.969 9.305 7.922Z"/>
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
