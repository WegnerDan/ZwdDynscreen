CLASS zcl_dynscreen_screen_base DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_base CREATE PROTECTED.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF mty_position,
        x TYPE n LENGTH 3,
        y TYPE n LENGTH 3,
      END OF mty_position .
    METHODS:
      constructor IMPORTING !iv_text TYPE textpooltx OPTIONAL,
      display RETURNING VALUE(rv_subrc) TYPE sy-subrc,
      set_pretty_print IMPORTING iv_pretty_print TYPE abap_bool DEFAULT abap_true,
      get_pretty_print RETURNING VALUE(rv_pretty_print) TYPE abap_bool.
  PROTECTED SECTION.
    CONSTANTS:
      BEGIN OF mc_default_starting_pos,
        x TYPE n LENGTH 3 VALUE 50,
        y TYPE n LENGTH 3 VALUE 10,
      END OF mc_default_starting_pos.
    DATA:
      mv_is_subscreen      TYPE abap_bool,
      mv_is_window         TYPE abap_bool,
      ms_starting_position TYPE mty_position VALUE mc_default_starting_pos,
      ms_ending_position   TYPE mty_position.
    METHODS:
      set_subscreen IMPORTING !iv_is_subscreen TYPE abap_bool DEFAULT abap_true,
      set_window IMPORTING !iv_is_window TYPE abap_bool DEFAULT abap_true,
      generate_close REDEFINITION,
      generate_open REDEFINITION.
  PRIVATE SECTION.
    TYPES:
      mty_funcgroup_id TYPE n LENGTH 3.
    CLASS-DATA:
      mv_funcgroup_id TYPE mty_funcgroup_id.
    DATA:
      mv_pretty_print TYPE abap_bool,
      mt_gen_notice   LIKE mt_source.
    METHODS:
      get_generation_notice RETURNING VALUE(rt_src) LIKE mt_source,
      get_generation_target RETURNING VALUE(rs_incnames) TYPE mty_s_gentarget_incnames.
ENDCLASS.



CLASS zcl_dynscreen_screen_base IMPLEMENTATION.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( ).

* ---------------------------------------------------------------------
    set_text( iv_text ).
    mv_is_variable = abap_false.

