class Z_BS_0G_GUIBB_DOCUMENTSWANG definition
  public
  inheriting from CL_BS_BP_GUIBB_LIST
  create public .

public section.

  methods IF_FPM_GUIBB_LIST~GET_DEFINITION
    redefinition .
  methods IF_FPM_GUIBB_LIST~PROCESS_EVENT
    redefinition .
  methods IF_FPM_GUIBB_OVS~HANDLE_PHASE_1
    redefinition .
protected section.

  types:
    BEGIN OF mty_dktxt,
      doknr TYPE doknr,
      dktxt TYPE dktxt,
    END OF mty_dktxt .
  types:
    BEGIN OF mty_dokar,
      dokar  TYPE dokar,
      dartxt TYPE dartxt,
    END OF mty_dokar .
  types:
    BEGIN OF mty_ovs_input,
      dktxt TYPE dktxt,
      langu TYPE cvlang,
      dokar TYPE dokar,
      doknr TYPE doknr,
    END OF mty_ovs_input .
  types:
    BEGIN OF mty_ovs_output,
      doknr TYPE doknr,
      dokar TYPE dokar,
      doktl TYPE doktl_d,
      dokvr TYPE dokvr,
      dktxt TYPE dktxt,
    END OF mty_ovs_output .

  constants MC_EVENT_CREATE_DOC type FPM_EVENT_ID value 'CREATE_DOC' ##NO_TEXT.
  constants MC_EVENT_SHOW_DOC type FPM_EVENT_ID value 'SHOW_DOC' ##NO_TEXT.
  constants MC_FIELD_DKTXT type STRING value 'DKTXT' ##NO_TEXT.
  constants MC_FIELD_DOKAR type STRING value 'DOKAR' ##NO_TEXT.
  constants MC_FIELD_DOKNR type STRING value 'DOKNR' ##NO_TEXT.
  constants MC_FIELD_DOKTL type STRING value 'DOKTL' ##NO_TEXT.
  constants MC_FIELD_DOKVR type STRING value 'DOKVR' ##NO_TEXT.
  constants MC_FIELD_LANGU type STRING value 'LANGU' ##NO_TEXT.
  data MO_GOV_API type ref to IF_USMD_CONV_SOM_GOV_API .
  data MO_PARENT_ENTITY type ref to CL_CRM_BOL_ENTITY .
  data:
    mt_dktxt TYPE STANDARD TABLE OF mty_dktxt .
  data:
    mt_dokar TYPE STANDARD TABLE OF mty_dokar .
  data:
    mt_dokst TYPE STANDARD TABLE OF tdwst .

  methods SET_PARENT_ENTITY .
  methods CREATE_DOCUMENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT .
  methods PROCESS_DOCUMENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT .
  methods GET_DOKST .
  methods GET_DOKAR .
  methods SHOW_DOCUMENT
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IV_RAISED_BY_OWN_UI type BOOLE_D optional
      !IV_LEAD_INDEX type SYTABIX
      !IV_EVENT_INDEX type SYTABIX
      !IT_SELECTED_LINES type RSTABIXTAB
      !IO_UI_INFO type ref to IF_FPM_LIST_ATS_UI_INFO optional
    exporting
      !EV_RESULT type FPM_EVENT_RESULT
      !ET_MESSAGES type FPMGB_T_MESSAGES .
  methods GET_DISPLAY_GUI_TYPE
    importing
      !IS_DOC_INFO type BSS_CUIL_DOCUMENT
    returning
      value(RV_GUI_TYPE) type FPM_GUITYPE .

  methods ADD_STANDARD_ROW_ACTIONS
    redefinition .
  methods CHECK_ACTION_USAGE
    redefinition .
  methods CREATE_STRUCT_RTTI
    redefinition .
  methods GET_ACTIONS
    redefinition .
  methods GET_ENTITY_DATA
    redefinition .
  methods GET_FIELD_UI_PROP
    redefinition .
  methods IS_CREATE_ENABLED
    redefinition .
  methods OVS_HANDLE_PHASE_0
    redefinition .
  methods OVS_HANDLE_PHASE_2
    redefinition .
  methods OVS_HANDLE_PHASE_3
    redefinition .
  methods CHECK_ACTION_USAGE_SINGLE
    redefinition .
private section.
ENDCLASS.



CLASS Z_BS_0G_GUIBB_DOCUMENTSWANG IMPLEMENTATION.


  METHOD ADD_STANDARD_ROW_ACTIONS.

    super->add_standard_row_actions( ).
    IF NOT line_exists( me->mt_row_action[ id = mc_event_show_doc ] ).
      me->mt_row_action = VALUE #( BASE me->mt_row_action
        ( id = mc_event_show_doc  text = ' ' tooltip = TEXT-003
          image_source = '~Icon/Log'  is_implicit_edit = abap_false ) ).
      INSERT VALUE #( id = mc_event_show_doc ) INTO TABLE me->mt_row_action_ref.
    ENDIF.

  ENDMETHOD.


  METHOD CHECK_ACTION_USAGE.
