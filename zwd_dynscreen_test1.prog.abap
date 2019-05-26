REPORT zwd_dynscreen_test1.

CLASS lcl DEFINITION CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS:
      run.
  PRIVATE SECTION.
    METHODS:
      handle_button_click  FOR EVENT button_click OF zcl_dynscreen_button
        IMPORTING sender,
      handle_program_value_request FOR EVENT zif_dynscreen_request_event~value_request OF zcl_dynscreen_parameter
        IMPORTING sender,
      handle_radiobutton_selected FOR EVENT radiobutton_click OF zcl_dynscreen_radiobutton_grp
        IMPORTING sender.

ENDCLASS.

NEW lcl( )->run( ).


CLASS lcl IMPLEMENTATION.

  METHOD run.
* ---------------------------------------------------------------------
    DATA:
      lo_screen     TYPE REF TO zcl_dynscreen_screen,
      lo_btn        TYPE REF TO zcl_dynscreen_button,
      lo_pa_matnr1  TYPE REF TO zcl_dynscreen_parameter,
      lo_pa_matnr2  TYPE REF TO zcl_dynscreen_parameter,
      lo_so_vbeln   TYPE REF TO zcl_dynscreen_selectoption,
      lo_pa_ebeln   TYPE REF TO zcl_dynscreen_parameter,
      lo_rb_grp1    TYPE REF TO zcl_dynscreen_radiobutton_grp,
      lo_rb_option1 TYPE REF TO zcl_dynscreen_radiobutton,
      lo_rb_option2 TYPE REF TO zcl_dynscreen_radiobutton,
      lo_pa_program TYPE REF TO zcl_dynscreen_parameter,
      lx            TYPE REF TO cx_root.

* ---------------------------------------------------------------------
    lo_screen = NEW #( ).
    lo_screen->set_pretty_print( ).
    lo_screen->set_text( 'Selection Screen Generation Test' ).

    TRY.
        lo_pa_matnr1 = NEW #( iv_type = 'MARA-MATNR' ).
        lo_pa_matnr1->set_value( 'DEFAULT' ).
        lo_pa_matnr1->set_text( lo_pa_matnr1->get_text( ) && ` ` && '1' ).
        lo_screen->add( lo_pa_matnr1 ).
        lo_pa_matnr2 = NEW #( iv_type = 'MARA-MATNR' ).
        lo_pa_matnr2->set_text( lo_pa_matnr2->get_text( ) && ` ` && '2' ).
        lo_screen->add( lo_pa_matnr2 ).
      CATCH zcx_dynscreen_type_error
            zcx_dynscreen_value_error
            zcx_dynscreen_incompatible
            zcx_dynscreen_too_many_elems INTO lx.
        MESSAGE lx TYPE 'E'.
    ENDTRY.

    TRY.
        lo_btn = NEW #( iv_text = 'Testbutton' iv_length = 20 ).
        SET HANDLER handle_button_click FOR lo_btn.
        lo_screen->add( lo_btn ).
      CATCH zcx_dynscreen_type_error
            zcx_dynscreen_incompatible
            zcx_dynscreen_too_many_elems INTO lx.
        MESSAGE lx TYPE 'E'.
    ENDTRY.


    TRY.
        lo_so_vbeln = NEW #( iv_type = 'VBAK-VBELN' ).
        lo_screen->add( lo_so_vbeln ).
        lo_pa_ebeln = NEW #( iv_type = 'EKKO-EBELN' ).
        lo_screen->add( lo_pa_ebeln ).
        lo_pa_program = NEW #( iv_type = 'RS38M-PROGRAMM' ).
        lo_screen->add( lo_pa_program ).
        SET HANDLER handle_program_value_request FOR lo_pa_program.
      CATCH zcx_dynscreen_type_error
            zcx_dynscreen_value_error
            zcx_dynscreen_incompatible
            zcx_dynscreen_too_many_elems INTO lx.
        MESSAGE lx TYPE 'E'.
    ENDTRY.

    TRY.
        lo_rb_option1 = NEW #( iv_text = 'Option 1' ).
        lo_rb_option2 = NEW #( iv_text = 'Option 2' ).
        lo_rb_grp1    = NEW #( it_radiobuttons = VALUE #( ( lo_rb_option1 )
                                                          ( lo_rb_option2 ) ) ).
        lo_screen->add( lo_rb_grp1 ).
        SET HANDLER handle_radiobutton_selected FOR lo_rb_grp1.
      CATCH zcx_dynscreen_type_error
            zcx_dynscreen_incompatible
            zcx_dynscreen_too_many_elems INTO lx.
        MESSAGE lx TYPE 'E'.
    ENDTRY.

    TRY.
        lo_screen->display( ).

