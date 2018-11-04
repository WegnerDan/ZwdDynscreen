REPORT zwd_dynscreen_test5_lines.

CLASS lcl DEFINITION.
  PUBLIC SECTION.
    METHODS:
      run.
ENDCLASS.

NEW lcl( )->run( ).

CLASS lcl IMPLEMENTATION.
  METHOD run.
* ---------------------------------------------------------------------
    DATA:
      lo_screen      TYPE REF TO zcl_dynscreen_screen,
      lo_line        TYPE REF TO zcl_dynscreen_line,
      lo_param_matnr TYPE REF TO zcl_dynscreen_parameter,
      lo_param_maktx TYPE REF TO zcl_dynscreen_parameter,
      lx             TYPE REF TO cx_root.

* ---------------------------------------------------------------------
    lo_screen = NEW #( ).

* ---------------------------------------------------------------------
    lo_line = NEW #( ).
    TRY.
        lo_param_matnr = NEW #( iv_type = 'MARA-MATNR' ).
        lo_param_maktx = NEW #( iv_type = 'MAKT-MAKTX' ).
        lo_param_maktx->set_input( abap_false ).
      CATCH zcx_dynscreen_type_error INTO lx.
        MESSAGE lx TYPE 'E'.
    ENDTRY.

* ---------------------------------------------------------------------
    TRY.
        lo_screen->add( lo_line ).
        lo_line->add( lo_param_matnr ).
        lo_line->add( lo_param_maktx ).
      CATCH zcx_dynscreen_incompatible
            zcx_dynscreen_too_many_elems INTO lx.
        MESSAGE lx TYPE 'E'.
    ENDTRY.

* ---------------------------------------------------------------------
    TRY.
        lo_screen->display( ).
        WRITE: /, lo_param_matnr->get_value( ).
        MESSAGE 'success' TYPE 'S'.
      CATCH zcx_dynscreen_canceled.
        MESSAGE 'canceled' TYPE 'S'.
      CATCH zcx_dynscreen_syntax_error INTO lx.
        MESSAGE lx TYPE 'E'.
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
