CLASS zcx_dynscreen_incompatible DEFINITION PUBLIC INHERITING FROM zcx_dynscreen_base FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF zcx_dynscreen_incompatible,
        msgid TYPE symsgid VALUE 'Z_DYNSCREEN',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'INCOMPATIBLE_CLASS',
        attr2 TYPE scx_attrname VALUE 'PARENT_CLASS',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF zcx_dynscreen_incompatible.
    DATA:
      parent_class       TYPE seoclsname,
      incompatible_class TYPE seoclsname.
    METHODS:
      constructor IMPORTING parent_class       TYPE REF TO object
                            incompatible_class TYPE REF TO object.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcx_dynscreen_incompatible IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
* ---------------------------------------------------------------------
    super->constructor( ).

* ---------------------------------------------------------------------
    CLEAR me->textid.

* ---------------------------------------------------------------------
    me->parent_class       = get_class_name( parent_class ).
    me->incompatible_class = get_class_name( incompatible_class ).

* ---------------------------------------------------------------------
    if_t100_message~t100key = zcx_dynscreen_incompatible.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
