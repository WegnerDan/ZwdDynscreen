CLASS zcl_dynscreen_radiobutton DEFINITION
  PUBLIC
  INHERITING FROM zcl_dynscreen_parameter
  FINAL
  CREATE PROTECTED

  GLOBAL FRIENDS zcl_dynscreen_radiobutton_grp .

  PUBLIC SECTION.

    METHODS set_generic_type
         REDEFINITION .
    METHODS set_type
         REDEFINITION .
    METHODS set_value
         REDEFINITION .
  PROTECTED SECTION.

    TYPES:
      mty_radiobutton_grp TYPE c LENGTH 4 .

    DATA mv_radiobutton_grp TYPE mty_radiobutton_grp .

    METHODS constructor
      IMPORTING
        !iv_radiobutton_grp TYPE mty_radiobutton_grp
        !iv_text            TYPE textpooltx OPTIONAL .

    METHODS generate_open
         REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DYNSCREEN_RADIOBUTTON IMPLEMENTATION.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( iv_type = 'ABAP_BOOL'
                        iv_text = iv_text     ).

* ---------------------------------------------------------------------
    mv_radiobutton_grp = iv_radiobutton_grp.

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
    mc_syn-param && ` ` && mc_syn-var_prefix && mv_id && ` ` && mc_syn-type && ` ` && mv_type && ` ` && mc_syn-radiob && ` ` && mv_radiobutton_grp && lv_default_value && '.'
    TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_generic_type.
* ---------------------------------------------------------------------
    " not supported for radiobuttons
    RETURN.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_type.
* ---------------------------------------------------------------------
    " not supported for radiobuttons
    RETURN.

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
        RETURN.
      ENDIF.
    ELSEIF iv_value     IS NOT SUPPLIED
    AND    iv_value_str IS SUPPLIED.
      IF iv_value_str <> abap_true
      OR iv_value_str <> abap_false.
        RETURN.
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------
    super->set_value( iv_conversion = iv_conversion
                      iv_value      = iv_value
                      iv_value_str  = iv_value_str  ).

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
