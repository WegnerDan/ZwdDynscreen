CLASS zcl_dynscreen_selectoption DEFINITION
  PUBLIC
  INHERITING FROM zcl_dynscreen_io_element
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !iv_type TYPE typename
        !iv_text TYPE textpooltx OPTIONAL .

    METHODS get_value REDEFINITION .
    METHODS set_type REDEFINITION .
    METHODS raise_event REDEFINITION .
  PROTECTED SECTION.

    DATA mo_tabledescr TYPE REF TO cl_abap_tabledescr .

    METHODS generate_close
         REDEFINITION .
    METHODS generate_open
         REDEFINITION .
    METHODS get_var_name
         REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DYNSCREEN_SELECTOPTION IMPLEMENTATION.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( iv_type = iv_type
                        iv_text = iv_text ).

* ---------------------------------------------------------------------
    set_type( iv_type ).
*mo_elemdescr
*md_value

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_open.
* ---------------------------------------------------------------------
    APPEND mc_syn-data && ` ` && 'D' && mc_syn-var_prefix && mv_id && ` ` && mc_syn-type && ` ` && mv_type && '.' TO mt_source.
    APPEND mc_syn-selopt && ` ` && mc_syn-var_prefix && mv_id && ` ` && 'FOR' && ` ` && 'D' && mc_syn-var_prefix && mv_id && '.' TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_value.
* ---------------------------------------------------------------------
    DATA:
      lv_value TYPE c LENGTH 1000.
    FIELD-SYMBOLS:
      <lv_value> TYPE any.

* ---------------------------------------------------------------------
    ASSIGN md_value->* TO <lv_value>.
    IF <lv_value> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------
    IF mv_value IS NOT INITIAL.
      TRY.
          CALL TRANSFORMATION id SOURCE XML mv_value RESULT value = <lv_value>.
        CATCH cx_root.
          FREE: <lv_value>, mv_value.
      ENDTRY.
    ENDIF.

* ---------------------------------------------------------------------
    CASE iv_conversion.

* ---------------------------------------------------------------------
      WHEN mc_conv_xml.
        IF ev_value IS SUPPLIED.
          ev_value = mv_value.
        ENDIF.
        rv_value = mv_value.

* ---------------------------------------------------------------------
      WHEN mc_conv_write.
*        WRITE <lv_value> TO lv_value.
*        IF ev_value IS SUPPLIED.
*          ev_value = lv_value.
*        ENDIF.
*        rv_value = lv_value.

* ---------------------------------------------------------------------
      WHEN mc_conv_cast.
        IF ev_value IS SUPPLIED.
          ev_value = <lv_value>.
        ENDIF.
        FREE rv_value.

* ---------------------------------------------------------------------
      WHEN OTHERS.
        RETURN.
    ENDCASE.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_var_name.
* ---------------------------------------------------------------------
    rv_var_name = super->get_var_name( ) && '[]'.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD raise_event.
  ENDMETHOD.


  METHOD set_type.
* ---------------------------------------------------------------------
    DATA:
      lo_datadescr  TYPE REF TO cl_abap_datadescr,
      lt_components TYPE cl_abap_structdescr=>component_table.

* ---------------------------------------------------------------------
    super->set_type( iv_type  ).

* ---------------------------------------------------------------------
    TRY .
        lo_datadescr ?= cl_abap_typedescr=>describe_by_name( 'CHAR1' ).
        APPEND VALUE #( name = 'SIGN'
                        type = lo_datadescr ) TO lt_components.
        lo_datadescr ?= cl_abap_typedescr=>describe_by_name( 'CHAR2' ).
        APPEND VALUE #( name = 'OPTION'
                        type = lo_datadescr ) TO lt_components.
        APPEND VALUE #( name = 'LOW'
                        type = mo_elemdescr ) TO lt_components.
        APPEND VALUE #( name = 'HIGH'
                        type = mo_elemdescr ) TO lt_components.
        mo_tabledescr = cl_abap_tabledescr=>create( cl_abap_structdescr=>create( lt_components ) ).
        CREATE DATA md_value TYPE HANDLE mo_tabledescr.
      CATCH cx_root.
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
