CLASS zcx_dynscreen_too_many_elems DEFINITION PUBLIC INHERITING FROM zcx_dynscreen_base FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF zcx_dynscreen_too_many_elems,
        msgid TYPE symsgid VALUE 'Z_DYNSCREEN',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF zcx_dynscreen_too_many_elems.
    METHODS:
      constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_dynscreen_too_many_elems IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
* ---------------------------------------------------------------------
    super->constructor( ).

* ---------------------------------------------------------------------
    CLEAR me->textid.

* ---------------------------------------------------------------------
    if_t100_message~t100key = zcx_dynscreen_too_many_elems.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
