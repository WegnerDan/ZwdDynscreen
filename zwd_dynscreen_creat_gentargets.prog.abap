REPORT zwd_dynscreen_creat_gentargets.

" THIS IS BROKEN, DO NOT RUN
RETURN.
*Z_DYNSCREEN_GENERATION_T000 Dynscreen Generation Target
*Z_DYNSCREEN000 DYNSCREEN GENERATION TARGET
DATA lv_poolname TYPE tlibg-area.
DATA lv_funcname TYPE rs38l-name.
DATA lv_inc_eve TYPE rs38l-name.
DATA lv_inc_scr TYPE rs38l-name.
DATA lv_index TYPE n LENGTH 3.
DATA lt_exception_list   TYPE STANDARD TABLE OF rsexc WITH DEFAULT KEY.
DATA lt_export_parameter TYPE STANDARD TABLE OF rsexp WITH DEFAULT KEY.
DATA lt_import_parameter TYPE STANDARD TABLE OF rsimp WITH DEFAULT KEY.
DATA lt_parameter_docu   TYPE STANDARD TABLE OF rsfdo WITH DEFAULT KEY.
DATA lt_tables_parameter TYPE STANDARD TABLE OF rstbl WITH DEFAULT KEY.

APPEND VALUE #( parameter = 'IO_VALUE_TRANSPORT' reference = abap_true typ = 'REF TO ZCL_DYNSCREEN_TRANSPORT' ref_class = abap_true ) TO lt_import_parameter.
APPEND VALUE #( parameter = 'IO_EVENTS' reference = abap_true typ = 'REF TO ZCL_DYNSCREEN_EVENTS' ref_class = abap_true ) TO lt_import_parameter.


DO 999 TIMES.
  lv_index = sy-index.
  lv_poolname = 'Z_DYNSCREEN' && lv_index.
  CALL FUNCTION 'FUNCTION_POOL_CREATE'
    EXPORTING
      pool_name           = lv_poolname    " Name der Funktionsgruppe (>=4-stellig)
*     responsible         = SY-UNAME    " Verantwortlicher der Funktionsgruppe
      short_text          = 'DYNSCREEN GENERATION TARGET'     " Kurzbeschreibung
*     namespace           = SPACE    " Namensraum der Funktionsgruppe
*     unicode_checks      = 'X'    " Flag, ob Unicodeprüfungen durchgeführt werden
*     no_se80_tree_refresh = SPACE    " X = SE80-Baum wird nicht aktualisiert
    EXCEPTIONS
      name_already_exists = 1
      name_not_correct    = 2
      OTHERS              = 3.
  IF sy-subrc <> 0.
    BREAK-POINT.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  lv_funcname = 'Z_DYNSCREEN_GENERATION_T' && lv_index.
  CALL FUNCTION 'FUNCTION_CREATE'
    EXPORTING
*     corrnum                 = SPACE    " Korrekturnummer
      funcname                = lv_funcname    " Name des Funktionsbausteins
      function_pool           = lv_poolname    " Zugehoerige Funktionsgruppe ohne Namensraum
*     interface_global        = SPACE    " Kennzeichen für globale Schnittstelle
*     remote_call             = SPACE    " Remote-Function-Call fähig
      short_text              = 'DYNSCREEN GENERATION TARGET'     " Kurzbeschreibung des Funktionsbausteins
*     suppress_corr_check     = 'X'    " Unterdrückung des Korrektursystems (=Default)
*     update_task             = SPACE    " Verbuchungstyp
*     namespace               = SPACE    " Namensraum der Funktionsgruppe
*     suppress_enqueue        = SPACE
*     save_active             = 'X'    "  X = Aktiv sichern
*     exception_class         = SPACE    " X = mit Exception Klassen
*     remote_basxml_supported = SPACE    " Einstelliges Kennzeichen
*     rfc_attributes          = SPACE    " RFC classification
*  IMPORTING
*     function_include        =     " Name des zugehoerigen INCLUDE-Files
    TABLES
      exception_list          = lt_exception_list      " Liste der Ausnahmen
      export_parameter        = lt_export_parameter    " Export-Parameter
      import_parameter        = lt_import_parameter    " Import-Parameter
      parameter_docu          = lt_parameter_docu      " Kurzbeschreibung der Parameter
      tables_parameter        = lt_tables_parameter    " Tabellen-Parameter
