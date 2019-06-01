CLASS zcl_dynscreen_checkbox DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_parameter FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES:
      zif_dynscreen_uc_event.
    METHODS:
      constructor IMPORTING io_parent TYPE REF TO zcl_dynscreen_screen_base
                            iv_text   TYPE textpooltx OPTIONAL
                  RAISING   zcx_dynscreen_incompatible
                            zcx_dynscreen_too_many_elems,
      set_type REDEFINITION,
      set_value REDEFINITION.
    EVENTS:
      checkbox_click EXPORTING VALUE(ev_value) TYPE abap_bool OPTIONAL.
  PROTECTED SECTION.
    METHODS:
      generate_open REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_checkbox IMPLEMENTATION.

  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( io_parent = io_parent
                        iv_type   = 'ABAP_BOOL'
                        iv_text   = iv_text     ).

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
    mc_syn-param && ` ` && mc_syn-var_prefix && mv_id && ` ` && mc_syn-type && ` ` && mv_type && ` ` &&
    mc_syn-chkbox && lv_default_value && ` ` && mc_syn-ucomm && ` ` &&
    mc_syn-ucm_prefix && mv_id && ` ` && mc_syn-modif && ` ` && base10_to_22( mv_id ) && '.'
    TO mt_source.

* ---------------------------------------------------------------------
    append_uc_event_src( ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_type.
* ---------------------------------------------------------------------
    RAISE EXCEPTION TYPE zcx_dynscreen_type_error
      EXPORTING
        textid       = zcx_dynscreen_type_error=>type_change_not_supported
        parent_class = me.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_value.
* ---------------------------------------------------------------------
    IF iv_conversion = zcl_dynscreen_io_element=>mc_conv_cast.
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
    ENDIF.

* ---------------------------------------------------------------------
    super->set_value( iv_conversion = iv_conversion
                      iv_value      = iv_value
                      iv_value_str  = iv_value_str  ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD zif_dynscreen_uc_event~raise.
* ---------------------------------------------------------------------
    FIELD-SYMBOLS:
      <lv_value> TYPE abap_bool.

* ---------------------------------------------------------------------
    ASSIGN md_value->* TO <lv_value>.
    RAISE EVENT checkbox_click EXPORTING ev_value = <lv_value>.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