*! Check action usage. Control the buttons on the list UIBB.
    super->check_action_usage( CHANGING ct_action_usage = ct_action_usage ).

    IF me->mo_collection IS NOT BOUND
      OR me->mo_collection->size( ) EQ 0.
      me->modify_cnr_button( iv_event_id         = if_fpm_constants=>gc_event-local_edit
                             iv_ovp_uibb_toolbar = abap_true
                             iv_visibility       = if_fpm_constants=>gc_visibility-visible
                             iv_enabled          = abap_false ).
    ENDIF.

    IF me->mv_fpm_edit_mode NE if_fpm_constants=>gc_edit_mode-read_only.
      me->modify_cnr_button( iv_event_id         = if_fpm_constants=>gc_event-local_edit
                             iv_ovp_uibb_toolbar = abap_true
                             iv_visibility       = if_fpm_constants=>gc_visibility-visible
                             iv_enabled          = abap_false ).
    ENDIF.
  ENDMETHOD.


  METHOD CHECK_ACTION_USAGE_SINGLE.
*! Check a single action usage.
    super->check_action_usage_single( CHANGING cs_action_usage = cs_action_usage ).

    IF cs_action_usage-id = mc_event_create_doc.
      cs_action_usage-enabled = me->is_create_enabled( ).
      cs_action_usage-visible = cs_action_usage-enabled.
      ms_change-action_usage = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD CREATE_DOCUMENT.

    DATA: lr_event              TYPE REF TO cl_fpm_event.

    CREATE OBJECT lr_event
      EXPORTING
        iv_event_id = if_fpm_constants=>gc_event-open_dialog.

    lr_event->mo_event_data->set_value(
      EXPORTING
        iv_key   = if_fpm_constants=>gc_dialog_box-id
        iv_value = 'ZMDG_CCTR_DOCUMENT_POPUP1' ).
    MOVE-CORRESPONDING io_event->ms_source_uibb TO lr_event->ms_source_uibb.
    lr_event->mv_is_implicit_edit = abap_true.
    cl_fpm_factory=>get_instance( )->raise_event( io_event = lr_event ).

  ENDMETHOD.


  METHOD CREATE_STRUCT_RTTI.

    DATA: lt_components        TYPE cl_abap_structdescr=>component_table.

    FIELD-SYMBOLS: <component> LIKE LINE OF lt_components.

    super->create_struct_rtti( ).

    lt_components = me->mo_struct_rtti->get_components( ).

    APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
    <component>-name = if_mdg_bs_ecc_bp_constants=>gc_cu_field-doc_status.
    <component>-type = cl_abap_elemdescr=>get_string( ).
    APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
    <component>-name = if_mdg_bs_ecc_bp_constants=>gc_cu_field-doc_status_txt.
    <component>-type = cl_abap_elemdescr=>get_string( ).
    APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
    <component>-name = if_mdg_bs_ecc_bp_constants=>gc_cu_field-doc_description.
    <component>-type = cl_abap_elemdescr=>get_string( ).

    me->mo_struct_rtti = cl_abap_structdescr=>create( lt_components ).

  ENDMETHOD.


  METHOD GET_ACTIONS.
    FIELD-SYMBOLS:
      <ls_actiondef> LIKE LINE OF me->mt_actiondef.

    super->get_actions( ).

    " Create new event ID for document creation
    APPEND INITIAL LINE TO me->mt_actiondef ASSIGNING <ls_actiondef>.
    <ls_actiondef>-id = mc_event_create_doc.
    <ls_actiondef>-visible = cl_wd_uielement=>e_visible-visible.
    <ls_actiondef>-text = TEXT-001.
    <ls_actiondef>-enabled = abap_true.
    <ls_actiondef>-action_type = 0.
    <ls_actiondef>-imagesrc = '~Icon/NewItem'.
    <ls_actiondef>-exposable = abap_true.
    <ls_actiondef>-is_implicit_edit = abap_true.
    <ls_actiondef>-event_param_strukname = 'FPM_BOL_ENTITY_CREATE_CONTROL'.

  ENDMETHOD.


  METHOD GET_DISPLAY_GUI_TYPE.
    rv_gui_type = 'WIN_GUI'.
  ENDMETHOD.


  METHOD GET_DOKAR.
    DATA lt_tdwo TYPE TABLE OF tdwo.

    SELECT * FROM tdwo INTO TABLE lt_tdwo
      WHERE dokob EQ if_mdg_bs_ecc_bp_constants=>gc_cu_dokob.
    IF sy-subrc NE 0.
      CLEAR me->mt_dokar[].
      RETURN.
    ENDIF.
    SELECT dokar dartxt FROM tdwat INTO CORRESPONDING FIELDS OF TABLE me->mt_dokar
      FOR ALL ENTRIES IN lt_tdwo
      WHERE cvlang EQ sy-langu
        AND dokar  EQ lt_tdwo-dokar.

  ENDMETHOD.


  METHOD GET_DOKST.

    SELECT * FROM tdwst INTO TABLE me->mt_dokst
        WHERE cvlang EQ sy-langu.

  ENDMETHOD.


  METHOD GET_ENTITY_DATA.

    DATA: ld_dokst TYPE dokst,
          ld_dktxt TYPE dktxt.

    FIELD-SYMBOLS: <data>  TYPE any,
                   <dokar> TYPE dokar,
                   <doknr> TYPE doknr,
                   <doktl> TYPE doktl_d,
                   <dokvr> TYPE dokvr,
                   <dokst> TYPE tdwst,
                   <dktxt> TYPE mty_dktxt.

    super->get_entity_data( EXPORTING io_access = io_access
                            CHANGING  cs_data   = cs_data ).

    CHECK io_access IS BOUND.
    DATA(lo_entity) = CAST cl_crm_bol_entity( io_access ).
    CHECK lo_entity IS BOUND AND lo_entity->get_state_of_changes( ) NE lo_entity->co_change_state_rejected.

    ASSIGN COMPONENT if_mdg_bs_ecc_bp_constants=>gc_cu_field-doc_status_txt
        OF STRUCTURE cs_data TO <data>.
    CHECK sy-subrc EQ 0.
    IF <data> IS INITIAL.
      ASSIGN COMPONENT mc_field_dokar OF STRUCTURE cs_data TO <dokar>.
      ASSIGN COMPONENT mc_field_doknr OF STRUCTURE cs_data TO <doknr>.
      ASSIGN COMPONENT mc_field_doktl OF STRUCTURE cs_data TO <doktl>.
      ASSIGN COMPONENT mc_field_dokvr OF STRUCTURE cs_data TO <dokvr>.

      CHECK ( <dokar> IS ASSIGNED AND <dokar> IS NOT INITIAL ) AND
            ( <doknr> IS ASSIGNED AND <doknr> IS NOT INITIAL ) AND
            ( <doktl> IS ASSIGNED AND <doktl> IS NOT INITIAL ) AND
            ( <dokvr> IS ASSIGNED AND <dokvr> IS NOT INITIAL ).

      SELECT SINGLE dokst FROM draw INTO ld_dokst
        WHERE dokar EQ <dokar>
          AND doknr EQ <doknr>
          AND doktl EQ <doktl>
          AND dokvr EQ <dokvr>.

      IF ld_dokst IS NOT INITIAL.
        IF me->mt_dokst IS INITIAL.
          me->get_dokst( ).
        ENDIF.
        READ TABLE me->mt_dokst ASSIGNING <dokst> WITH KEY dokst = ld_dokst.
        CHECK sy-subrc EQ 0.
        <data> = <dokst>-dostx.
      ENDIF.

      UNASSIGN <data>.
      ASSIGN COMPONENT if_mdg_bs_ecc_bp_constants=>gc_cu_field-doc_description
          OF STRUCTURE cs_data TO <data>.
      CHECK sy-subrc EQ 0 AND <data> IS INITIAL.

      SELECT SINGLE dktxt FROM drat INTO ld_dktxt
        WHERE dokar EQ <dokar>
          AND doknr EQ <doknr>
          AND doktl EQ <doktl>
          AND dokvr EQ <dokvr>
          AND langu EQ sy-langu.

      IF ld_dktxt IS NOT INITIAL.
        <data> = ld_dktxt.
      ELSE.
        READ TABLE me->mt_dktxt ASSIGNING <dktxt>
          WITH KEY doknr = <doknr>.
        CHECK sy-subrc EQ 0.
        <data> = <dktxt>-dktxt.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD GET_FIELD_UI_PROP.

    DATA: ld_komp  TYPE name_komp,
          ld_dokar TYPE dokar,
          ld_doknr TYPE doknr,
          ld_doktl TYPE doktl_d,
          ld_dokvr TYPE dokvr.

    rs_property = super->get_field_ui_prop(
       io_entity         = io_entity
       iv_attr_name      = iv_attr_name
       iv_change_allowed = iv_change_allowed
       is_prop           = is_prop ).

    CASE iv_attr_name.
      WHEN mc_field_dokar.
        IF io_entity IS BOUND.
          ld_komp = mc_field_dokar.
          io_entity->get_property_as_value(
            EXPORTING iv_attr_name = ld_komp
            IMPORTING ev_result    = ld_dokar ).

          IF NOT ld_dokar IS INITIAL AND
             io_entity->is_send_active( ) EQ abap_true.
            rs_property-read_only = abap_true.
          ENDIF.
        ENDIF.

      WHEN mc_field_doknr.
        IF io_entity IS BOUND.
          ld_komp = mc_field_doknr.
          io_entity->get_property_as_value(
            EXPORTING iv_attr_name = ld_komp
            IMPORTING ev_result    = ld_doknr ).

          IF NOT ld_doknr IS INITIAL AND
             io_entity->is_send_active( ) EQ abap_true.
            rs_property-read_only = abap_true.
          ENDIF.
        ENDIF.

      WHEN mc_field_doktl.
        IF io_entity IS BOUND.
          ld_komp = mc_field_doktl.
          io_entity->get_property_as_value(
            EXPORTING iv_attr_name = ld_komp
            IMPORTING ev_result    = ld_doktl ).

          IF NOT ld_doktl IS INITIAL AND
             io_entity->is_send_active( ) EQ abap_true.
            rs_property-read_only = abap_true.
          ENDIF.
        ENDIF.

      WHEN mc_field_dokvr.
        IF io_entity IS BOUND.
          ld_komp = mc_field_dokvr.
          io_entity->get_property_as_value(
            EXPORTING iv_attr_name = ld_komp
            IMPORTING ev_result    = ld_dokvr ).

          IF NOT ld_dokvr IS INITIAL AND
             io_entity->is_send_active( ) EQ abap_true.
            rs_property-read_only = abap_true.
          ENDIF.
        ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD IF_FPM_GUIBB_LIST~GET_DEFINITION.
    FIELD-SYMBOLS: <ls_field_description> LIKE LINE OF et_field_description.

    super->if_fpm_guibb_list~get_definition(
      IMPORTING
        eo_field_catalog         = eo_field_catalog
        et_field_description     = et_field_description
        et_action_definition     = et_action_definition
        et_special_groups        = et_special_groups
        es_message               = es_message
        ev_additional_error_info = ev_additional_error_info
        et_dnd_definition        = et_dnd_definition
        et_row_actions           = et_row_actions
        es_options               = es_options ).

    LOOP AT et_field_description ASSIGNING <ls_field_description>
      WHERE name = mc_field_dokar
         OR name = mc_field_doknr
         OR name = mc_field_doktl
         OR name = mc_field_dokvr.
      <ls_field_description>-ovs_name = me->class_name.
    ENDLOOP.

  ENDMETHOD.


  METHOD IF_FPM_GUIBB_LIST~PROCESS_EVENT.

