* ---------------------------------------------------------------------
* THIS IS A GENERATED PROGRAM!
*     changes are futile
*     last generation: 20171226 012249
* ---------------------------------------------------------------------
DATA go_events TYPE REF TO zcl_dynscreen_events.
DATA gv_subrc TYPE sy-subrc.
SELECTION-SCREEN BEGIN OF SCREEN 0003 .
DATA DV_0004 TYPE MARA-MATNR.
SELECT-OPTIONS V_0004 FOR DV_0004.
SELECTION-SCREEN END OF SCREEN 0003.
AT SELECTION-SCREEN.
IF sy-ucomm = '_%_%_EXIT_%_%_'.
LEAVE TO SCREEN 0.
ENDIF.
