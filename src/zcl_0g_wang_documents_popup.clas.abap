class ZCL_0G_WANG_DOCUMENTS_POPUP definition
  public
  inheriting from CL_BS_BP_GUIBB_FORM
  create public .

public section.

  constants MC_EVENT_DOC_SELECTED type FPM_EVENT_ID value 'DOC_SELECTED' ##NO_TEXT.

  methods IF_FPM_GUIBB_FORM~FLUSH
    redefinition .
  methods IF_FPM_GUIBB_FORM~GET_DATA
    redefinition .
  methods IF_FPM_GUIBB_FORM~GET_DEFINITION
    redefinition .
  methods IF_FPM_GUIBB_FORM~PROCESS_EVENT
    redefinition .
protected section.

  types:
    BEGIN OF mty_dokar,
           dokar  TYPE dokar,
           dartxt TYPE dartxt,
         END OF mty_dokar .

  constants MC_DOKOB type DOKOB value 'KNA1' ##NO_TEXT.
  constants MC_FIELD_DKTXT type STRING value 'DKTXT' ##NO_TEXT.
  constants MC_FIELD_DOKAR type STRING value 'DOKAR' ##NO_TEXT.
  constants MC_FIELD_DOKNR type STRING value 'DOKNR' ##NO_TEXT.
  constants MC_FIELD_DOKTL type STRING value 'DOKTL' ##NO_TEXT.
  constants MC_FIELD_DOKVR type STRING value 'DOKVR' ##NO_TEXT.
  data MD_DAPPL type DAPPL .
  data MD_DOC_DESCRIPTION type DKTXT .
  data MD_DOKAR type DOKAR .
  data MD_FILECONTENT type MDG_BS_BP_DRAW_XSTRING .
  data MD_FILEP type FILEP .
  data MD_STORAGE_CATORG type SDOK_STCAT .
  data:
    mt_dokar TYPE STANDARD TABLE OF mty_dokar .
  constants GC_FIELD_DOKAR type STRING value 'Z_DOKAR' ##NO_TEXT.
  constants GC_FIELD_DOKNR type STRING value 'Z_DOKNR' ##NO_TEXT.
  constants GC_FIELD_DOKTL type STRING value 'Z_DOKTL' ##NO_TEXT.
  constants GC_FIELD_DOKVR type STRING value 'Z_DOKVR' ##NO_TEXT.
  constants GC_DOKOB type STRING value 'DRAD' ##NO_TEXT.
  data GD_DOKAR type DOKAR .
  data GD_FILEP type FILEP .

  methods CLEAR_BUFFER .
  methods CREATE_DOCUMENT_API
    exporting
      !ED_DOKNR type DOKNR
      !ED_DOKTL type DOKTL_D
      !ED_DOKVR type DOKVR
      !ED_FAILED type BOOLE_D
      !ET_MESSAGE type USMD_T_MESSAGE .
  methods GET_DOKAR .

  methods CHECK_FIELD_USAGE_SINGLE
    redefinition .
  methods CREATE_STRUCT_RTTI
    redefinition .
  methods OVS_HANDLE_PHASE_2
    redefinition .
private section.

  data GD_DOC_DESCRIPTION type DKTXT .
  data GD_FILECONTENT type MDG_BS_BP_DRAW_XSTRING .
  data GD_STORAGE_CATORG type SDOK_STCAT .
  data GD_DAPPL type DAPPL .
ENDCLASS.



