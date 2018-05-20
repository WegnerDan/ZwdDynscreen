CLASS zcl_dynscreen_tab DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_subscreen CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_text TYPE textpooltx OPTIONAL,
      add REDEFINITION.
  PROTECTED SECTION.
    DATA:
      mo_screen TYPE REF TO zcl_dynscreen_subscreen.
    METHODS:
      generate REDEFINITION,
      generate_close REDEFINITION,
      generate_open REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_tab IMPLEMENTATION.


  METHOD add.
* ---------------------------------------------------------------------
    IF mo_screen IS BOUND.
      mo_screen->add( io_screen_element ).
    ELSE.
      mo_screen = NEW #( ).
      mo_screen->set_id( CONV i( get_id( ) ) ).
      mo_screen->add( io_screen_element ).
      super->add( mo_screen ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( ).

* ---------------------------------------------------------------------
    set_text( iv_text ).
    mv_is_variable = abap_false.

* ---------------------------------------------------------------------
    IF get_text( ) IS INITIAL.
      set_text( `Tab ` && mv_id  ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate.
* ---------------------------------------------------------------------
    super->generate( ).

* ---------------------------------------------------------------------
    " line 1 is the only line that has to remain in mt_source at this point
    APPEND LINES OF mt_source FROM 2 TO mt_source_as.
    DELETE mt_source FROM 2.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------
* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_open.
* ---------------------------------------------------------------------
    APPEND
    mc_syn-selscreen && ` ` && mc_syn-tab && ` (10) ` && mc_syn-tab_prefix && mv_id && ` ` &&
    mc_syn-ucomm && ` ` && mc_syn-tab_prefix && mv_id && ` ` && mc_syn-default && ` ` && mc_syn-screen
    && ` ` && mv_id && '.'
    TO mt_source.

* ---------------------------------------------------------------------
    APPEND mc_syn-tab_prefix && mv_id && ` = ` && mc_syn-sq && mv_text && mc_syn-sq && '.'
    TO ms_source_eve-t_init.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
