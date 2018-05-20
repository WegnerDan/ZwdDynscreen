CLASS zcl_dynscreen_radiobutton_grp DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_io_element CREATE PUBLIC GLOBAL FRIENDS zcl_dynscreen_radiobutton.
  PUBLIC SECTION.
    INTERFACES:
      zif_dynscreen_uc_event.
    TYPES:
      mty_t_radiobutton TYPE STANDARD TABLE OF REF TO zcl_dynscreen_radiobutton WITH DEFAULT KEY.
    METHODS:
      constructor IMPORTING it_radiobuttons TYPE mty_t_radiobutton OPTIONAL
                  RAISING   zcx_dynscreen_type_error
                            zcx_dynscreen_incompatible,
      add REDEFINITION.
    EVENTS:
      radiobutton_click.
  PROTECTED SECTION.
    METHODS:
      generate_close REDEFINITION,
      generate_open REDEFINITION,
      get_first_radiobutton FINAL RETURNING VALUE(ro_radiobutton) TYPE REF TO zcl_dynscreen_radiobutton
                                  RAISING   cx_sy_itab_line_not_found.
  PRIVATE SECTION.
    DATA:
      mt_radiobuttons TYPE mty_t_radiobutton.
ENDCLASS.



CLASS zcl_dynscreen_radiobutton_grp IMPLEMENTATION.


  METHOD add.
* ---------------------------------------------------------------------
    IF '\CLASS=ZCL_DYNSCREEN_RADIOBUTTON' = cl_abap_classdescr=>get_class_name( io_screen_element ).
      io_screen_element->mo_parent = me.
      INSERT VALUE #( id  = io_screen_element->get_id( )
                      ref = io_screen_element
                      var = io_screen_element->is_var( ) ) INTO TABLE mt_elements.
    ELSE.
      RAISE EXCEPTION TYPE zcx_dynscreen_incompatible.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD constructor.
* ---------------------------------------------------------------------
    DATA:
      lo_radiobutton TYPE REF TO zcl_dynscreen_radiobutton.

* ---------------------------------------------------------------------
    super->constructor( is_generic_type = VALUE #( datatype = mc_type-n length = 3 ) ).

* ---------------------------------------------------------------------
    LOOP AT it_radiobuttons ASSIGNING FIELD-SYMBOL(<lo_rb>).
      add( <lo_rb> ).
    ENDLOOP.
    mt_radiobuttons = it_radiobuttons.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------
    APPEND
    'CASE abap_true.' ##NO_TEXT
    TO mt_source_ac.

* ---------------------------------------------------------------------
    LOOP AT mt_radiobuttons ASSIGNING FIELD-SYMBOL(<lo_rb>).
      APPEND
      `  WHEN ` && <lo_rb>->get_var_name( ) && '.'
      TO mt_source_ac.
      APPEND
      `    ` && mc_syn-var_prefix && mv_id && ` = ` && <lo_rb>->get_id( ) && '.'
      TO mt_source_ac.
    ENDLOOP.

* ---------------------------------------------------------------------
    APPEND
    'ENDCASE.'
    TO mt_source_ac.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_open.
* ---------------------------------------------------------------------
    APPEND
    mc_syn-data && ` ` && mc_syn-var_prefix && mv_id && ` ` && mc_syn-type && ` ` && mv_generic_type_string && '.'
    TO mt_source.

* ---------------------------------------------------------------------
    append_uc_event_src( ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD zif_dynscreen_uc_event~raise.
* ---------------------------------------------------------------------
    RAISE EVENT radiobutton_click.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_first_radiobutton.
* ---------------------------------------------------------------------
    ro_radiobutton = mt_radiobuttons[ 1 ].

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
