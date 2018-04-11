CLASS zcl_dynscreen_callback DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS:
      process_pbo,
      set_caller IMPORTING io_caller TYPE REF TO zcl_dynscreen_base,
      set_value IMPORTING iv_id    TYPE zcl_dynscreen_base=>mty_id
                          iv_value TYPE any,
      get_value IMPORTING iv_id    TYPE zcl_dynscreen_base=>mty_id
                EXPORTING ev_value TYPE any,
      raise_uc_event IMPORTING iv_id    TYPE zcl_dynscreen_base=>mty_id
                               iv_value TYPE any OPTIONAL
                     CHANGING  cv_ucomm TYPE sy-ucomm,
      set_subrc IMPORTING iv_subrc TYPE sy-subrc,
      get_subrc RETURNING VALUE(rv_subrc) TYPE sy-subrc.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      mv_subrc  TYPE sy-subrc,
      mo_caller TYPE REF TO zcl_dynscreen_base.
ENDCLASS.



CLASS zcl_dynscreen_callback IMPLEMENTATION.


  METHOD get_subrc.
* ---------------------------------------------------------------------
    rv_subrc = mv_subrc.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_value.
* ---------------------------------------------------------------------
    READ TABLE mo_caller->mt_elements ASSIGNING FIELD-SYMBOL(<ls_elem>)
    WITH KEY id = iv_id BINARY SEARCH.
    IF <ls_elem> IS ASSIGNED.
      DATA(lo_io) = CAST zcl_dynscreen_io_element( <ls_elem>-ref ).
      lo_io->get_value( IMPORTING ev_value = ev_value ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD process_pbo.
* ---------------------------------------------------------------------
    LOOP AT SCREEN INTO DATA(ls_screen).
      IF ls_screen-group1 IS INITIAL.
        CONTINUE.
      ENDIF.
      READ TABLE mo_caller->mt_elements ASSIGNING FIELD-SYMBOL(<ls_elem>)
      WITH KEY id = mo_caller->base22_to_10( ls_screen-group1 ) BINARY SEARCH.
      IF sy-subrc = 0.
        DATA(lo_io) = CAST zcl_dynscreen_io_element( <ls_elem>-ref ).
        CASE lo_io->get_visible( ).
          WHEN abap_true.
            ls_screen-invisible = 0.
            ls_screen-active    = 1.
          WHEN abap_false.
            ls_screen-invisible = 1.
            ls_screen-active    = 0.
        ENDCASE.
        CASE lo_io->get_obligatory( ).
          WHEN abap_true.
            ls_screen-required = 1.
          WHEN abap_false.
            ls_screen-required = 0.
        ENDCASE.
        IF ls_screen-group3 = 'PAR'  " parameter
        OR ls_screen-group3 = 'PBU'  " button
        OR ls_screen-group3 = 'LOW'  " low field of select option
        OR ls_screen-group3 = 'HGH'. " high field of select option
          CASE lo_io->get_input( ).
            WHEN abap_true.
              ls_screen-input = 1.
            WHEN abap_false.
              ls_screen-input = 0.
          ENDCASE.
        ENDIF.
        MODIFY screen FROM ls_screen.
      ENDIF.
    ENDLOOP.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD raise_uc_event.
* ---------------------------------------------------------------------
    READ TABLE mo_caller->mt_elements ASSIGNING FIELD-SYMBOL(<ls_elem>)
    WITH KEY id = iv_id BINARY SEARCH.
    IF <ls_elem> IS ASSIGNED.
      TRY.
          DATA(lo_io) = CAST zcl_dynscreen_io_element( <ls_elem>-ref ).
          lo_io->set_value( iv_value ).
          lo_io->set_ucomm( cv_ucomm ).
          lo_io->raise_event( ).
          cv_ucomm = lo_io->get_ucomm( ).
        CATCH zcx_dynscreen_base.
      ENDTRY.
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
      TRY.
          DATA(lo_io) = CAST zcl_dynscreen_io_element( <ls_elem>-ref ).
          lo_io->set_value( iv_value ).
        CATCH zcx_dynscreen_base.
      ENDTRY.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
