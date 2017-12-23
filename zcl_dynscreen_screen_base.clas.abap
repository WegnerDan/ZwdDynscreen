CLASS zcl_dynscreen_screen_base DEFINITION
  PUBLIC
  INHERITING FROM zcl_dynscreen_base
  CREATE PROTECTED .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF mty_position,
        x TYPE n LENGTH 3,
        y TYPE n LENGTH 3,
      END OF mty_position .

    METHODS constructor
      IMPORTING
        !iv_text TYPE textpooltx OPTIONAL .
    METHODS display
      RETURNING
        VALUE(rv_subrc) TYPE sy-subrc .
  PROTECTED SECTION.

    CONSTANTS:
      BEGIN OF mc_default_starting_pos,
        x TYPE n LENGTH 3 VALUE 50,
        y TYPE n LENGTH 3 VALUE 10,
      END OF mc_default_starting_pos.
    DATA mv_is_subscreen TYPE abap_bool .
    DATA mv_is_window TYPE abap_bool .
    DATA ms_starting_position TYPE mty_position VALUE mc_default_starting_pos.
    DATA ms_ending_position TYPE mty_position .

    METHODS set_subscreen
      IMPORTING
        !iv_is_subscreen TYPE abap_bool DEFAULT abap_true .
    METHODS set_window
      IMPORTING
        !iv_is_window TYPE abap_bool DEFAULT abap_true .

    METHODS generate_close
         REDEFINITION .
    METHODS generate_open
         REDEFINITION .
  PRIVATE SECTION.
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
*    APPEND `FUNCTION-POOL ` && mc_gentarget_incnames-func_pool && '.' TO lt_top_incl_src.
    APPEND mc_syn-data && ` go_events TYPE REF TO zcl_dynscreen_events.` TO lt_top_incl_src.
    APPEND mc_syn-data && ` gv_subrc ` && mc_syn-type && ` sy-subrc.` TO lt_top_incl_src.
*    APPEND `INCLUDE ` && mc_gentarget_incnames-scr_inc && '.' TO lt_top_incl_src.
    APPEND LINES OF mt_source TO lt_top_incl_src.

* ---------------------------------------------------------------------
    APPEND LINES OF generate_events( ) TO lt_top_incl_src.

* ---------------------------------------------------------------------
    APPEND mc_syn-cline TO lt_func_module_src.
    APPEND '* THIS IS A GENERATED PROGRAM!' TO lt_func_module_src.
    APPEND '*     changes are futile' TO lt_func_module_src.
    GET TIME.
    APPEND `*     last generation: ` && sy-datum && ` ` && sy-uzeit TO lt_func_module_src.
    APPEND mc_syn-cline TO lt_func_module_src.
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
    pretty_print( CHANGING ct_source = lt_func_module_src ).
    pretty_print( CHANGING ct_source = lt_top_incl_src ).

* ---------------------------------------------------------------------
    INSERT REPORT mc_gentarget_incnames-func_inc FROM lt_func_module_src.
    INSERT REPORT mc_gentarget_incnames-top_inc  FROM lt_top_incl_src.

* ---------------------------------------------------------------------
    READ TEXTPOOL mc_gentarget_incnames-func_pool INTO lt_old_texts.
    IF lt_old_texts <> mt_textpool.
      INSERT TEXTPOOL mc_gentarget_incnames-func_pool FROM mt_textpool.
    ENDIF.

* ---------------------------------------------------------------------
    DATA(lo_syncheck) = NEW cl_abap_syntax_check_norm( p_program = mc_gentarget_incnames-func_pool ).
    IF lo_syncheck->subrc <> 0.
      rv_subrc = mc_selection_canceled.
      MESSAGE `syntax error: ` && lo_syncheck->message TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------
    CALL FUNCTION mc_gentarget_incnames-func_module
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
ENDCLASS.
