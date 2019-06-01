CLASS zcl_dynscreen_subscreen DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_screen_base CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING !iv_text TYPE textpooltx OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_subscreen IMPLEMENTATION.

  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( iv_text ).

* ---------------------------------------------------------------------
    set_subscreen( ).

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