* Call parent
    super->if_fpm_guibb_list~process_event(
      EXPORTING
        io_event            = io_event
        iv_raised_by_own_ui = iv_raised_by_own_ui
        iv_lead_index       = iv_lead_index
        iv_event_index      = iv_event_index
        it_selected_lines   = it_selected_lines
        io_ui_info          = io_ui_info
      IMPORTING
        ev_result           = ev_result
        et_messages         = et_messages ).

* Specific handling after parent call
    CASE io_event->mv_event_id.
      WHEN mc_event_create_doc.
        me->create_document(
          EXPORTING io_event = io_event ).

      WHEN cl_bs_cu_guibb_documents_popup=>mc_event_doc_selected.
        me->process_document(
          EXPORTING io_event = io_event ).

      WHEN mc_event_show_doc.
        me->show_document(
            EXPORTING
              io_event            = io_event
              iv_raised_by_own_ui = iv_raised_by_own_ui
              iv_lead_index       = iv_lead_index
              iv_event_index      = iv_event_index
              it_selected_lines   = it_selected_lines
              io_ui_info          = io_ui_info
            IMPORTING
              ev_result           = ev_result
              et_messages         = et_messages ).

      WHEN OTHERS.
        "nothing to do
    ENDCASE.

  ENDMETHOD.


  METHOD IF_FPM_GUIBB_OVS~HANDLE_PHASE_1.
    DATA ls_sel_input TYPE mty_ovs_input.
    DATA lr_data TYPE REF TO data.
    DATA ls_label_text TYPE wdr_name_value.
    DATA lt_label_texts TYPE wdr_name_value_list.

    FIELD-SYMBOLS: <input> TYPE any,
                   <langu> TYPE cvlang,
                   <dokar> TYPE dokar.

    CASE iv_field_name.
      WHEN mc_field_doknr
        OR mc_field_doktl
        OR mc_field_dokvr.

        CREATE DATA lr_data TYPE mty_ovs_input.
        ASSIGN lr_data->* TO <input>.
        ASSIGN COMPONENT mc_field_langu OF STRUCTURE <input> TO <langu>.
        CHECK <langu> IS ASSIGNED.
        <langu> = sy-langu.

        ASSIGN COMPONENT mc_field_dokar OF STRUCTURE <input> TO <dokar>.
        CHECK <dokar> IS ASSIGNED.
        io_ovs_callback->context_element->get_attribute(
          EXPORTING name  = mc_field_dokar
          IMPORTING value = <dokar>
        ).
        io_ovs_callback->set_input_structure(
          input = <input>
          label_texts = lt_label_texts
          display_values_immediately = abap_false
        ).

      WHEN OTHERS.
        super->if_fpm_guibb_ovs~handle_phase_1(
          iv_field_name   = iv_field_name
          io_ovs_callback = io_ovs_callback
        ).

    ENDCASE.

  ENDMETHOD.


  METHOD IS_CREATE_ENABLED.

    DATA: ld_komp TYPE name_komp.

  "  rv_enabled = super->is_create_enabled( ).

    CHECK rv_enabled EQ abap_true AND me->mo_collection IS BOUND AND me->mo_collection->size( ) GT 0.

