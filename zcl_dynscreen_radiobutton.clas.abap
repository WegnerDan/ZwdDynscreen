CLASS zcl_dynscreen_radiobutton DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_io_element FINAL CREATE PUBLIC
GLOBAL FRIENDS zcl_dynscreen_radiobutton_grp.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_text TYPE textpooltx OPTIONAL
                  RAISING   zcx_dynscreen_type_error
                            zcx_dynscreen_incompatible
                            zcx_dynscreen_too_many_elems,
      add REDEFINITION,
      set_generic_type REDEFINITION,
      set_type REDEFINITION,
      set_value REDEFINITION.
  PROTECTED SECTION.
    METHODS:
      generate_open REDEFINITION,
      generate_close REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_radiobutton IMPLEMENTATION.

  METHOD add.
* ---------------------------------------------------------------------
    RAISE EXCEPTION TYPE zcx_dynscreen_incompatible
      EXPORTING
        parent_class       = me
        incompatible_class = io_screen_element.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( iv_type = 'ABAP_BOOL'
                        iv_text = iv_text    ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------
* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_open.
* ---------------------------------------------------------------------
    DATA:
      lv_default_value TYPE string.

* ---------------------------------------------------------------------
    IF mv_value IS NOT INITIAL.
      lv_default_value = ` ` && mc_syn-default && ` ` && mc_syn-sq && get_value( mc_conv_cast ) && mc_syn-sq.
    ENDIF.

* ---------------------------------------------------------------------
    DATA(lo_rb_grp) = CAST zcl_dynscreen_radiobutton_grp( get_parent( ) ).

* ---------------------------------------------------------------------
    IF lo_rb_grp->get_first_radiobutton( )->get_id( ) = mv_id.
      DATA(lv_usercommand) = mc_syn-ucomm && ` ` && mc_syn-ucm_prefix && lo_rb_grp->get_id( ).
    ELSE.
      lv_usercommand = ''.
    ENDIF.

* ---------------------------------------------------------------------
    APPEND
    mc_syn-param && ` ` && mc_syn-var_prefix && mv_id && ` ` && mc_syn-type && ` ` && mv_type && ` ` &&
    mc_syn-radiob && ` ` && lo_rb_grp->get_id( ) && lv_default_value && ` ` && lv_usercommand &&'.'
    TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_generic_type.
* ---------------------------------------------------------------------
    " not supported for radiobuttons
    RAISE EXCEPTION TYPE zcx_dynscreen_type_error
      EXPORTING
        textid       = zcx_dynscreen_type_error=>type_change_not_supported
        parent_class = me.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_type.
* ---------------------------------------------------------------------
    " not supported for radiobuttons
    RAISE EXCEPTION TYPE zcx_dynscreen_type_error
      EXPORTING
        textid       = zcx_dynscreen_type_error=>type_change_not_supported
        parent_class = me.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_value.
* ---------------------------------------------------------------------
    " only either iv_value or iv_value_str are allowed to be supplied
    " only abap_true and abap_false are allowed values
    IF  iv_value     IS SUPPLIED
    AND iv_value_str IS NOT SUPPLIED.
      IF  iv_value <> abap_true
      AND iv_value <> abap_false.
        RAISE EXCEPTION TYPE zcx_dynscreen_value_error
          EXPORTING
            textid       = zcx_dynscreen_value_error=>invalid_value
            value        = iv_value
            parent_class = me.
      ENDIF.
    ELSEIF iv_value     IS NOT SUPPLIED
    AND    iv_value_str IS SUPPLIED.
      IF iv_value_str <> abap_true
      OR iv_value_str <> abap_false.
        RAISE EXCEPTION TYPE zcx_dynscreen_value_error
          EXPORTING
            textid       = zcx_dynscreen_value_error=>invalid_value
            value        = iv_value_str
            parent_class = me.
      ENDIF.
    ELSE.
      RAISE EXCEPTION TYPE zcx_dynscreen_value_error
        EXPORTING
          textid = zcx_dynscreen_value_error=>no_value_provided.
    ENDIF.

* ---------------------------------------------------------------------
    super->set_value( iv_conversion = iv_conversion
                      iv_value      = iv_value
                      iv_value_str  = iv_value_str  ).

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
