CLASS zcl_dynscreen_line DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_base FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS:
      add REDEFINITION.
  PROTECTED SECTION.
    METHODS:
      generate_open REDEFINITION,
      generate_close REDEFINITION.

  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_line IMPLEMENTATION.
  METHOD add.
* ---------------------------------------------------------------------
    DATA:
      lo_io_element TYPE REF TO zcl_dynscreen_io_element.

* ---------------------------------------------------------------------
    TRY.
        lo_io_element ?= io_screen_element.
        lo_io_element->zif_dynscreen_line_item~mv_is_line_item = abap_true.
      CATCH cx_sy_move_cast_error.
        RAISE EXCEPTION TYPE zcx_dynscreen_incompatible.
    ENDTRY.

* ---------------------------------------------------------------------
    "TODO
    " add position and length checking
    IF 0 = 1.
      RAISE EXCEPTION TYPE zcx_dynscreen_incompatible
        EXPORTING
          previous = NEW zcx_dynscreen_line_space_error( ).
    ENDIF.

* ---------------------------------------------------------------------
    super->add( io_screen_element ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_open.
* ---------------------------------------------------------------------
    APPEND mc_syn-selscreen && ` ` && mc_syn-begin && ` LINE.` TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------
    APPEND mc_syn-selscreen && ` ` && mc_syn-end && ` LINE.` TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


ENDCLASS.
