REPORT zwd_dynscreen_test1.

CLASS lcl_appl DEFINITION CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS process.
  PRIVATE SECTION.
    METHODS handle_button_click FOR EVENT button_click OF zcl_dynscreen_button IMPORTING sender.
ENDCLASS.

NEW lcl_appl( )->process( ).


CLASS lcl_appl IMPLEMENTATION.

  METHOD process.
* ---------------------------------------------------------------------
    DATA:
      lo_screen    TYPE REF TO zcl_dynscreen_screen,
      lo_btn       TYPE REF TO zcl_dynscreen_button,
      lo_pa_matnr1 TYPE REF TO zcl_dynscreen_parameter,
      lo_pa_matnr2 TYPE REF TO zcl_dynscreen_parameter,
      lo_so_vbeln  TYPE REF TO zcl_dynscreen_selectoption,
      lo_pa_ebeln  TYPE REF TO zcl_dynscreen_parameter.

* ---------------------------------------------------------------------
    lo_screen = NEW #( ).
    lo_screen->set_pretty_print( ).
    lo_screen->set_text( 'Selection Screen Generation Test' ).

    lo_pa_matnr1 = NEW #( iv_type = 'MARA-MATNR' ).
    lo_pa_matnr1->set_value( 'DEFAULT' ).
    lo_pa_matnr2 = NEW #( iv_type = 'MARA-MATNR' ).
    lo_pa_matnr1->set_text( lo_pa_matnr1->get_text( ) && ` ` && '1' ).
    lo_pa_matnr2->set_text( lo_pa_matnr2->get_text( ) && ` ` && '2' ).

    lo_screen->add( lo_pa_matnr1 ).
    lo_screen->add( lo_pa_matnr2 ).
    lo_btn = NEW #( iv_text = 'Testbutton' iv_length = 20 ).
    SET HANDLER handle_button_click FOR lo_btn.

    lo_screen->add( lo_btn ).

    lo_so_vbeln = NEW #( iv_type = 'VBAK-VBELN' ).
    lo_screen->add( lo_so_vbeln ).


    lo_pa_ebeln = NEW #( iv_type = 'EKKO-EBELN' ).
    lo_screen->add( lo_pa_ebeln ).

    TRY.
        lo_screen->display( ).

* ---------------------------------------------------------------------
        " ev_value is "type any"
        DATA lv_matnr1 TYPE mara-matnr.
        lo_pa_matnr1->get_value( IMPORTING ev_value = lv_matnr1 ).

* ---------------------------------------------------------------------
        " all io elements have a generated variable reference held internally
        " which can be accessed with method GET_VALUE_REF
        FIELD-SYMBOLS <lv_matnr2> TYPE mara-matnr.
        DATA(lv_matnr2_ref) = lo_pa_matnr2->get_value_ref( ).
        ASSIGN lv_matnr2_ref->* TO <lv_matnr2>.

* ---------------------------------------------------------------------
        DATA lr_vbeln TYPE RANGE OF vbak-vbeln.
        lo_so_vbeln->get_value( IMPORTING ev_value = lr_vbeln ).

* ---------------------------------------------------------------------
        " method GET_VALUE also has a returning parameter of type string
        " if the io element is not of type string, using this will cause two type conversions
        " in this case:
        " internal value of type EKKO-EBELN cast to string -> string cast to LV_EBELN of type EKKO_EBELN
        DATA lv_ebeln TYPE ekko-ebeln.
        lv_ebeln = lo_pa_ebeln->get_value( ).


* ---------------------------------------------------------------------
        WRITE: `lo_pa_matnr1: `, lv_matnr1, /.

        WRITE: `lo_pa_matnr2: `, <lv_matnr2>, /.

        WRITE: 'lo_so_vbeln:', /.
        LOOP AT lr_vbeln ASSIGNING FIELD-SYMBOL(<lrs_vbeln>).
          WRITE: <lrs_vbeln>-sign, ` `, <lrs_vbeln>-option, ` `, <lrs_vbeln>-low, ` `, <lrs_vbeln>-high, /.
        ENDLOOP.
        WRITE /.

        WRITE: `lo_pa_ebeln: `, lv_ebeln, /.

      CATCH zcx_dynscreen_canceled.
        MESSAGE 'Selection canceled' TYPE 'I'.
      CATCH zcx_dynscreen_syntax_error INTO DATA(lx_syntax_error).
        MESSAGE lx_syntax_error->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD handle_button_click.
    MESSAGE 'Button pressed!' TYPE 'I'.
  ENDMETHOD.
ENDCLASS.
