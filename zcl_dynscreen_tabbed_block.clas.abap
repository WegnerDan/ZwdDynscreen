CLASS zcl_dynscreen_tabbed_block DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_base CREATE PUBLIC
GLOBAL FRIENDS zcl_dynscreen_tab.
  PUBLIC SECTION.
    TYPES:
      mty_lines TYPE n LENGTH 3 .
    METHODS:
      constructor IMPORTING io_parent TYPE REF TO zcl_dynscreen_screen_base
                            iv_lines  TYPE mty_lines OPTIONAL
                  RAISING   zcx_dynscreen_incompatible
                            zcx_dynscreen_too_many_elems,
      set_lines IMPORTING iv_lines TYPE mty_lines,
      get_lines RETURNING VALUE(rv_lines) TYPE mty_lines.
  PROTECTED SECTION.
    DATA:
      mv_lines TYPE mty_lines.
    METHODS:
      generate_close REDEFINITION,
      generate_open REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_tabbed_block IMPLEMENTATION.

  METHOD constructor.
* ---------------------------------------------------------------------
    DATA:
      lo_parent TYPE REF TO zcl_dynscreen_base.

* ---------------------------------------------------------------------
    super->constructor( ).

* ---------------------------------------------------------------------
    IF iv_lines > 0.
      set_lines( iv_lines ).
    ELSE.
      set_lines( 36 ).
    ENDIF.

* ---------------------------------------------------------------------
    mv_is_variable = abap_false.

* ---------------------------------------------------------------------
    lo_parent = io_parent.
    lo_parent->add( me ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------
    APPEND
    mc_syn-selscreen && ` ` && mc_syn-end && ` ` && mc_syn-block && ` ` && mc_syn-blk_prefix && mv_id && '.'
    TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_open.
* ---------------------------------------------------------------------
    APPEND
    mc_syn-selscreen && ` ` && mc_syn-begin && ` ` && mc_syn-tabblock && ` ` && mc_syn-blk_prefix && mv_id && ` FOR ` && mv_lines && ` LINES.`
    TO mt_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_lines.
* ---------------------------------------------------------------------
    rv_lines = mv_lines.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_lines.
* ---------------------------------------------------------------------
    mv_lines = iv_lines.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
