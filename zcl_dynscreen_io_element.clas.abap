CLASS zcl_dynscreen_io_element DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_base ABSTRACT CREATE PUBLIC
GLOBAL FRIENDS zcl_dynscreen_base zcl_dynscreen_callback.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF mty_s_generic_type_info,
        datatype  TYPE dd01l-datatype,
        length    TYPE dd01l-leng,
        decimals  TYPE dd01l-decimals,
        lowercase TYPE abap_bool,
      END OF mty_s_generic_type_info.
    CONSTANTS:
      mc_conv_write TYPE c LENGTH 1 VALUE 'W' ##NO_TEXT,
      mc_conv_xml   TYPE c LENGTH 1 VALUE 'X' ##NO_TEXT,
      mc_conv_cast  TYPE c LENGTH 1 VALUE 'C' ##NO_TEXT,
      BEGIN OF mc_type,
        c          TYPE dd01l-datatype VALUE 'CHAR' ##NO_TEXT,
        string     TYPE dd01l-datatype VALUE 'STRG' ##NO_TEXT,
        x          TYPE dd01l-datatype VALUE 'RAW' ##NO_TEXT,
        n          TYPE dd01l-datatype VALUE 'NUMC' ##NO_TEXT,
        i          TYPE dd01l-datatype VALUE 'INT4' ##NO_TEXT,
        d          TYPE dd01l-datatype VALUE 'DATS' ##NO_TEXT,
        t          TYPE dd01l-datatype VALUE 'TIMS' ##NO_TEXT,
        p          TYPE dd01l-datatype VALUE 'DEC' ##NO_TEXT,
        decfloat16 TYPE dd01l-datatype VALUE 'D16S' ##NO_TEXT,
        decfloat34 TYPE dd01l-datatype VALUE 'D34S' ##NO_TEXT,
      END OF mc_type.
    METHODS:
      add REDEFINITION,
      get_ddic_text RETURNING VALUE(rv_ddic_text) TYPE textpooltx,
      set_ddic_text IMPORTING iv_ddic_text TYPE textpooltx,
      set_generic_type IMPORTING is_type_info TYPE mty_s_generic_type_info
                       RAISING   zcx_dynscreen_type_error,
      constructor IMPORTING iv_type         TYPE typename OPTIONAL
                            is_generic_type TYPE mty_s_generic_type_info OPTIONAL
                            iv_text         TYPE textpooltx OPTIONAL
                  RAISING   zcx_dynscreen_type_error,
      get_type RETURNING VALUE(rv_type) TYPE typename,
      get_value IMPORTING iv_conversion   TYPE c DEFAULT mc_conv_cast
                EXPORTING ev_value        TYPE any
                RETURNING VALUE(rv_value) TYPE string
                RAISING   zcx_dynscreen_value_error,
      set_type IMPORTING iv_type TYPE typename
               RAISING   zcx_dynscreen_type_error,
      set_value IMPORTING iv_conversion TYPE c DEFAULT mc_conv_cast
                          iv_value      TYPE any OPTIONAL
                          iv_value_str  TYPE string OPTIONAL
                            PREFERRED PARAMETER iv_value
                RAISING   zcx_dynscreen_value_error,
      get_value_ref RETURNING VALUE(rd_value) TYPE REF TO data,
      set_ucomm IMPORTING iv_ucomm TYPE sscrfields-ucomm,
      get_ucomm RETURNING VALUE(rv_ucomm) TYPE sscrfields-ucomm,
      set_visible IMPORTING iv_visible TYPE abap_bool DEFAULT abap_true,
      get_visible RETURNING VALUE(rv_visible) TYPE abap_bool,
      set_obligatory IMPORTING iv_obligatory TYPE abap_bool DEFAULT abap_true,
      get_obligatory RETURNING VALUE(rv_obligatory) TYPE abap_bool,
      set_input IMPORTING iv_input TYPE abap_bool DEFAULT abap_true,
      get_input RETURNING VALUE(rv_input) TYPE abap_bool.
  PROTECTED SECTION.
    CONSTANTS:
      mc_type_generic TYPE typename VALUE '_%_%_GENERIC_%_%_'. "#EC NOTEXT
    DATA:
      mv_ucomm               TYPE sscrfields-ucomm,
      mo_elemdescr           TYPE REF TO cl_abap_elemdescr,
      mv_ddic_text           TYPE c LENGTH 40,
      mv_type                TYPE typename,
      ms_generic_type_info   TYPE mty_s_generic_type_info,
      mv_generic_type_string TYPE string,
      mv_visible             TYPE abap_bool,
      mv_obligatory          TYPE abap_bool,
      mv_input               TYPE abap_bool,
      mv_value               TYPE string,
      md_value               TYPE REF TO data.
    METHODS:
      get_var_name RETURNING VALUE(rv_var_name) TYPE mty_varname,
      get_text_from_ddic RETURNING VALUE(rv_text) TYPE textpooltx,
      get_text_generic RETURNING VALUE(rv_text) TYPE textpooltx,
      append_uc_event_src.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_io_element IMPLEMENTATION.


  METHOD add.
