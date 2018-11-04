INTERFACE zif_dynscreen_line_item PUBLIC.
  TYPES:
    mty_pos TYPE n LENGTH 2,
    mty_len TYPE n LENGTH 2.
  CONSTANTS:
    mc_max_pos TYPE mty_pos VALUE 83,
    mc_max_len TYPE mty_len VALUE 83.
  DATA:
    mv_is_line_item TYPE abap_bool READ-ONLY,
    mv_pos          TYPE mty_pos READ-ONLY,
    mv_len          TYPE mty_len READ-ONLY.
  METHODS:
    set_line_pos IMPORTING iv_pos TYPE mty_pos
                 RAISING   zcx_dynscreen_line_space_error,
    set_line_len IMPORTING iv_len TYPE mty_len
                 RAISING   zcx_dynscreen_line_space_error.
ENDINTERFACE.