CLASS ZCL_0G_WANG_DOCUMENTS_POPUP IMPLEMENTATION.


  METHOD CHECK_FIELD_USAGE_SINGLE.
    FIELD-SYMBOLS: <dokar>       TYPE mty_dokar,
                   <values>      TYPE wdr_context_attr_value,
                   <storage_cat> TYPE cl_mdg_bs_draw_api=>ty_mdg_bs_s_dttrg,
                   <application> TYPE cl_mdg_bs_draw_api=>ty_mdg_bs_s_dappl.

    super->check_field_usage_single( CHANGING cs_field_usage = cs_field_usage ).

    CASE cs_field_usage-name.
      WHEN 'Z_DOKAR'.
        IF me->mt_dokar IS INITIAL.
          me->get_dokar( ).
        ENDIF.
        CLEAR cs_field_usage-fixed_values.
        LOOP AT me->mt_dokar ASSIGNING <dokar>.
          APPEND INITIAL LINE TO cs_field_usage-fixed_values
                       ASSIGNING <values>.
          <values>-value = <dokar>-dokar.
          <values>-text  = <dokar>-dartxt.
        ENDLOOP.
        cs_field_usage-fixed_values_changed = abap_true.
        cs_field_usage-mandatory            = abap_true.
        cs_field_usage-read_only            = abap_false.


      WHEN 'STORAGE_CATORG'.
        cs_field_usage-mandatory     = abap_false.
        cs_field_usage-read_only     = abap_true.

        cl_cmd_bs_draw_api=>get_storage_categories(
          EXPORTING
            iv_dokar          = me->md_dokar
            iv_dappl          = me->md_dappl ).

        CHECK me->md_dokar IS NOT INITIAL.
        cs_field_usage-mandatory            = abap_true.
        cs_field_usage-read_only            = abap_false.

        CLEAR cs_field_usage-fixed_values.
        LOOP AT cl_cmd_bs_draw_api=>mt_storage_cat ASSIGNING <storage_cat>.
          APPEND INITIAL LINE TO cs_field_usage-fixed_values
                       ASSIGNING <values>.
          <values>-value = <storage_cat>-dttrg.
          IF <storage_cat>-cvtext IS NOT INITIAL.
            <values>-text = <storage_cat>-cvtext.
          ELSE.
            <values>-text = <storage_cat>-dttrg.
          ENDIF.
        ENDLOOP.
        cs_field_usage-fixed_values_changed = abap_true.


      WHEN 'DAPPL'.
        cs_field_usage-mandatory     = abap_false. "abap_true.
        cs_field_usage-read_only     = abap_false.

        IF me->md_filep IS NOT INITIAL.
          cl_cmd_bs_draw_api=>get_applications(
            EXPORTING
              iv_file  = me->md_filep ).
        ENDIF.

        CLEAR cs_field_usage-fixed_values.
        LOOP AT cl_cmd_bs_draw_api=>mt_application ASSIGNING <application>.
          APPEND INITIAL LINE TO cs_field_usage-fixed_values
                       ASSIGNING <values>.
          <values>-value = <application>-dappl.
          <values>-text  = <application>-cvtext.
        ENDLOOP.
        cs_field_usage-fixed_values_changed = abap_true.


      WHEN 'DOC_DESCRIPTION'.
        cs_field_usage-mandatory     = abap_false. "abap_true.
        cs_field_usage-read_only     = abap_false.

      WHEN OTHERS.

    ENDCASE.

*    .
  ENDMETHOD.


  METHOD CLEAR_BUFFER.

    CLEAR: me->md_filep, me->md_filecontent, me->md_dokar, me->md_storage_catorg,
           me->md_dappl, me->md_doc_description, me->mt_dokar.

  ENDMETHOD.


  METHOD CREATE_DOCUMENT_API.

    DATA: ld_no_auth        TYPE boole,
          ld_filecontent    TYPE mdg_bs_bp_draw_xstring,
          ld_doctype        TYPE dokar,
          ld_doc_exists_aa  TYPE boole_d,
          ld_doc_exists_buf TYPE boole_d.

    DATA: ls_draw            TYPE mdg_bs_drad_s_draw_api.

    DATA: lt_return          TYPE bapiret2_t.

    FIELD-SYMBOLS: <return>  TYPE bapiret2,
                   <message> TYPE usmd_s_message.

    CLEAR: ed_failed, et_message.

