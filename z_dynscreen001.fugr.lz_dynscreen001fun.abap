* ---------------------------------------------------------------------
* THIS IS A GENERATED PROGRAM!
*     changes are futile
*     last generation: 20171226 010159
* ---------------------------------------------------------------------
go_events = io_events.
CALL SELECTION-SCREEN 0003.
gv_subrc = sy-subrc.
IF io_value_transport IS BOUND.
io_value_transport->set_subrc( gv_subrc ).
io_value_transport->add_value( iv_fname = 'V_0004[]' iv_value = V_0004[] ).
ENDIF.
