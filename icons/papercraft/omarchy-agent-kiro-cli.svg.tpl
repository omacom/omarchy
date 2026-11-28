<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Kiro CLI</title>
  <desc>Kiro CLI's mark in a terminal window, as Herdr's ram, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="logo" d="M6.562 17.742Q5.438 18.141 4.781 18.023Q4.125 17.906 3.867 17.508Q3.609 17.086 3.633 16.547Q3.656 16.031 3.867 15.609Q4.148 15.07 4.359 14.719Q4.547 14.344 4.664 13.992Q4.898 13.383 4.992 12.914Q5.086 12.445 5.18 11.883Q5.32 10.711 5.438 9.586Q5.531 8.484 5.812 7.5Q6.539 4.664 8.484 3.234Q10.406 1.828 12.75 1.828Q15.094 1.828 17.062 3.234Q19.055 4.641 19.875 7.453Q20.016 7.875 20.18 9Q20.367 10.125 20.367 11.742Q20.367 13.336 19.945 15.234Q19.523 17.133 18.469 19.125Q17.953 20.016 17.109 20.789Q16.289 21.562 15.375 21.961Q14.461 22.336 13.688 22.078Q12.914 21.844 12.539 20.719Q11.25 21.727 9.938 22.031Q8.648 22.336 7.664 21.938Q6.68 21.539 6.375 20.438Q6.07 19.359 6.844 17.602ZM12.938 10.711Q13.922 10.664 13.969 9.094Q13.969 8.297 13.641 7.875Q13.383 7.5 12.914 7.5Q12.492 7.5 12.234 7.852Q11.953 8.273 11.953 9.094Q11.93 9.586 12.117 10.125Q12.305 10.664 12.914 10.711ZM17.414 9.094Q17.414 8.297 17.109 7.875Q16.828 7.5 16.383 7.5Q15.938 7.5 15.703 7.852Q15.422 8.273 15.422 9.094Q15.398 9.586 15.586 10.125Q15.773 10.664 16.383 10.711Q17.391 10.664 17.414 9.094Z"/>
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