* ---------------------------------------------------------------------
    " io elements usually have no children
    RAISE EXCEPTION TYPE zcx_dynscreen_incompatible
      EXPORTING
        parent_class       = me
        incompatible_class = io_screen_element.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD append_uc_event_src.
* ---------------------------------------------------------------------
    APPEND
    `  IF sscrfields-ucomm = '` && mc_syn-ucm_prefix && mv_id && `'. `    ##NO_TEXT
    TO ms_source_eve-t_selscreen.
    IF mv_is_variable = abap_true.
      DATA(lv_value) = `iv_value = ` && get_var_name( ) ##NO_TEXT.
    ELSE.
      lv_value = ''.
    ENDIF.
    APPEND
    `    go_cb->raise_uc_event( exporting iv_id = '` && mv_id &&   ##NO_TEXT
    `' ` && lv_value && ` changing cv_ucomm = sscrfields-ucomm ).` ##NO_TEXT
    TO ms_source_eve-t_selscreen.
    APPEND
    `  ENDIF.`                                                     ##NO_TEXT
    TO ms_source_eve-t_selscreen.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( ).

* ---------------------------------------------------------------------
    IF iv_type IS NOT INITIAL
    AND iv_type <> mc_type_generic.
      set_type( iv_type ).
    ELSEIF is_generic_type IS NOT INITIAL.
      set_generic_type( is_generic_type ).
    ELSE.
      RAISE EXCEPTION TYPE zcx_dynscreen_type_error
        EXPORTING
          textid = zcx_dynscreen_type_error=>no_type_provided.
    ENDIF.
    set_text( iv_text ).
    mv_is_variable = abap_true.

* ---------------------------------------------------------------------
    IF mv_type <> mc_type_generic.
      set_ddic_text( get_text_from_ddic( ) ).
      IF get_text( ) IS INITIAL.
        set_text( get_ddic_text( ) ).
      ENDIF.
    ELSE.
      IF get_text( ) IS INITIAL.
        set_text( get_text_generic( ) ).
      ENDIF.
    ENDIF.

* ---------------------------------------------------------------------
    mv_visible = abap_true.
    mv_input   = abap_true.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_ddic_text.
* ---------------------------------------------------------------------
    rv_ddic_text = mv_ddic_text.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_input.
* ---------------------------------------------------------------------
    rv_input = mv_input.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_obligatory.
* ---------------------------------------------------------------------
    rv_obligatory = mv_obligatory.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_text_from_ddic.
