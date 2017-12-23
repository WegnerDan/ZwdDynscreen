CLASS zcl_dynscreen_button DEFINITION
  PUBLIC
  INHERITING FROM zcl_dynscreen_io_element
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor IMPORTING iv_text TYPE textpooltx OPTIONAL.
    METHODS raise_event REDEFINITION .
    EVENTS button_click EXPORTING VALUE(ev_ucomm) TYPE sy-ucomm OPTIONAL.
  PROTECTED SECTION.
    METHODS generate_open REDEFINITION .
    METHODS generate_close REDEFINITION .


  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DYNSCREEN_BUTTON IMPLEMENTATION.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( iv_type         = mc_type_generic
                        is_generic_type = VALUE #( datatype = mc_type_c length = 1 )
                        iv_text         = iv_text                                   ).
    mv_is_variable = abap_false.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_close.
  ENDMETHOD.


  METHOD generate_open.
    APPEND mc_syn-selscreen && ` SKIP 1.` TO mt_source.
    APPEND mc_syn-selscreen && ` ` && mc_syn-button && ` 1(8) ` && mc_syn-btn_prefix && mv_id && ` ` && mc_syn-ucomm && ` ` && mc_syn-ucm_prefix && mv_id && '.' TO mt_source.

    APPEND `  IF sy-ucomm = '` && mc_syn-ucm_prefix && mv_id && `'. ` TO ms_source_eve-t_selscreen.
    APPEND `    sy-ucomm = go_events->raise( iv_id = '` && mv_id && `' iv_ucomm = sy-ucomm ).` TO ms_source_eve-t_selscreen.
    APPEND '  ENDIF.' TO ms_source_eve-t_selscreen.

    zcl_dynscreen_events=>get_inst( )->add( me ).

    IF mv_text IS NOT INITIAL.
      APPEND mc_syn-btn_prefix && mv_id && ` = '` && mv_text && `'.` TO ms_source_eve-t_init.
    ENDIF.

  ENDMETHOD.


  METHOD raise_event.
    RAISE EVENT button_click.
  ENDMETHOD.
ENDCLASS.
