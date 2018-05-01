CLASS zcl_dynscreen_radiobutton DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_radiobutton_grp FINAL CREATE PUBLIC
GLOBAL FRIENDS zcl_dynscreen_radiobutton_grp.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_text TYPE textpooltx OPTIONAL
                  RAISING   zcx_dynscreen_type_error,
      set_generic_type REDEFINITION,
      set_type REDEFINITION,
      set_value REDEFINITION.
  PROTECTED SECTION.
    DATA:
      mv_from_constructor TYPE abap_bool.
    METHODS:
      generate_open REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_radiobutton IMPLEMENTATION.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( ).
    mv_from_constructor = abap_true.
    set_type( 'ABAP_BOOL' ).
    set_text( iv_text ).
    mv_from_constructor = abap_false.

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
    APPEND
    mc_syn-param && ` ` && mc_syn-var_prefix && mv_id && ` ` && mc_syn-type && ` ` && mv_type && ` `
    && mc_syn-radiob && ` ` && get_parent( )->get_id( ) && lv_default_value && '.'
    TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_generic_type.
* ---------------------------------------------------------------------
    IF mv_from_constructor = abap_true.
      super->set_generic_type( is_type_info ).
    ELSE.
      " not supported for radiobuttons
      RAISE EXCEPTION TYPE zcx_dynscreen_type_error.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_type.
* ---------------------------------------------------------------------
    IF mv_from_constructor = abap_true.
      super->set_type( iv_type ).
    ELSE.
      " not supported for radiobuttons
      RAISE EXCEPTION TYPE zcx_dynscreen_type_error.
    ENDIF.

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
        RAISE EXCEPTION TYPE zcx_dynscreen_value_error.
      ENDIF.
    ELSEIF iv_value     IS NOT SUPPLIED
    AND    iv_value_str IS SUPPLIED.
      IF iv_value_str <> abap_true
      OR iv_value_str <> abap_false.
        RAISE EXCEPTION TYPE zcx_dynscreen_value_error.
      ENDIF.
    ELSE.
      RAISE EXCEPTION TYPE zcx_dynscreen_value_error.
    ENDIF.

* ---------------------------------------------------------------------
    super->set_value( iv_conversion = iv_conversion
                      iv_value      = iv_value
                      iv_value_str  = iv_value_str  ).

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