* Check authorization for document creation from document type
    cl_mdg_bs_document_auth_check=>check_authority_docu_act(
      EXPORTING
        iv_actvt   = '01'
        iv_dokar   = me->md_dokar
      IMPORTING
        ev_no_auth = ld_no_auth
      CHANGING
        ct_return  = lt_return ).

    IF ld_no_auth IS NOT INITIAL.
      LOOP AT lt_return ASSIGNING <return>.
        APPEND INITIAL LINE TO et_message ASSIGNING <message>.
        <message>-msgid = <return>-id.
        <message>-msgty = <return>-type.
        <message>-msgno = <return>-number.
        <message>-msgv1 = <return>-message_v1.
        <message>-msgv2 = <return>-message_v2.
        <message>-msgv3 = <return>-message_v3.
        <message>-msgv4 = <return>-message_v4.
        <message>-row   = <return>-row.
        <message>-fieldname = <return>-field.
      ENDLOOP.
      ed_failed = abap_true.
      RETURN.
    ENDIF.

* Set necessary attributes
    ls_draw-dokar           = me->md_dokar.
    ls_draw-storage_catorg  = me->md_storage_catorg.
    ls_draw-appnrorg        = '1'.
    ls_draw-filenameorg     = me->md_filep.
    ls_draw-orig_check_in   = abap_true.
    ls_draw-languorg        = sy-langu.
    ls_draw-dapplorg        = me->md_dappl.
    ls_draw-doc_description = me->md_doc_description.
    ld_filecontent          = me->md_filecontent.

* Create document
    cl_mdg_bs_draw_api=>create_document_buff(
      EXPORTING
        is_api_doc_data   =   ls_draw
        iv_dokob          =   if_mdg_bs_ecc_bp_constants=>gc_cu_dokob
        iv_file_content   =   ld_filecontent
      IMPORTING
        ev_docnumber      =   ed_doknr            " Document number
        ev_doctype        =   ld_doctype          " Document Type
        ev_docpart        =   ed_doktl            " Document Part
        ev_docversion     =   ed_dokvr            " Document Version
        ev_doc_exists_aa  =   ld_doc_exists_aa    " Document exists in active area
        ev_doc_exists_buf =   ld_doc_exists_buf   " Document exists in buffer
        et_message        =   et_message ).       " Messages

    CHECK et_message IS NOT INITIAL.
    READ TABLE et_message TRANSPORTING NO FIELDS
         WITH KEY msgty = cl_mdg_bs_draw_api=>gc_msgty_error.
    " CHECK sy-subrc EQ 0.
    " ed_failed = abap_true.

  "  create document

