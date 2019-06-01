CLASS zcl_dynscreen_selectoption DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_io_element FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES:
      zif_dynscreen_request_event.
    METHODS:
      constructor IMPORTING io_parent TYPE REF TO zcl_dynscreen_screen_base
                            iv_type   TYPE typename
                            iv_text   TYPE textpooltx OPTIONAL
                  RAISING   zcx_dynscreen_type_error
                            zcx_dynscreen_incompatible
                            zcx_dynscreen_too_many_elems,
      get_value REDEFINITION,
      set_type REDEFINITION.
  PROTECTED SECTION.
    DATA:
      md_request_value TYPE REF TO data,
      mo_tabledescr    TYPE REF TO cl_abap_tabledescr.
    METHODS:
      generate_close REDEFINITION,
      generate_open REDEFINITION,
      get_var_name REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_selectoption IMPLEMENTATION.

  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( io_parent = io_parent
                        iv_type   = iv_type
                        iv_text   = iv_text   ).

* ---------------------------------------------------------------------
    set_type( iv_type ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_open.
* ---------------------------------------------------------------------
    DATA:
      lv_nr_of_handlers TYPE i,
      lt_selcrit        TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

* ---------------------------------------------------------------------
    APPEND mc_syn-data && ` ` && 'D' && mc_syn-var_prefix && mv_id && ` ` &&
           mc_syn-type && ` ` && mv_type && '.' TO mt_source.
    APPEND mc_syn-selopt && ` ` && mc_syn-var_prefix && mv_id && ` ` && 'FOR' && ` ` && 'D' &&
           mc_syn-var_prefix && mv_id && ` ` && mc_syn-modif && ` ` && base10_to_22( mv_id ) && '.' TO mt_source.

* ---------------------------------------------------------------------
    APPEND
    mc_syn-eve_selscreen_one && ` ` && mc_syn-var_prefix && mv_id && '.'
    TO ms_source_eve-t_selscreen_on.
    APPEND
    `go_cb->set_value( iv_id = '` && mv_id && `' iv_value = ` && get_var_name( ) && ` ).` ##NO_TEXT
    TO ms_source_eve-t_selscreen_on.

* ---------------------------------------------------------------------
    lt_selcrit = VALUE #( ( `LOW`  )
                          ( `HIGH` ) ).
    lv_nr_of_handlers = 0.
    SYSTEM-CALL EVENTS GET NUM_HANDLERS FOR zif_dynscreen_request_event~help_request
    OF INST me INTO lv_nr_of_handlers.               "#EC CI_SYSTEMCALL
    IF lv_nr_of_handlers > 0.
      LOOP AT lt_selcrit ASSIGNING FIELD-SYMBOL(<lv_selcrit>).
        APPEND
        mc_syn-eve_selscreen_ohr && ` ` && mc_syn-var_prefix && mv_id && '-' && <lv_selcrit> && '.'
        TO ms_source_eve-t_selscreen_ohr.
        APPEND
        `go_cb->raise_request_event( iv_id = '` && mv_id &&                             ##NO_TEXT
        ` iv_vname = '` && mc_syn-var_prefix && mv_id && '-' && <lv_selcrit> && '''' && ##NO_TEXT
        `' iv_kind = ` && zif_dynscreen_request_event=>kind_help_request && ` ).`       ##NO_TEXT
        TO ms_source_eve-t_selscreen_ohr.
      ENDLOOP.
    ENDIF.
    lv_nr_of_handlers = 0.
    SYSTEM-CALL EVENTS GET NUM_HANDLERS FOR zif_dynscreen_request_event~value_request
    OF INST me INTO lv_nr_of_handlers.               "#EC CI_SYSTEMCALL
    IF lv_nr_of_handlers > 0.
      LOOP AT lt_selcrit ASSIGNING <lv_selcrit>.
        APPEND
        mc_syn-eve_selscreen_ovr && ` ` && mc_syn-var_prefix && mv_id && '-' && <lv_selcrit> && '.'
        TO ms_source_eve-t_selscreen_ovr.
        APPEND
        `go_cb->raise_request_event( EXPORTING iv_id = '` && mv_id &&                   ##NO_TEXT
        `' iv_kind = ` && zif_dynscreen_request_event=>kind_value_request &&            ##NO_TEXT
        ` iv_vname = '` && mc_syn-var_prefix && mv_id && '-' && <lv_selcrit> && '''' && ##NO_TEXT
        ` CHANGING cv_value = ` && mc_syn-var_prefix && mv_id && '-' && <lv_selcrit> && ` ).` ##NO_TEXT
        TO ms_source_eve-t_selscreen_ovr.
      ENDLOOP.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_value.
* ---------------------------------------------------------------------
    IF iv_conversion = mc_conv_write.
      RAISE EXCEPTION TYPE zcx_dynscreen_value_error
        EXPORTING
          textid = zcx_dynscreen_value_error=>get_value_write_conv_selopt.
    ENDIF.

* ---------------------------------------------------------------------
    super->get_value( EXPORTING iv_conversion = iv_conversion
                      IMPORTING ev_value      = ev_value      ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_var_name.
* ---------------------------------------------------------------------
    rv_var_name = super->get_var_name( ) && mc_syn-itab_body.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_type.
* ---------------------------------------------------------------------
    DATA:
      lv_sign       TYPE c LENGTH 1,
      lv_option     TYPE c LENGTH 2,
      lo_datadescr  TYPE REF TO cl_abap_datadescr,
      lt_components TYPE cl_abap_structdescr=>component_table,
      lx_root       TYPE REF TO cx_root.
    FIELD-SYMBOLS:
      <lv> TYPE any.

* ---------------------------------------------------------------------
    super->set_type( iv_type  ).

* ---------------------------------------------------------------------
    ASSIGN md_value->* TO <lv>.
    IF cl_abap_elemdescr=>get_data_type_kind( <lv> ) = 'F'.
      RAISE EXCEPTION TYPE zcx_dynscreen_type_error
        EXPORTING
          textid = zcx_dynscreen_type_error=>float_selopt.
    ENDIF.

* ---------------------------------------------------------------------
    TRY.
        lo_datadescr ?= cl_abap_typedescr=>describe_by_data( lv_sign ).
        APPEND VALUE #( name = 'SIGN'
                        type = lo_datadescr ) TO lt_components.
        lo_datadescr ?= cl_abap_typedescr=>describe_by_data( lv_option ).
        APPEND VALUE #( name = 'OPTION'
                        type = lo_datadescr ) TO lt_components.
        APPEND VALUE #( name = 'LOW'
                        type = mo_elemdescr ) TO lt_components.
        APPEND VALUE #( name = 'HIGH'
                        type = mo_elemdescr ) TO lt_components.
        mo_tabledescr = cl_abap_tabledescr=>create( cl_abap_structdescr=>create( lt_components ) ).
        CREATE DATA md_value TYPE HANDLE mo_tabledescr.
      CATCH cx_root INTO lx_root.
        RAISE EXCEPTION TYPE zcx_dynscreen_type_error
          EXPORTING
            textid   = zcx_dynscreen_type_error=>type_error_with_prev
            previous = lx_root.
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD zif_dynscreen_request_event~set_req_field_ref.
* ---------------------------------------------------------------------
    zif_dynscreen_request_event~md_request_value = id_value.

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
