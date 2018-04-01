CLASS zcl_dynscreen_callback DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    METHODS:
      set_caller IMPORTING io_caller TYPE REF TO zcl_dynscreen_base,
      set_value IMPORTING iv_id    TYPE zcl_dynscreen_base=>mty_id
                          iv_value TYPE any,
      raise_event IMPORTING iv_id    TYPE zcl_dynscreen_base=>mty_id
                            iv_value TYPE any OPTIONAL
                  CHANGING  cv_ucomm TYPE sy-ucomm,
      set_subrc IMPORTING iv_subrc TYPE sy-subrc,
      get_subrc RETURNING VALUE(rv_subrc) TYPE sy-subrc.
    CLASS-METHODS:
      get_inst IMPORTING iv_new_inst  TYPE abap_bool DEFAULT abap_false
               RETURNING VALUE(ro_me) TYPE REF TO zcl_dynscreen_callback.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      mv_subrc  TYPE sy-subrc,
      mo_caller TYPE REF TO zcl_dynscreen_base.
    CLASS-DATA:
      mo_me TYPE REF TO zcl_dynscreen_callback.
ENDCLASS.



CLASS zcl_dynscreen_callback IMPLEMENTATION.


  METHOD get_inst.
* ---------------------------------------------------------------------
    IF iv_new_inst = abap_true.
      FREE mo_me.
    ENDIF.

* ---------------------------------------------------------------------
    IF mo_me IS NOT BOUND.
      mo_me = NEW #( ).
    ENDIF.

* ---------------------------------------------------------------------
    ro_me = mo_me.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_subrc.
* ---------------------------------------------------------------------
    rv_subrc = mv_subrc.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD raise_event.
* ---------------------------------------------------------------------
    READ TABLE mo_caller->mt_elements ASSIGNING FIELD-SYMBOL(<ls_elem>)
    WITH KEY id = iv_id BINARY SEARCH.
    IF <ls_elem> IS ASSIGNED.
      DATA(lo_io) = CAST zcl_dynscreen_io_element( <ls_elem>-ref ).
      lo_io->set_value( iv_value ).
      lo_io->set_ucomm( cv_ucomm ).
      lo_io->raise_event( ).
      cv_ucomm = lo_io->get_ucomm( ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_caller.
* ---------------------------------------------------------------------
    mo_caller = io_caller.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_subrc.
* ---------------------------------------------------------------------
    mv_subrc = iv_subrc.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_value.
* ---------------------------------------------------------------------
    READ TABLE mo_caller->mt_elements ASSIGNING FIELD-SYMBOL(<ls_elem>)
    WITH KEY id = iv_id BINARY SEARCH.
    IF <ls_elem> IS ASSIGNED.
      DATA(lo_io) = CAST zcl_dynscreen_io_element( <ls_elem>-ref ).
      lo_io->set_value( iv_value ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
