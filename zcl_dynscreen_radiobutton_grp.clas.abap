CLASS zcl_dynscreen_radiobutton_grp DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_io_element FINAL CREATE PUBLIC GLOBAL FRIENDS zcl_dynscreen_radiobutton.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF mty_s_radiobutton,
        id   TYPE mty_id,
        text TYPE textpooltx,
      END OF mty_s_radiobutton,
      mty_t_radiobutton TYPE SORTED TABLE OF mty_s_radiobutton WITH UNIQUE KEY id.
    METHODS:
      constructor IMPORTING !it_radiobuttons TYPE mty_t_radiobutton OPTIONAL,
      add REDEFINITION,
      raise_event REDEFINITION.
  PROTECTED SECTION.
    TYPES:
      BEGIN OF mty_s_radiobutton_ref.
            INCLUDE TYPE mty_s_radiobutton.
    TYPES:
      refid TYPE mty_id,
      ref   TYPE REF TO zcl_dynscreen_radiobutton,
      END OF mty_s_radiobutton_ref,
      mty_t_radiobutton_ref TYPE SORTED TABLE OF mty_s_radiobutton_ref WITH UNIQUE KEY id.
    DATA:
      mt_radiobuttons TYPE mty_t_radiobutton_ref.
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
    super->constructor( is_generic_type = VALUE #( datatype = 'NUMC' length = 3 ) ).

* ---------------------------------------------------------------------
    LOOP AT it_radiobuttons ASSIGNING FIELD-SYMBOL(<ls_rb>).
      lo_radiobutton = NEW #( iv_text            = <ls_rb>-text
                              iv_radiobutton_grp = 'RB' && mv_id+2(2) ).
      INSERT VALUE #( id    = <ls_rb>-id
                      refid = lo_radiobutton->mv_id
                      text  = <ls_rb>-text
                      ref   = lo_radiobutton ) INTO TABLE mt_radiobuttons.
      add( lo_radiobutton ).
    ENDLOOP.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
* ---------------------------------------------------------------------
    APPEND
    'CASE abap_true.'
    TO mt_source_ac.

* ---------------------------------------------------------------------
    LOOP AT mt_radiobuttons ASSIGNING FIELD-SYMBOL(<ls_rb>).
      READ TABLE mt_variables ASSIGNING FIELD-SYMBOL(<ls_var>) WITH KEY id = <ls_rb>-refid.
      IF <ls_var> IS ASSIGNED.
        APPEND
        `  WHEN ` && <ls_var>-name && '.'
        TO mt_source_ac.
        APPEND
        `    ` && mc_syn-var_prefix && mv_id && ` = ` && <ls_rb>-id && '.'
        TO mt_source_ac.
      ENDIF.
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


  METHOD raise_event.
* ---------------------------------------------------------------------

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
