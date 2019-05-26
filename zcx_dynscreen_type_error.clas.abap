CLASS zcx_dynscreen_type_error DEFINITION PUBLIC INHERITING FROM zcx_dynscreen_dyna_chk_base FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF zcx_dynscreen_type_error,
        msgid TYPE symsgid VALUE 'Z_DYNSCREEN',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '' ##MG_MISSING,
        attr2 TYPE scx_attrname VALUE '' ##MG_MISSING,
        attr3 TYPE scx_attrname VALUE '' ##MG_MISSING,
        attr4 TYPE scx_attrname VALUE '' ##MG_MISSING,
      END OF zcx_dynscreen_type_error,
      BEGIN OF type_error_with_prev,
        msgid TYPE symsgid VALUE 'Z_DYNSCREEN',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'PREVIOUS_ERROR+000(50)' ##MG_MIS_ATT,
        attr2 TYPE scx_attrname VALUE 'PREVIOUS_ERROR+050(50)' ##MG_MIS_ATT,
        attr3 TYPE scx_attrname VALUE 'PREVIOUS_ERROR+100(50)' ##MG_MIS_ATT,
        attr4 TYPE scx_attrname VALUE 'PREVIOUS_ERROR+150(50)' ##MG_MIS_ATT,
      END OF type_error_with_prev,
      BEGIN OF type_change_not_supported,
        msgid TYPE symsgid VALUE 'Z_DYNSCREEN',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'PARENT_CLASS',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF type_change_not_supported,
      BEGIN OF generic_type_not_supported,
        msgid TYPE symsgid VALUE 'Z_DYNSCREEN',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'GENERIC_DATA_TYPE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF generic_type_not_supported,
      BEGIN OF type_not_found,
        msgid TYPE symsgid VALUE 'Z_DYNSCREEN',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'TYPE_NAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF type_not_found,
      BEGIN OF float_selopt,
        msgid TYPE symsgid VALUE 'Z_DYNSCREEN',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF float_selopt,
      BEGIN OF no_type_provided,
        msgid TYPE symsgid VALUE 'Z_DYNSCREEN',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_type_provided.
    DATA:
      previous_error    TYPE mty_previous_error,
      parent_class      TYPE seoclsname,
      generic_data_type TYPE zcl_dynscreen_io_element=>mty_s_generic_type_info-datatype,
      type_name         TYPE typename.
    METHODS:
      constructor IMPORTING textid            LIKE if_t100_message=>t100key OPTIONAL
                            previous          TYPE REF TO cx_root OPTIONAL
                            parent_class      TYPE REF TO object OPTIONAL
                            generic_data_type TYPE zcl_dynscreen_io_element=>mty_s_generic_type_info-datatype OPTIONAL
                            type_name         TYPE typename OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_dynscreen_type_error IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
* ---------------------------------------------------------------------
    super->constructor( previous = previous ).

* ---------------------------------------------------------------------
    CLEAR me->textid.

* ---------------------------------------------------------------------
    me->parent_class      = get_class_name( parent_class ).
    me->generic_data_type = generic_data_type.
    me->type_name         = type_name.

* ---------------------------------------------------------------------
    IF textid IS INITIAL.
      if_t100_message~t100key = zcx_dynscreen_type_error.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

* ---------------------------------------------------------------------
    IF textid = type_error_with_prev.
      previous_error = get_previous_text( ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
