* ---------------------------------------------------------------------
* THIS IS A GENERATED PROGRAM!
*     changes are futile
*     last generation: 20171224 023501
* ---------------------------------------------------------------------
go_events = io_events.
CALL SELECTION-SCREEN 0001.
gv_subrc = sy-subrc.
IF io_value_transport IS BOUND.
io_value_transport->set_subrc( gv_subrc ).
io_value_transport->add_value( iv_fname = 'V_0002' iv_value = V_0002 ).
io_value_transport->add_value( iv_fname = 'V_0003' iv_value = V_0003 ).
io_value_transport->add_value( iv_fname = 'V_0005[]' iv_value = V_0005[] ).
io_value_transport->add_value( iv_fname = 'V_0006' iv_value = V_0006 ).
ENDIF.