*    DATA lt_documents TYPE mdg_bs_bp_t_ei_document.
*    DATA ls_documents TYPE mdg_bs_bp_s_ei_document.
*
*    ls_documents-task = 'I'.
*    ls_documents-data_key-dokar = me->md_dokar.
*    ls_documents-data_key-doknr = ed_doknr.
*    ls_documents-data_key-dokvr = ed_dokvr.
*    ls_documents-data_key-doktl = ed_doktl.
*    ls_documents-data-newestver = abap_true.
*    APPEND ls_documents TO lt_documents.
*
*   "  CALL FUNCTION 'ZMDG_BS_ECC_CCTR_DRAD_UPDATE' IN UPDATE TASK
*     "CALL FUNCTION 'MDG_BS_ECC_BP_DRAD_UPDATE' IN UPDATE TASK
*    "    EXPORTING
*    "      id_lifnr     = '01'
*    "     it_documents = lt_documents.
*
*
*    DATA : ls_docs   TYPE bapi_doc_draw2,
*           lw_docs   TYPE bapi_doc_draw2,
*           lit_docsx TYPE TABLE OF bapi_doc_drawx2,
*           lit_files TYPE TABLE OF bapi_doc_files2.
*    DATA: ls_docsx TYPE bapi_doc_drawx2.
*
*    ls_docs-documenttype = ld_doctype.
*    ls_docs-documentnumber = ed_doknr.
*    ls_docs-documentpart  =  ed_doktl.
*    ls_docs-documentversion = ed_dokvr.
*    ls_docs-username        = sy-uname.
*    ls_docs-description     = me->md_doc_description.
*    ls_docsx-documenttype = 'X'.
*    ls_docsx-documentnumber = 'X'.
*    ls_docsx-documentpart  =  'X'.
*    ls_docsx-documentversion = 'X'.
*    ls_docsx-username        = 'X'.
*    ls_docsx-description     = 'X'.
*
*    lit_files = VALUE #( ( documenttype   = ld_doctype
*                               documentnumber = ed_doknr
*                               documentpart  =  ed_doktl
*                               documentversion = ed_dokvr
*                               description     = me->md_doc_description
*                               storagecategory = me->md_storage_catorg
*                               wsapplication = me->md_dappl
*                               docfile = me->md_filep
**                                 docpath = 'C:\Users\titus-dev-user256\Desktop\'
*                               " docpath = lw_pc_doc-zpc_filepath
*                           ) ).
*
*
*    CALL FUNCTION 'BAPI_DOCUMENT_CHANGE2'
*      EXPORTING
*        documenttype    = ld_doctype
*        documentnumber  = ed_doknr
*        documentpart    = ed_doktl
*        documentversion = ed_dokvr
*        documentdata    = ls_docs
*        documentdatax   = ls_docsx
**       HOSTNAME        =
**       DOCBOMCHANGENUMBER         =
**       DOCBOMVALIDFROM =
**       DOCBOMREVISIONLEVEL        =
**       SENDCOMPLETEBOM = ' '
**       PF_FTP_DEST     = ' '
**       PF_HTTP_DEST    = ' '
**       CAD_MODE        = ' '
**       ACCEPT_EMPTY_BOM           = ' '
* IMPORTING
*       RETURN          = lt_return
*      TABLES
**       CHARACTERISTICVALUES       =
**       CLASSALLOCATIONS           =
**       DOCUMENTDESCRIPTIONS       =
**       OBJECTLINKS     =
**       DOCUMENTSTRUCTURE          =
*        documentfiles   = lit_files
**       LONGTEXTS       =
**       COMPONENTS      =
*.

  "  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
  "    EXPORTING
  "      wait = abap_true.


  ENDMETHOD.


  METHOD CREATE_STRUCT_RTTI.

    DATA: lt_components        TYPE cl_abap_structdescr=>component_table.

    FIELD-SYMBOLS: <component> LIKE LINE OF lt_components.

    super->create_struct_rtti( ).

    lt_components = me->mo_struct_rtti->get_components( ).

    APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
    <component>-name = if_mdg_bs_ecc_bp_constants=>gc_cu_field-file_path.
    <component>-type = cl_abap_elemdescr=>get_string( ).

    APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
    <component>-name = if_mdg_bs_ecc_bp_constants=>gc_cu_field-file_content.
    <component>-type = cl_abap_elemdescr=>get_string( ).

    APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
    <component>-name = if_mdg_bs_ecc_bp_constants=>gc_cu_field-doc_description.
    <component>-type = cl_abap_elemdescr=>get_string( ).

    me->mo_struct_rtti = cl_abap_structdescr=>create( lt_components ).

  ENDMETHOD.


  method GET_DOKAR.
     DATA: lt_tdwo TYPE TABLE OF tdwo.

