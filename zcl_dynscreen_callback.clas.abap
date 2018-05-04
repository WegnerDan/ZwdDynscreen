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
      raise_request_event IMPORTING iv_id    TYPE zcl_dynscreen_base=>mty_id
                                    iv_vname TYPE zcl_dynscreen_base=>mty_varname
                                    iv_kind  TYPE i
                          CHANGING  cv_value TYPE any OPTIONAL,
      set_subrc IMPORTING iv_subrc TYPE sy-subrc,
      get_subrc RETURNING VALUE(rv_subrc) TYPE sy-subrc.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      mv_subrc  TYPE sy-subrc,
      mo_caller TYPE REF TO zcl_dynscreen_base.
    METHODS:
      read_elements IMPORTING io_ref            TYPE REF TO zcl_dynscreen_base
                              iv_id             TYPE zcl_dynscreen_base=>mty_id
                    RETURNING VALUE(rs_element) TYPE zcl_dynscreen_base=>mty_s_screen_element
                    RAISING   cx_sy_itab_line_not_found.
ENDCLASS.



CLASS zcl_dynscreen_callback IMPLEMENTATION.


  METHOD get_subrc.
* ---------------------------------------------------------------------
    rv_subrc = mv_subrc.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_value.
* ---------------------------------------------------------------------
    TRY.
        DATA(lo_io) = CAST zcl_dynscreen_io_element( read_elements( io_ref = mo_caller
                                                                    iv_id  = iv_id     )-ref ).
        lo_io->get_value( IMPORTING ev_value = ev_value ).
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD process_pbo.
* ---------------------------------------------------------------------
    LOOP AT SCREEN INTO DATA(ls_screen).
      IF ls_screen-group1 IS INITIAL.
        CONTINUE.
      ENDIF.
      TRY.
          DATA(lo_io) = CAST zcl_dynscreen_io_element(
                          read_elements( io_ref = mo_caller
                                         iv_id  = mo_caller->base22_to_10( ls_screen-group1 ) && '' )-ref ).
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
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDLOOP.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD raise_request_event.
* ---------------------------------------------------------------------
    DATA:
      lt_fieldvalues TYPE STANDARD TABLE OF rsselread WITH DEFAULT KEY,
      ld_value       TYPE REF TO data.
    FIELD-SYMBOLS:
      <lt>           TYPE INDEX TABLE,
      <ls>           TYPE any,
      <lv_src_field> TYPE any.

* ---------------------------------------------------------------------
    TRY.
        DATA(ls_elem) = read_elements( io_ref = mo_caller
                                       iv_id  = iv_id     ).
        TRY.
            DATA(lo_io) = CAST zcl_dynscreen_io_element( ls_elem-ref ).
            DATA(lo_req_eve) = CAST zif_dynscreen_request_event( ls_elem-ref ).
            CASE iv_kind.
              WHEN lo_req_eve->kind_help_request.
                lo_req_eve->raise_help_request( ).
              WHEN lo_req_eve->kind_value_request.
                DATA(lo_parent) = CAST zcl_dynscreen_screen_base( lo_io->get_parent( ) ).
                DATA(lv_var_name) = iv_vname.
                IF lv_var_name CP '*-LOW'.
                  lv_var_name = replace( val = lv_var_name sub = '-LOW' with = '' ).
                  lt_fieldvalues = VALUE #( ( name     = lv_var_name
                                              kind     = 'S'
                                              position = 'LOW'       ) ).
                ELSEIF lv_var_name CP '*-HIGH'.
                  lv_var_name = replace( val = lv_var_name sub = '-HIGH' with = '' ).
                  lt_fieldvalues = VALUE #( ( name     = lv_var_name
                                              kind     = 'S'
                                              position = 'HIGH'      ) ).
                ELSE.
                  lt_fieldvalues = VALUE #( ( name     = lv_var_name
                                              kind     = 'P'         ) ).
                ENDIF.
                IF sy-dynnr = lo_parent->get_id( ).
                  CALL FUNCTION 'RS_SELECTIONSCREEN_READ'
                    EXPORTING
                      program     = lo_parent->mv_gentarget
                      dynnr       = sy-dynnr
                    TABLES
                      fieldvalues = lt_fieldvalues.
                ELSE.
                  CALL FUNCTION 'RS_SELECTIONSCREEN_READ'
                    EXPORTING
                      program     = lo_parent->mv_gentarget
                    TABLES
                      fieldvalues = lt_fieldvalues.
                ENDIF.
                cv_value = lt_fieldvalues[ 1 ]-fieldvalue.
                GET REFERENCE OF cv_value INTO ld_value.
                lo_req_eve->set_req_field_ref( ld_value ).
                lo_req_eve->raise_value_request( ).
            ENDCASE.
          CATCH zcx_dynscreen_base.
        ENDTRY.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD raise_uc_event.
* ---------------------------------------------------------------------
    TRY.
        DATA(lo_io) = CAST zcl_dynscreen_io_element( read_elements( io_ref = mo_caller
                                                                    iv_id  = iv_id     )-ref ).
        lo_io->set_value( iv_value ).
        lo_io->set_ucomm( cv_ucomm ).
        DATA(lo_uc_event) = CAST zif_dynscreen_uc_event( lo_io ).
        lo_uc_event->raise( ).
        cv_ucomm = lo_io->get_ucomm( ).
      CATCH cx_sy_itab_line_not_found
            zcx_dynscreen_base.
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD read_elements.
* ---------------------------------------------------------------------
    READ TABLE io_ref->mt_elements INTO rs_element
    WITH KEY id = iv_id BINARY SEARCH.
    IF sy-subrc = 0.
      RETURN.
    ELSE.
      LOOP AT io_ref->mt_elements ASSIGNING FIELD-SYMBOL(<ls_elem>).
        TRY.
            rs_element = read_elements( io_ref = <ls_elem>-ref
                                        iv_id  = iv_id         ).
            RETURN.
          CATCH cx_sy_itab_line_not_found.
            CONTINUE.
        ENDTRY.
      ENDLOOP.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
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
    TRY.
        DATA(lo_io) = CAST zcl_dynscreen_io_element( read_elements( io_ref = mo_caller
                                                                    iv_id  = iv_id     )-ref ).
        lo_io->set_value( iv_value ).
      CATCH cx_sy_itab_line_not_found.
      CATCH zcx_dynscreen_base.
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
