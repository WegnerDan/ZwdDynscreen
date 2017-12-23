REPORT zwd_dynscreen_test1.

CLASS lcl_appl DEFINITION CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS process.
  PRIVATE SECTION.
    DATA mo_screen TYPE REF TO zcl_dynscreen_screen.
    DATA mo_btn TYPE REF TO zcl_dynscreen_button.
    METHODS handle_button_click FOR EVENT button_click OF zcl_dynscreen_button.
ENDCLASS.

NEW lcl_appl( )->process( ).


CLASS lcl_appl IMPLEMENTATION.

  METHOD process.
* ---------------------------------------------------------------------
    DATA:
      lo_pa_matnr1 TYPE REF TO zcl_dynscreen_parameter,
      lo_pa_matnr2 TYPE REF TO zcl_dynscreen_parameter,
      lo_so_vbeln  TYPE REF TO zcl_dynscreen_selectoption,
      lo_pa_ebeln  TYPE REF TO zcl_dynscreen_parameter,
      lv_text      TYPE textpooltx.

* ---------------------------------------------------------------------
    mo_screen = NEW #( ).
    mo_screen->set_text( 'Selection Screen Generation Test' ).

    lo_pa_matnr1 = NEW #( iv_type = 'MARA-MATNR' ).
    lo_pa_matnr1->set_value( 'DEFAULT' ).
    lo_pa_matnr2 = NEW #( iv_type = 'MARA-MATNR' ).
    lv_text = lo_pa_matnr1->get_text( ).
    lo_pa_matnr1->set_text( lv_text && ` ` && '1' ).
    lv_text = lo_pa_matnr2->get_text( ).
    lo_pa_matnr2->set_text( lv_text && ` ` && '2' ).

    mo_screen->add( lo_pa_matnr1 ).
    mo_screen->add( lo_pa_matnr2 ).
    mo_btn = NEW #( iv_text = 'Testbutton' ).
    SET HANDLER handle_button_click FOR mo_btn.

    mo_screen->add( mo_btn ).

    lo_so_vbeln = NEW #( iv_type = 'VBAK-VBELN' ).
    mo_screen->add( lo_so_vbeln ).


    lo_pa_ebeln = NEW #( iv_type = 'EKKO-EBELN' ).
    mo_screen->add( lo_pa_ebeln ).


    DO 1000 TIMES.
      IF mo_screen->display( ) <> zwd_dynscreen_basis=>mc_selection_ok.
        EXIT.
      ENDIF.
    ENDDO.

    DATA lv_matnr TYPE mara-matnr.
    lo_pa_matnr1->get_value( IMPORTING ev_value = lv_matnr ).
    DATA lr_vbeln TYPE RANGE OF vbak-vbeln.
    lo_so_vbeln->get_value( IMPORTING ev_value = lr_vbeln ).

  ENDMETHOD.

  METHOD handle_button_click.
    mo_btn->set_ucomm( mo_btn->mc_com-exit ).
    mo_screen->add( NEW zcl_dynscreen_parameter( iv_type = 'FLAG') ).
  ENDMETHOD.
ENDCLASS.