* ---------------------------------------------------------------------
    IF mv_type = mc_type_generic.
      rv_text = mc_type_generic.
      RETURN.
    ENDIF.
    IF mo_elemdescr->is_ddic_type( ) = abap_true.
      TRY.
          IF strlen( mo_elemdescr->get_ddic_field( )-scrtext_l ) > 30.
            rv_text = mo_elemdescr->get_ddic_field( )-scrtext_m.
          ELSE.
            rv_text = mo_elemdescr->get_ddic_field( )-scrtext_l.
          ENDIF.
        CATCH cx_root.
          rv_text = mv_type.
      ENDTRY.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_text_generic.
* ---------------------------------------------------------------------
    rv_text = 'Generic'(001) && ` ` && mv_generic_type_string.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_type.
* ---------------------------------------------------------------------
    rv_type = mv_type.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_ucomm.
* ---------------------------------------------------------------------
    rv_ucomm = mv_ucomm.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_value.
* ---------------------------------------------------------------------
    DATA:
      lv_value                TYPE c LENGTH 1000,
      lx_transformation_error TYPE REF TO cx_transformation_error.
    FIELD-SYMBOLS:
      <lv_value> TYPE any.

* ---------------------------------------------------------------------
    FREE ev_value.

* ---------------------------------------------------------------------
    ASSIGN md_value->* TO <lv_value>.
    IF <lv_value> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE zcx_dynscreen_value_error.
    ENDIF.

* ---------------------------------------------------------------------
    IF mv_value IS NOT INITIAL.
      TRY.
          CALL TRANSFORMATION id SOURCE XML mv_value RESULT value = <lv_value>.
        CATCH cx_transformation_error INTO lx_transformation_error.
          RAISE EXCEPTION TYPE zcx_dynscreen_value_error
            EXPORTING
              textid   = zcx_dynscreen_value_error=>value_error_with_prev
              previous = lx_transformation_error.
      ENDTRY.
    ENDIF.

* ---------------------------------------------------------------------
    CASE iv_conversion.

* ---------------------------------------------------------------------
      WHEN mc_conv_xml.
        IF ev_value IS SUPPLIED.
          ev_value = mv_value.
        ENDIF.
        rv_value = mv_value.

* ---------------------------------------------------------------------
      WHEN mc_conv_write.
        WRITE <lv_value> TO lv_value.
        IF ev_value IS SUPPLIED.
          ev_value = lv_value.
        ENDIF.
        rv_value = lv_value.

* ---------------------------------------------------------------------
      WHEN mc_conv_cast.
        IF ev_value IS SUPPLIED.
          ev_value = <lv_value>.
        ENDIF.
        rv_value = <lv_value>.

* ---------------------------------------------------------------------
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_dynscreen_value_error
          EXPORTING
            textid     = zcx_dynscreen_value_error=>invalid_conversion
            conversion = iv_conversion.
    ENDCASE.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_value_ref.
* ---------------------------------------------------------------------
    rd_value = md_value.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_var_name.
* ---------------------------------------------------------------------
    rv_var_name = mc_syn-var_prefix && mv_id.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_visible.
* ---------------------------------------------------------------------
    rv_visible = mv_visible.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_ddic_text.
* ---------------------------------------------------------------------
    mv_ddic_text = iv_ddic_text.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_generic_type.
* ---------------------------------------------------------------------
    DATA:
      lv_length     TYPE i,
      lv_decimals   TYPE i,
      lx_type_error TYPE REF TO zcx_dynscreen_type_error,
      lx_root       TYPE REF TO cx_root.

* ---------------------------------------------------------------------
    TRY.
        FREE ms_generic_type_info.
        ms_generic_type_info = is_type_info.
        mv_type              = mc_type_generic.
        lv_length            = ms_generic_type_info-length.
        lv_decimals          = ms_generic_type_info-decimals.

* ---------------------------------------------------------------------
        CASE ms_generic_type_info-datatype.

* ---------------------------------------------------------------------
          WHEN mc_type-c. " Character String
            mo_elemdescr = cl_abap_elemdescr=>get_c( lv_length ).
            mv_generic_type_string = `C ` && mc_syn-length && ` ` && ms_generic_type_info-length.

