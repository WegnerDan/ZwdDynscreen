CLASS zcl_dynscreen_popup DEFINITION
  PUBLIC
  INHERITING FROM zcl_dynscreen_screen_base
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS get_ending_position
      RETURNING
        VALUE(rs_position) TYPE mty_position .
    METHODS get_starting_position
      RETURNING
        VALUE(rs_position) TYPE mty_position .
    METHODS set_ending_position
      IMPORTING
        !is_position TYPE mty_position .
    METHODS set_starting_position
      IMPORTING
        !is_position TYPE mty_position .
    METHODS constructor
      IMPORTING
        !iv_text TYPE textpooltx OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DYNSCREEN_POPUP IMPLEMENTATION.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( iv_text ).

* ---------------------------------------------------------------------
    set_window( ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_ending_position.
* ---------------------------------------------------------------------
    rs_position = ms_ending_position.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_starting_position.
* ---------------------------------------------------------------------
    rs_position = ms_starting_position.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_ending_position.
* ---------------------------------------------------------------------
    IF is_position-x <= ms_starting_position-x
    OR is_position-y <= ms_starting_position-y.
      FREE ms_ending_position.
    ELSE.
      ms_ending_position = is_position.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_starting_position.
* ---------------------------------------------------------------------
    IF is_position-x = 0
    OR is_position-y = 0.
      ms_starting_position = mc_default_starting_pos.
    ELSE.
      ms_starting_position = is_position.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
