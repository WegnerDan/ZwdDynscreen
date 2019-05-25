CLASS zcx_dynscreen_base DEFINITION PUBLIC INHERITING FROM cx_static_check ABSTRACT CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES:
      if_t100_message.
    METHODS:
      constructor IMPORTING textid   LIKE if_t100_message=>t100key OPTIONAL
                            previous LIKE previous OPTIONAL .
  PROTECTED SECTION.
    TYPES:
      mty_previous_error TYPE c LENGTH 200.
    METHODS:
      get_class_name IMPORTING io        TYPE REF TO object
                     RETURNING VALUE(rv) TYPE seoclsname,
      get_previous_text RETURNING VALUE(rv) TYPE mty_previous_error.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_dynscreen_base IMPLEMENTATION.

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
  ENDMETHOD.


  METHOD get_class_name.
* ---------------------------------------------------------------------
    IF io IS INITIAL
    OR io IS NOT BOUND.
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------
    DATA(lv_class_name) = cl_abap_classdescr=>get_class_name( io ).

* ---------------------------------------------------------------------
    rv = replace( val  = lv_class_name
                  sub  = '\CLASS='
                  with = ''            ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_previous_text.
* ---------------------------------------------------------------------
    rv = previous->get_text( ).

* ---------------------------------------------------------------------
    IF rv IS INITIAL.
      rv = previous->get_longtext( ).
    ENDIF.

* ---------------------------------------------------------------------
    IF rv IS INITIAL.
      rv = get_class_name( previous ).
    ENDIF.

* ---------------------------------------------------------------------
    IF rv IS NOT INITIAL.
      rv = `: ` && rv.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
