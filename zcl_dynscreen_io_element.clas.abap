CLASS zcl_dynscreen_io_element DEFINITION PUBLIC INHERITING FROM zcl_dynscreen_base ABSTRACT CREATE PUBLIC GLOBAL FRIENDS zcl_dynscreen_base.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF mty_s_generic_type_info,
        datatype  TYPE dd01l-datatype,
        length    TYPE dd01l-leng,
        decimals  TYPE dd01l-decimals,
        lowercase TYPE abap_bool,
      END OF mty_s_generic_type_info.
    CONSTANTS:
      mc_conv_write      TYPE c LENGTH 1 VALUE 'W' ##NO_TEXT,
      mc_conv_xml        TYPE c LENGTH 1 VALUE 'X' ##NO_TEXT,
      mc_conv_cast       TYPE c LENGTH 1 VALUE 'C' ##NO_TEXT,
      mc_type_c          TYPE dd01l-datatype VALUE 'CHAR' ##NO_TEXT,
      mc_type_string     TYPE dd01l-datatype VALUE 'STRG' ##NO_TEXT,
      mc_type_x          TYPE dd01l-datatype VALUE 'RAW' ##NO_TEXT,
      mc_type_n          TYPE dd01l-datatype VALUE 'NUMC' ##NO_TEXT,
      mc_type_i          TYPE dd01l-datatype VALUE 'INT4' ##NO_TEXT,
      mc_type_d          TYPE dd01l-datatype VALUE 'DATS' ##NO_TEXT,
      mc_type_t          TYPE dd01l-datatype VALUE 'TIMS' ##NO_TEXT,
      mc_type_p          TYPE dd01l-datatype VALUE 'DEC' ##NO_TEXT,
      mc_type_decfloat16 TYPE dd01l-datatype VALUE 'D16S' ##NO_TEXT,
      mc_type_decfloat34 TYPE dd01l-datatype VALUE 'D34S' ##NO_TEXT.
    METHODS:
      get_ddic_text RETURNING VALUE(rv_ddic_text) TYPE textpooltx,
      set_ddic_text IMPORTING !iv_ddic_text TYPE textpooltx,
      set_generic_type IMPORTING !is_type_info TYPE mty_s_generic_type_info,
      constructor IMPORTING !iv_type         TYPE typename OPTIONAL
                            !is_generic_type TYPE mty_s_generic_type_info OPTIONAL
                            !iv_text         TYPE textpooltx OPTIONAL,
      get_type RETURNING VALUE(rv_type) TYPE typename,
      get_value IMPORTING !iv_conversion  TYPE c DEFAULT mc_conv_cast
                EXPORTING !ev_value       TYPE any
                RETURNING VALUE(rv_value) TYPE string,
      set_type IMPORTING !iv_type TYPE typename,
      set_value IMPORTING !iv_conversion TYPE c DEFAULT mc_conv_cast
                          !iv_value      TYPE any OPTIONAL
                          !iv_value_str  TYPE string OPTIONAL
                            PREFERRED PARAMETER iv_value,
      get_value_ref RETURNING VALUE(rd_value) TYPE REF TO data,
      raise_event ABSTRACT,
      set_ucomm IMPORTING iv_ucomm TYPE sy-ucomm,
      get_ucomm RETURNING VALUE(rv_ucomm) TYPE sy-ucomm.
  PROTECTED SECTION.
    CONSTANTS:
      mc_type_generic TYPE typename VALUE '_%_%_GENERIC_%_%_'. "#EC NOTEXT
    DATA:
      mv_ucomm               TYPE sy-ucomm,
      mo_elemdescr           TYPE REF TO cl_abap_elemdescr,
      mv_ddic_text           TYPE c LENGTH 40,
      mv_type                TYPE typename,
      ms_generic_type_info   TYPE mty_s_generic_type_info,
      mv_generic_type_string TYPE string,
      mv_value               TYPE string,
      md_value               TYPE REF TO data.
    METHODS:
      get_var_name RETURNING VALUE(rv_var_name) TYPE mty_varname,
      get_text_from_ddic RETURNING VALUE(rv_text) TYPE textpooltx,
      get_text_generic RETURNING VALUE(rv_text) TYPE textpooltx.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dynscreen_io_element IMPLEMENTATION.


  METHOD constructor.
* ---------------------------------------------------------------------
    super->constructor( ).

* ---------------------------------------------------------------------
    IF iv_type IS NOT INITIAL
    AND iv_type <> mc_type_generic.
      set_type( iv_type ).
    ELSEIF is_generic_type IS NOT INITIAL.
      set_generic_type( is_generic_type ).
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
  ENDMETHOD.


  METHOD get_ddic_text.
* ---------------------------------------------------------------------
    rv_ddic_text = mv_ddic_text.

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
      lv_value TYPE c LENGTH 1000.
    FIELD-SYMBOLS:
      <lv_value> TYPE any.