*   When an entry is under creation, then it should be completed before the next entry can be created
    ld_komp = mc_field_doknr.
    CHECK me->mo_entity IS BOUND AND me->mo_entity->alive( ) AND me->mo_entity->get_property_as_string( ld_komp ) IS INITIAL.
    rv_enabled = abap_false.

  ENDMETHOD.


  METHOD OVS_HANDLE_PHASE_0.
    DATA ls_label_text TYPE wdr_name_value.

    CASE iv_field_name.
      WHEN mc_field_doknr
        OR mc_field_doktl
        OR mc_field_dokvr.

        ls_label_text-name  = mc_field_dktxt.
        ls_label_text-value = TEXT-l01.
        INSERT ls_label_text INTO TABLE et_label_texts.
        INSERT ls_label_text INTO TABLE et_column_texts.

        ls_label_text-name  = mc_field_langu.
        ls_label_text-value = TEXT-l02.
        INSERT ls_label_text INTO TABLE et_label_texts.

        ls_label_text-name  = mc_field_dokar.
        ls_label_text-value = TEXT-l03.
        INSERT ls_label_text INTO TABLE et_label_texts.
        INSERT ls_label_text INTO TABLE et_column_texts.

        ls_label_text-name  = mc_field_doknr.
        ls_label_text-value = TEXT-l04.
        INSERT ls_label_text INTO TABLE et_label_texts.
        INSERT ls_label_text INTO TABLE et_column_texts.

        ls_label_text-name  = mc_field_doktl.
        ls_label_text-value = TEXT-l05.
        INSERT ls_label_text INTO TABLE et_column_texts.

        ls_label_text-name  = mc_field_dokvr.
        ls_label_text-value = TEXT-l06.
        INSERT ls_label_text INTO TABLE et_column_texts.

      WHEN OTHERS.
        super->ovs_handle_phase_0(
          EXPORTING
            iv_field_name   = iv_field_name
          IMPORTING
            ev_window_title = ev_window_title
            ev_group_header = ev_group_header
            et_label_texts  = et_label_texts
            ev_table_header = ev_table_header
            et_column_texts = et_column_texts
            ev_col_count    = ev_col_count
            ev_row_count    = ev_row_count ).

    ENDCASE.

  ENDMETHOD.


  METHOD OVS_HANDLE_PHASE_2.
    DATA: lt_tdwo   TYPE TABLE OF tdwo,
          lt_dktxt  TYPE RANGE OF drat-dktxt,
          lt_langu  TYPE RANGE OF drat-langu,
          lt_dokar_range  TYPE RANGE OF drat-dokar,
          ls_dokar_range  LIKE LINE OF lt_dokar_range,
          lt_doknr  TYPE RANGE OF drat-doknr,
          lt_output TYPE TABLE OF mty_ovs_output.
    DATA: lr_data TYPE REF TO data.

    FIELD-SYMBOLS: <output>     TYPE ANY TABLE,
                   <parameters> TYPE mty_ovs_input,
                   <dktxt>      LIKE LINE OF lt_dktxt,
                   <langu>      LIKE LINE OF lt_langu,
                   <doknr>      LIKE LINE OF lt_doknr.

    CASE iv_field_name.
      WHEN mc_field_dokar.

        IF me->mt_dokar IS INITIAL.
          me->get_dokar( ).
        ENDIF.
        CREATE DATA lr_data TYPE STANDARD TABLE OF mty_dokar.
        ASSIGN lr_data->* TO <output>.
        <output>  = me->mt_dokar.
        er_output = lr_data.

      WHEN mc_field_doknr
        OR mc_field_doktl
        OR mc_field_dokvr.

        CHECK ir_query_parameter IS BOUND.
        ASSIGN ir_query_parameter->* TO <parameters>.
        CHECK <parameters> IS ASSIGNED.

        CREATE DATA lr_data TYPE STANDARD TABLE OF mty_ovs_output.
        ASSIGN lr_data->* TO <output>.
        er_output = lr_data.

        APPEND INITIAL LINE TO lt_dktxt ASSIGNING <dktxt>.
        <dktxt>-sign   = 'I'.
        <dktxt>-option = 'CP'.
        IF <parameters>-dktxt IS INITIAL.
          <dktxt>-low    = '*'.
        ELSE.
          <dktxt>-low    = <parameters>-dktxt.
        ENDIF.

        APPEND INITIAL LINE TO lt_langu ASSIGNING <langu>.
        <langu>-sign   = 'I'.
        <langu>-option = 'CP'.
        IF <parameters>-langu IS INITIAL.
          <langu>-low    = '*'.
        ELSE.
          <langu>-low    = <parameters>-langu.
        ENDIF.

        IF me->mt_dokar IS INITIAL.
          me->get_dokar( ).
        ENDIF.
        ls_dokar_range-sign   = 'I'.
        ls_dokar_range-option = 'EQ'.
        IF <parameters>-dokar IS INITIAL.
          <parameters>-dokar = '*'.
        ENDIF.
        LOOP AT me->mt_dokar INTO DATA(ls_dokar)
          WHERE dokar CP <parameters>-dokar.
          ls_dokar_range-low = ls_dokar-dokar.
          APPEND ls_dokar_range TO lt_dokar_range.
        ENDLOOP.
        IF lt_dokar_range[] IS INITIAL.
          RETURN.
        ENDIF.

        APPEND INITIAL LINE TO lt_doknr ASSIGNING <doknr>.
        <doknr>-sign   = 'I'.
        <doknr>-option = 'CP'.
        IF <parameters>-doknr IS INITIAL.
          <doknr>-low    = '*'.
        ELSE.
          <doknr>-low    = <parameters>-doknr.
        ENDIF.

        SELECT * FROM drat INTO CORRESPONDING FIELDS OF TABLE lt_output
            WHERE dokar IN lt_dokar_range
              AND doknr IN lt_doknr
              AND langu IN lt_langu
              AND dktxt IN lt_dktxt.

        <output> = lt_output.

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


  METHOD OVS_HANDLE_PHASE_3.
    DATA: lr_data TYPE REF TO data.

    FIELD-SYMBOLS: <output>      TYPE mty_ovs_output,
                   <field_value> LIKE LINE OF et_field_value.

    CALL METHOD super->ovs_handle_phase_3
      EXPORTING
        iv_field_name  = iv_field_name
        ir_selection   = ir_selection
      IMPORTING
        et_field_value = et_field_value
        eo_fpm_event   = eo_fpm_event.

    CASE iv_field_name.
      WHEN mc_field_doknr.
        CREATE DATA lr_data TYPE mty_ovs_output.
        lr_data = ir_selection.
        ASSIGN lr_data->* TO <output>.

        IF NOT <output>-dokar IS INITIAL.
          APPEND INITIAL LINE TO et_field_value ASSIGNING <field_value>.
          <field_value>-name   = mc_field_dokar.
          GET REFERENCE OF <output>-dokar INTO <field_value>-value.
        ENDIF.

        IF NOT <output>-doktl IS INITIAL.
          APPEND INITIAL LINE TO et_field_value ASSIGNING <field_value>.
          <field_value>-name   = mc_field_doktl.
          GET REFERENCE OF <output>-doktl INTO <field_value>-value.
        ENDIF.

        IF NOT <output>-dokvr IS INITIAL.
          APPEND INITIAL LINE TO et_field_value ASSIGNING <field_value>.
          <field_value>-name   = mc_field_dokvr.
          GET REFERENCE OF <output>-dokvr INTO <field_value>-value.
        ENDIF.

        eo_fpm_event = cl_fpm_event=>create_by_id( iv_event_id = if_fpm_constants=>gc_event-refresh ).

      WHEN mc_field_doktl.
        CREATE DATA lr_data TYPE mty_ovs_output.
        lr_data = ir_selection.
        ASSIGN lr_data->* TO <output>.

        IF NOT <output>-doknr IS INITIAL.
          APPEND INITIAL LINE TO et_field_value ASSIGNING <field_value>.
          <field_value>-name   = mc_field_doknr.
          GET REFERENCE OF <output>-doknr INTO <field_value>-value.
        ENDIF.

        IF NOT <output>-dokar IS INITIAL.
          APPEND INITIAL LINE TO et_field_value ASSIGNING <field_value>.
          <field_value>-name   = mc_field_dokar.
          GET REFERENCE OF <output>-dokar INTO <field_value>-value.
        ENDIF.

        IF NOT <output>-dokvr IS INITIAL.
          APPEND INITIAL LINE TO et_field_value ASSIGNING <field_value>.
          <field_value>-name   = mc_field_dokvr.
          GET REFERENCE OF <output>-dokvr INTO <field_value>-value.
        ENDIF.

        eo_fpm_event = cl_fpm_event=>create_by_id( iv_event_id = if_fpm_constants=>gc_event-refresh ).

      WHEN mc_field_dokvr.
        CREATE DATA lr_data TYPE mty_ovs_output.
        lr_data = ir_selection.
        ASSIGN lr_data->* TO <output>.

        IF NOT <output>-doknr IS INITIAL.
          APPEND INITIAL LINE TO et_field_value ASSIGNING <field_value>.
          <field_value>-name   = mc_field_doknr.
          GET REFERENCE OF <output>-doknr INTO <field_value>-value.
        ENDIF.

        IF NOT <output>-dokar IS INITIAL.
          APPEND INITIAL LINE TO et_field_value ASSIGNING <field_value>.
          <field_value>-name   = mc_field_dokar.
          GET REFERENCE OF <output>-dokar INTO <field_value>-value.
        ENDIF.

        IF NOT <output>-doktl IS INITIAL.
          APPEND INITIAL LINE TO et_field_value ASSIGNING <field_value>.
          <field_value>-name   = mc_field_doktl.
          GET REFERENCE OF <output>-doktl INTO <field_value>-value.
        ENDIF.

        eo_fpm_event = cl_fpm_event=>create_by_id( iv_event_id = if_fpm_constants=>gc_event-refresh ).

      WHEN mc_field_dokar.
        eo_fpm_event = cl_fpm_event=>create_by_id( iv_event_id = if_fpm_constants=>gc_event-refresh ).

    ENDCASE.

  ENDMETHOD.


  METHOD PROCESS_DOCUMENT.

    DATA: ld_dokar TYPE dokar,
          ld_doknr TYPE doknr,
          ld_doktl TYPE doktl_d,
          ld_dokvr TYPE dokvr,
          ld_dktxt TYPE dktxt.

    DATA: ls_document TYPE bss_cuil_document.

    DATA: lr_entity_drad  TYPE REF TO cl_crm_bol_entity.

    FIELD-SYMBOLS: <dktxt> TYPE mty_dktxt.

    io_event->mo_event_data->get_value(
       EXPORTING
         iv_key   = mc_field_dokar
       IMPORTING
         ev_value = ld_dokar ).

    io_event->mo_event_data->get_value(
      EXPORTING
        iv_key   = mc_field_doknr
      IMPORTING
        ev_value = ld_doknr ).

    io_event->mo_event_data->get_value(
      EXPORTING
        iv_key   = mc_field_doktl
        IMPORTING
        ev_value = ld_doktl ).

    io_event->mo_event_data->get_value(
      EXPORTING
        iv_key   = mc_field_dokvr
        IMPORTING
          ev_value = ld_dokvr ).

    io_event->mo_event_data->get_value(
      EXPORTING
        iv_key   = mc_field_dktxt
        IMPORTING
          ev_value = ld_dktxt ).

    ls_document-dokar = ld_dokar.
    ls_document-doknr = ld_doknr.
    ls_document-doktl = ld_doktl.
    ls_document-dokvr = ld_dokvr.
    lr_entity_drad = create( iv_event_id = me->mv_action_create ).
    CHECK lr_entity_drad IS BOUND.
    lr_entity_drad->set_properties( is_attributes = ls_document ).

    APPEND INITIAL LINE TO me->mt_dktxt ASSIGNING <dktxt>.
    <dktxt>-doknr = ld_doknr.
    <dktxt>-dktxt = ld_dktxt.

  ENDMETHOD.


  METHOD SET_PARENT_ENTITY.

    DATA: lr_connector TYPE REF TO cl_bs_bp_connector_bol_rel,
          lr_entity    TYPE REF TO cl_crm_bol_entity.

    CHECK me->mo_parent_entity IS NOT BOUND.
    CHECK me->mo_connector IS BOUND.

    TRY.
        lr_connector ?= me->mo_connector.
      CATCH cx_sy_move_cast_error.
        RETURN.
    ENDTRY.

    ASSERT lr_connector IS BOUND.
    lr_entity = lr_connector->get_parent( ).

    CHECK lr_entity IS BOUND.
    me->mo_parent_entity = lr_entity.

  ENDMETHOD.


  METHOD SHOW_DOCUMENT.

    DATA: ld_component TYPE string,
          ld_exist     TYPE boole_d,
          ld_error     TYPE boole_d.

    DATA: ls_data          TYPE bss_cuil_document,
          ls_ta_fields     TYPE fpm_s_launch_transaction,
          ls_ta_params     TYPE apb_lpd_s_params,
          ls_add_params    TYPE apb_lpd_s_add_trans_parameters,
          ls_draw          TYPE draw,
          ls_message       TYPE fpm_s_t100_message,
          ls_fpmgb_message TYPE fpmgb_s_t100_message.

    DATA: lt_message            TYPE fpm_t_t100_messages.

    DATA: lr_entity      TYPE REF TO cl_crm_bol_entity,
          lr_iterator    TYPE REF TO if_bol_entity_col_iterator,
          lr_fpm         TYPE REF TO if_fpm,
          lr_navigate_to TYPE REF TO if_fpm_navigate_to.

    FIELD-SYMBOLS: <data>    TYPE bss_cuil_document,
                   <doknr>   TYPE doknr,
                   <dokar>   TYPE dokar,
                   <doktl>   TYPE doktl_d,
                   <dokvr>   TYPE dokvr,
                   <message> TYPE fpmgb_s_t100_message.

    CHECK iv_event_index >= 1.
    CHECK me->mo_collection IS BOUND.
    lr_iterator = me->mo_collection->get_iterator( ).
    lr_entity   = lr_iterator->get_by_index( iv_index = iv_event_index ).
    CHECK lr_entity IS BOUND AND lr_entity->alive( ).
    lr_entity->get_properties( IMPORTING es_attributes = ls_data ).
    ASSIGN ls_data TO <data>.

    ev_result = if_fpm_constants=>gc_event_result-ok.

