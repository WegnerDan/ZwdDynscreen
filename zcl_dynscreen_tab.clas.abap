CLASS zcl_dynscreen_tab DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_base CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING !iv_text TYPE textpooltx OPTIONAL,
      add REDEFINITION.
  PROTECTED SECTION.
    DATA:
      mo_screen TYPE REF TO zcl_dynscreen_subscreen .
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
      mo_screen->set_id( get_id( ) ).
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
      set_text( 'Tab' && ` ` && mv_id  ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate.
* ---------------------------------------------------------------------
    DATA:
      lo_io TYPE REF TO zcl_dynscreen_io_element.
    FIELD-SYMBOLS:
      <ls_element> LIKE LINE OF mt_elements.

* ---------------------------------------------------------------------
    generate_open( ).
    LOOP AT mt_elements ASSIGNING <ls_element>.
      <ls_element>-ref->generate( ).
      APPEND LINES OF <ls_element>-ref->mt_source TO mt_source_ac.
      INSERT LINES OF <ls_element>-ref->mt_variables INTO TABLE mt_variables.
      " if element is a variable (parameters or select options)
      IF <ls_element>-var = abap_true.
        lo_io ?= <ls_element>-ref.
        INSERT VALUE #( id   = <ls_element>-id
                        name = lo_io->get_var_name( )
                        ref  = lo_io                 ) INTO TABLE mt_variables.
      ENDIF.
      APPEND LINES OF <ls_element>-ref->mt_source_ac TO mt_source_ac.
    ENDLOOP.
    generate_close( ).
* ---------------------------------------------------------------------
*SUPER->GENERATE( ).
  ENDMETHOD.


  METHOD generate_close.
  ENDMETHOD.


  METHOD generate_open.
* ---------------------------------------------------------------------
    APPEND
    mc_syn-selscreen && ` ` && mc_syn-tab && ` (10) ` && mc_syn-tab_prefix && mv_id && ` ` &&
    mc_syn-ucomm && ` ` && mc_syn-tab_prefix && mv_id && ` ` && mc_syn-default && ` ` && mc_syn-screen && ` ` && mv_id && '.'
    TO mt_source.
    APPEND mc_syn-tab_prefix && mv_id && ` = ` && mc_syn-sq && mv_text && mc_syn-sq && '.'
    TO mt_source.
*SELECTION-SCREEN TAB (10) tabtab1 USER-COMMAND tabtab1 DEFAULT SCREEN 8000.
*tabtab1 = 'asdf'.
* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