* Since buffered table TDWAT no join but separated select statements
    SELECT * FROM tdwo INTO TABLE lt_tdwo
        WHERE dokob EQ me->gc_dokob.
    CHECK sy-subrc EQ 0.
    SELECT dokar dartxt FROM tdwat INTO CORRESPONDING FIELDS OF TABLE me->mt_dokar
        FOR ALL ENTRIES IN lt_tdwo
        WHERE cvlang EQ sy-langu
          AND dokar  EQ lt_tdwo-dokar.
  endmethod.


  METHOD IF_FPM_GUIBB_FORM~FLUSH.

    FIELD-SYMBOLS: <data>  TYPE any.
    FIELD-SYMBOLS: <field> TYPE any.

    super->if_fpm_guibb_form~flush(
      EXPORTING
        it_change_log = it_change_log
        is_data       = is_data ).

    CHECK is_data IS NOT INITIAL.
    ASSIGN is_data->* TO <data>.

    CHECK <data> IS ASSIGNED
    AND   <data> IS NOT INITIAL.

    ASSIGN COMPONENT 'FILE_CONTENT' OF STRUCTURE <data> TO <field>.
    IF sy-subrc EQ 0
    AND <field> IS NOT INITIAL.
      me->md_filecontent = <field>.
    ENDIF.

    ASSIGN COMPONENT 'FILEP' OF STRUCTURE <data> TO <field>.
    IF sy-subrc EQ 0
    AND <field> IS NOT INITIAL.
      me->md_filep = <field>.
    ENDIF.

    ASSIGN COMPONENT 'Z_DOKAR' OF STRUCTURE <data> TO <field>.
    IF sy-subrc EQ 0
    AND <field> IS NOT INITIAL.
      me->md_dokar = <field>.
    ENDIF.

    ASSIGN COMPONENT 'STORAGE_CATORG' OF STRUCTURE <data> TO <field>.
    IF sy-subrc EQ 0
    AND <field> IS NOT INITIAL.
      me->md_storage_catorg = <field>.
    ENDIF.

    ASSIGN COMPONENT 'DAPPL'  OF STRUCTURE <data> TO <field>.
    IF sy-subrc EQ 0
    AND <field> IS NOT INITIAL.
      me->md_dappl = <field>.
    ENDIF.

    ASSIGN COMPONENT 'DOC_DESCRIPTION' OF STRUCTURE <data> TO <field>.
    IF sy-subrc EQ 0
    AND <field> IS NOT INITIAL.
      me->md_doc_description = <field>.
    ENDIF.

  ENDMETHOD.


  METHOD IF_FPM_GUIBB_FORM~GET_DATA.
    DATA: ld_dialog_id   TYPE string,
          ld_key         TYPE string,
          ld_filep       TYPE filep,
          ld_filecontent TYPE mdg_bs_bp_draw_xstring.

    DATA: ls_message       TYPE fpmgb_s_t100_message.

    DATA: lt_path          TYPE TABLE OF string.

    DATA: lr_event         TYPE REF TO cl_fpm_event.

    FIELD-SYMBOLS: <field>  TYPE any.

    super->if_fpm_guibb_form~get_data(
     EXPORTING
       io_event                = io_event
       iv_raised_by_own_ui     = iv_raised_by_own_ui
       it_selected_fields      = it_selected_fields
       iv_edit_mode            = iv_edit_mode
       io_extended_ctrl        = io_extended_ctrl
     IMPORTING
       et_messages             = et_messages
       ev_data_changed         = ev_data_changed
       ev_field_usage_changed  = ev_field_usage_changed
       ev_action_usage_changed = ev_action_usage_changed
     CHANGING
       cs_data                 = cs_data
       ct_field_usage          = ct_field_usage
       ct_action_usage         = ct_action_usage ).

    io_event->mo_event_data->get_value(
      EXPORTING
        iv_key   = if_fpm_constants=>gc_dialog_box-id
      IMPORTING
        ev_value = ld_dialog_id ).

    IF ld_dialog_id EQ 'ZMDG_CCTR_DOCUMENT_POPUP2' AND
       io_event->mv_event_id EQ if_fpm_constants=>gc_event-open_dialog.

      CLEAR: me->md_filep, me->md_filecontent.

      ld_key = 'FILEP'.
      io_event->mo_event_data->get_value(
        EXPORTING iv_key   = ld_key
        IMPORTING ev_value = ld_filep ).

      ld_key = 'FILE_CONTENT'.
      io_event->mo_event_data->get_value(
        EXPORTING iv_key   = ld_key
        IMPORTING ev_value = ld_filecontent ).

      me->md_filep       = ld_filep.
      me->md_filecontent = ld_filecontent.

      ASSIGN COMPONENT 'FILEP'
          OF STRUCTURE cs_data TO <field>.
      IF me->md_filep IS NOT INITIAL.
        <field> = me->md_filep.
      ENDIF.

      ASSIGN COMPONENT 'FILE_CONTENT'
          OF STRUCTURE cs_data TO <field>.
      IF me->md_filecontent IS NOT INITIAL.
        <field> = me->md_filecontent.
      ENDIF.
    ENDIF.

    CHECK cs_data IS NOT INITIAL.

    ASSIGN COMPONENT 'FILE_CONTENT'
        OF STRUCTURE cs_data TO <field>.
    IF me->md_filecontent IS NOT INITIAL.
      <field> = me->md_filecontent.
    ENDIF.

    ASSIGN COMPONENT 'FILEP'
        OF STRUCTURE cs_data TO <field>.
    IF me->md_filep IS NOT INITIAL.
      <field> = me->md_filep.
    ENDIF.

    ASSIGN COMPONENT gc_field_dokar OF STRUCTURE cs_data TO <field>.
    IF me->md_dokar IS NOT INITIAL.
      <field> = me->md_dokar.
      ASSIGN COMPONENT 'STORAGE_CATORG'
          OF STRUCTURE cs_data TO <field>.
      IF NOT me->md_storage_catorg IS INITIAL.
        <field> = me->md_storage_catorg.
      ENDIF.
    ENDIF.

    ASSIGN COMPONENT 'DAPPL'
        OF STRUCTURE cs_data TO <field>.
    IF me->md_dappl IS NOT INITIAL.
      <field> = me->md_dappl.
    ENDIF.

    ASSIGN COMPONENT 'DOC_DESCRIPTION'
        OF STRUCTURE cs_data TO <field>.
    IF me->md_doc_description IS NOT INITIAL.
      <field> = me->md_doc_description.
    ENDIF.

    ev_data_changed = abap_true.
  ENDMETHOD.


  METHOD IF_FPM_GUIBB_FORM~GET_DEFINITION.

    FIELD-SYMBOLS: <formfield> TYPE fpmgb_s_formfield_descr.

    super->if_fpm_guibb_form~get_definition(
      IMPORTING
        eo_field_catalog         = eo_field_catalog
        et_field_description     = et_field_description
        et_action_definition     = et_action_definition
        et_special_groups        = et_special_groups
        et_dnd_definition        = et_dnd_definition
        es_options               = es_options
        es_message               = es_message
        ev_additional_error_info = ev_additional_error_info ).

    READ TABLE et_field_description ASSIGNING <formfield>
      WITH TABLE KEY name = if_mdg_bs_ecc_bp_constants=>gc_cu_field-file_content.
    IF sy-subrc EQ 0.
      <formfield>-file_name_ref = 'FILEP'.
      <formfield>-mandatory     = abap_true.
    ENDIF.
    READ TABLE et_field_description ASSIGNING <formfield>
      WITH KEY name = gc_field_dokar.
    IF sy-subrc EQ 0.
      <formfield>-ovs_name = me->class_name.
    ENDIF.

  ENDMETHOD.


  METHOD IF_FPM_GUIBB_FORM~PROCESS_EVENT.

    DATA: ld_dialog_id     TYPE string,
          ld_dialog_action TYPE string,
          ld_key           TYPE string,
          ld_doknr         TYPE doknr,
          ld_doktl         TYPE doktl_d,
          ld_dokvr         TYPE dokvr,
          ld_failed        TYPE boole_d.

    DATA: lt_path    TYPE TABLE OF string,
          lt_message TYPE usmd_t_message.

    DATA: lr_event         TYPE REF TO cl_fpm_event.

    FIELD-SYMBOLS: <fpm_message> TYPE fpmgb_s_t100_message,
                   <message>     TYPE usmd_s_message.

    CLEAR et_messages.
    ev_result = if_fpm_constants=>gc_event_result-ok.