* Prepare Transaction Launch
    CALL METHOD me->get_display_gui_type
      EXPORTING
        is_doc_info = ls_data
      receiving
        rv_gui_type = ls_ta_fields-gui_type.

    ls_ta_fields-system_alias = 'SAP_LocalSystem'.
    ls_ta_fields-tcode        = 'CV03N'.

    ld_component = mc_field_doknr.
    ASSIGN COMPONENT ld_component OF STRUCTURE <data> TO <doknr>.
    CHECK sy-subrc EQ 0.

    ls_ta_params-key = |DRAW-{ ld_component }|.
    ls_ta_params-value = <doknr>.
    INSERT ls_ta_params INTO TABLE ls_ta_fields-parameter.

    ld_component = mc_field_dokar.
    ASSIGN COMPONENT ld_component OF STRUCTURE <data> TO <dokar>.
    IF sy-subrc EQ 0.
      ls_ta_params-key = |DRAW-{ ld_component }|.
      ls_ta_params-value = <dokar>.
      INSERT ls_ta_params INTO TABLE ls_ta_fields-parameter.
    ENDIF.

    ld_component = mc_field_doktl.
    ASSIGN COMPONENT ld_component OF STRUCTURE <data> TO <doktl>.
    IF sy-subrc EQ 0.
      ls_ta_params-key = |DRAW-DOKTL|.
      ls_ta_params-value = <doktl>.
      INSERT ls_ta_params INTO TABLE ls_ta_fields-parameter.
    ENDIF.

    ld_component = mc_field_dokvr.
    ASSIGN COMPONENT ld_component OF STRUCTURE <data> TO <dokvr>.
    IF sy-subrc EQ 0.
      ls_ta_params-key = |DRAW-DOKVR|.
      ls_ta_params-value = <dokvr>.
      INSERT ls_ta_params INTO TABLE ls_ta_fields-parameter.
    ENDIF.

