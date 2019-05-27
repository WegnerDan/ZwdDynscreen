CLASS zcx_dynscreen_syntax_error DEFINITION PUBLIC INHERITING FROM zcx_dynscreen_dyna_chk_base FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF zcx_dynscreen_syntax_error,
        msgid TYPE symsgid VALUE 'Z_DYNSCREEN',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'SYNTAX_ERROR+000(50)' ##MG_MIS_ATT,
        attr2 TYPE scx_attrname VALUE 'SYNTAX_ERROR+050(50)' ##MG_MIS_ATT,
        attr3 TYPE scx_attrname VALUE 'SYNTAX_ERROR+100(50)' ##MG_MIS_ATT,
        attr4 TYPE scx_attrname VALUE 'SYNTAX_ERROR+150(50)' ##MG_MIS_ATT,
      END OF zcx_dynscreen_syntax_error.
    DATA:
      syntax_error TYPE c LENGTH 200 READ-ONLY.
    METHODS:
      constructor IMPORTING syn_check TYPE REF TO cl_abap_syntax_check_norm,
      get_syntax_check RETURNING VALUE(ro_syntax_check) TYPE REF TO cl_abap_syntax_check_norm.
  PROTECTED SECTION.
    DATA:
      mo_syntax_check TYPE REF TO cl_abap_syntax_check_norm.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_dynscreen_syntax_error IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
* ---------------------------------------------------------------------
    super->constructor( ).

* ---------------------------------------------------------------------
    CLEAR me->textid.

* ---------------------------------------------------------------------
    mo_syntax_check = syn_check.
    me->syntax_error = mo_syntax_check->message.

* ---------------------------------------------------------------------
    if_t100_message~t100key = zcx_dynscreen_syntax_error.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_syntax_check.
* ---------------------------------------------------------------------
    ro_syntax_check = mo_syntax_check.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
