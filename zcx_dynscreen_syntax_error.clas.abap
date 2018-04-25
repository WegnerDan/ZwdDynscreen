CLASS zcx_dynscreen_syntax_error DEFINITION PUBLIC INHERITING FROM zcx_dynscreen_base FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING textid    LIKE if_t100_message=>t100key OPTIONAL
                            previous  LIKE previous OPTIONAL
                            syn_check TYPE REF TO cl_abap_syntax_check_norm OPTIONAL,
      get_text REDEFINITION,
      get_syntax_check RETURNING VALUE(ro_syntax_check) TYPE REF TO cl_abap_syntax_check_norm.
  PROTECTED SECTION.
    DATA:
      mo_syntax_check TYPE REF TO cl_abap_syntax_check_norm.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_dynscreen_syntax_error IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
* ---------------------------------------------------------------------
    super->constructor( previous = previous ).

* ---------------------------------------------------------------------
    CLEAR me->textid.

* ---------------------------------------------------------------------
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

* ---------------------------------------------------------------------
    mo_syntax_check = syn_check.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_syntax_check.
* ---------------------------------------------------------------------
    ro_syntax_check = mo_syntax_check.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_text.
* ---------------------------------------------------------------------
    result = mo_syntax_check->message.

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
