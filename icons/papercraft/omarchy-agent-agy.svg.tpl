<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Antigravity</title>
  <desc>Antigravity's mark in a terminal window, as Herdr's ram, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="logo" d="M17.414 17.836Q16.523 16.523 15.844 15.305Q15.188 14.086 14.344 13.289Q13.477 12.492 12.07 12.469Q10.641 12.492 9.797 13.289Q8.953 14.086 8.297 15.305Q7.617 16.523 6.727 17.836Q5.836 19.148 4.312 20.227Q3.891 20.531 3.445 20.602Q3 20.672 2.695 20.531Q2.414 20.367 2.461 19.992Q2.508 19.617 3.094 19.031Q3.938 18.211 4.523 17.109Q5.133 16.008 5.602 14.719Q6.047 13.43 6.445 12.07Q6.82 10.711 7.195 9.398Q7.547 8.086 7.992 6.914Q8.414 5.766 8.977 4.875Q9.539 3.984 10.289 3.492Q11.039 2.977 12.07 2.977Q13.078 2.977 13.852 3.492Q14.602 3.984 15.164 4.875Q15.727 5.766 16.148 6.914Q16.57 8.086 16.945 9.398Q17.32 10.711 17.695 12.07Q18.07 13.43 18.539 14.719Q18.984 16.008 19.594 17.109Q20.203 18.211 21.023 19.031Q21.562 19.57 21.609 19.945Q21.656 20.32 21.375 20.484Q21.094 20.648 20.672 20.578Q20.25 20.531 19.828 20.227Q18.305 19.148 17.414 17.836Z"/>
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
