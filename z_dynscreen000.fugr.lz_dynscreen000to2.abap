* ---------------------------------------------------------------------
* THIS IS A GENERATED PROGRAM!
*     changes are futile
*     last generation: 20171225 232646
* ---------------------------------------------------------------------
DATA go_events TYPE REF TO zcl_dynscreen_events.
DATA gv_subrc TYPE sy-subrc.
SELECTION-SCREEN BEGIN OF SCREEN 0001 .
PARAMETERS v_0002 TYPE mara-matnr DEFAULT 'DEFAULT'.
PARAMETERS v_0003 TYPE mara-matnr.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN PUSHBUTTON 01(20) bt_0004 USER-COMMAND uc_0004.
DATA dv_0005 TYPE vbak-vbeln.
SELECT-OPTIONS v_0005 FOR dv_0005.
PARAMETERS v_0006 TYPE ekko-ebeln.
SELECTION-SCREEN END OF SCREEN 0001.

LOAD-OF-PROGRAM.
  bt_0004 = 'Testbutton'.

AT SELECTION-SCREEN.
  IF sy-ucomm = 'UC_0004'.
    sy-ucomm = go_events->raise( iv_id = '0004' iv_ucomm = sy-ucomm ).
  ENDIF.
  IF sy-ucomm = '_%_%_EXIT_%_%_'.
    LEAVE TO SCREEN 0.
  ENDIF.
