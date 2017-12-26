* ---------------------------------------------------------------------
* THIS IS A GENERATED PROGRAM!
*     changes are futile
*     last generation: 20171226 010153
* ---------------------------------------------------------------------
go_events = io_events.
CALL SELECTION-SCREEN 0001.
gv_subrc = sy-subrc.
IF io_value_transport IS BOUND.
  io_value_transport->set_subrc( gv_subrc ).
  io_value_transport->add_value( iv_fname = 'V_0002' iv_value = v_0002 ).
ENDIF.
