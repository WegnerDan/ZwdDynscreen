CLASS zcl_dynscreen_radiobutton_grp DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_io_element CREATE PUBLIC GLOBAL FRIENDS zcl_dynscreen_radiobutton.
  PUBLIC SECTION.
    INTERFACES:
      zif_dynscreen_uc_event.
    TYPES:
      mty_t_radiobutton TYPE STANDARD TABLE OF REF TO zcl_dynscreen_radiobutton WITH DEFAULT KEY.
    METHODS:
      constructor IMPORTING it_radiobuttons TYPE mty_t_radiobutton OPTIONAL
                  RAISING   zcx_dynscreen_incompatible
                            zcx_dynscreen_too_many_elems,
      add REDEFINITION,
      get_selected_radiobutton RETURNING VALUE(ro_radiobutton) TYPE REF TO zcl_dynscreen_radiobutton.
    EVENTS:
      radiobutton_click.
  PROTECTED SECTION.
    METHODS:
      generate_close REDEFINITION,
      generate_open REDEFINITION,
      generate_callback_set_value REDEFINITION,
      get_first_radiobutton FINAL RETURNING VALUE(ro_radiobutton) TYPE REF TO zcl_dynscreen_radiobutton
                                  RAISING   cx_sy_itab_line_not_found.
  PRIVATE SECTION.
    DATA:
      mt_radiobuttons TYPE mty_t_radiobutton.
ENDCLASS.



CLASS zcl_dynscreen_radiobutton_grp IMPLEMENTATION.


  METHOD add.
* ---------------------------------------------------------------------
    IF cl_abap_classdescr=>get_class_name( io_screen_element ) <> '\CLASS=ZCL_DYNSCREEN_RADIOBUTTON'.
      RAISE EXCEPTION TYPE zcx_dynscreen_incompatible
        EXPORTING
          parent_class       = me
          incompatible_class = io_screen_element.
    ENDIF.

* ---------------------------------------------------------------------
    io_screen_element->mo_parent = me.
    INSERT VALUE #( id  = io_screen_element->get_id( )
                    ref = io_screen_element
                    var = io_screen_element->is_var( ) ) INTO TABLE mt_elements.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD constructor.
* ---------------------------------------------------------------------
    DATA:
      lo_radiobutton TYPE REF TO zcl_dynscreen_radiobutton.

* ---------------------------------------------------------------------
    super->constructor( is_generic_type = VALUE #( datatype = mc_type-n
                                                   length   = 4         ) ).

* ---------------------------------------------------------------------
    LOOP AT it_radiobuttons ASSIGNING FIELD-SYMBOL(<lo_rb>).
      add( <lo_rb> ).
    ENDLOOP.
    mt_radiobuttons = it_radiobuttons.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------

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


  METHOD get_selected_radiobutton.
* ---------------------------------------------------------------------
    FIELD-SYMBOLS:
      <lv_value> TYPE mty_id.

* ---------------------------------------------------------------------
    ASSIGN md_value->* TO <lv_value>.

* ---------------------------------------------------------------------
    ro_radiobutton = mt_radiobuttons[ table_line->mv_id = <lv_value> ].

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_callback_set_value.
* ---------------------------------------------------------------------
    IF mt_radiobuttons IS NOT INITIAL.
      APPEND
      'CASE abap_true.' ##NO_TEXT
      TO rt.
      LOOP AT mt_radiobuttons ASSIGNING FIELD-SYMBOL(<lo_rb>).
        APPEND
        `  WHEN ` && <lo_rb>->get_var_name( ) && '.'
        TO rt.
        APPEND
        `    ` && mc_syn-var_prefix && mv_id && ` = ` && <lo_rb>->get_id( ) && '.'
        TO rt.
      ENDLOOP.
      APPEND
      'ENDCASE.'
      TO rt.
    ENDIF.

* ---------------------------------------------------------------------
    APPEND LINES OF super->generate_callback_set_value( ) TO rt.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