*     changing_parameter      =
    EXCEPTIONS
      double_task             = 1
      error_message           = 2
      function_already_exists = 3
      invalid_function_pool   = 4
      invalid_name            = 5
      too_many_functions      = 6
      OTHERS                  = 7.
  IF sy-subrc <> 0.
    BREAK-POINT.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  DATA ls_trdir TYPE trdir.
  ls_trdir-name = 'SAPLZ_DYNSCREEN' && lv_index.
  SELECT SINGLE * FROM trdir INTO ls_trdir WHERE name = ls_trdir-name.

  lv_inc_eve = 'LZ_DYNSCREEN' && lv_index && 'EVE'.
  CALL FUNCTION 'RS_EDTR_ATTRIBUTE'
    EXPORTING
      name                = space
      program             = lv_inc_eve
      report_title        = 'Include'
      type                = 'I'
      new_or_modf         = 'NEW'
      upper_lower_case    = space
      trdir_rahmen        = ls_trdir
      type_switch_allowed = space
      suppress_dialog     = space
*    IMPORTING
*     next_action         = next_action
*     new_trdir           = trdir
    EXCEPTIONS
      not_executed        = 01
      program_enqueued    = 02.
  IF sy-subrc <> 0.
    BREAK-POINT.
  ENDIF.

  lv_inc_scr = 'LZ_DYNSCREEN' && lv_index && 'SCR'.
  CALL FUNCTION 'RS_EDTR_ATTRIBUTE'
    EXPORTING
      name                = space
      program             = lv_inc_scr
      report_title        = 'Include'
      type                = 'I'
      new_or_modf         = 'NEW'
      upper_lower_case    = space
      trdir_rahmen        = ls_trdir
      type_switch_allowed = space
      suppress_dialog     = space
*    IMPORTING
*     next_action         = next_action
*     new_trdir           = trdir
    EXCEPTIONS
      not_executed        = 01
      program_enqueued    = 02.
  IF sy-subrc <> 0.
    BREAK-POINT.
  ENDIF.
*  DATA lt_tadir TYPE trtad_keys.
*  FREE lt_tadir.
*  APPEND VALUE #( pgmid = 'R3TR' object = 'FUGR' obj_name = lv_poolname ) TO lt_tadir.
**
*  CALL FUNCTION 'TR_CHANGE_OBJS_DEVC'
*    EXPORTING
*      it_tadir           = lt_tadir    " Objektschlüssel der umzuhängenden Objekte
*      iv_target_devc     = 'ZWD_DYNSCREEN'    " Zielpaket
**     iv_complete_only   = ' '    " Umhängen nur, wenn für alle Objekte möglich
*      iv_task            = 'E21K900345'    " zu verwendende Aufgabe
**     iv_author          = ' '    " Neue Verantwortliche, nur bei Zielpaket $TMP
**  IMPORTING
**     et_error           =     " Tabelle mit Fehlermeldungen objektabh. Fehlern
**     ev_error_status    =     " Fehlerstatus
**     et_tadir_new       =     " TADIR-Einträge der umgehängten Objekte
**     et_korr_entries    =     " E071-Einträge die neu aufgenommen wurden
**     ev_korrnum         =     " Korrektur, in die Objekte aufgenommen wurden
*    EXCEPTIONS
*      object_indep_error = 1
*      object_dep_error   = 2
*      user_cancel        = 3
*      OTHERS             = 4.
*  IF sy-subrc <> 0.
**    BREAK-POINT.
** MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

ENDDO.
