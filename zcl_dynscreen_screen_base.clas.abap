CLASS zcl_dynscreen_screen_base DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_base CREATE PROTECTED.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF mty_s_position,
        x TYPE n LENGTH 3,
        y TYPE n LENGTH 3,
      END OF mty_s_position.
    DATA:
      mv_gentarget TYPE zcl_dynscreen_screen_base=>mty_srcname READ-ONLY.
    METHODS:
      constructor IMPORTING iv_text TYPE textpooltx OPTIONAL,
      display RETURNING VALUE(rv_subrc) TYPE sy-subrc
              RAISING   zcx_dynscreen_canceled
                        zcx_dynscreen_syntax_error,
      set_pretty_print IMPORTING iv_pretty_print TYPE abap_bool DEFAULT abap_true,
      get_pretty_print RETURNING VALUE(rv_pretty_print) TYPE abap_bool,
      serialize FINAL RETURNING VALUE(rv_xml) TYPE string.
    CLASS-METHODS:
      deserialize IMPORTING iv_xml        TYPE string
                  RETURNING VALUE(ro_scr) TYPE REF TO zcl_dynscreen_screen_base.
  PROTECTED SECTION.
    CONSTANTS:
      BEGIN OF mc_default_starting_pos,
        x TYPE n LENGTH 3 VALUE 50,
        y TYPE n LENGTH 3 VALUE 10,
      END OF mc_default_starting_pos.
    DATA:
      mv_is_subscreen      TYPE abap_bool,
      mv_is_window         TYPE abap_bool,
      ms_starting_position TYPE mty_s_position VALUE mc_default_starting_pos,
      ms_ending_position   TYPE mty_s_position.
    METHODS:
      set_subscreen IMPORTING !iv_is_subscreen TYPE abap_bool DEFAULT abap_true,
      set_window IMPORTING !iv_is_window TYPE abap_bool DEFAULT abap_true,
      generate_close REDEFINITION,
      generate_open REDEFINITION.
  PRIVATE SECTION.
    TYPES:
      mty_source_id TYPE n LENGTH 3.
    CLASS-DATA:
      mv_source_id TYPE mty_source_id.
    DATA:
      mv_pretty_print TYPE abap_bool,
      mt_gen_notice   LIKE mt_source.
    METHODS:
      get_generation_notice RETURNING VALUE(rt_src) LIKE mt_source,
      get_generation_target RETURNING VALUE(rv_srcname) TYPE mty_srcname.
ENDCLASS.



CLASS ZCL_DYNSCREEN_SCREEN_BASE IMPLEMENTATION.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( ).

* ---------------------------------------------------------------------
    set_text( iv_text ).
    mv_is_variable = abap_false.

* ---------------------------------------------------------------------
    IF get_text( ) IS INITIAL.
      set_text( 'Generated Screen' && ` ` && mv_id  ) ##NO_TEXT.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD deserialize.
* ---------------------------------------------------------------------
    CALL TRANSFORMATION id
    SOURCE XML iv_xml
    RESULT screen = ro_scr.

* ---------------------------------------------------------------------
    ro_scr->generate( ).

* ---------------------------------------------------------------------
    LOOP AT ro_scr->mt_variables ASSIGNING FIELD-SYMBOL(<ls_var>).
      IF <ls_var>-ref->mv_type IS NOT INITIAL.
        TRY.
            <ls_var>-ref->set_type( <ls_var>-ref->mv_type ).
          CATCH zcx_dynscreen_type_error.
        ENDTRY.
      ENDIF.
      IF <ls_var>-ref->mv_value IS NOT INITIAL.
        TRY.
            <ls_var>-ref->set_value( iv_conversion = <ls_var>-ref->mc_conv_xml
                                     iv_value_str  = <ls_var>-ref->mv_value    ).
          CATCH zcx_dynscreen_value_error.
        ENDTRY.
      ENDIF.
    ENDLOOP.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD display.
* ---------------------------------------------------------------------
    DATA:
      lt_source    LIKE mt_source,
      lt_old_texts LIKE mt_textpool,
      lv_position  TYPE string.

* ---------------------------------------------------------------------
    generate( ).
    generate_texts( ).

* ---------------------------------------------------------------------
    DATA(lo_callback) = NEW zcl_dynscreen_callback( ).
    lo_callback->set_caller( me ).