***********************************************************************
* Call superior                                                       *
***********************************************************************
    super->if_fpm_guibb_form~process_event(
      EXPORTING
        io_event            = io_event
        iv_raised_by_own_ui = iv_raised_by_own_ui
      IMPORTING
        ev_result           = ev_result
        et_messages         = et_messages ).

***********************************************************************
* Get dialog box which raised the event & corresponding action        *
***********************************************************************
    io_event->mo_event_data->get_value(
      EXPORTING
        iv_key   = if_fpm_constants=>gc_dialog_box-id
      IMPORTING
        ev_value = ld_dialog_id ).
* Get action
    io_event->mo_event_data->get_value(
      EXPORTING
        iv_key   = if_fpm_constants=>gc_dialog_box-dialog_buton_key
      IMPORTING
        ev_value = ld_dialog_action ).

***********************************************************************
* Dialogue box for document upload                                    *
***********************************************************************
    IF ld_dialog_id EQ 'ZMDG_CCTR_DOCUMENT_POPUP1' AND
       io_event->mv_event_id EQ if_fpm_constants=>gc_event-close_dialog.
* action ok
      IF ld_dialog_action = if_fpm_constants=>gc_dialog_action_id-ok.
*     Check entries & handle file separators (OS-dependent)...
        IF me->md_filecontent IS INITIAL AND
           me->md_filep       IS INITIAL.
          ev_result = if_fpm_constants=>gc_event_result-failed.
          APPEND INITIAL LINE TO et_messages ASSIGNING <fpm_message>.
          <fpm_message>-msgid    = if_mdg_bs_ecc_bp_constants=>gc_msgid_ui.
          <fpm_message>-msgno    = '042'.
          <fpm_message>-severity = if_fpm_message_manager=>gc_severity_error.
        ELSE.
          SPLIT me->md_filep AT '\' INTO TABLE lt_path.
          IF lines( lt_path ) EQ 0.
            SPLIT me->md_filep AT '/' INTO TABLE lt_path.
          ENDIF.
          IF NOT lines( lt_path ) EQ 0.
            READ TABLE lt_path INTO me->md_filep INDEX lines( lt_path ).
          ENDIF.

          CREATE OBJECT lr_event
            EXPORTING
              iv_event_id = if_fpm_constants=>gc_event-open_dialog.

          lr_event->mo_event_data->set_value(
            iv_key   = if_fpm_constants=>gc_dialog_box-id
            iv_value = 'ZMDG_CCTR_DOCUMENT_POPUP2' ).

          ld_key = if_mdg_bs_ecc_bp_constants=>gc_cu_field-file_path.
          lr_event->mo_event_data->set_value(
            iv_key   = ld_key
            iv_value = me->md_filep ).

          ld_key = if_mdg_bs_ecc_bp_constants=>gc_cu_field-file_content.
          lr_event->mo_event_data->set_value(
            iv_key   = ld_key
            iv_value = me->md_filecontent ).

          MOVE-CORRESPONDING me->ms_instance_key TO lr_event->ms_source_uibb.
          lr_event->ms_source_uibb-config_id      = 'ZMDG_CCTR_DOCUMENT_POPUP2'.
          lr_event->ms_source_uibb-interface_view = if_fpm_constants=>gc_windows-form.
          lr_event->mv_is_implicit_edit           = abap_true.
          cl_fpm_factory=>get_instance( )->raise_event( io_event = lr_event ).

        ENDIF.
      ENDIF.
      me->clear_buffer( ).
    ENDIF.