* ---------------------------------------------------------------------
          WHEN mc_type-string. " Character String of Variable Length
            mo_elemdescr = cl_abap_elemdescr=>get_string( ).
            mv_generic_type_string = 'STRING'.

* ---------------------------------------------------------------------
          WHEN mc_type-x. " Uninterpreted sequence of bytes
            mo_elemdescr = cl_abap_elemdescr=>get_x( lv_length ).
            mv_generic_type_string = `X ` && mc_syn-length && ` ` && ms_generic_type_info-length.

* ---------------------------------------------------------------------
          WHEN mc_type-n. " Character string with only digits
            mo_elemdescr = cl_abap_elemdescr=>get_n( lv_length ).
            mv_generic_type_string = `N ` && mc_syn-length && ` ` && ms_generic_type_info-length.

* ---------------------------------------------------------------------
          WHEN mc_type-i. " 4-byte integer, integer number with sign
            mo_elemdescr = cl_abap_elemdescr=>get_i( ).
            mv_generic_type_string = 'I'.

* ---------------------------------------------------------------------
          WHEN mc_type-d. " Date field (YYYYMMDD) stored as char(8)
            mo_elemdescr = cl_abap_elemdescr=>get_d( ).
            mv_generic_type_string = 'D'.

* ---------------------------------------------------------------------
          WHEN mc_type-t. " Time field (hhmmss), stored as char(6)
            mo_elemdescr = cl_abap_elemdescr=>get_t( ).
            mv_generic_type_string = 'T'.

* ---------------------------------------------------------------------
          WHEN mc_type-p. " Counter or amount field with comma and sign
            mo_elemdescr = cl_abap_elemdescr=>get_p( p_length   = lv_length
                                                     p_decimals = lv_decimals ).
            mv_generic_type_string = `P ` && mc_syn-length && ` ` && ms_generic_type_info-length && ` ` && mc_syn-decimals && ` ` && ms_generic_type_info-decimals.

* ---------------------------------------------------------------------
          WHEN mc_type-decfloat16. " Decimal Floating Point. 16 Digits, with Scale Field
            mo_elemdescr = cl_abap_elemdescr=>get_decfloat16( ).
            mv_generic_type_string = 'DECFLOAT16'.

* ---------------------------------------------------------------------
          WHEN mc_type-decfloat34. " Decimal Floating Point, 34 Digits, with Scale Field
            mo_elemdescr = cl_abap_elemdescr=>get_decfloat34( ).
            mv_generic_type_string = 'DECFLOAT34'.

* ---------------------------------------------------------------------
          WHEN OTHERS.
            RAISE EXCEPTION TYPE zcx_dynscreen_type_error
              EXPORTING
                textid            = zcx_dynscreen_type_error=>generic_type_not_supported
                generic_data_type = ms_generic_type_info-datatype.

* ---------------------------------------------------------------------
        ENDCASE.

* ---------------------------------------------------------------------
        CREATE DATA md_value TYPE HANDLE mo_elemdescr.

* ---------------------------------------------------------------------
      CATCH zcx_dynscreen_type_error INTO lx_type_error.
        RAISE EXCEPTION lx_type_error.

* ---------------------------------------------------------------------
      CATCH cx_root INTO lx_root.
        RAISE EXCEPTION TYPE zcx_dynscreen_type_error
          EXPORTING
            textid   = zcx_dynscreen_type_error=>type_error_with_prev
            previous = lx_root.

* ---------------------------------------------------------------------
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_input.
* ---------------------------------------------------------------------
    mv_input = iv_input.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_obligatory.
* ---------------------------------------------------------------------
    mv_obligatory = iv_obligatory.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_type.
* ---------------------------------------------------------------------
    DATA:
      lo_typedescr  TYPE REF TO cl_abap_typedescr,
      lx_type_error TYPE REF TO zcx_dynscreen_type_error,
      lx_root       TYPE REF TO cx_root.