* ---------------------------------------------------------------------
    ASSIGN md_value->* TO <lv_value>.
    IF <lv_value> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------
    IF mv_value IS NOT INITIAL.
      TRY.
          CALL TRANSFORMATION id SOURCE XML mv_value RESULT value = <lv_value>.
        CATCH cx_root.
          FREE <lv_value>.
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
        RETURN.
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


  METHOD set_ddic_text.
* ---------------------------------------------------------------------
    mv_ddic_text = iv_ddic_text.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_generic_type.
* ---------------------------------------------------------------------
    DATA:
      lv_length   TYPE i,
      lv_decimals TYPE i.

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
          WHEN mc_type_c. " Character String
            IF lv_length IS NOT INITIAL.
              mo_elemdescr = cl_abap_elemdescr=>get_c( lv_length ).
              mv_generic_type_string = `C ` && mc_syn-length && ` ` && ms_generic_type_info-length.
            ENDIF.

* ---------------------------------------------------------------------
          WHEN mc_type_string. " Character String of Variable Length
            mo_elemdescr = cl_abap_elemdescr=>get_string( ).
            mv_generic_type_string = 'STRING'.

* ---------------------------------------------------------------------
          WHEN mc_type_x. " Uninterpreted sequence of bytes
            IF lv_length IS NOT INITIAL.
              mo_elemdescr = cl_abap_elemdescr=>get_x( lv_length ).
              mv_generic_type_string = `X ` && mc_syn-length && ` ` && ms_generic_type_info-length.
            ENDIF.

* ---------------------------------------------------------------------
          WHEN mc_type_n. " Character string with only digits
            IF lv_length IS NOT INITIAL.
              mo_elemdescr = cl_abap_elemdescr=>get_n( lv_length ).
              mv_generic_type_string = `N ` && mc_syn-length && ` ` && ms_generic_type_info-length.
            ENDIF.

* ---------------------------------------------------------------------
          WHEN mc_type_i. " 4-byte integer, integer number with sign
            mo_elemdescr = cl_abap_elemdescr=>get_i( ).
            mv_generic_type_string = 'I'.

* ---------------------------------------------------------------------
          WHEN mc_type_d. " Date field (YYYYMMDD) stored as char(8)
            mo_elemdescr = cl_abap_elemdescr=>get_d( ).
            mv_generic_type_string = 'D'.

* ---------------------------------------------------------------------
          WHEN mc_type_t. " Time field (hhmmss), stored as char(6)
            mo_elemdescr = cl_abap_elemdescr=>get_t( ).
            mv_generic_type_string = 'T'.

* ---------------------------------------------------------------------
          WHEN mc_type_p. " Counter or amount field with comma and sign
            IF  lv_length   IS NOT INITIAL
            AND lv_decimals IS NOT INITIAL.
              mo_elemdescr = cl_abap_elemdescr=>get_p( p_length   = lv_length
                                                       p_decimals = lv_decimals ).
              mv_generic_type_string = `P ` && mc_syn-length && ` ` && ms_generic_type_info-length && ` ` && mc_syn-decimals && ` ` && ms_generic_type_info-decimals.
            ENDIF.

* ---------------------------------------------------------------------
          WHEN mc_type_decfloat16. " Decimal Floating Point. 16 Digits, with Scale Field
            mo_elemdescr = cl_abap_elemdescr=>get_decfloat16( ).
            mv_generic_type_string = 'DECFLOAT16'.

* ---------------------------------------------------------------------
          WHEN mc_type_decfloat34. " Decimal Floating Point, 34 Digits, with Scale Field
            mo_elemdescr = cl_abap_elemdescr=>get_decfloat34( ).
            mv_generic_type_string = 'DECFLOAT34'.

* ---------------------------------------------------------------------
          WHEN OTHERS.

* ---------------------------------------------------------------------
        ENDCASE.

* ---------------------------------------------------------------------
        CREATE DATA md_value TYPE HANDLE mo_elemdescr.

      CATCH cx_root.
        BREAK-POINT.
    ENDTRY.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_type.
* ---------------------------------------------------------------------
    TRY.
        mo_elemdescr ?= cl_abap_elemdescr=>describe_by_name( iv_type ).
        mv_type = iv_type.
        CREATE DATA md_value TYPE HANDLE mo_elemdescr.
      CATCH cx_root.
        BREAK-POINT .
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
    FIELD-SYMBOLS:
      <lv_value> TYPE any.

* ---------------------------------------------------------------------
    IF  iv_value     IS NOT SUPPLIED
    AND iv_value_str IS NOT SUPPLIED.
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------
    ASSIGN md_value->* TO <lv_value>.
    IF <lv_value> IS NOT ASSIGNED.
      RETURN.
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
          CALL TRANSFORMATION id SOURCE value = <lv_value> RESULT XML mv_value.
        ENDIF.
      WHEN mc_conv_xml.
        IF iv_value IS NOT INITIAL.
          mv_value = iv_value.
        ELSEIF iv_value_str IS NOT INITIAL.
          mv_value = iv_value_str.
        ENDIF.
        CALL TRANSFORMATION id SOURCE XML mv_value RESULT value = <lv_value>.
      WHEN mc_conv_write.
      WHEN OTHERS.
    ENDCASE.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
