INTERFACE zif_dynscreen_request_event PUBLIC.
  CONSTANTS:
    kind_help_request  TYPE i VALUE 1,
    kind_value_request TYPE i VALUE 2.
  DATA:
    md_request_value TYPE REF TO data READ-ONLY.
  EVENTS:
    help_request,
    value_request.
  METHODS:
    raise_help_request,
    raise_value_request,
    set_req_field_ref IMPORTING id_value TYPE REF TO data.
ENDINTERFACE.
