CLASS zcl_dynscreen_base DEFINITION PUBLIC ABSTRACT CREATE PUBLIC GLOBAL FRIENDS zcl_dynscreen_io_element.
  PUBLIC SECTION.
    INTERFACES if_serializable_object .
    TYPES:
      mty_id      TYPE n LENGTH 4,
      mty_varname TYPE c LENGTH 30,
      BEGIN OF mty_variable,
        id   TYPE mty_id,
        name TYPE mty_varname,
        ref  TYPE REF TO zcl_dynscreen_io_element,
      END OF mty_variable,
      mty_variables_tt TYPE SORTED TABLE OF mty_variable WITH UNIQUE KEY id,
      mty_srcname      TYPE c LENGTH 40.
    CONSTANTS:
      BEGIN OF mc_gentarget_incnames,
        func_pool   TYPE mty_srcname VALUE 'SAPLZ_DYNSCREEN000' ##NO_TEXT,
        func_group  TYPE mty_srcname VALUE 'Z_DYNSCREEN000' ##NO_TEXT,
        func_module TYPE mty_srcname VALUE 'Z_DYNSCREEN_GENERATION_T000' ##NO_TEXT,
        top_inc     TYPE mty_srcname VALUE 'LZ_DYNSCREEN000TO2' ##NO_TEXT,
        func_inc    TYPE mty_srcname VALUE 'LZ_DYNSCREEN000FUN' ##NO_TEXT,
      END OF mc_gentarget_incnames,
      mc_selection_ok       TYPE sy-subrc VALUE 0 ##NO_TEXT,
      mc_selection_canceled TYPE sy-subrc VALUE 4 ##NO_TEXT,
      BEGIN OF mc_com,
        exit TYPE sy-ucomm VALUE '_%_%_EXIT_%_%_',
      END OF mc_com.
    CLASS-METHODS:
      class_constructor.
    METHODS:
      constructor,
      get_variables RETURNING VALUE(rt_variables) TYPE mty_variables_tt,
      get_text RETURNING VALUE(rv_text) TYPE textpooltx,
      set_text IMPORTING !iv_text TYPE textpooltx,
      add IMPORTING !io_screen_element TYPE REF TO zcl_dynscreen_base,
      set_id IMPORTING !iv_id TYPE i,
      get_id RETURNING VALUE(rv_id) TYPE i.
  PROTECTED SECTION.
    TYPE-POOLS:
      abap.
    TYPES:
      BEGIN OF mty_screen_element,
        id  TYPE mty_id,
        ref TYPE REF TO zcl_dynscreen_base,
        var TYPE abap_bool,
      END OF mty_screen_element,
      mty_screen_elements_tt TYPE SORTED TABLE OF mty_screen_element WITH UNIQUE KEY id,
      mty_source             TYPE c LENGTH 254,
      mty_source_tt          TYPE STANDARD TABLE OF mty_source WITH DEFAULT KEY,
      BEGIN OF mty_generated,
        srcname TYPE mty_srcname,
      END OF mty_generated,
      mty_generated_tt TYPE STANDARD TABLE OF mty_generated WITH DEFAULT KEY.
    CONSTANTS:
      BEGIN OF mc_syn,
        sq                TYPE c LENGTH 1  VALUE '''', " single quote
        dq                TYPE c LENGTH 1  VALUE '"',  " double quote
        dat_prefix        TYPE c LENGTH 1  VALUE 'D',
        var_prefix        TYPE c LENGTH 2  VALUE 'V_',
        tit_prefix        TYPE c LENGTH 2  VALUE 'T_',
        blk_prefix        TYPE c LENGTH 2  VALUE 'B_',
        tab_prefix        TYPE c LENGTH 4  VALUE 'TAB_',
        btn_prefix        TYPE c LENGTH 3  VALUE 'BT_',
        ucm_prefix        TYPE c LENGTH 3  VALUE 'UC_',
        data              TYPE c LENGTH 4  VALUE 'DATA',
        param             TYPE c LENGTH 10 VALUE 'PARAMETERS',
        selopt            TYPE c LENGTH 14 VALUE 'SELECT-OPTIONS',
        type              TYPE c LENGTH 4  VALUE 'TYPE',
        default           TYPE c LENGTH 7  VALUE 'DEFAULT',
        selscreen         TYPE c LENGTH 16 VALUE 'SELECTION-SCREEN',
        begin             TYPE c LENGTH 8  VALUE 'BEGIN OF',
        end               TYPE c LENGTH 6  VALUE 'END OF',
        screen            TYPE c LENGTH 6  VALUE 'SCREEN',
        subscreen         TYPE c LENGTH 12 VALUE 'AS SUBSCREEN',
        block             TYPE c LENGTH 5  VALUE 'BLOCK',
        tab               TYPE c LENGTH 3  VALUE 'TAB',
        tabblock          TYPE c LENGTH 12 VALUE 'TABBED BLOCK',
        line              TYPE c LENGTH 4  VALUE 'LINE',
        title             TYPE c LENGTH 5  VALUE 'TITLE',
        modif             TYPE c LENGTH 8  VALUE 'MODIF ID',
        nointv            TYPE c LENGTH 12 VALUE 'NO INTERVALS',
        window            TYPE c LENGTH 9  VALUE 'AS WINDOW',
        oblig             TYPE c LENGTH 10 VALUE 'OBLIGATORY',
        nodisp            TYPE c LENGTH 10 VALUE 'NO-DISPLAY',
        vislen            TYPE c LENGTH 14 VALUE 'VISIBLE LENGTH',
        length            TYPE c LENGTH 6  VALUE 'LENGTH',
        decimals          TYPE c LENGTH 8  VALUE 'DECIMALS',
        chkbox            TYPE c LENGTH 11 VALUE 'AS CHECKBOX',
        radiob            TYPE c LENGTH 17 VALUE 'RADIOBUTTON GROUP',
        lstbox            TYPE c LENGTH 25 VALUE 'AS LISTBOX VISIBLE LENGTH',
        ucomm             TYPE c LENGTH 12 VALUE 'USER-COMMAND',
        button            TYPE c LENGTH 10 VALUE 'PUSHBUTTON',
        cline             TYPE c LENGTH 71 VALUE '* ---------------------------------------------------------------------',
        eve_init          TYPE c LENGTH 15 VALUE 'LOAD-OF-PROGRAM',
        eve_selscreen     TYPE c LENGTH 19 VALUE 'AT SELECTION-SCREEN',
        eve_selscreen_out TYPE c LENGTH 26 VALUE 'AT SELECTION-SCREEN OUTPUT',
        eve_selscreen_on  TYPE c LENGTH 23 VALUE 'AT SELECTION-SCREEN ON',
        eve_selscreen_obl TYPE c LENGTH 28 VALUE 'AT SELECTION-SCREEN ON BLOCK',
        eve_selscreen_org TYPE c LENGTH 40 VALUE 'AT SELECTION-SCREEN ON RADIOBUTTON GROUP',
        eve_selscreen_ovr TYPE c LENGTH 40 VALUE 'AT SELECTION-SCREEN ON VALUE-REQUEST FOR',
        eve_selscreen_ohr TYPE c LENGTH 39 VALUE 'AT SELECTION-SCREEN ON HELP-REQUEST FOR',
      END OF mc_syn.
    CLASS-DATA:
      mv_last_id TYPE mty_id.
    DATA:
      mv_id          TYPE mty_id,
      mv_is_variable TYPE abap_bool,
      mv_text        TYPE textpooltx,
      mt_elements    TYPE mty_screen_elements_tt,
      mt_source      TYPE mty_source_tt,
      mt_source_ac   TYPE mty_source_tt,
      BEGIN OF ms_source_eve,
        t_init          TYPE mty_source_tt,
        t_selscreen     TYPE mty_source_tt,
        t_selscreen_out TYPE mty_source_tt,
        t_selscreen_on  TYPE mty_source_tt,
        t_selscreen_obl TYPE mty_source_tt,
        t_selscreen_org TYPE mty_source_tt,
        t_selscreen_ovr TYPE mty_source_tt,
        t_selscreen_ohr TYPE mty_source_tt,
      END OF ms_source_eve,
      mt_variables TYPE mty_variables_tt,
      mt_textpool  TYPE SORTED TABLE OF textpool WITH UNIQUE KEY id key.
    CLASS-METHODS:
      set_last_id IMPORTING !iv_last_id TYPE i,
      get_last_id RETURNING VALUE(rv_id) TYPE i.
    METHODS:
      generate_value_transport RETURNING VALUE(rt_valtrans_source) TYPE mty_source_tt,
      generate_events RETURNING VALUE(rt_events_source) TYPE mty_source_tt,
      generate_texts,
      is_var FINAL RETURNING VALUE(rv_is_var) TYPE abap_bool,
      generate,
      generate_open ABSTRACT,
      generate_close ABSTRACT,
      pretty_print FINAL CHANGING ct_source TYPE mty_source_tt.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_base IMPLEMENTATION.


  METHOD add.
* ---------------------------------------------------------------------
    IF lines( mt_elements ) < 199.
      INSERT VALUE #( id  = io_screen_element->get_id( )
                      ref = io_screen_element
                      var = io_screen_element->is_var( ) ) INTO TABLE mt_elements.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD class_constructor.
* ---------------------------------------------------------------------
    " every object from a class inheriting from this class has to have a unique id
    " when this class is accessed for the first time set mv_last_id to zero (the member variable is static)
    mv_last_id = 0.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD constructor.
* ---------------------------------------------------------------------
    IF get_last_id( ) IS INITIAL.
      " if there is no last id, set current id to 1
      set_id( 1 ).
      set_last_id( 1 ).
    ELSE.
      " set current id to last id plus one
      set_id( get_last_id( ) + 1 ).
      set_last_id( get_last_id( ) + 1 ).
    ENDIF.

* ---------------------------------------------------------------------
    mv_is_variable = abap_false.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate.
* ---------------------------------------------------------------------
    DATA:
      lo_io TYPE REF TO zcl_dynscreen_io_element.
    FIELD-SYMBOLS:
      <ls_element> LIKE LINE OF mt_elements.

* ---------------------------------------------------------------------
    FREE: mt_source, mt_source_ac, ms_source_eve.

* ---------------------------------------------------------------------
    generate_open( ).
    LOOP AT mt_elements ASSIGNING <ls_element>.
      <ls_element>-ref->generate( ).
      APPEND LINES OF <ls_element>-ref->mt_source TO mt_source.
      INSERT LINES OF <ls_element>-ref->mt_variables INTO TABLE mt_variables.
      " if element is a variable (parameters or select options)
      IF <ls_element>-var = abap_true.
        lo_io ?= <ls_element>-ref.
        INSERT VALUE #( id   = <ls_element>-id
                        name = lo_io->get_var_name( )
                        ref  = lo_io                 ) INTO TABLE mt_variables.
      ENDIF.
      APPEND LINES OF <ls_element>-ref->mt_source_ac TO mt_source_ac.
      APPEND LINES OF <ls_element>-ref->ms_source_eve-t_init          TO ms_source_eve-t_init.
      APPEND LINES OF <ls_element>-ref->ms_source_eve-t_selscreen     TO ms_source_eve-t_selscreen.
      APPEND LINES OF <ls_element>-ref->ms_source_eve-t_selscreen_out TO ms_source_eve-t_selscreen_out.
      APPEND LINES OF <ls_element>-ref->ms_source_eve-t_selscreen_on  TO ms_source_eve-t_selscreen_on.
      APPEND LINES OF <ls_element>-ref->ms_source_eve-t_selscreen_obl TO ms_source_eve-t_selscreen_obl.
      APPEND LINES OF <ls_element>-ref->ms_source_eve-t_selscreen_org TO ms_source_eve-t_selscreen_org.
      APPEND LINES OF <ls_element>-ref->ms_source_eve-t_selscreen_ovr TO ms_source_eve-t_selscreen_ovr.
      APPEND LINES OF <ls_element>-ref->ms_source_eve-t_selscreen_ohr TO ms_source_eve-t_selscreen_ohr.
    ENDLOOP.
    generate_close( ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_events.
* ---------------------------------------------------------------------
    IF ms_source_eve-t_init IS NOT INITIAL.
      APPEND mc_syn-eve_init && '.' TO rt_events_source.
      APPEND LINES OF ms_source_eve-t_init TO rt_events_source.
    ENDIF.

* ---------------------------------------------------------------------
    APPEND mc_syn-eve_selscreen && '.' TO rt_events_source.
    APPEND LINES OF ms_source_eve-t_selscreen TO rt_events_source.
    APPEND `IF sy-ucomm = '` && mc_com-exit && `'.` TO rt_events_source.
    APPEND 'LEAVE TO SCREEN 0.' TO rt_events_source.
    APPEND 'ENDIF.' TO rt_events_source.

* ---------------------------------------------------------------------
    IF ms_source_eve-t_selscreen_out IS NOT INITIAL.
      APPEND mc_syn-eve_selscreen_out && '.' TO rt_events_source.
      APPEND LINES OF ms_source_eve-t_selscreen_out TO rt_events_source.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_texts.
* ---------------------------------------------------------------------
    CONSTANTS:
      lc_id_title     TYPE c LENGTH  1 VALUE 'R',
      lc_id_seltx     TYPE c LENGTH  1 VALUE 'S',
      lc_seltx_prefln TYPE i           VALUE 8,           " selection text needs to be offset by this amount
      lc_seltx_ddic   TYPE c LENGTH 11 VALUE 'D       .', " selection text needs to contain this to use available ddic texts
      lc_seltx_ddicln TYPE i           VALUE 9,           " text length seems to bet set to 9 for ddic entries (but it also works if 0 is provided)
      lc_tab_body     TYPE c LENGTH  2 VALUE '[]'.
    DATA:
      lv_text  TYPE textpooltx,
      lv_txlen TYPE textpoolln.

* ---------------------------------------------------------------------
    FREE mt_textpool.

* ---------------------------------------------------------------------
    " append line for report title
    lv_text  = get_text( ).
    lv_txlen = strlen( lv_text ).
    APPEND VALUE #( id     = lc_id_title
                    key    = ''
                    entry  = lv_text
                    length = lv_txlen    ) TO mt_textpool.

* ---------------------------------------------------------------------
    " append lines for io element texts
    LOOP AT mt_variables ASSIGNING FIELD-SYMBOL(<ls_var>).
      FREE: lv_text, lv_txlen.

      lv_text = <ls_var>-ref->get_text( ).
      IF lv_text IS INITIAL.
        " no text set -> no need to create textpool entry
        CONTINUE.
      ENDIF.

      IF lv_text = <ls_var>-ref->get_ddic_text( ).
        lv_text  = lc_seltx_ddic.
        lv_txlen = lc_seltx_ddicln.
      ELSE.
        lv_txlen = strlen( lv_text ).
        lv_txlen = lv_txlen + lc_seltx_prefln.
        SHIFT lv_text BY lc_seltx_prefln PLACES RIGHT IN CHARACTER MODE.
      ENDIF.

      APPEND VALUE #( id     = lc_id_seltx
                      key    = replace( val = <ls_var>-name sub = lc_tab_body with = '' )
                      entry  = lv_text
                      length = lv_txlen      ) TO mt_textpool.
    ENDLOOP.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_value_transport.
* ---------------------------------------------------------------------
* because we generate a report and run it using the submit command
* there is no official way to transport values provided to the generated report
* as a solution, the class ZWD_DYNSCREEN_TRANSPORT is used to save the values to memory
* the method ADD_VALUE is called once for every entry of the table MT_VARIABLES
* ---------------------------------------------------------------------
    FREE rt_valtrans_source.

* ---------------------------------------------------------------------
    APPEND 'IF io_value_transport IS BOUND.' TO rt_valtrans_source.

* ---------------------------------------------------------------------
    " remember subrc
    APPEND 'io_value_transport->set_subrc( gv_subrc ).' TO rt_valtrans_source.

* ---------------------------------------------------------------------
    " remember variable values
    LOOP AT mt_variables ASSIGNING FIELD-SYMBOL(<ls_var>).
      APPEND
      `io_value_transport->add_value( iv_fname = '` && <ls_var>-name && `' iv_value = ` && <ls_var>-name && ` ).`
      TO rt_valtrans_source.
    ENDLOOP.

* ---------------------------------------------------------------------
    APPEND 'ENDIF.' TO rt_valtrans_source.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_id.
* ---------------------------------------------------------------------
    rv_id = mv_id.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_last_id.
* ---------------------------------------------------------------------
    rv_id = mv_last_id.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_text.
* ---------------------------------------------------------------------
    rv_text = mv_text.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_variables.
* ---------------------------------------------------------------------
    rt_variables = mt_variables.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD is_var.
* ---------------------------------------------------------------------
    rv_is_var = mv_is_variable.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD pretty_print.
    DATA: ls_settings  TYPE rseumod,
          lt_source    TYPE rswsourcet,
          lt_lineindex TYPE STANDARD TABLE OF edlineindx.
    CALL FUNCTION 'RS_WORKBENCH_CUSTOMIZING'
      EXPORTING
        suppress_dialog = abap_true
      IMPORTING
        setting         = ls_settings.
    IF ls_settings-indent <> '2'.
      CALL FUNCTION 'RS_WB_CUSTOMIZING_SET_VALUE'
        EXPORTING
          name  = 'INDENT'
          value = '2'.
    ENDIF.

    CALL FUNCTION 'PRETTY_PRINTER'
      EXPORTING
        inctoo             = abap_false
      TABLES
        ntext              = ct_source
        otext              = ct_source
      EXCEPTIONS
        enqueue_table_full = 1
        include_enqueued   = 2
        include_readerror  = 3
        include_writeerror = 4
        OTHERS             = 5.

    IF sy-subrc <> 0.
*   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    MOVE-CORRESPONDING ct_source TO lt_source.
    PERFORM change_case_for_content_new IN PROGRAM sapllocal_edt1 IF FOUND
      TABLES lt_source
             lt_lineindex
      USING  'HIKEY'.
    MOVE-CORRESPONDING lt_source TO ct_source.
    IF ls_settings-indent <> '2'.
      CALL FUNCTION 'RS_WB_CUSTOMIZING_SET_VALUE'
        EXPORTING
          name  = 'INDENT'
          value = ls_settings-indent.
    ENDIF.
  ENDMETHOD.


  METHOD set_id.
* ---------------------------------------------------------------------
    mv_id = iv_id.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_last_id.
* ---------------------------------------------------------------------
    mv_last_id = iv_last_id.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_text.
* ---------------------------------------------------------------------
    mv_text = iv_text.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
