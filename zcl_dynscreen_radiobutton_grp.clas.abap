CLASS zcl_dynscreen_radiobutton_grp DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_io_element FINAL CREATE PUBLIC GLOBAL FRIENDS zcl_dynscreen_radiobutton.
  PUBLIC SECTION.
    INTERFACES:
      zif_dynscreen_uc_event.
    TYPES:
      mty_t_radiobutton TYPE STANDARD TABLE OF REF TO zcl_dynscreen_radiobutton WITH DEFAULT KEY.
    METHODS:
      constructor IMPORTING it_radiobuttons TYPE mty_t_radiobutton OPTIONAL
                  RAISING   zcx_dynscreen_type_error,
      add REDEFINITION.
  PROTECTED SECTION.
*    TYPES:
*      BEGIN OF mty_s_radiobutton_ref.
*            INCLUDE TYPE mty_s_radiobutton.
*    TYPES:
*      refid TYPE mty_id,
*      ref   TYPE REF TO zcl_dynscreen_radiobutton,
*      END OF mty_s_radiobutton_ref,
*      mty_t_radiobutton_ref TYPE SORTED TABLE OF mty_s_radiobutton_ref WITH UNIQUE KEY id.
    DATA:
      mt_radiobuttons TYPE mty_t_radiobutton.
    METHODS:
      generate_close REDEFINITION,
      generate_open REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_radiobutton_grp IMPLEMENTATION.


  METHOD add.
* ---------------------------------------------------------------------
    IF '\CLASS=ZWD_DYNSCREEN_RADIOBUTTON' = cl_abap_classdescr=>get_class_name( io_screen_element ).
      super->add( io_screen_element ).
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
  ENDMETHOD.


  METHOD zif_dynscreen_uc_event~raise.
* ---------------------------------------------------------------------

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