* ---------------------------------------------------------------------
    IF get_text( ) IS INITIAL.
      set_text( 'Generated Screen' && ` ` && mv_id  ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD display.
* ---------------------------------------------------------------------
    DATA:
      lt_func_module_src LIKE mt_source,
      lt_top_incl_src    LIKE mt_source,
      lt_old_texts       LIKE mt_textpool,
      lv_subrc           TYPE sy-subrc,
      lv_position        TYPE string,
      lv_msg             TYPE string,  " for debugging
      lv_lin             TYPE i,       " for debugging
      lv_wrd             TYPE string.  " for debugging

* ---------------------------------------------------------------------
    generate( ).
    generate_texts( ).

* ---------------------------------------------------------------------
    APPEND LINES OF get_generation_notice( ) TO lt_top_incl_src.
    APPEND mc_syn-data && ` go_events TYPE REF TO zcl_dynscreen_events.` TO lt_top_incl_src.
    APPEND mc_syn-data && ` gv_subrc ` && mc_syn-type && ` sy-subrc.` TO lt_top_incl_src.
    APPEND LINES OF mt_source TO lt_top_incl_src.
    APPEND LINES OF generate_events( ) TO lt_top_incl_src.

* ---------------------------------------------------------------------
    APPEND LINES OF get_generation_notice( ) TO lt_func_module_src.

    IF mv_is_window IS NOT INITIAL.
      lv_position = ` STARTING AT ` && ms_starting_position-x && ` ` && ms_starting_position-y.
      IF ms_ending_position IS NOT INITIAL.
        lv_position = lv_position && ` ENDING AT ` && ms_ending_position-x && ` ` && ms_ending_position-y.
      ENDIF.
    ENDIF.
    APPEND 'go_events = io_events.' TO lt_func_module_src.
    APPEND `CALL SELECTION-SCREEN ` && mv_id && lv_position && `.` TO lt_func_module_src.
    APPEND `gv_subrc = sy-subrc.` TO lt_func_module_src.
    APPEND LINES OF mt_source_ac TO lt_func_module_src.
    APPEND LINES OF generate_value_transport( ) TO lt_func_module_src.

* ---------------------------------------------------------------------
    IF mv_pretty_print = abap_true.
      pretty_print( CHANGING ct_source = lt_func_module_src ).
      pretty_print( CHANGING ct_source = lt_top_incl_src ).
    ENDIF.

* ---------------------------------------------------------------------
    DATA(ls_gentarget_incnames) = get_generation_target( ).

* ---------------------------------------------------------------------
    INSERT REPORT ls_gentarget_incnames-func_inc FROM lt_func_module_src.
    INSERT REPORT ls_gentarget_incnames-top_inc  FROM lt_top_incl_src.

* ---------------------------------------------------------------------
    READ TEXTPOOL ls_gentarget_incnames-func_pool INTO lt_old_texts.
    IF lt_old_texts <> mt_textpool.
      INSERT TEXTPOOL ls_gentarget_incnames-func_pool FROM mt_textpool.
    ENDIF.

* ---------------------------------------------------------------------
    DATA(lo_syncheck) = NEW cl_abap_syntax_check_norm( p_program = ls_gentarget_incnames-func_pool ).
    IF lo_syncheck->subrc <> 0.
      rv_subrc = mc_selection_canceled.
      MESSAGE `syntax error: ` && lo_syncheck->message TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------
    CALL FUNCTION ls_gentarget_incnames-func_module
      EXPORTING
        io_value_transport = zcl_dynscreen_transport=>get_inst( )
        io_events          = zcl_dynscreen_events=>get_inst( ).

* ---------------------------------------------------------------------
    IF zcl_dynscreen_transport=>get_inst( )->get_subrc( ) = 0.
      rv_subrc = mc_selection_ok.
    ELSE.
      rv_subrc = mc_selection_canceled.
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------
    zcl_dynscreen_transport=>get_inst( )->set_values( mt_variables ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------
    APPEND mc_syn-selscreen && ` ` && mc_syn-end && ` ` && mc_syn-screen && ` ` && mv_id && '.' TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_open.
* ---------------------------------------------------------------------
    DATA:
      lv_screen_kind TYPE string.

* ---------------------------------------------------------------------
    lv_screen_kind = ''. " standard screen
    CASE abap_true.
      WHEN mv_is_subscreen.
        lv_screen_kind = mc_syn-subscreen.
      WHEN mv_is_window.
        lv_screen_kind = mc_syn-window.
    ENDCASE.

* ---------------------------------------------------------------------
    APPEND mc_syn-selscreen && ` ` && mc_syn-begin && ` ` && mc_syn-screen && ` ` && mv_id && ` ` && lv_screen_kind && '.' TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_subscreen.
* ---------------------------------------------------------------------
    IF iv_is_subscreen = abap_true.
      mv_is_window = abap_false.
    ENDIF.
    mv_is_subscreen = iv_is_subscreen.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_window.
* ---------------------------------------------------------------------
    IF iv_is_window = abap_true.
      mv_is_subscreen = abap_false.
    ENDIF.
    mv_is_window = iv_is_window.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_pretty_print.
* ---------------------------------------------------------------------
    mv_pretty_print = iv_pretty_print.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_pretty_print.
* ---------------------------------------------------------------------
    rv_pretty_print = mv_pretty_print.

* ---------------------------------------------------------------------
  ENDMETHOD.

  METHOD get_generation_notice.
* ---------------------------------------------------------------------
    IF mt_gen_notice IS INITIAL.
      APPEND mc_syn-cline TO mt_gen_notice.
      APPEND '* THIS IS A GENERATED PROGRAM!' TO mt_gen_notice.
      APPEND '*     changes are futile' TO mt_gen_notice.
      GET TIME.
      APPEND `*     last generation: ` && sy-datum && ` ` && sy-uzeit TO mt_gen_notice.
      APPEND mc_syn-cline TO mt_gen_notice.
    ENDIF.

* ---------------------------------------------------------------------
    rt_src = mt_gen_notice.

* ---------------------------------------------------------------------
  ENDMETHOD.

  METHOD get_generation_target.
* ---------------------------------------------------------------------
    CONSTANTS lc_repl TYPE c LENGTH 3 VALUE '%%%'.

* ---------------------------------------------------------------------
    rs_incnames-func_pool   = mc_gentarget_incnames-func_pool.
    rs_incnames-func_group  = mc_gentarget_incnames-func_group.
    rs_incnames-func_module = mc_gentarget_incnames-func_module.
    rs_incnames-top_inc     = mc_gentarget_incnames-top_inc.
    rs_incnames-func_inc    = mc_gentarget_incnames-func_inc.

* ---------------------------------------------------------------------
    REPLACE FIRST OCCURRENCE OF lc_repl IN rs_incnames-func_pool   WITH mv_funcgroup_id.
    REPLACE FIRST OCCURRENCE OF lc_repl IN rs_incnames-func_group  WITH mv_funcgroup_id.
    REPLACE FIRST OCCURRENCE OF lc_repl IN rs_incnames-func_module WITH mv_funcgroup_id.
    REPLACE FIRST OCCURRENCE OF lc_repl IN rs_incnames-top_inc     WITH mv_funcgroup_id.
    REPLACE FIRST OCCURRENCE OF lc_repl IN rs_incnames-func_inc    WITH mv_funcgroup_id.

* ---------------------------------------------------------------------
    mv_funcgroup_id = mv_funcgroup_id + 1.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
