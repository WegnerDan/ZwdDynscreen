CLASS zcl_dynscreen_transport DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    INTERFACES:
      if_serializable_object.
    TYPES:
      BEGIN OF mty_s_transport,
        fname TYPE fieldname,
        value TYPE string,
      END OF mty_s_transport,
      mty_t_transport TYPE SORTED TABLE OF mty_s_transport WITH UNIQUE KEY fname.
    CLASS-METHODS:
      get_inst RETURNING VALUE(ro_inst) TYPE REF TO zcl_dynscreen_transport.
    METHODS:
      add_value IMPORTING !iv_fname TYPE fieldname
                          !iv_value TYPE any,
      set_values IMPORTING !it_variables TYPE zcl_dynscreen_base=>mty_variables_tt,
      set_subrc IMPORTING !iv_subrc TYPE sy-subrc,
      get_subrc RETURNING VALUE(rv_subrc) TYPE sy-subrc.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      mv_subrc  TYPE sy-subrc,
      mt_values TYPE mty_t_transport.
    CLASS-DATA:
      mo_me TYPE REF TO zcl_dynscreen_transport .
ENDCLASS.



CLASS zcl_dynscreen_transport IMPLEMENTATION.


  METHOD add_value.
* ---------------------------------------------------------------------
    READ TABLE mt_values ASSIGNING FIELD-SYMBOL(<ls_value>) WITH KEY fname = iv_fname.
    IF sy-subrc <> 0.
      INSERT VALUE #( fname = iv_fname ) INTO TABLE mt_values ASSIGNING <ls_value>.
    ENDIF.
    CALL TRANSFORMATION id SOURCE value = iv_value RESULT XML <ls_value>-value.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_inst.
* ---------------------------------------------------------------------
    IF mo_me IS NOT BOUND.
      mo_me = NEW #( ).
    ENDIF.
    ro_inst = mo_me.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_subrc.
* ---------------------------------------------------------------------
    rv_subrc = mv_subrc.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_subrc.
* ---------------------------------------------------------------------
    mv_subrc = iv_subrc.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_values.
* ---------------------------------------------------------------------
    LOOP AT it_variables ASSIGNING FIELD-SYMBOL(<ls_var>).
      READ TABLE mt_values ASSIGNING FIELD-SYMBOL(<ls_value>) WITH KEY fname = <ls_var>-name BINARY SEARCH.
      IF <ls_value> IS ASSIGNED.
        <ls_var>-ref->set_value( iv_conversion = zwd_dynscreen_io_element=>mc_conv_xml
                                 iv_value      = <ls_value>-value                      ).
      ENDIF.
    ENDLOOP.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