* ---------------------------------------------------------------------
    mv_gentarget = get_generation_target( ).

* ---------------------------------------------------------------------
    APPEND mc_syn-funcpool && ` ` && mv_gentarget && '.' TO lt_source.
    APPEND LINES OF get_generation_notice( ) TO lt_source.
    APPEND mc_syn-data && ` go_cb ` && mc_syn-type_ref && ` ` && mc_syn-callback && '.' TO lt_source.
    APPEND LINES OF mt_source TO lt_source.
    APPEND LINES OF generate_events( ) TO lt_source.

* ---------------------------------------------------------------------
    DATA(lv_formname) = 'DISPLAY_' && mv_id.
    APPEND '' TO lt_source.
    APPEND mc_syn-cline TO lt_source.
    APPEND `FORM ` && lv_formname && ` ` &&
           `USING io_cb ` && mc_syn-type_ref && ` ` && mc_syn-callback && '.' TO lt_source ##NO_TEXT.
    APPEND 'go_cb = io_cb.' TO lt_source ##NO_TEXT.
    IF mv_is_window = abap_true.
      lv_position = ` STARTING AT ` && ms_starting_position-x && ` ` && ms_starting_position-y.
      IF ms_ending_position IS NOT INITIAL.
        lv_position = lv_position && ` ENDING AT ` && ms_ending_position-x && ` ` && ms_ending_position-y.
      ENDIF.
    ENDIF.
    APPEND `CALL ` && mc_syn-selscreen && ` `  && mv_id && lv_position && `.` TO lt_source.
    APPEND LINES OF mt_source_ac TO lt_source.
    APPEND 'io_cb->set_subrc( sy-subrc ).' TO lt_source ##NO_TEXT.
    APPEND 'ENDFORM.' TO lt_source.

* ---------------------------------------------------------------------
    IF mv_pretty_print = abap_true.
      pretty_print( CHANGING ct_source = lt_source ).
    ENDIF.

* ---------------------------------------------------------------------
    INSERT REPORT mv_gentarget FROM lt_source.

* ---------------------------------------------------------------------
    READ TEXTPOOL mv_gentarget INTO lt_old_texts.
    IF lt_old_texts <> mt_textpool.
      INSERT TEXTPOOL mv_gentarget FROM mt_textpool.
    ENDIF.

* ---------------------------------------------------------------------
    DATA(lo_syncheck) = NEW cl_abap_syntax_check_norm( p_program = mv_gentarget ).
    IF lo_syncheck->subrc <> 0.
      DATA(lv_syntax_error) = CONV char200( lo_syncheck->message ).
      RAISE EXCEPTION TYPE zcx_dynscreen_syntax_error
        EXPORTING
          textid    = VALUE #( msgid = '00'
                               msgno = 1
                               attr1 = lv_syntax_error+000(50)
                               attr2 = lv_syntax_error+050(50)
                               attr3 = lv_syntax_error+100(50)
                               attr4 = lv_syntax_error+150(50) )
          syn_check = lo_syncheck.
    ENDIF.

* ---------------------------------------------------------------------
    PERFORM (lv_formname) IN PROGRAM (mv_gentarget) USING lo_callback.

* ---------------------------------------------------------------------
    IF lo_callback->get_subrc( ) <> 0.
      RAISE EXCEPTION TYPE zcx_dynscreen_canceled.
    ENDIF.

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
    rv_srcname = replace( val  = mc_gentarget_incname
                          sub  = '%%%'
                          with = mv_source_id         ).

* ---------------------------------------------------------------------
    " MV_SOURCE_ID is a static member var
    " everytime the DISPLAY method is called, another function group will be used
    " this is necessary to enable generating different screens in the same origin LUW
    " a side effect of this is that even if the same screen is used twice, the generation target will differ
    mv_source_id = mv_source_id + 1.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_pretty_print.
* ---------------------------------------------------------------------
    rv_pretty_print = mv_pretty_print.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD serialize.
* ---------------------------------------------------------------------
    CALL TRANSFORMATION id
    SOURCE screen = me RESULT XML rv_xml
    OPTIONS technical_types = 'ignore'.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_pretty_print.
* ---------------------------------------------------------------------
    mv_pretty_print = iv_pretty_print.

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
