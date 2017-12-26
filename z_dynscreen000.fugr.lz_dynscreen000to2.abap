* ---------------------------------------------------------------------
* THIS IS A GENERATED PROGRAM!
*     changes are futile
*     last generation: 20171226 012457
* ---------------------------------------------------------------------
DATA go_events TYPE REF TO zcl_dynscreen_events.
DATA gv_subrc TYPE sy-subrc.
SELECTION-SCREEN BEGIN OF SCREEN 0001 .
PARAMETERS v_0002 TYPE databrowse-tablename.
SELECTION-SCREEN END OF SCREEN 0001.

AT SELECTION-SCREEN.
  IF sy-ucomm = '_%_%_EXIT_%_%_'.
    LEAVE TO SCREEN 0.
  ENDIF.
