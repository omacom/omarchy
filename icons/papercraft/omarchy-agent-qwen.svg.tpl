<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Qwen Code</title>
  <desc>Qwen Code's mark in a terminal window, as Herdr's ram, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="logo" d="M22.43 14.719 21 17.203Q20.859 17.438 20.578 17.438H18L15.281 22.148Q15.141 22.383 14.859 22.406H12Q11.719 22.383 11.578 22.148L10.289 19.922H4.852Q4.57 19.922 4.43 19.664L3 17.203Q2.859 16.945 3 16.711L4.289 14.484L1.57 9.773Q1.43 9.516 1.57 9.281L3 6.797Q3.141 6.562 3.422 6.562H6L8.719 1.852Q8.859 1.617 9.141 1.594H12Q12.281 1.617 12.422 1.852L13.711 4.078H19.148Q19.43 4.078 19.57 4.336L21 6.797Q21.141 7.055 21 7.289L19.711 9.516L22.43 14.227Q22.57 14.484 22.43 14.719ZM6.422 6.797 7.992 9.516H19.148L20.578 7.055H9.141L10.57 4.57L9.141 2.109ZM11.859 16.711Q9.07 11.883 6.281 7.055H3.422L9.141 16.945H6.281L4.852 19.43H10.289ZM22.008 14.484 19.289 9.773H16.148Q13.359 14.602 10.57 19.43L12 21.891L17.719 12L19.148 14.484Z"/>
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
