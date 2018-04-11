CLASS zcl_dynscreen_parameter DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_io_element CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_type         TYPE typename OPTIONAL
                            is_generic_type TYPE mty_s_generic_type_info OPTIONAL
                            iv_text         TYPE textpooltx OPTIONAL
                  RAISING   zcx_dynscreen_type_error,
      raise_event REDEFINITION.
  PROTECTED SECTION.
    METHODS:
      generate_close REDEFINITION,
      generate_open REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_parameter IMPLEMENTATION.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( iv_type         = iv_type
                        is_generic_type = is_generic_type
                        iv_text         = iv_text         ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_open.
* ---------------------------------------------------------------------
    DATA:
      lv_default_value TYPE string,
      lv_type          TYPE string.

* ---------------------------------------------------------------------
    IF mv_type = mc_type_generic.
      lv_type = mv_generic_type_string.
    ELSE.
      lv_type = mv_type.
    ENDIF.

* ---------------------------------------------------------------------
    IF mv_value IS NOT INITIAL.
      lv_default_value = ` ` && mc_syn-default && ` ` && mc_syn-sq && get_value( mc_conv_cast ) && mc_syn-sq.
    ENDIF.

* ---------------------------------------------------------------------
    APPEND
    mc_syn-param && ` ` && mc_syn-var_prefix && mv_id && ` ` && mc_syn-type && ` ` && lv_type &&
    lv_default_value && ` ` && mc_syn-modif && ` ` && base10_to_22( mv_id ) && '.'
    TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD raise_event.
  ENDMETHOD.
ENDCLASS.
