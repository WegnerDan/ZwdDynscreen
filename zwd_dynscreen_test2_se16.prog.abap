REPORT zwd_dynscreen_test2_se16.

* ---------------------------------------------------------------------
TYPES:
  BEGIN OF gty_s_selfield,
    fieldname TYPE fieldname,
    so_ref    TYPE REF TO zcl_dynscreen_selectoption,
  END OF gty_s_selfield,
  gty_t_selfield TYPE SORTED TABLE OF gty_s_selfield WITH UNIQUE KEY fieldname.
DATA:
  go_tab_screen TYPE REF TO zcl_dynscreen_screen,
  go_pa_table   TYPE REF TO zcl_dynscreen_parameter,
  gv_tabname    TYPE tabname,
  gt_selfields  TYPE gty_t_selfield,
  go_sel_screen TYPE REF TO zcl_dynscreen_screen.

* ---------------------------------------------------------------------
go_tab_screen = NEW #( iv_text = 'Dynscreen Data Browser Demo' ).
go_tab_screen->set_pretty_print( ).

* ---------------------------------------------------------------------
go_pa_table = NEW #( iv_type = 'DATABROWSE-TABLENAME' ).
go_tab_screen->add( go_pa_table ).

* ---------------------------------------------------------------------
DO.
  IF go_tab_screen->display( ) <> zcl_dynscreen_base=>mc_selection_ok.
    RETURN.
  ENDIF.
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
SELECT fieldname
FROM dd03l
INTO TABLE @DATA(gt_key_fields)
WHERE tabname   =  @gv_tabname
AND   as4local  =  'A'
AND   fieldname <> 'MANDT'
AND   keyflag   =   @abap_true.

* ---------------------------------------------------------------------
BREAK-POINT.
FREE gt_selfields.
go_sel_screen = NEW #( ).
LOOP AT gt_key_fields ASSIGNING FIELD-SYMBOL(<gs_key_fld>).
  INSERT VALUE #( fieldname = <gs_key_fld>-fieldname
                  so_ref    = NEW #( iv_type = gv_tabname && '-' && <gs_key_fld>-fieldname )
                ) INTO TABLE gt_selfields ASSIGNING FIELD-SYMBOL(<gs_selfield>).
  go_sel_screen->add( <gs_selfield>-so_ref ).
ENDLOOP.

* ---------------------------------------------------------------------
go_sel_screen->display( ).
