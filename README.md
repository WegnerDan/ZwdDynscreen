# ZwdDynscreen 

Object Oriented Selection Screen Generation for SAP


## Use Case / Usage

You need to display a simple popup for a couple of values, but don't want to create a dynpro in your program.

Add a method like this:
### Method Definition
```abap
METHODS display_material_popup RETURNING VALUE(rv_matnr) TYPE MARA-MATNR
                               RAISING zcx_dynscreen_canceled. " selection canceled
```

### Method Implementation
```abap
METHOD display_material_popup.
  DATA:
    lo_popup TYPE REF TO zcl_dynscreen_popup,
    lo_matnr TYPE REF TO zcl_dynscreen_paramater.
  
  lo_popup = NEW #( iv_text = 'Please enter a new Material Number' ).
  lo_matnr = NEW #( io_parent = go_popup
                    iv_type   = 'MARA-MATNR' ).
                    
  lo_matnr->get_value( IMPORTING ev_value = rv_value ).
                    
ENDMETHOD.
```
### Method Call
```abap
TRY.
    lv_material = display_material_popup( ).
  CATCH zcx_dynscreen_canceled.
    " popup was closed or selection canceled with cancel button
    
ENDTRY.
```

## Examples
Report ZWD_DYNSCREEN_TEST1 for a demo of a couple screen elements. [Sample Generation Result for Report ZWD_DYNSCREEN_TEST1](https://gist.github.com/thedoginthewok/141e0c83df0e054d0f839596afcce016)

Report ZWD_DYNSCREEN_TEST2_POPUP contains very similar elements as zwd_dynscreen_test1 but generates a popup.

Report ZWD_DYNSCREEN_TEST3_SE16 generates a selection screen based on db table fields (similar to SE16).

Report ZWD_DYNSCREEN_TEST4_TABS generates a screen with Tabs.

Report ZWD_DYNSCREEN_TEST5_MINIMAL contains a minimal example and generates a popup with a single field.
