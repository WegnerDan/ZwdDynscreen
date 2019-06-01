*&---------------------------------------------------------------------*
*& Report zwd_dynscreen_test5_minimal
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zwd_dynscreen_test5_minimal.
* ---------------------------------------------------------------------
DATA:
  go_popup    TYPE REF TO zcl_dynscreen_popup,
  go_pa_matnr TYPE REF TO zcl_dynscreen_parameter.

* ---------------------------------------------------------------------
go_popup = NEW #( iv_text = 'Selection Screen Test 5' ).
go_pa_matnr = NEW #( io_parent = go_popup
                     iv_type   = 'MARA-MATNR' ).

* -- -------------------------------------------------------------------
TRY.
    go_popup->display( ).
  CATCH zcx_dynscreen_canceled INTO DATA(lx_canceled).
    MESSAGE lx_canceled TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
ENDTRY.

* ---------------------------------------------------------------------
WRITE: `lo_pa_matnr: `, go_pa_matnr->get_value( ), /.
ULINE.

* ---------------------------------------------------------------------
MESSAGE 'Selection successful!' TYPE 'S'.