***********************************************************************
* Dialogue box for DMS integration                                    *
***********************************************************************
    IF ld_dialog_id EQ 'ZMDG_CCTR_DOCUMENT_POPUP2' AND
       io_event->mv_event_id EQ if_fpm_constants=>gc_event-close_dialog.
      CASE ld_dialog_action.
* action yes
        WHEN if_fpm_constants=>gc_dialog_action_id-yes.
          me->create_document_api( IMPORTING ed_doknr   = ld_doknr
                                             ed_doktl   = ld_doktl
                                             ed_dokvr   = ld_dokvr
                                             ed_failed  = ld_failed
                                             et_message = lt_message ).

          LOOP AT lt_message ASSIGNING <message>.
            APPEND INITIAL LINE TO et_messages ASSIGNING <fpm_message>.
            <fpm_message>-msgid       = <message>-msgid.
            <fpm_message>-msgno       = <message>-msgno.
            <fpm_message>-severity    = <message>-msgty.
            <fpm_message>-parameter_1 = <message>-msgv1.
            <fpm_message>-parameter_2 = <message>-msgv2.
            <fpm_message>-parameter_3 = <message>-msgv3.
            <fpm_message>-parameter_4 = <message>-msgv4.
          ENDLOOP.

          IF ld_failed EQ abap_true.
            ev_result = if_fpm_constants=>gc_event_result-failed.
            RETURN.
          ENDIF.
