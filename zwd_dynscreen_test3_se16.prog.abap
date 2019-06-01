REPORT zwd_dynscreen_test3_se16.

* ---------------------------------------------------------------------
TYPES:
  BEGIN OF gty_s_selfield,
    fieldname TYPE fieldname,
    so_ref    TYPE REF TO zcl_dynscreen_selectoption,
  END OF gty_s_selfield,
  gty_t_selfield TYPE SORTED TABLE OF gty_s_selfield WITH UNIQUE KEY fieldname.
DATA:
  go_tab_screen   TYPE REF TO zcl_dynscreen_screen,
  go_pa_table     TYPE REF TO zcl_dynscreen_parameter,
  go_checkbox_key TYPE REF TO zcl_dynscreen_checkbox,
  gv_keys_only    TYPE abap_bool,
  gv_tabname      TYPE tabname,
  gt_selfields    TYPE gty_t_selfield,
  go_sel_screen   TYPE REF TO zcl_dynscreen_screen,
  gt_selopt       TYPE STANDARD TABLE OF rsdsselopt_255 WITH DEFAULT KEY,
  gt_or_selfields TYPE se16n_or_t.

* ---------------------------------------------------------------------
go_tab_screen = NEW #( iv_text = 'Dynscreen Data Browser Demo' ).
go_tab_screen->set_pretty_print( ).

* ---------------------------------------------------------------------
go_pa_table = NEW #( io_parent = go_tab_screen
                     iv_type   = 'DATABROWSE-TABLENAME' ).
go_checkbox_key = NEW #( io_parent = go_tab_screen
                         iv_text   = 'Gen. SelOpts for keys only' ).
go_checkbox_key->set_value( abap_true ).

* ---------------------------------------------------------------------
DO.
  TRY.
      go_tab_screen->display( ).
    CATCH zcx_dynscreen_canceled.
      RETURN.
    CATCH zcx_dynscreen_syntax_error INTO DATA(lx_syntax_error).
      MESSAGE lx_syntax_error->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.
  gv_tabname = go_pa_table->get_value( ).
  SELECT SINGLE @abap_true
  FROM dd03l
  INTO @DATA(gv_tab_exists)
  WHERE tabname = @gv_tabname
  AND as4local = 'A'.
  IF gv_tab_exists = abap_true.
    EXIT.
  ELSE.
    MESSAGE `Table ` && gv_tabname && ` does not exist` TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.
ENDDO.

* ---------------------------------------------------------------------
go_checkbox_key->get_value( IMPORTING ev_value = gv_keys_only ).

* ---------------------------------------------------------------------
SELECT fieldname
FROM dd03l
INTO TABLE @DATA(gt_key_fields)
WHERE tabname   =  @gv_tabname
AND   as4local  =  'A'
AND   fieldname <> 'MANDT'
AND   keyflag   =   @gv_keys_only
ORDER BY position.

* ---------------------------------------------------------------------
FREE gt_selfields.
go_sel_screen = NEW #( ).
LOOP AT gt_key_fields ASSIGNING FIELD-SYMBOL(<gs_key_fld>) TO 200.
  TRY.
      INSERT VALUE #( fieldname = <gs_key_fld>-fieldname
                      so_ref    = NEW #( io_parent = go_sel_screen
                                         iv_type   = gv_tabname && '-' && <gs_key_fld>-fieldname )
                    ) INTO TABLE gt_selfields ASSIGNING FIELD-SYMBOL(<gs_selfield>).
    CATCH zcx_dynscreen_type_error.
      CONTINUE.
    CATCH zcx_dynscreen_too_many_elems.
      EXIT.
  ENDTRY.
ENDLOOP.

* ---------------------------------------------------------------------
TRY.
    go_sel_screen->display( ).
  CATCH zcx_dynscreen_canceled.
    RETURN.
  CATCH zcx_dynscreen_syntax_error INTO lx_syntax_error.
    MESSAGE lx_syntax_error->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
ENDTRY.

* ---------------------------------------------------------------------
APPEND INITIAL LINE TO gt_or_selfields ASSIGNING FIELD-SYMBOL(<gs_or_selfields>).

* ---------------------------------------------------------------------
LOOP AT gt_selfields ASSIGNING <gs_selfield>.
  FREE gt_selopt.
  <gs_selfield>-so_ref->get_value( IMPORTING ev_value = gt_selopt ).
  LOOP AT gt_selopt ASSIGNING FIELD-SYMBOL(<gs_selopt>).
    APPEND CORRESPONDING #( <gs_selopt> ) TO <gs_or_selfields>-seltab ASSIGNING FIELD-SYMBOL(<gs_seltab>).
    <gs_seltab>-field = <gs_selfield>-fieldname.
  ENDLOOP.
ENDLOOP.

* ---------------------------------------------------------------------
CALL FUNCTION 'SE16N_INTERFACE'
  EXPORTING
    i_tab           = gv_tabname
    i_clnt_dep      = abap_true
  TABLES
    it_or_selfields = gt_or_selfields
  EXCEPTIONS
    no_values       = 1
    OTHERS          = 2.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
  DISPLAY LIKE 'E'.
ENDIF.
