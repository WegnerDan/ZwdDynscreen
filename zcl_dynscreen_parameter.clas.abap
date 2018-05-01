CLASS zcl_dynscreen_parameter DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_io_element CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES:
      zif_dynscreen_request_event.
    METHODS:
      constructor IMPORTING iv_type         TYPE typename OPTIONAL
                            is_generic_type TYPE mty_s_generic_type_info OPTIONAL
                            iv_text         TYPE textpooltx OPTIONAL
                  RAISING   zcx_dynscreen_type_error.
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
      lv_default_value  TYPE string,
      lv_type           TYPE string,
      lv_nr_of_handlers TYPE i.

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
    lv_nr_of_handlers = 0.
    SYSTEM-CALL EVENTS GET NUM_HANDLERS FOR zif_dynscreen_request_event~help_request
    OF INST me INTO lv_nr_of_handlers.               "#EC CI_SYSTEMCALL
    IF lv_nr_of_handlers > 0.
      APPEND
      mc_syn-eve_selscreen_ohr && ` ` && mc_syn-var_prefix && mv_id && '.'
      TO ms_source_eve-t_selscreen_ohr.
      APPEND
      `go_cb->raise_request_event( iv_id = '` && mv_id &&                      ##NO_TEXT
      `' iv_kind = ` && zif_dynscreen_request_event~kind_help_request && ` ).` ##NO_TEXT
      TO ms_source_eve-t_selscreen_ohr.
    ENDIF.
    lv_nr_of_handlers = 0.
    SYSTEM-CALL EVENTS GET NUM_HANDLERS FOR zif_dynscreen_request_event~value_request
    OF INST me INTO lv_nr_of_handlers.               "#EC CI_SYSTEMCALL
    IF lv_nr_of_handlers > 0.
      APPEND
      mc_syn-eve_selscreen_ovr && ` ` && mc_syn-var_prefix && mv_id && '.'
      TO ms_source_eve-t_selscreen_ovr.
      APPEND
      `go_cb->raise_request_event( EXPORTING iv_id = '` && mv_id &&         ##NO_TEXT
      `' iv_kind = ` && zif_dynscreen_request_event~kind_value_request &&   ##NO_TEXT
      ` CHANGING cv_value = ` && mc_syn-var_prefix && mv_id && ` ).`        ##NO_TEXT
      TO ms_source_eve-t_selscreen_ovr.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD zif_dynscreen_request_event~raise_help_request.
* ---------------------------------------------------------------------
    RAISE EVENT zif_dynscreen_request_event~help_request.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD zif_dynscreen_request_event~raise_value_request.
* ---------------------------------------------------------------------
    RAISE EVENT zif_dynscreen_request_event~value_request.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
