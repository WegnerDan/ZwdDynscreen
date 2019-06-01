CLASS zcl_dynscreen_radiobutton_grp DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_io_element CREATE PUBLIC
GLOBAL FRIENDS zcl_dynscreen_radiobutton.
  PUBLIC SECTION.
    INTERFACES:
      zif_dynscreen_uc_event.
    TYPES:
      mty_t_radiobutton TYPE STANDARD TABLE OF REF TO zcl_dynscreen_radiobutton WITH DEFAULT KEY.
    METHODS:
      constructor IMPORTING io_parent TYPE REF TO zcl_dynscreen_screen_base
                  RAISING   zcx_dynscreen_incompatible
                            zcx_dynscreen_too_many_elems,
      get_selected_radiobutton RETURNING VALUE(ro_radiobutton) TYPE REF TO zcl_dynscreen_radiobutton.
    EVENTS:
      radiobutton_click.
  PROTECTED SECTION.
    METHODS:
      add REDEFINITION,
      generate_close REDEFINITION,
      generate_open REDEFINITION,
      generate_callback_set_value REDEFINITION,
      generate_callback_get_value REDEFINITION,
      get_first_radiobutton FINAL RETURNING VALUE(ro_radiobutton) TYPE REF TO zcl_dynscreen_radiobutton
                                  RAISING   cx_sy_itab_line_not_found.
  PRIVATE SECTION.
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
    " set initial value of radio button group
    IF mt_elements IS INITIAL.
      set_value( iv_value = io_screen_element->get_id( ) ).
    ENDIF.

* ---------------------------------------------------------------------
    io_screen_element->mo_parent = me.
    INSERT VALUE #( id  = io_screen_element->get_id( )
                    ref = io_screen_element            ) INTO TABLE mt_elements.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD constructor.
* ---------------------------------------------------------------------
    " internal type is the same as mty_id
    " value of radio button group corresponds to id of chosen radio button
    super->constructor( io_parent       = io_parent
                        is_generic_type = VALUE #( datatype = mc_type-n
                                                   length   = 4         ) ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_callback_get_value.
* ---------------------------------------------------------------------
    " no corresponding screen field exists for radiobutton groups
    " -> callback get value not necessary

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_callback_set_value.
* ---------------------------------------------------------------------
    " make sure that value of radio button group is updated to id of chosen radio button
    IF mt_elements IS NOT INITIAL.
      APPEND
      'CASE abap_true.' ##NO_TEXT
      TO rt.
      LOOP AT mt_elements ASSIGNING FIELD-SYMBOL(<ls_element>).
        DATA(lo_radiobutton) = CAST zcl_dynscreen_radiobutton( <ls_element>-ref ).
        APPEND
        `  WHEN ` && lo_radiobutton->get_var_name( ) && '.'
        TO rt.
        APPEND
        `    ` && mc_syn-var_prefix && mv_id && ` = ` && lo_radiobutton->get_id( ) && '.'
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


  METHOD get_first_radiobutton.
* ---------------------------------------------------------------------
    ro_radiobutton = CAST #( mt_elements[ 1 ]-ref ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_selected_radiobutton.
* ---------------------------------------------------------------------
    FIELD-SYMBOLS:
      <lv_value> TYPE mty_id.

* ---------------------------------------------------------------------
    ASSIGN md_value->* TO <lv_value>.

* ---------------------------------------------------------------------
    ro_radiobutton = CAST #( mt_elements[ id = <lv_value> ]-ref ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD zif_dynscreen_uc_event~raise.
* ---------------------------------------------------------------------
    RAISE EVENT radiobutton_click.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