* ---------------------------------------------------------------------
        " ev_value is "type any"
        DATA lv_matnr1 TYPE mara-matnr.
        lo_pa_matnr1->get_value( IMPORTING ev_value = lv_matnr1 ).

* ---------------------------------------------------------------------
        " all io elements have a generated variable reference held internally
        " which can be accessed with method GET_VALUE_REF
        FIELD-SYMBOLS <lv_matnr2> TYPE mara-matnr.
        DATA(lv_matnr2_ref) = lo_pa_matnr2->get_value_ref( ).
        ASSIGN lv_matnr2_ref->* TO <lv_matnr2>.

* ---------------------------------------------------------------------
        DATA lr_vbeln TYPE RANGE OF vbak-vbeln.
        lo_so_vbeln->get_value( IMPORTING ev_value = lr_vbeln ).

* ---------------------------------------------------------------------
        " method GET_VALUE also has a returning parameter of type string
        " if the io element is not of type string, using this will cause two type conversions
        " in this case:
        " internal value of type EKKO-EBELN cast to string -> string cast to LV_EBELN of type EKKO_EBELN
        DATA lv_ebeln TYPE ekko-ebeln.
        lv_ebeln = lo_pa_ebeln->get_value( ).

* ---------------------------------------------------------------------
        WRITE: `lo_pa_matnr1: `, lv_matnr1, /.
        ULINE.

        WRITE: `lo_pa_matnr2: `, <lv_matnr2>, /.
        ULINE.

        WRITE: 'lo_so_vbeln:', /.
        LOOP AT lr_vbeln ASSIGNING FIELD-SYMBOL(<lrs_vbeln>).
          WRITE: <lrs_vbeln>-sign, ` `, <lrs_vbeln>-option, ` `, <lrs_vbeln>-low, ` `, <lrs_vbeln>-high, /.
        ENDLOOP.
        ULINE.

        WRITE: `lo_pa_ebeln: `, lv_ebeln, /.
        ULINE.

        WRITE: `lo_pa_program: `, lo_pa_program->get_value( ), /.
        ULINE.

        WRITE: `lo_rb_option1: `, lo_rb_option1->get_value( ), /.
        WRITE: `lo_rb_option2: `, lo_rb_option2->get_value( ), /.
        ULINE.

* ---------------------------------------------------------------------
        MESSAGE 'Selection successful!' TYPE 'S'.

      CATCH zcx_dynscreen_canceled INTO DATA(lx_canceled).
        MESSAGE lx_canceled TYPE 'S' DISPLAY LIKE 'E'.
      CATCH zcx_dynscreen_value_error
            zcx_dynscreen_syntax_error INTO lx.
        MESSAGE lx TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD handle_button_click.
* ---------------------------------------------------------------------
    MESSAGE 'Button pressed!' TYPE 'I'.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD handle_program_value_request.
* ---------------------------------------------------------------------
    FIELD-SYMBOLS:
      <lv_program> TYPE rs38m-programm.

    ASSIGN sender->zif_dynscreen_request_event~md_request_value->* TO <lv_program>.

    PERFORM program_directory IN PROGRAM saplwbabap USING <lv_program> abap_true.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD handle_radiobutton_selected.
* ---------------------------------------------------------------------
    MESSAGE sender->get_selected_radiobutton( )->get_text( ) && ` selected!` TYPE 'S'.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