* Existance check, when buffered previously
    CALL METHOD cl_mdg_bs_draw_api=>read_document_buff
      EXPORTING
        iv_docnumber            = <doknr>
        iv_doctype              = <dokar>
        iv_docpart              = <doktl>
        iv_docversion           = <dokvr>
        iv_only_doc_exist_check = abap_true
      IMPORTING
        ev_doc_exists           = ld_exist.

    IF ld_exist EQ abap_true. "Document still in buffer...
      IF 1 = 0. "only to enable where-used list
        MESSAGE e043(mdg_bs_cust_bolui).
      ENDIF.
      APPEND INITIAL LINE TO et_messages ASSIGNING <message>.
      <message>-msgid    = 'MDG_BS_CUST_BOLUI'.
      <message>-msgno    = '043'.
      <message>-severity = 'E'.
      RETURN.
    ENDIF.

* Commence with triggering document display
    ls_add_params-navigation_mode              = 'EXTERNAL'.
    ls_add_params-skip_init_screen_if_possible = abap_true.
    ls_add_params-parameter_forwarding         = 'P'.
    ls_add_params-batch_input_program          = 'SAPLCV110'.
    ls_add_params-batch_input_dynnr            = '100'.
    ls_add_params-batch_input_ok_code          = '/00'.

* Launch Transaction
    lr_fpm = cl_fpm=>get_instance( ).
    lr_navigate_to = lr_fpm->get_navigate_to( ).
    lr_navigate_to->launch_transaction(
      EXPORTING is_transaction_fields    = ls_ta_fields
                is_additional_parameters = ls_add_params
      IMPORTING et_messages              = lt_message
                ev_error                 = ld_error ).

    LOOP AT lt_message INTO ls_message.
      MOVE-CORRESPONDING ls_message TO ls_fpmgb_message.
      APPEND ls_fpmgb_message TO et_messages.
    ENDLOOP.
    IF ld_error EQ abap_true.
      ev_result = if_fpm_constants=>gc_event_result-failed.
    ELSE.
      ev_result = if_fpm_constants=>gc_event_result-ok.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
