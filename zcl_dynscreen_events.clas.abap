CLASS zcl_dynscreen_events DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF mty_s_event,
        id  TYPE zcl_dynscreen_base=>mty_id,
        ref TYPE REF TO zcl_dynscreen_io_element,
      END OF mty_s_event,
      mty_t_events TYPE SORTED TABLE OF mty_s_event WITH UNIQUE KEY id.
    CLASS-METHODS:
      get_inst IMPORTING iv_new_inst  TYPE abap_bool DEFAULT abap_false
               RETURNING VALUE(ro_me) TYPE REF TO zcl_dynscreen_events.
    METHODS:
      add IMPORTING io_ref TYPE REF TO zcl_dynscreen_io_element,
      raise IMPORTING iv_id           TYPE zcl_dynscreen_base=>mty_id
                      iv_ucomm        TYPE sy-ucomm OPTIONAL
                      iv_value        TYPE any OPTIONAL
            RETURNING VALUE(rv_ucomm) TYPE sy-ucomm.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      mo_me TYPE REF TO zcl_dynscreen_events.
    DATA:
      mt_events TYPE mty_t_events.
ENDCLASS.



CLASS zcl_dynscreen_events IMPLEMENTATION.


  METHOD add.
* ---------------------------------------------------------------------
    INSERT VALUE #( id  = io_ref->get_id( )
                    ref = io_ref            ) INTO TABLE mt_events.

* ---------------------------------------------------------------------
  ENDMETHOD.


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


  METHOD raise.
* ---------------------------------------------------------------------
    READ TABLE mt_events ASSIGNING FIELD-SYMBOL(<ls_event>) WITH KEY id = iv_id BINARY SEARCH.
    IF <ls_event> IS ASSIGNED.
      <ls_event>-ref->set_ucomm( iv_ucomm ).
      <ls_event>-ref->set_value( iv_value ).
      <ls_event>-ref->raise_event( ).
      rv_ucomm = <ls_event>-ref->get_ucomm( ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