* ---------------------------------------------------------------------
    TRY.
        cl_abap_elemdescr=>describe_by_name( EXPORTING  p_name      = iv_type
                                             RECEIVING  p_descr_ref = lo_typedescr
                                             EXCEPTIONS OTHERS      = 1            ).
        IF sy-subrc <> 0.
          " goddamn old school exceptions...
          RAISE EXCEPTION TYPE zcx_dynscreen_type_error
            EXPORTING
              textid    = zcx_dynscreen_type_error=>type_not_found
              type_name = iv_type.
        ENDIF.
        mo_elemdescr ?= lo_typedescr.
        mv_type = iv_type.
        CREATE DATA md_value TYPE HANDLE mo_elemdescr.
      CATCH zcx_dynscreen_type_error INTO lx_type_error.
        RAISE EXCEPTION lx_type_error.
      CATCH cx_root INTO lx_root.
        RAISE EXCEPTION TYPE zcx_dynscreen_type_error
          EXPORTING
            textid   = zcx_dynscreen_type_error=>type_error_with_prev
            previous = lx_root.
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_ucomm.
* ---------------------------------------------------------------------
    mv_ucomm = iv_ucomm.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_value.
* ---------------------------------------------------------------------
    DATA:
      lx_transformation_error TYPE REF TO cx_transformation_error.
    FIELD-SYMBOLS:
      <lv_value> TYPE any.

* ---------------------------------------------------------------------
    IF  iv_value     IS NOT SUPPLIED
    AND iv_value_str IS NOT SUPPLIED.
      RAISE EXCEPTION TYPE zcx_dynscreen_value_error
        EXPORTING
          textid = zcx_dynscreen_value_error=>no_value_provided.
    ENDIF.

* ---------------------------------------------------------------------
    ASSIGN md_value->* TO <lv_value>.
    IF <lv_value> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE zcx_dynscreen_value_error.
    ENDIF.

* ---------------------------------------------------------------------
    CASE iv_conversion.
      WHEN mc_conv_cast.
        IF iv_value IS SUPPLIED.
          <lv_value> = iv_value.
        ELSEIF iv_value_str IS SUPPLIED.
          <lv_value> = iv_value_str.
        ENDIF.
        IF <lv_value> IS INITIAL.
          FREE mv_value.
        ELSE.
          TRY.
              CALL TRANSFORMATION id SOURCE value = <lv_value> RESULT XML mv_value.
            CATCH cx_transformation_error INTO lx_transformation_error.
              RAISE EXCEPTION TYPE zcx_dynscreen_value_error
                EXPORTING
                  textid   = zcx_dynscreen_value_error=>value_error_with_prev
                  previous = lx_transformation_error.
          ENDTRY.
        ENDIF.
      WHEN mc_conv_xml.
        IF iv_value IS NOT INITIAL.
          mv_value = iv_value.
        ELSEIF iv_value_str IS NOT INITIAL.
          mv_value = iv_value_str.
        ENDIF.
        TRY.
            CALL TRANSFORMATION id SOURCE XML mv_value RESULT value = <lv_value>.
          CATCH cx_transformation_error INTO lx_transformation_error.
            RAISE EXCEPTION TYPE zcx_dynscreen_value_error
              EXPORTING
                textid   = zcx_dynscreen_value_error=>value_error_with_prev
                previous = lx_transformation_error.
        ENDTRY.
      WHEN mc_conv_write.
        RAISE EXCEPTION TYPE zcx_dynscreen_value_error
          EXPORTING
            textid = zcx_dynscreen_value_error=>set_value_write_conv.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_dynscreen_value_error
          EXPORTING
            textid     = zcx_dynscreen_value_error=>invalid_conversion
            conversion = iv_conversion.
    ENDCASE.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_visible.
* ---------------------------------------------------------------------
    mv_visible = iv_visible.

* ---------------------------------------------------------------------
  ENDMETHOD.


ENDCLASS.