* get back to list
          CREATE OBJECT lr_event
            EXPORTING
              iv_event_id = mc_event_doc_selected.

          lr_event->mo_event_data->set_value(
            EXPORTING
              iv_key   = mc_field_dokar
              iv_value = me->md_dokar ).

          lr_event->mo_event_data->set_value(
            EXPORTING
              iv_key   = mc_field_doknr
              iv_value = ld_doknr ).

          lr_event->mo_event_data->set_value(
            EXPORTING
              iv_key   = mc_field_doktl
              iv_value = ld_doktl ).

          lr_event->mo_event_data->set_value(
            EXPORTING
              iv_key   = mc_field_dokvr
              iv_value = ld_dokvr ).

          lr_event->mo_event_data->set_value(
            EXPORTING
              iv_key   = mc_field_dktxt
              iv_value = me->md_doc_description ).

          cl_fpm_factory=>get_instance( )->raise_event( io_event = lr_event ).

        WHEN if_fpm_constants=>gc_dialog_action_id-no.
* get back to dialogue 1
          CREATE OBJECT lr_event
            EXPORTING
              iv_event_id = if_fpm_constants=>gc_event-open_dialog.

          lr_event->mo_event_data->set_value(
            iv_key   = if_fpm_constants=>gc_dialog_box-id
            iv_value = 'ZMDG_CCTR_DOCUMENT_POPUP1').

          MOVE-CORRESPONDING io_event->ms_source_uibb TO lr_event->ms_source_uibb.
          cl_fpm_factory=>get_instance( )->raise_event( io_event = lr_event ).

        WHEN OTHERS.

      ENDCASE.

      me->clear_buffer( ).

    ENDIF.

  ENDMETHOD.


 METHOD OVS_HANDLE_PHASE_2.
 DATA lt_tdwo TYPE TABLE OF tdwo.
    DATA lr_data TYPE REF TO data.
    FIELD-SYMBOLS: <output> TYPE ANY TABLE.

    CASE iv_field_name.
      WHEN mc_field_dokar.

        IF me->mt_dokar IS INITIAL.
          SELECT * FROM tdwo INTO TABLE lt_tdwo
              WHERE dokob EQ 'DRAD'.
          CHECK sy-subrc EQ 0.
          SELECT dokar dartxt FROM tdwat INTO CORRESPONDING FIELDS OF TABLE me->mt_dokar
              FOR ALL ENTRIES IN lt_tdwo
              WHERE cvlang EQ sy-langu
                AND dokar  EQ lt_tdwo-dokar.
        ENDIF.
        CREATE DATA lr_data TYPE STANDARD TABLE OF mty_dokar.
        ASSIGN lr_data->* TO <output>.
        <output>  = me->mt_dokar.
        er_output = lr_data.

      WHEN OTHERS.
        super->ovs_handle_phase_2(
          EXPORTING
            iv_field_name      = iv_field_name
            ir_query_parameter = ir_query_parameter
            io_access          = io_access
          IMPORTING
            er_output          = er_output
            ev_table_header    = ev_table_header
            et_column_texts    = et_column_texts ).

    ENDCASE.
ENDMETHOD.
ENDCLASS.
