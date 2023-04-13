class ZCL_MDG_BS_GUIBB_LISTWANG definition
  public
  inheriting from CL_GUIBB_BOL_LIST
  create public .

public section.
  type-pools USMD0 .

  interfaces IF_BS_BOL_HOW_FEEDER .

  methods CONSTRUCTOR .

  methods IF_FPM_GUIBB_LIST_PAGING~FLUSH
    redefinition .
  methods IF_FPM_GUIBB_LIST_PAGING~GET_DATA
    redefinition .
  methods IF_FPM_GUIBB_LIST_PAGING~PROCESS_EVENT
    redefinition .
  methods IF_FPM_GUIBB_LIST~CHECK_CONFIG
    redefinition .
  methods IF_FPM_GUIBB_LIST~FLUSH
    redefinition .
  methods IF_FPM_GUIBB_LIST~GET_DATA
    redefinition .
  methods IF_FPM_GUIBB_LIST~GET_DEFAULT_CONFIG
    redefinition .
  methods IF_FPM_GUIBB_LIST~GET_DEFINITION
    redefinition .
  methods IF_FPM_GUIBB_LIST~PROCESS_EVENT
    redefinition .
  methods IF_FPM_GUIBB~GET_PARAMETER_LIST
    redefinition .
  methods IF_FPM_GUIBB~INITIALIZE
    redefinition .
protected section.

  types:
    BEGIN OF s_attr2entity,
      attribute  TYPE usmd_fieldname,
      edition    TYPE abap_bool,
      entity     TYPE usmd_entity,
      key_fields TYPE usmd_ts_attribute,
    END OF s_attr2entity .
  types:
    BEGIN OF s_entity_info_hc,
      join_id        TYPE join_id,
      entity         TYPE REF TO cl_crm_bol_entity,
      crud           TYPE usmd_crud,
      saved_change   TYPE usmd_saved_change,
      unsaved_change TYPE usmd_unsaved_change,
      object_name    TYPE crmt_ext_obj_name,
    END OF s_entity_info_hc .
  types:
    t_entity_info_hc TYPE STANDARD TABLE OF s_entity_info_hc .
  types:
    ts_attr2entity TYPE SORTED TABLE OF s_attr2entity WITH UNIQUE KEY attribute .
  types:
    ty_t_list_of_fixings TYPE STANDARD TABLE OF crmt_name_value_pair_tab .

  constants CV_DELETE_COLUMN type NAME_KOMP value 'FPMOVPNAVIDELETE' ##NO_TEXT.
  constants CV_EDIT_COLUMN type NAME_KOMP value 'FPMOVPNAVIEDIT' ##NO_TEXT.
  constants CV_EVENT_ID_SHOW type FPM_EVENT_ID value 'SHOW' ##NO_TEXT.
  constants CV_EVENT_ID_SHOW_SOVP type FPM_EVENT_ID value 'SHOW_SOVP' ##NO_TEXT.
  constants:
    BEGIN OF gc_pbo,
      none        TYPE c VALUE ' ',
      preliminary TYPE c VALUE 'P',
      final       TYPE c VALUE 'F',
    END OF gc_pbo .
  data MO_CLONING_EVENT type ref to CL_FPM_EVENT .
  data MO_ENTITY_CLONER type ref to IF_BS_BOL_ENTITY_CLONER .
  data MO_FPM_TOOLBOX type ref to CL_BS_FPM_TOOLBOX .
  data MO_HIGHLIGHT_CHANGES type ref to IF_USMD_HIGHLIGHT_CHANGES_API .
  data MO_HOW_TO type ref to CL_BS_DO_GUIBB_BOL .
  data MO_MORPH_CONFIG_SUPERVISOR type ref to IF_BS_MORPH_CONFIG_SUPERVISOR .
  data MO_TEXT_ASSIST type ref to CL_USMD_GENERIC_GENIL_TEXT .
  data MS_INIT_ERROR type FPMGB_S_T100_MESSAGE .
  data MT_ATTR2ENTITY type TS_ATTR2ENTITY .
  data MT_CONFIG_FIELDS type CRMT_ATTR_NAME_TAB .
  data MT_DELAYED_CHANGES type CL_BS_DO_GUIBB_BOL=>TY_T_DELAYED_CHANGES .
  data MT_DYNAMIC_LABELS type CL_MDG_BS_GUIBB_FORM=>TY_T_DYNAMIC_LABELS .
  data MT_EXCLUDED_EVENTS_PER_ACTION type BST_EVENT_EXCLUSION .
  data MT_FPM_MESSAGES type FPMGB_T_MESSAGES .
  data MT_LABELS_OF_ENTITIES type CL_MDG_BS_GUIBB_FORM=>TY_T_LABELS_OF_ENTITIES .
  data MV_ACTION type USMD_ACTION .
  data MV_ATS_LIST type ABAP_BOOL value ABAP_TRUE ##NO_TEXT.
  data MV_CHECK_MUTABILITY type ABAP_BOOL value ABAP_TRUE ##NO_TEXT.
  data MV_DIALOG_ID type FPM_DIALOG_WINDOW_ID .
  data MV_DISABLE_HC type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_HIGHLIGHT_DEL_ACTIVE type ABAP_BOOL .
  data MV_LABELS_SCPL_LOCATION type SCPL_LOCATION_ID value CL_BS_BOL_STYLIST=>GC_LOCATION ##NO_TEXT.
  data MV_MOMENTUM_FOR_UNDO type I .
  data MV_MULTI_PROCESSING_LIST type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_NECESSARY_MOMENTUM type I .
  data MV_OCA_DELETE_ENABLED type ABAP_BOOL value ABAP_TRUE ##NO_TEXT.
  data MV_OCA_DELETE_ENABLED_REF type NAME_KOMP value 'OCA_DELETE_ENABLED' ##NO_TEXT.
  data MV_OCA_DISPLAY_VISIBLE_REF type NAME_KOMP value 'OCA_DISPLAY_VISIBLE' ##NO_TEXT.
  data MV_OCA_EDIT_ENABLED type ABAP_BOOL value ABAP_TRUE ##NO_TEXT.
  data MV_OCA_EDIT_ENABLED_REF type NAME_KOMP value 'OCA_EDIT_ENABLED' ##NO_TEXT.
  data MV_ONLY_DYNAMIC_LABELS type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_PBO type C value GC_PBO-NONE ##NO_TEXT.
  data MV_REFRESH_DATA type ABAP_BOOL value ABAP_TRUE ##NO_TEXT.
  data MV_UNCHANGEABLE_KEYS type STRING .

  methods ADJUST_CHANGED_OBJECT_INFO
    importing
      !IO_ENTITY type ref to CL_CRM_BOL_ENTITY
      !IV_IS_NEW_ENTITY type ABAP_BOOL
      !IV_MAIN_ENTITY type ABAP_BOOL
    changing
      !CS_CHANGED_OBJECT type USMD_S_CHANGED_OBJECT
      !CS_DATA type DATA .
  methods ASSIGN_SEARCH_HELPS
    changing
      !CT_FIELD_DESCRIPTION type FPMGB_T_LISTFIELD_DESCR .
  methods CONVERT_UTC_TIMESTAMP
    importing
      !IV_TIMESTAMP type TIMESTAMP
    returning
      value(RV_TIMESTAMP) type TIMESTAMP .
  methods DETERMINE_PBO_STATUS .
  methods DISABLE_HIGHLIGHT_DELETIONS .
  methods GET_CHANGED_TRANSIENT_FIELDS
    importing
      !IT_CHANGED_FIELDS type USMD_TS_CHANGED_FIELDS_HC
    returning
      value(RRT_TRANS_FIELDS_MAPPING) type ref to USMD_TS_CHANGED_FIELDS_HC .
  methods GET_DELETED_TRANSIENT_FIELDS
    importing
      !IT_DELETED_FIELDS type USMD_TS_CHANGED_FIELDS_HC
    returning
      value(RRT_TRANS_FIELDS_MAPPING) type ref to USMD_TS_CHANGED_FIELDS_HC .
  methods GET_ENTITY_KEY_VALUES
    importing
      !IO_EVENT type ref to CL_FPM_EVENT optional
      !IO_ENTITY type ref to CL_CRM_BOL_ENTITY optional
    exporting
      !ES_ENTITY_KEY_VALUES type ANY .
  methods GET_INITIAL_DATA_CREATE_ROOT
    changing
      !CS_INITIAL_DATA type FPM_BOL_INITIAL_DATA .
  methods GET_LABEL_TEXT
    importing
      !IV_NAME type NAME_KOMP
      !IV_LABEL_TEXT_USAGE type STRING
      !IV_BOL_OBJECT_NAME type CRMT_EXT_OBJ_NAME optional
      !IV_BOL_ATTRIBUTE_NAME type NAME_KOMP optional
    returning
      value(RV_LABEL_TEXT) type STRING .
  methods GET_MAIN_ENTITY_OF_LINE_BY_IDX
    importing
      !IV_INDEX type SYTABIX
    returning
      value(RO_ENTITY_BOL) type ref to CL_CRM_BOL_ENTITY .
  methods GET_SELECTION_FOR_TEXTS
    importing
      !IO_ENTITY type ref to CL_CRM_BOL_ENTITY
      !IV_ATTRIBUTE type FIELDNAME
      !IV_VALUE type ANY
    exporting
      !ET_SEL type USMD_TS_SEL
      !EV_ENTITY type USMD_ENTITY .
  methods HANDLE_ENTITY_FOR_EDIT_REG .
  methods HANDLE_HIGHLIGHT_CHANGES
    importing
      !IT_SELECTED_FIELDS type FPMGB_T_SELECTED_FIELDS
      !IO_EXTENDED_CONTROL type ref to IF_FPM_LIST_ATS_EXT_CTRL optional
    changing
      !CT_DATA type DATA
      !CV_DATA_CHANGED type ABAP_BOOL
      !CT_FIELD_USAGE type FPMGB_T_FIELDUSAGE
      !CV_FIELD_USAGE_CHANGED type ABAP_BOOL .
  methods HANDLE_SELECTION_DIALOG
    importing
      !IV_DIALOG_ID type FPM_DIALOG_WINDOW_ID
    exporting
      !ET_LIST_OF_FIXINGS type TY_T_LIST_OF_FIXINGS .
  methods ON_BOL_COPY
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
  methods ON_CREATE_ROOT
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
  methods ON_CR_REFRESH
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IV_LEAD_INDEX type SYTABIX
      !IV_EVENT_INDEX type SYTABIX
      !IT_SELECTED_LINES type RSTABIXTAB
      !IV_RAISED_BY_OWN_UI type BOOLE_D optional
      !IO_UI_INFO type ref to IF_FPM_LIST_ATS_UI_INFO optional
    exporting
      !EV_RESULT type FPM_EVENT_RESULT
      !ET_MESSAGES type FPMGB_T_MESSAGES .
  methods ON_DISCARD_DELETION
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
  methods ON_SHOW
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IV_LEAD_INDEX type SYTABIX
      !IV_EVENT_INDEX type SYTABIX
      !IT_SELECTED_LINES type RSTABIXTAB
      !IV_RAISED_BY_OWN_UI type BOOLE_D optional
      !IO_UI_INFO type ref to IF_FPM_LIST_ATS_UI_INFO optional
    exporting
      !EV_RESULT type FPM_EVENT_RESULT
      !ET_MESSAGES type FPMGB_T_MESSAGES .
  methods ON_SHOW_SOVP
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IV_LEAD_INDEX type SYTABIX
      !IV_EVENT_INDEX type SYTABIX
      !IT_SELECTED_LINES type RSTABIXTAB
      !IV_RAISED_BY_OWN_UI type BOOLE_D optional
      !IO_UI_INFO type ref to IF_FPM_LIST_ATS_UI_INFO optional
    exporting
      !EV_RESULT type FPM_EVENT_RESULT
      !ET_MESSAGES type FPMGB_T_MESSAGES .
  methods OPEN_SELECTION_DIALOG
    importing
      !IV_DIALOG_ID type FPM_DIALOG_WINDOW_ID .
  methods OVS_OUTPUT_FILTER
    importing
      !IV_FIELD_NAME type NAME_KOMP
      !IR_QUERY_PARAMETER type ref to DATA
      !IO_ACCESS type ref to IF_BOL_BO_PROPERTY_ACCESS optional
      !IV_FIELD_NAME_KEY type NAME_KOMP default SPACE
    changing
      !CR_OUTPUT type ref to DATA .
  methods OVS_OUTPUT_FILTER_ALPHA
    importing
      !IV_FIELD_NAME type NAME_KOMP
      !IV_QUERY_COMPONENT type NAME_KOMP
    returning
      value(RV_ALPHA) type I .
  methods SET_CHANGE_INDICATOR
    importing
      !IO_ENTITY type ref to CL_CRM_BOL_ENTITY
      !IV_IS_NEW_ENTITY type ABAP_BOOL
      !IS_CHANGED_OBJECT type USMD_S_CHANGED_OBJECT
    changing
      !CS_DATA type DATA
      !CV_DATA_CHANGED type ABAP_BOOL .
  methods SET_DEFAULT_TOOLTIP
    importing
      !IT_FIELD_USAGE type FPMGB_T_FIELDUSAGE
      !IO_EXTENDED_CTRL type ref to IF_FPM_LIST_ATS_EXT_CTRL optional
    changing
      !CT_DATA type INDEX TABLE
      !CV_DATA_CHANGED type ABAP_BOOL .
  methods SET_HC_CONFIGURED_FIELDS
    importing
      !IT_FIELD_USAGE type FPMGB_T_FIELDUSAGE
      !IT_CHANGED_FIELD type USMD_TS_CHANGED_FIELDS_HC
      !IT_DELETED_FIELD type USMD_TS_CHANGED_FIELDS_HC
      !IT_CHANGED_OBJECTS type USMD_T_CHANGED_OBJECT
      !IT_SELECTED_FIELDS type FPMGB_T_SELECTED_FIELDS
      !IV_IS_NEW_ENTITY type ABAP_BOOL
    changing
      !CS_DATA type ANY .
  methods SET_UIBB_EXPLANATION
    importing
      !IV_EXPLANATION type FPM_EXPLANATION
      !IS_INSTANCE_KEY type FPM_S_UIBB_INSTANCE_KEY .
  methods SET_UIBB_EXPLANATION_DOC
    importing
      !IV_DOCUMENT type FPM_EXPLANATION_DOCUMENT
      !IS_INSTANCE_KEY type FPM_S_UIBB_INSTANCE_KEY .

  methods ADD_STANDARD_ROW_ACTIONS
    redefinition .
  methods CHECK_ACTION_USAGE
    redefinition .
  methods CHECK_ACTION_USAGE_SINGLE
    redefinition .
  methods CLAIM_GENIL_MESSAGES
    redefinition .
  methods CREATE
    redefinition .
  methods CREATE_ENTITY
    redefinition .
  methods CREATE_STRUCT_RTTI
    redefinition .
  methods DELETE_ENTITY
    redefinition .
  methods EVALUATE_PARAMETERS
    redefinition .
  methods FPM_BOL_HANDLE_MASS_EDIT_MODE
    redefinition .
  methods GET_ACTIONS
    redefinition .
  methods GET_ATTR_VALUE_SET
    redefinition .
  methods GET_ENTITY_DATA
    redefinition .
  methods GET_FIELD_UI_PROP
    redefinition .
  methods GET_GENIL_MESSAGES
    redefinition .
  methods GET_INITIAL_DATA
    redefinition .
  methods GET_MESSAGES
    redefinition .
  methods IS_PAGING_ACTIVE
    redefinition .
  methods IS_ROW_ACTION_ENABLED
    redefinition .
  methods IS_ROW_ACTION_VISIBLE
    redefinition .
  methods LOCK
    redefinition .
  methods LOCK_FOR_EDIT
    redefinition .
  methods MODIFY_CNR_BUTTON
    redefinition .
  methods SET_ACCESS_ATTRIBUTE
    redefinition .
  methods SET_COLLECTION
    redefinition .
  methods TAP_CONNECTOR
    redefinition .
private section.
   types:
    BEGIN OF S_CUSTOM_FIELDS,
      l_date       TYPE DATS,
    END OF S_CUSTOM_FIELDS .
  data MO_MDG_API type ref to IF_USMD_CONV_SOM_GOV_API .
  data MO_STRUCT_RTTI_CLEAR type ref to CL_ABAP_STRUCTDESCR .
ENDCLASS.



CLASS ZCL_MDG_BS_GUIBB_LISTWANG IMPLEMENTATION.


  METHOD IF_BS_BOL_HOW_FEEDER~SET_ACCESS_ATTRIBUTE.
    DATA ls_delayed_change LIKE LINE OF me->mt_delayed_changes.

    me->set_access_attribute( io_access = io_access  iv_attr_name = iv_attr_name  iv_value = iv_value ).
    rv_gain_momentum = boolc( me->mv_unchangeable_keys IS NOT INITIAL AND contains( val = me->mv_unchangeable_keys  sub = iv_attr_name ) ).
    CHECK io_access IS NOT BOUND.
    ls_delayed_change-name = iv_attr_name.
    ls_delayed_change-value = iv_value.
    APPEND ls_delayed_change TO me->mt_delayed_changes.
  ENDMETHOD.


METHOD IF_FPM_GUIBB_LIST_PAGING~FLUSH.
  super->if_fpm_guibb_list_paging~flush(
    it_change_log   = it_change_log
    iv_new_lead_sel = iv_new_lead_sel
    iv_old_lead_sel = iv_old_lead_sel
  ).
  IF it_change_log IS NOT INITIAL.
    me->mv_refresh_data = abap_true.
  ENDIF.
ENDMETHOD.


METHOD IF_FPM_GUIBB_LIST_PAGING~GET_DATA.
*! GET_DATA for paging.
*
*  Disable the highlight deletions functionality for the current genIL object.
  IF iv_eventid->mv_event_id = if_fpm_constants=>gc_event-leave_initial_screen
  OR iv_eventid->mv_event_id = if_fpm_constants=>gc_event-done_and_back_to_main
  OR iv_eventid->mv_event_id = if_fpm_constants=>gc_event-call_default_edit_page
  OR iv_eventid->mv_event_id = if_fpm_constants=>gc_event-call_suboverview_page.
    me->mv_refresh_data = abap_true.
  ENDIF.

  IF iv_eventid->mv_event_id = if_fpm_constants=>gc_event-leave_initial_screen
    OR iv_eventid->mv_event_id = if_fpm_constants=>gc_event-start.
    me->disable_highlight_deletions( ).
  ENDIF.

  super->if_fpm_guibb_list_paging~get_data(
    EXPORTING
      iv_eventid                = iv_eventid
      it_selected_fields        = it_selected_fields
      iv_raised_by_own_ui       = iv_raised_by_own_ui
      iv_visible_rows           = iv_visible_rows
      iv_edit_mode              = iv_edit_mode
    IMPORTING
      et_messages               = et_messages
      ev_data_changed           = ev_data_changed
      ev_field_usage_changed    = ev_field_usage_changed
      ev_action_usage_changed   = ev_action_usage_changed
      ev_selected_lines_changed = ev_selected_lines_changed
      ev_dnd_attr_changed       = ev_dnd_attr_changed
    CHANGING
      ct_field_usage            = ct_field_usage
      ct_action_usage           = ct_action_usage
      ct_selected_lines         = ct_selected_lines
      cv_lead_index             = cv_lead_index
      ct_dnd_attributes         = ct_dnd_attributes
  ).
ENDMETHOD.


METHOD IF_FPM_GUIBB_LIST_PAGING~PROCESS_EVENT.
  CASE io_event->mv_event_id.
    WHEN cl_usmd_cr_guibb_general_data=>cv_action_refresh.
      me->on_cr_refresh(
        EXPORTING
          io_event            = io_event
          iv_lead_index       = iv_lead_index
          iv_event_index      = iv_event_index
          it_selected_lines   = it_selected_lines
          iv_raised_by_own_ui = iv_raised_by_own_ui
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages
      ).

    WHEN if_usmd_generic_bolui_const=>gc_action_create_root.
      me->on_create_root(
        EXPORTING
          io_event            = io_event
          iv_raised_by_own_ui = iv_raised_by_own_ui
          iv_lead_index       = iv_lead_index
          iv_event_index      = iv_event_index
          it_selected_lines   = it_selected_lines
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages
      ).

    WHEN cv_event_id_show.
      me->on_show(
        EXPORTING
          io_event            = io_event
          iv_lead_index       = iv_lead_index
          iv_event_index      = iv_event_index
          it_selected_lines   = it_selected_lines
          iv_raised_by_own_ui = iv_raised_by_own_ui
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages
      ).

    WHEN OTHERS.
      super->if_fpm_guibb_list_paging~process_event(
        EXPORTING
          io_event            = io_event
          iv_lead_index       = iv_lead_index
          iv_event_index      = iv_event_index
          it_selected_lines   = it_selected_lines
          iv_raised_by_own_ui = iv_raised_by_own_ui
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages
      ).

  ENDCASE.
  IF iv_raised_by_own_ui = abap_true AND io_event->mv_is_implicit_edit = abap_true.
    me->mv_refresh_data = abap_true.
  ENDIF.
ENDMETHOD.


METHOD IF_FPM_GUIBB_LIST~CHECK_CONFIG.
  super->if_fpm_guibb_list~check_config(
    EXPORTING io_layout_config = io_layout_config
    IMPORTING et_messages = et_messages
  ).
  me->mo_morph_config_supervisor->validate_configuration(
    EXPORTING io_list_config = io_layout_config
    IMPORTING et_messages = et_messages
  ).
ENDMETHOD.


METHOD IF_FPM_GUIBB_LIST~FLUSH.
  super->if_fpm_guibb_list~flush(
    it_change_log   = it_change_log
    it_data         = it_data
    iv_old_lead_sel = iv_old_lead_sel
    iv_new_lead_sel = iv_new_lead_sel
  ).
  IF it_change_log IS NOT INITIAL.
    me->mv_refresh_data = abap_true.
  ENDIF.
ENDMETHOD.


METHOD IF_FPM_GUIBB_LIST~GET_DATA.
  DATA lv_dialog_id TYPE fpm_dialog_window_id.
  DATA lv_button_key TYPE string.
  DATA lt_list_of_fixings TYPE ty_t_list_of_fixings.

  DATA lr_clear TYPE REF TO data.                           "2952747
  FIELD-SYMBOLS <fs_transient>   TYPE any.
  FIELD-SYMBOLS <fs_data_tab>    TYPE ANY TABLE.
  FIELD-SYMBOLS <fs_data_struct> TYPE any.

  me->determine_pbo_status( ).

  IF iv_eventid->mv_event_id = 'CHG_CRUIBB_VISIBILITY' OR   "2934986
     iv_eventid->mv_event_id = 'USMD_FILTER_CR_TYPES1' OR
     iv_eventid->mv_event_id = 'DONOTHING'             OR
     iv_eventid->mv_event_id = 'AFTER_BOL_MODIFY'      OR
     iv_eventid->mv_event_id = 'ATT_FILE_ADD'          OR   "2996094
     iv_eventid->mv_event_id = 'CR_ATT_FILE_ADD'       OR
     iv_eventid->mv_event_id = 'CR_ATT_FILE_CREATE'    OR
    ( iv_eventid->mv_event_id = cl_fpm_event=>gc_event_local_edit AND iv_raised_by_own_ui = abap_false ) OR
    ( iv_eventid->mv_event_id = 'FPM_LIST_SELECTION_UPDATE' AND iv_raised_by_own_ui = abap_false ).
    RETURN.
  ENDIF.

  IF cl_usmd5_cust_access_service=>is_cr_action( |{ iv_eventid->mv_event_id }| ) IS NOT INITIAL OR
   iv_eventid->mv_event_id = 'CR_SUBMIT' OR
   iv_eventid->mv_event_id = 'FPM_SAVE' .
* These actions raise a CR_CHECK event. If this is the case we will only perform the GET_DATA
* during CR_CHECK
    cl_fpm_factory=>get_instance( )->read_event_queue(
     IMPORTING et_event_queue = DATA(lt_event_queue) ) .

    READ TABLE lt_event_queue TRANSPORTING NO FIELDS WITH KEY id = 'CR_CHECK'.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.
  ENDIF.

  IF iv_eventid->mv_event_id = if_fpm_constants=>gc_event-close_dialog.
    iv_eventid->mo_event_data->get_value( EXPORTING iv_key = if_fpm_constants=>gc_dialog_box-dialog_buton_key  IMPORTING ev_value = lv_button_key ).
    IF lv_button_key = 'OK'.
      iv_eventid->mo_event_data->get_value( EXPORTING iv_key = if_fpm_constants=>gc_dialog_box-id  IMPORTING ev_value = lv_dialog_id ).
      IF lv_dialog_id = me->mv_dialog_id.
        me->handle_selection_dialog( EXPORTING iv_dialog_id = lv_dialog_id  IMPORTING et_list_of_fixings = lt_list_of_fixings ).
        IF lt_list_of_fixings IS NOT INITIAL AND me->mo_cloning_event IS BOUND.
          me->mo_cloning_event->mo_event_data->set_value( iv_key = 'LIST_OF_FIXINGS'  iv_value = lt_list_of_fixings ).
          me->get_fpm_instance( )->raise_event( me->mo_cloning_event ).
        ENDIF.
        CLEAR: me->mo_cloning_event, me->mv_dialog_id.
        RETURN.
      ENDIF.

      IF lv_dialog_id = 'USMD_ENTITY_ATT_FILE'.              "  2996094
        IF not ms_object_key-object_name CS 'Atth'.
          RETURN. "Only the attachment list needs to be read after attachment upload
        ENDIF.
      ENDIF.

      IF lv_dialog_id = 'USMD_CR_ATT_FILE'.
        RETURN.
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

  "HC_DEL: Set Indicator also for Sub-Classes
  IF mo_highlight_changes IS BOUND AND mo_mdg_api IS BOUND AND mv_disable_hc NE abap_true AND
     me->mo_highlight_changes->is_highlight_deletion_active( iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                                                             iv_crequest_step = me->mo_mdg_api->mv_wf_step ) = abap_true.
    mv_highlight_del_active = abap_true.
  ELSE.
    mv_highlight_del_active = abap_false.
    IF mv_disable_hc EQ abap_true "already disabled during INITIALIZE
      AND ( iv_eventid->mv_event_id EQ if_fpm_constants=>gc_event-leave_initial_screen OR
            iv_eventid->mv_event_id EQ if_fpm_constants=>gc_event-start ).
      "ensure that no deleted data is read
      me->disable_highlight_deletions( ).
    ENDIF.
  ENDIF.

* Fields named COLxxx or TLTxxx will be added after the super call. Inside this call FPM compares the
* previous ct_data with the data newly read by conv-api. The data are never identical because of the
* priviously mentioned transient fields. Consequently ev_data_changed is always true. To prevent this, we clear
* these fields before the super call. The comparison takes place in CL_GUIBB_BOL_LIST GET_COLLECTION_DATA_ATS

  IF ct_data IS NOT INITIAL.
    CREATE DATA lr_clear TYPE HANDLE mo_struct_rtti_clear . "2952747
    ASSIGN lr_clear->* TO <fs_transient>.
    ASSIGN ct_data TO <fs_data_tab>.
    LOOP AT <fs_data_tab> ASSIGNING <fs_data_struct>.
      MOVE-CORRESPONDING <fs_transient> TO <fs_data_struct>.
    ENDLOOP.
  ENDIF.

  super->if_fpm_guibb_list~get_data(
    EXPORTING
      iv_eventid                = iv_eventid
      it_selected_fields        = it_selected_fields
      iv_raised_by_own_ui       = iv_raised_by_own_ui
      iv_visible_rows           = iv_visible_rows
      iv_edit_mode              = iv_edit_mode
      io_extended_ctrl          = io_extended_ctrl
    IMPORTING
      et_messages               = et_messages
      ev_data_changed           = ev_data_changed
      ev_field_usage_changed    = ev_field_usage_changed
      ev_action_usage_changed   = ev_action_usage_changed
      ev_selected_lines_changed = ev_selected_lines_changed
      ev_dnd_attr_changed       = ev_dnd_attr_changed
      eo_itab_change_log        = eo_itab_change_log
    CHANGING
      ct_data                   = ct_data
      ct_field_usage            = ct_field_usage
      ct_action_usage           = ct_action_usage
      ct_selected_lines         = ct_selected_lines
      cv_lead_index             = cv_lead_index
      cv_first_visible_row      = cv_first_visible_row
      cs_additional_info        = cs_additional_info
      ct_dnd_attributes         = ct_dnd_attributes
  ).


  me->set_default_tooltip(
    EXPORTING it_field_usage = ct_field_usage
              io_extended_ctrl = io_extended_ctrl
    CHANGING ct_data = ct_data
             cv_data_changed = ev_data_changed
  ).

  IF  iv_eventid->mv_event_id = 'FPM_GUIBB_LIST_CELL_ACTION'
  AND iv_raised_by_own_ui     = abap_true
  AND me->mv_fpm_edit_mode    = if_fpm_constants=>gc_edit_mode-edit.
    "Avoid runtime errors when a new initial line triggers an event,
    "therefore set the data changed indicator
    ev_data_changed = abap_true.
  ENDIF.
  me->handle_highlight_changes(
    EXPORTING it_selected_fields  = it_selected_fields
              io_extended_control = io_extended_ctrl
    CHANGING ct_data = ct_data
             cv_data_changed = ev_data_changed
             ct_field_usage = ct_field_usage
             cv_field_usage_changed = ev_field_usage_changed
  ).

  me->mv_pbo = gc_pbo-none.



ENDMETHOD.


METHOD IF_FPM_GUIBB_LIST~GET_DEFAULT_CONFIG.
  DATA lt_actiondef TYPE fpmgb_t_actiondef.
  DATA lv_index LIKE sy-tabix.

  FIELD-SYMBOLS <ls_actiondef> TYPE fpmgb_s_actiondef.

  "Check for issue during the initialize phase. If there are any, prevent further processing.
  IF me->ms_init_error IS NOT INITIAL.
    RETURN.
  ENDIF.

* Prevent Backend Actions from Default-UI-Config
  LOOP AT mt_actiondef ASSIGNING <ls_actiondef>
                                   WHERE text = cl_mdg_bs_genil=>gc_method_name-handle_check_results
                                   OR    text = cl_mdg_bs_genil=>gc_method_name-check
                                   OR    text = cl_mdg_bs_genil=>gc_method_name-process_main_entity_del
                                   OR    text = cl_mdg_bs_genil=>gc_method_name-get_changes.
    lv_index = sy-tabix.
    APPEND <ls_actiondef> TO lt_actiondef.
    DELETE mt_actiondef INDEX lv_index."FROM <ls_actiondef>.
  ENDLOOP.

  "inherit
  super->if_fpm_guibb_list~get_default_config(
      io_layout_config = io_layout_config ).

  APPEND LINES OF lt_actiondef TO mt_actiondef.
ENDMETHOD.


METHOD IF_FPM_GUIBB_LIST~GET_DEFINITION.

  DATA:
    lv_header_label    TYPE string,
    lv_obj_name        TYPE crmt_ext_obj_name,
    lv_attr_name       TYPE name_komp,
    ls_join_attr       TYPE me->s_join_attr,
    ls_join            TYPE me->s_join,
    lo_struct_descr    TYPE REF TO cl_abap_structdescr,
    lo_elem_descr      TYPE REF TO cl_abap_elemdescr,
   lt_component       TYPE abap_component_tab,
    lt_component_clear TYPE abap_component_tab, "Fields that must be cleared in GET_DATA
    ls_component       TYPE abap_componentdescr,
    lv_string          TYPE string,
    lo_elem_descr_tlt  TYPE REF TO cl_abap_elemdescr.

  FIELD-SYMBOLS:
    <ls_field_description> TYPE fpmgb_s_listfield_descr.

  "Check for issue during the initialize phase. If there are any, report
  "them and prevent further processing.
  IF me->ms_init_error IS NOT INITIAL.
    es_message = me->ms_init_error.
    RETURN.
  ENDIF.

  "inherit
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

  lo_elem_descr   ?= cl_abap_elemdescr=>describe_by_name( 'wdui_table_cell_design' ) ##no_text.
  lo_struct_descr ?= eo_field_catalog->get_table_line_type( ).
  lt_component     = lo_struct_descr->get_components( ).
  lo_elem_descr_tlt ?= cl_abap_elemdescr=>describe_by_data( lv_string ).

  LOOP AT et_field_description ASSIGNING <ls_field_description> WHERE technical_field EQ abap_false.
    "in design time hidden (invisible) fields must not be added to the field catalog
    IF me->is_design_time( ) EQ abap_true
      AND <ls_field_description>-visibility EQ if_fpm_constants=>gc_visibility-not_visible.
      <ls_field_description>-technical_field = abap_true.
    ENDIF.

    IF is_paging_active( ) = abap_true.
      CLEAR <ls_field_description>-allow_sort.
    ENDIF.

    IF me->is_design_time( ) = abap_false.
      "For UI-Attributes configured via JOINED Entities get the correct field & object name
      READ TABLE me->mt_join_attr INTO ls_join_attr WITH KEY name = <ls_field_description>-name.
      IF sy-subrc = 0.
        READ TABLE me->mt_join INTO ls_join WITH KEY id = ls_join_attr-join_id.
        IF sy-subrc = 0.
          lv_attr_name = ls_join_attr-bol_attr_name.
          lv_obj_name = ls_join-object_name.
        ENDIF.
      ELSE.
        lv_attr_name = <ls_field_description>-name.
        lv_obj_name  = me->ms_object_key-object_name.
      ENDIF.

      "add fixed values
      IF lv_attr_name IS NOT INITIAL AND lv_obj_name IS NOT INITIAL.
        me->get_attr_value_set(
          EXPORTING
            iv_object_name = lv_obj_name
            iv_attr_name   = lv_attr_name
          IMPORTING
            et_value_set   = <ls_field_description>-fixed_values ).
      ENDIF.
    ENDIF.

* The change indicator field should always be available in the field catalog (because of delivered configurations)
* It should not be visible if the Framework Switch is switched off
    IF <ls_field_description>-name = if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator.
      <ls_field_description>-enumeration = me->mo_highlight_changes->get_sort_text_change_indicator( ).
      <ls_field_description>-header_label = 'Changes'(011).
      <ls_field_description>-default_display_type = if_fpm_guibb_constants=>gc_display_type-image.
      IF cl_usmd_switch_check=>mdg_application_framework_5( ) = abap_false.
        <ls_field_description>-visibility = if_fpm_constants=>gc_visibility-not_visible.
      ENDIF.
    ENDIF.


* Add COLOR and TOOLTIP fields for Highlight Changes
    IF me->is_design_time( ) = abap_false AND mv_disable_hc = abap_false
      AND <ls_field_description>-visibility <> if_fpm_constants=>gc_visibility-not_visible.

      IF cl_usmd_switch_check=>gv_framework_switch5 = abap_true.
        <ls_field_description>-cell_design_ref = me->mo_highlight_changes->add_col_prefix( <ls_field_description>-name ).
        ls_component-name = <ls_field_description>-cell_design_ref.
        ls_component-type = lo_elem_descr.
        INSERT ls_component INTO TABLE lt_component.
        INSERT ls_component INTO TABLE lt_component_clear.
      ENDIF.
      <ls_field_description>-tooltip_ref = me->mo_highlight_changes->add_tlt_prefix( <ls_field_description>-name ).
      ls_component-name = <ls_field_description>-tooltip_ref.
      ls_component-type = lo_elem_descr_tlt.
      INSERT ls_component INTO TABLE lt_component.
      INSERT ls_component INTO TABLE lt_component_clear.
    ENDIF.


    "Some of the fields might be dynamically generated text attributes (like
    "'USMD_EDITION__TXT') that are not based on specific data elements. That is,
    "a label text has to be assigned explicitly.
    IF me->mo_text_assist IS BOUND AND
       <ls_field_description>-header_label IS INITIAL.
      CHECK me->mo_text_assist->is_text_attribute(
              iv_attr_structure = me->mv_struct_name
              iv_text_attribute = <ls_field_description>-name ) = abap_true.
      lv_header_label = me->mo_text_assist->get_label_4_text_attribute(
                          iv_attr_structure = me->mv_struct_name
                          iv_text_attribute = <ls_field_description>-name ).
      IF lv_header_label IS NOT INITIAL.
        <ls_field_description>-header_label = lv_header_label.
        <ls_field_description>-header_label_by_ddic = abap_false.
      ENDIF.
    ENDIF.

  ENDLOOP.

  lo_struct_descr  = cl_abap_structdescr=>create( lt_component ).
  eo_field_catalog  = cl_abap_tabledescr=>create( lo_struct_descr ).

  "Assign search helps
  me->assign_search_helps( CHANGING ct_field_description = et_field_description ).

  lo_elem_descr   ?= cl_abap_elemdescr=>describe_by_name( 'USMD_LIST_CHANGE_INDICATOR' ) .
  ls_component-name = if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator.
  ls_component-type = lo_elem_descr.
  INSERT ls_component INTO TABLE lt_component_clear.

  mo_struct_rtti_clear = cl_abap_structdescr=>get( p_components = lt_component_clear ).

  "custom
*  lo_table_descr ?= cl_abap_tabledescr=>describe_by_name(
*              'H99_CLST_T_RGDIR' ).
*  lo_struc_descr ?= lo_table_descr->get_table_line_type( ).
*  lt_component_tab = lo_struc_descr->get_components( ).
*  ls_component_wa-name = 'NAME'.
*  ls_component_wa-type ?= cl_abap_datadescr=>describe_by_name( 'P0002-NACHN' ).
*  ls_component_wa-as_include = abap_false.
*  APPEND ls_component_wa TO lt_component_tab.
*  ls_component_wa-name = 'BETRG'.
*  ls_component_wa-type ?= cl_abap_datadescr=>describe_by_name( 'MAXBT').
*  ls_component_wa-as_include = abap_false.
*  APPEND ls_component_wa TO lt_component_tab.
*  CLEAR: lo_struc_descr.
*  FIELD-SYMBOLS <ls_new_field_descr> type FPMGB_S_LISTFIELD_DESCR.
*  APPEND INITIAL LINE TO ET_FIELD_DESCRIPTION ASSIGNING <ls_new_field_descr>.

  ls_component-name = 'ZDATE'.
  ls_component-type ?= cl_abap_datadescr=>describe_by_name( 'ZZDATEC' ).
  INSERT ls_component INTO TABLE lt_component.

  lo_struct_descr  = cl_abap_structdescr=>create( lt_component ).
  eo_field_catalog  = cl_abap_tabledescr=>create( lo_struct_descr ).

  loop at et_row_actions ASSIGNING FIELD-SYMBOL(<ls_actions>).
    If <ls_actions>-ID = 'FPM_BOL_ROW_DELETE'.
      <ls_actions>-ENABLED_REF = ''.
      <ls_actions>-VISIBLE_REF = ''.
    ELSEIF <ls_actions>-ID = 'DISCARD_DELETE'.
       <ls_actions>-ENABLED_REF = ''.
      <ls_actions>-VISIBLE_REF = ''.
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD IF_FPM_GUIBB_LIST~PROCESS_EVENT.
  DATA lo_fpm TYPE REF TO cl_fpm.
  DATA lo_entity TYPE REF TO cl_crm_bol_entity.
  DATA lt_marked_indices TYPE crmt_bol_index_tab.
  DATA lv_lead_index LIKE iv_lead_index.
  DATA lv_event_index LIKE iv_event_index.

  lv_lead_index = iv_lead_index.
  lv_event_index = iv_event_index.
  lo_fpm ?= me->get_fpm_instance( ).

* The super call is responsible for setting MT_ENTITY_SEL in CL_GUIBB_BOL_COLLECTION->SET_SELECTION
* FPM_LIST_UIBB triggers a roundtrip when changing the selection. FPM_LIST_UIBB_ATS doesn't do that and
* we have to make sure that the selected entity is known when we handle the event.

        super->if_fpm_guibb_list~process_event(
        EXPORTING
          io_event            = io_event
          iv_lead_index       = lv_lead_index
          iv_event_index      = lv_event_index
          it_selected_lines   = it_selected_lines
          iv_raised_by_own_ui = iv_raised_by_own_ui
          io_ui_info          = io_ui_info
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages
      ).
      IF me->mt_fpm_messages IS NOT INITIAL AND io_event IS BOUND AND io_event->mv_event_id = cl_guibb_bol_collection=>cv_event_id_row_delete.
        " Special handling for event BOL_ROW_DELETE as by this event the number of lines will be redruced as well as the sorting of the lines might be affected
        " --> stored messages including message mapping are invalidated --> enforce rebuilding the message list
        CLEAR me->mt_fpm_messages.
      ENDIF.

  IF iv_raised_by_own_ui = abap_true.
    IF io_event->mv_event_id = if_fpm_constants=>gc_event-call_default_edit_page
    OR io_event->mv_event_id = cl_mdg_bs_communicator_assist=>gc_event-bol_copy.
      io_event->mo_event_data->get_value(
      EXPORTING iv_key = 'ENTITY_SELECTED'
      IMPORTING ev_value = lo_entity
* BOL_COPY never runs into this branch. The only thing method on_bol_copy needs
* is MT_ENTITY_SEL
    ).
      IF lo_entity IS BOUND AND lo_entity <> me->mo_entity.
        me->mo_entity = me->mo_collection->find( iv_entity = lo_entity ).
        IF me->mo_entity IS BOUND.
          CLEAR me->mt_entity_sel.
          APPEND me->mo_entity TO me->mt_entity_sel.
          me->mo_collection->if_bol_bo_col_multi_sel~unmark_all( ).
          me->mo_collection->if_bol_bo_col_multi_sel~mark( iv_bo = me->mo_entity ).
          lt_marked_indices = me->mo_collection->if_bol_bo_col_multi_sel~get_marked_indices( ).
          READ TABLE lt_marked_indices INDEX 1 INTO lv_lead_index.
          lv_event_index = lv_lead_index.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  CASE io_event->mv_event_id.
    WHEN cl_mdg_bs_communicator_assist=>gc_event-filter_cr_types1.
      "This Event is e.g. fired before a CR-Type PopUp is opened

      "Check if specific entity have to be registered for processing
      me->handle_entity_for_edit_reg( ).

    WHEN cl_usmd_cr_guibb_general_data=>cv_action_refresh.
      me->on_cr_refresh(
        EXPORTING
          io_event            = io_event
          iv_lead_index       = iv_lead_index
          iv_event_index      = iv_event_index
          it_selected_lines   = it_selected_lines
          iv_raised_by_own_ui = iv_raised_by_own_ui
          io_ui_info          = io_ui_info
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages
      ).

    WHEN if_usmd_generic_bolui_const=>gc_action_create_root.
      me->on_create_root(
        EXPORTING
          io_event            = io_event
          iv_raised_by_own_ui = iv_raised_by_own_ui
          iv_lead_index       = iv_lead_index
          iv_event_index      = iv_event_index
          it_selected_lines   = it_selected_lines
          io_ui_info          = io_ui_info
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages
      ).

    WHEN cv_event_id_show.
      me->on_show(
        EXPORTING
          io_event            = io_event
          iv_lead_index       = iv_lead_index
          iv_event_index      = iv_event_index
          it_selected_lines   = it_selected_lines
          iv_raised_by_own_ui = iv_raised_by_own_ui
          io_ui_info          = io_ui_info
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages
      ).

    WHEN cv_event_id_show_sovp.
      me->on_show_sovp(
        EXPORTING
          io_event            = io_event
          iv_lead_index       = iv_lead_index
          iv_event_index      = iv_event_index
          it_selected_lines   = it_selected_lines
          iv_raised_by_own_ui = iv_raised_by_own_ui
          io_ui_info          = io_ui_info
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages
      ).

    WHEN cl_mdg_bs_communicator_assist=>gc_event-bol_copy.
      me->on_bol_copy(
        EXPORTING io_event = io_event
                  iv_raised_by_own_ui = iv_raised_by_own_ui
                  iv_lead_index = iv_lead_index
                  iv_event_index = iv_event_index
                  it_selected_lines = it_selected_lines
                  io_ui_info = io_ui_info
        IMPORTING ev_result = ev_result
                  et_messages = et_messages
      ).

    WHEN if_usmd_generic_bolui_const=>gc_action_discard_delete.
      on_discard_deletion(
        EXPORTING
          io_event            = io_event    " CL_FPM_EVENT
          iv_raised_by_own_ui = iv_raised_by_own_ui    " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
          iv_lead_index       = iv_lead_index    " Index of Internal Tables
          iv_event_index      = iv_event_index    " Index of Internal Tables
          it_selected_lines   = it_selected_lines    " Repository Infosystem Table for Indexes
          io_ui_info          = io_ui_info    " facade to get UI-related information from ATS List UIBB
        IMPORTING
          ev_result           = ev_result    " FPM Event Result
          et_messages         = et_messages    " FPMGB Messages (T100 & Plaintext)
      ).
  ENDCASE.
  IF iv_raised_by_own_ui = abap_true AND io_event->mv_is_implicit_edit = abap_true.
    me->mv_refresh_data = abap_true.
  ENDIF.
  IF iv_raised_by_own_ui = abap_true.
    IF io_event->mv_event_id = cv_event_id_show
    OR io_event->mv_event_id = if_fpm_constants=>gc_event-call_default_edit_page
    OR io_event->mv_event_id = me->mv_action_create
    OR io_event->mv_event_id = 'FPM_BOL_TABLE_INSERT'.
      IF me->mo_entity IS NOT BOUND AND me->mo_collection IS BOUND.
        IF lv_event_index > 0.
          me->mo_entity = me->mo_collection->get_iterator( )->get_by_index( lv_event_index ).
        ELSE.
          me->mo_entity = me->mo_collection->get_current( ).
        ENDIF.
      ENDIF.
      CHECK me->mo_entity IS BOUND.
      io_event->mo_event_data->set_value( iv_key = 'ENTITY_SELECTED'  iv_value = me->mo_entity ).
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD IF_FPM_GUIBB~GET_PARAMETER_LIST.
  FIELD-SYMBOLS:
    <ls_parameter_description> LIKE LINE OF rt_parameter_descr.



  rt_parameter_descr = super->if_fpm_guibb~get_parameter_list( ).
  me->mo_morph_config_supervisor->enhance_parameter_list( CHANGING ct_parameters = rt_parameter_descr ).
  APPEND INITIAL LINE TO rt_parameter_descr ASSIGNING <ls_parameter_description>.
  <ls_parameter_description>-name = cl_mdg_bs_guibb_form=>gc_parameter-read_mode_per_action.
  <ls_parameter_description>-type = cl_mdg_bs_guibb_form=>gc_parameter_type-read_mode_per_action.
  <ls_parameter_description>-render_plug_in = abap_true.
  APPEND INITIAL LINE TO rt_parameter_descr ASSIGNING <ls_parameter_description>.
  <ls_parameter_description>-name = cl_mdg_bs_guibb_form=>gc_parameter-event_exclusion_per_action.
  <ls_parameter_description>-type = cl_mdg_bs_guibb_form=>gc_parameter_type-event_exclusion_per_action.
  <ls_parameter_description>-render_plug_in = abap_true.
ENDMETHOD.


METHOD IF_FPM_GUIBB~INITIALIZE.
*! Initialize the feeder class.
  DATA:
    lv_stuff          TYPE do_stuff,
    lr_component_name TYPE REF TO crmt_component_name,
    lr_object_name    TYPE REF TO crmt_ext_obj_name,
    ls_parameter      LIKE LINE OF it_parameter,
    lv_model          TYPE usmd_model,
    lv_set            TYPE crmt_genil_appl.



  "determine the current component
  CREATE DATA lr_component_name.
  READ TABLE it_parameter INTO ls_parameter
    WITH KEY name = cv_param_component.
  IF sy-subrc = 0.
    lr_component_name ?= ls_parameter-value.
  ENDIF.

  "In design time, check that the needed DDIC structures exist. If
  "structures do not exist further processing of initialize is
  "prevented. The related error message is reported in GET_DEFINITION.
  CLEAR me->ms_init_error.
  IF me->is_design_time( ) EQ abap_true.
    "determine the current object
    CREATE DATA lr_object_name.
    READ TABLE it_parameter INTO ls_parameter
      WITH KEY name = cv_param_object.
    IF sy-subrc = 0.
      lr_object_name ?= ls_parameter-value.
    ENDIF.
    "determine related component set
    lv_set = cl_usmd_generic_bolui_assist=>get_default_genil_comp_set( iv_component = lr_component_name->* ).
    "determine current model
    cl_usmd_generic_bolui_assist=>get_application_parameter(
      EXPORTING it_parameter = it_parameter
      IMPORTING ev_model     = lv_model ).
    "check structures
    TRY.
        "query result objects do not have a key structure!
        IF find( val = lr_object_name->* sub = if_usmd_generic_genil_const=>gc_query_result ) EQ -1.
          IF cl_crm_genil_model_service=>get_runtime_model( iv_application = lv_set )->get_key_struct_name( lr_object_name->* ) IS INITIAL.
            MESSAGE e001(usmd_generic_bolui)
              WITH lr_object_name->* lr_component_name->* lv_model
              INTO me->ms_init_error-plaintext.
          ENDIF.
        ENDIF.
        IF cl_crm_genil_model_service=>get_runtime_model( iv_application = lv_set )->get_attr_struct_name( lr_object_name->* ) IS INITIAL.
          MESSAGE e002(usmd_generic_bolui)
            WITH lr_object_name->* lr_component_name->* lv_model
            INTO me->ms_init_error-plaintext.
        ENDIF.
        IF me->ms_init_error-plaintext IS NOT INITIAL.
          ms_init_error-msgid = sy-msgid.
          ms_init_error-msgno = sy-msgno.
          ms_init_error-severity = sy-msgty.
          ms_init_error-parameter_1 = sy-msgv1.
          ms_init_error-parameter_2 = sy-msgv2.
          ms_init_error-parameter_3 = sy-msgv3.
          ms_init_error-parameter_4 = sy-msgv4.
          RETURN.
        ENDIF.
      CATCH cx_crm_unsupported_object cx_crm_genil_general_error. "#EC NO_HANDLER
    ENDTRY.
  ENDIF.

  "get an instance of the convenience API
  TRY.
      me->mo_mdg_api = cl_usmd_generic_bolui_assist=>get_mdg_api( it_parameter ).
      IF me->mo_mdg_api IS BOUND.
        me->mo_text_assist = cl_usmd_generic_genil_text=>get_instance( iv_model = me->mo_mdg_api->mv_model_name ).
      ENDIF.
    CATCH cx_usmd_conv_som_gov_api.
  ENDTRY.

  super->if_fpm_guibb~initialize(
      it_parameter      = it_parameter
      io_app_parameter  = io_app_parameter
      iv_component_name = iv_component_name
      is_config_key     = is_config_key
      iv_instance_id    = iv_instance_id ).

  IF me->mo_how_to IS NOT BOUND.
    lv_stuff = me->ms_object_key-component_name && me->ms_object_key-object_name.
    IF lv_stuff IS NOT INITIAL.
      me->mo_how_to = cl_bs_do_guibb_bol=>get_instance( iv_stuff = lv_stuff  io_feeder = me ).
    ENDIF.
  ENDIF.

  "highlight changes
  IF mo_highlight_changes IS NOT BOUND.
    mo_highlight_changes = cl_usmd_highlight_changes_api=>get_instance( ).
  ENDIF.
  "... might be disabled by the user, or by paging
  IF ( me->mo_highlight_changes IS BOUND AND
       me->mo_highlight_changes->get_hc_status_by_usr_appl_para( ) = abap_false )
    OR ( me->is_paging_active( ) EQ abap_true ).
    mv_disable_hc = abap_true.
  ENDIF.

  me->mo_entity_cloner = cl_bs_bol_entity_cloner=>get_instance( me->ms_object_key-component_name ).

  CLEAR me->mt_attr2entity.

ENDMETHOD.


METHOD IS_PAGING_ACTIVE.
  rv_paging_active = abap_false.
ENDMETHOD.


METHOD IS_ROW_ACTION_ENABLED.
  DATA lo_parent TYPE REF TO cl_crm_bol_entity.

  rv_enabled = super->is_row_action_enabled(
    iv_event_id = iv_event_id
    io_entity = io_entity
  ).
  READ TABLE me->mt_excluded_events_per_action TRANSPORTING NO FIELDS
       WITH TABLE KEY logical_action = me->mv_action
                      event_id = iv_event_id.
  IF sy-subrc = 0.
    rv_enabled = abap_false.
    RETURN.
  ENDIF.
  IF me->mv_edit_mode = abap_false.
    IF iv_event_id = cv_event_id_row_delete
    OR iv_event_id = if_fpm_constants=>gc_event-call_default_edit_page.
      rv_enabled = abap_false.
      RETURN.
    ENDIF.
  ENDIF.
  CHECK me->mv_check_mutability = abap_true.
  IF ( iv_event_id = cv_event_id_row_delete AND io_entity->is_delete_allowed( ) = abap_false ).
    rv_enabled = abap_false.
  ELSEIF ( iv_event_id = if_fpm_constants=>gc_event-call_default_edit_page
           AND io_entity->is_change_allowed( ) = abap_false ).
    rv_enabled = abap_false.
  ELSE.
    rv_enabled = abap_true.
  ENDIF.

  "HC_DEL
  CASE iv_event_id.
    WHEN if_usmd_generic_bolui_const=>gc_action_discard_delete.
      IF mv_highlight_del_active = abap_true.
        TRY.
            io_entity->execute( iv_method_name = cl_mdg_bs_genil=>gc_method_name-is_discard_del_allowed ).
            rv_enabled = abap_true.

            "If entity deleted - only enable when Parent is not deleted
            TRY.
                lo_parent = io_entity->get_parent( ).
                IF lo_parent IS BOUND.
                  lo_parent->execute( iv_method_name = cl_mdg_bs_genil=>gc_method_name-is_entity_deleted ).
                  rv_enabled = abap_false.
                ENDIF.
              CATCH cx_crm_bol_meth_exec_failed.
                rv_enabled = abap_true.
            ENDTRY.
          CATCH cx_crm_bol_meth_exec_failed.
            rv_enabled = abap_false.
        ENDTRY.
      ELSE.
        rv_enabled = abap_false.
      ENDIF.
  ENDCASE.
ENDMETHOD.


METHOD IS_ROW_ACTION_VISIBLE.
  DATA:
    lo_collection LIKE me->mo_collection,
    lo_connector  TYPE REF TO cl_mdg_bs_connector_bol_rel,
    lo_entity     LIKE io_entity,
    lo_iterator   TYPE REF TO if_bol_entity_col_iterator,
    lv_Z0M0041    TYPE zzshgcd,
    lv_Z0BUKRS    TYPE bukrs,
    lv_Z0M0047Q   TYPE char10,
    lo_model      TYPE REF TO if_usmd_model_ext,
    ls_sel        TYPE usmd_s_sel,
    lt_sel        TYPE usmd_ts_sel,
    lv_structure  TYPE REF TO data,
    lt_message    TYPE usmd_t_message.

  FIELD-SYMBOLS:
    <ls_excluded_event_per_action> LIKE LINE OF me->mt_excluded_events_per_action.

  FIELD-SYMBOLS : <lt_data> TYPE ANY TABLE.

  rv_visible = super->is_row_action_visible(
    iv_event_id = iv_event_id
    io_entity = io_entity
  ).

  "HC_DEL
  CASE iv_event_id.
    WHEN cl_guibb_bol_collection=>cv_event_id_row_delete.
      IF mv_highlight_del_active = abap_true.
        TRY.
            io_entity->execute( iv_method_name = cl_mdg_bs_genil=>gc_method_name-is_entity_deleted ).
            "Don't show the TrashCan for deleted Obj - replace by Undo icon
            rv_visible = abap_false.
          CATCH cx_crm_bol_meth_exec_failed.
            "Leave it as it is - returned value by super.
        ENDTRY.
      ELSE.
        "Leave it as it is - returned value by super.
      ENDIF.
      " custom start
      IF io_entity IS NOT BOUND.
        RETURN.
      ELSE.
        io_entity->get_property_as_value(
          EXPORTING
            iv_attr_name = 'Z0M0041' "key of list entity
          IMPORTING
            ev_result    = lv_Z0M0041 ).

        io_entity->get_property_as_value(
          EXPORTING
            iv_attr_name = 'Z0BUKRS' "key of list entity
          IMPORTING
            ev_result    = lv_Z0BUKRS ).

        io_entity->get_property_as_value(
          EXPORTING
            iv_attr_name = 'Z0M0047Q' "key of list entity
          IMPORTING
            ev_result    = lv_Z0M0047Q ).

        IF lv_Z0M0041 IS INITIAL OR lv_Z0BUKRS IS INITIAL OR lv_Z0M0047Q IS INITIAL.
          RETURN.
        ELSE.
          CALL METHOD cl_usmd_model_ext=>get_instance
            EXPORTING
              i_usmd_model = 'Z0'
            IMPORTING
              eo_instance  = lo_model.

          CLEAR: ls_sel, lt_sel.
          ls_sel-fieldname = 'Z0BUKRS'.
          ls_sel-option = 'EQ'.
          ls_sel-sign = 'I'.
          ls_sel-low = lv_Z0BUKRS.
          INSERT ls_sel INTO TABLE lt_sel.

          ls_sel-fieldname = 'Z0M0041'.
          ls_sel-option = 'EQ'.
          ls_sel-sign = 'I'.
          ls_sel-low = lv_Z0M0041.
          INSERT ls_sel INTO TABLE lt_sel.

          ls_sel-fieldname = 'Z0M0047Q'.
          ls_sel-option = 'EQ'.
          ls_sel-sign = 'I'.
          ls_sel-low = lv_Z0M0047Q.
          INSERT ls_sel INTO TABLE lt_sel.

          CALL METHOD lo_model->create_data_reference
            EXPORTING
              i_fieldname = 'Z0M0047' "name of list entity
              i_struct    = lo_model->gc_struct_key_attr
            IMPORTING
              er_data     = lv_structure.

          ASSIGN lv_structure->* TO <lt_data>.

          CALL METHOD lo_model->read_char_value
            EXPORTING
              i_fieldname = 'Z0M0047'
              it_sel      = lt_sel
              i_readmode  = '3'
            IMPORTING
              et_data     = <lt_data>.
          IF <lt_data> IS NOT INITIAL.
            rv_visible = abap_false.
          ENDIF.
        ENDIF.
      ENDIF.
      " custom end
    WHEN if_usmd_generic_bolui_const=>gc_action_discard_delete.
      IF mv_highlight_del_active = abap_true.
        TRY.
            io_entity->execute( iv_method_name = cl_mdg_bs_genil=>gc_method_name-is_entity_deleted ).
            rv_visible = abap_true.
          CATCH cx_crm_bol_meth_exec_failed.
            rv_visible = abap_false.
        ENDTRY.
      ELSE.
        rv_visible = abap_false.
      ENDIF.
  ENDCASE.


  READ TABLE me->mt_excluded_events_per_action ASSIGNING <ls_excluded_event_per_action>
       WITH TABLE KEY logical_action = me->mv_action
                      event_id = iv_event_id.
  IF sy-subrc = 0 AND <ls_excluded_event_per_action>-hide = abap_true.
    rv_visible = abap_false.
  ENDIF.



ENDMETHOD.


METHOD LOCK.
  DATA:
    lo_entity LIKE me->mo_entity,
    lo_fpm TYPE REF TO cl_fpm.


  lo_fpm ?= me->mo_fpm_toolbox->mo_fpm.
  IF me->mo_mdg_api IS BOUND.
    IF me->mo_mdg_api->mv_crequest_type IS INITIAL.
      rv_success = boolc( lo_fpm->mo_current_event->mv_event_id = if_fpm_constants=>gc_event-call_default_edit_page ).
    ELSE.
      IF lo_fpm IS BOUND AND lo_fpm->mo_current_event IS BOUND.
        IF lo_fpm->mo_current_event->mv_event_id = if_fpm_constants=>gc_event-call_default_edit_page AND
         lo_fpm->mo_current_event->mv_is_implicit_edit = abap_false.
        "Call of EditPage without implicit edit -> Display (Simulate that Lock worked for FPM)
        rv_success = abap_true.
        RETURN.
        ENDIF.
      ENDIF.
      lo_entity ?= io_access.
      " Check if locked entity is still alive: otherwise leave method with result = false
      IF lo_entity IS NOT BOUND OR lo_entity->alive( ) = abap_false.
        rv_success = abap_false.
        RETURN.
      ENDIF.
      IF lo_entity->is_change_allowed( ) = abap_true.
        rv_success = super->lock( io_access ).
      ELSE.
        "when navigation to edit-page is triggered for the situation that a CR is
        "active and the entity is not changable (due to that or other reasons)
        "pretend entity was successfully locked - otherwise FPM prevents navigation
        "into edit-page completely.
        rv_success = abap_true.
      ENDIF.
    ENDIF.
  ELSE.
    rv_success = super->lock( io_access ).
  ENDIF.
ENDMETHOD.


METHOD LOCK_FOR_EDIT.
  rv_success = super->lock_for_edit( iv_index ).
ENDMETHOD.


METHOD MODIFY_CNR_BUTTON.
  DATA:
    ls_instance_key LIKE me->ms_instance_key,
    lv_interface_view LIKE me->mv_interface_view,
    ls_tray TYPE cl_bs_fpm_toolbox=>ty_uibb.

* In general this works to modify related/surrounding buttons
  super->modify_cnr_button(
    iv_event_id         = iv_event_id
    iv_enabled          = iv_enabled
    iv_visibility       = iv_visibility
    iv_ovp_uibb_toolbar = iv_ovp_uibb_toolbar
  ).

* The following logic guarantees that also UIBBs which are part of UIBB
* compositions (TABBED,Composite) can change the next higher tray buttons
* (FPM does not support this currently)
  ls_tray = me->mo_fpm_toolbox->tray_of_uibb( me->ms_instance_key-config_id ).
  CHECK ls_tray IS NOT INITIAL.
  ls_instance_key = me->ms_instance_key.
  lv_interface_view = me->mv_interface_view.
  me->ms_instance_key = ls_tray-instance_key.
  me->mv_interface_view = ls_tray-interface_view.

  super->modify_cnr_button(
    iv_event_id         = iv_event_id
    iv_enabled          = iv_enabled
    iv_visibility       = iv_visibility
    iv_ovp_uibb_toolbar = iv_ovp_uibb_toolbar
  ).

  me->ms_instance_key = ls_instance_key.
  me->mv_interface_view = lv_interface_view.
ENDMETHOD.


  METHOD ON_BOL_COPY.
    DATA lo_entity TYPE REF TO cl_crm_bol_entity.
    DATA lv_pattern_id TYPE string.
    DATA lt_list_of_fixings TYPE ty_t_list_of_fixings.
    DATA lt_fixings LIKE LINE OF lt_list_of_fixings.
    DATA lo_clone TYPE REF TO cl_crm_bol_entity.
    DATA lv_tabix TYPE sytabix.

    CHECK iv_raised_by_own_ui = abap_true.
    READ TABLE me->mt_entity_sel INDEX 1 INTO lo_entity.
    CHECK sy-subrc = 0 AND lo_entity IS BOUND AND lo_entity->alive( ) = abap_true.
    ev_result = if_fpm_constants=>gc_event_result-ok.
    io_event->mo_event_data->set_value( iv_key = 'ENTITY_SELECTED'  iv_value = lo_entity ).
    me->mo_fpm_toolbox->get_event_data(
      EXPORTING io_event = io_event
                iv_name = 'IDENTIFIER'
      IMPORTING ev_value = lv_pattern_id
    ).
    io_event->mo_event_data->get_value( EXPORTING iv_key = 'LIST_OF_FIXINGS'  IMPORTING ev_value = lt_list_of_fixings ).
    IF lt_list_of_fixings IS INITIAL.
      me->mo_fpm_toolbox->get_event_data(
        EXPORTING io_event = io_event
                  iv_name  = 'DIALOG'
        IMPORTING ev_value = me->mv_dialog_id
      ).
      IF me->mv_dialog_id IS INITIAL.
        lo_clone = me->mo_entity_cloner->rise(
          io_stem_entity = lo_entity
          iv_using_pattern_id = lv_pattern_id
        ).
        CHECK lo_clone IS BOUND.
        IF me->mo_how_to IS BOUND AND me->mo_how_to->mv_muted = abap_false.
          me->mo_how_to->create( io_entity = lo_clone  io_created_by_event = io_event ).
        ENDIF.
      ELSE.
        me->open_selection_dialog( me->mv_dialog_id ).
        me->mo_cloning_event = io_event.
      ENDIF.
    ELSE.
      LOOP AT lt_list_of_fixings INTO lt_fixings.
        lv_tabix = sy-tabix.
        lo_clone = me->mo_entity_cloner->rise(
          io_stem_entity = lo_entity
          iv_using_pattern_id = lv_pattern_id
          it_fixings = lt_fixings
        ).
        CHECK lo_clone IS BOUND AND me->mo_how_to IS BOUND AND me->mo_how_to->mv_muted = abap_false.
        IF lv_tabix = 1.
          me->mo_how_to->create( io_entity = lo_clone  io_created_by_event = io_event ).
        ELSE.
          me->mo_how_to->create( lo_clone ).
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


METHOD ON_CREATE_ROOT.
*! This method handles the create root event. It creates the required
*  root element according to the given relation.
  DATA:
    lv_lead_index TYPE i,
    ls_initial_data TYPE fpm_bol_initial_data,
    lv_object_name  TYPE crmt_ext_obj_name.

  ev_result = if_fpm_constants=>gc_event_result-ok.

  "ensure to create the correct root object
  io_event->mo_event_data->get_value(
    EXPORTING
      iv_key   = if_usmd_generic_bolui_const=>gc_param_object_name
    IMPORTING
      ev_value = lv_object_name ).
  IF lv_object_name NE ms_object_key-object_name.
    RETURN.
  ENDIF.

  "get initial data
  ls_initial_data = me->get_initial_data( io_event->mv_event_id ).

  "create the entity
  me->mo_entity = me->create_root_entity( iv_object_name    = lv_object_name
                                          ir_default_values = ls_initial_data-default_values ).

  IF me->mo_entity IS BOUND.
    me->mo_collection->add( me->mo_entity ).
    me->mo_collection->if_bol_bo_col~mark( iv_bo = me->mo_entity ).
    CLEAR me->mt_entity_sel.
    APPEND me->mo_entity TO me->mt_entity_sel.
    me->adjust_selection( IMPORTING ev_lead_index = lv_lead_index ).
    me->ms_page_range-forced_visible = lv_lead_index.
    io_event->mo_event_data->set_value(
      iv_key = me->get_index_param_name( )
      iv_value = lv_lead_index
    ).
    CHECK me->mo_how_to IS BOUND.
    me->mo_how_to->create( me->mo_entity ).
  ELSE.
    ev_result = if_fpm_constants=>gc_event_result-failed.
  ENDIF.
ENDMETHOD.


METHOD ON_CR_REFRESH.
  DATA:
    lr_connector TYPE REF TO cl_mdg_bs_connector_bol_rel,
    lo_entity LIKE me->mo_entity,
    lv_action_canceled TYPE abap_bool.

  me->mo_fpm_toolbox->get_event_data(
  EXPORTING
    io_event = io_event
    iv_name  = cl_mdg_bs_cr_uibb_eventhandler=>cv_parameter_action_canceled
  IMPORTING
    ev_value = lv_action_canceled
).

  IF lv_action_canceled = abap_true.
    " Scenarios like Enrichments are pluged in and therefore have effect on data
    " & process validity. Therefore e.g. in case of a CANCEL on their PopUps also other data
    " has to be refreshed or reset. (e.g. also list data)
    TRY.
        lr_connector ?= me->mo_connector.
      CATCH cx_sy_move_cast_error.
        RETURN.
    ENDTRY.
    lo_entity = lr_connector->get_parent( ).
    IF lo_entity IS BOUND
      AND lo_entity->alive( ) EQ abap_true.
      lo_entity->reread( iv_invalidate_children = abap_true ).
    ENDIF.
  ELSE.
    TRY.
        lr_connector ?= me->mo_connector.
      CATCH cx_sy_move_cast_error.
        RETURN.
    ENDTRY.
    lo_entity = lr_connector->get_parent( ).
    IF lo_entity IS BOUND
      AND lo_entity->alive( ) EQ abap_true.
      lo_entity->reread( iv_invalidate_children = abap_true ).
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD ON_DISCARD_DELETION.
  DATA lo_entity TYPE REF TO cl_crm_bol_entity.
  DATA lv_row_index TYPE sytabix.
  DATA lo_main_entity TYPE REF TO cl_crm_bol_entity.
  DATA lv_deleted TYPE abap_bool.
  DATA lo_collection TYPE REF TO if_bol_entity_col.
  FIELD-SYMBOLS <ls_join> LIKE LINE OF me->mt_join.

  IF mo_mdg_api IS BOUND AND iv_raised_by_own_ui = abap_true AND
       me->mo_highlight_changes->is_highlight_deletion_active( iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                                                               iv_crequest_step = me->mo_mdg_api->mv_wf_step ) = abap_true.

    CALL METHOD io_event->mo_event_data->get_value
      EXPORTING
        iv_key   = get_index_param_name( )
      IMPORTING
        ev_value = lv_row_index.

    lo_main_entity = mo_collection->find( iv_index = lv_row_index ).

    CHECK lo_main_entity IS BOUND AND lo_main_entity->alive( ) = abap_true.

    CREATE OBJECT lo_collection TYPE cl_crm_bol_entity_col.
    lo_collection->add( lo_main_entity ).
    LOOP AT mt_join ASSIGNING <ls_join>.
      lo_entity = me->get_joined_entity( io_entity = lo_main_entity  iv_join_id = <ls_join>-id ).
      CHECK lo_entity IS BOUND.
      lo_collection->add( lo_entity ).
    ENDLOOP.
    lo_entity = lo_collection->get_first( ).
    WHILE lo_entity IS BOUND.
      CHECK lo_entity IS BOUND AND lo_entity->alive( ) = abap_true.
      TRY.
          IF lo_entity->lock( ) = abap_true.
            lo_entity->execute( iv_method_name = cl_mdg_bs_genil=>gc_method_name-discard_deletion ).
            lv_deleted = abap_true.
          ELSE.
            lv_deleted = abap_false.
          ENDIF.
        CATCH cx_crm_bol_meth_exec_failed.
          lv_deleted = abap_false.
      ENDTRY.

      lo_entity = lo_collection->get_next( ).
    ENDWHILE.

    IF lv_deleted = abap_false.
      ev_result = if_fpm_constants=>gc_event_result-failed.
    ELSE.
      "The discard can have effect on other UIBBs (e.g. TXTs) - reread UI data
      If mo_fpm_toolbox IS BOUND and mo_fpm_toolbox->mo_fpm IS BOUND.
        mo_fpm_toolbox->mo_fpm->raise_event_by_id( iv_event_id = CL_MDG_BS_CR_UIBB_EVENTHANDLER=>CV_ACTION_REFRESH ).
      ENDIF.
    ENDIF.

  ENDIF.

ENDMETHOD.


METHOD ON_SHOW.
  DATA:
    lo_event LIKE io_event.



  CHECK iv_raised_by_own_ui = abap_true.
  IF iv_event_index > 0 AND iv_event_index NE iv_lead_index.
    "An entry has been marked, but the different entry should be shown
    me->set_selection( iv_lead_index = iv_event_index ).
  ELSE.
    me->set_selection(
      iv_lead_index = iv_lead_index
      it_selection = it_selected_lines
    ).
  ENDIF.
  "create the FPM event that triggers the "navigation" to the edit page of this
  "list and hand over the meta-data of the SHOW-event
  lo_event = cl_fpm_event=>create_by_id(
    iv_event_id = if_fpm_constants=>gc_event-call_default_edit_page
    io_event_data = io_event->mo_event_data
  ).
  "make this event a "local event", so that it comes here again with
  "IV_RAISED_BY_OWN_UI set to ABAP_TRUE
  MOVE-CORRESPONDING me->ms_instance_key TO lo_event->ms_source_uibb.
  lo_event->ms_source_uibb-interface_view = me->mv_interface_view.
  me->mo_fpm_toolbox->mo_fpm->raise_event( lo_event ).
ENDMETHOD.


METHOD ON_SHOW_SOVP.
  DATA:
    lo_event LIKE io_event.



  CHECK iv_raised_by_own_ui = abap_true.
  "create the FPM event that triggers the "navigation" to the SOVP of this
  "list and hand over the meta-data of the SHOW_SOVP-event
  lo_event = cl_fpm_event=>create_by_id(
    iv_event_id = if_fpm_constants=>gc_event-call_suboverview_page
    io_event_data = io_event->mo_event_data
  ).
  "make this event a "local event", so that it comes here again with
  "IV_RAISED_BY_OWN_UI set to ABAP_TRUE
  MOVE-CORRESPONDING me->ms_instance_key TO lo_event->ms_source_uibb.
  lo_event->ms_source_uibb-interface_view = me->mv_interface_view.
  me->mo_fpm_toolbox->mo_fpm->raise_event( lo_event ).
ENDMETHOD.


  METHOD OPEN_SELECTION_DIALOG.
    " To be redefined, e.g. by using generic dialog handling of CL_MDG_BS_GUIBB_DDIC_LIST
  ENDMETHOD.


  METHOD OVS_OUTPUT_FILTER.
*! This method implements the default filter for OVS search results. It
*  supports any OVS search structure. All components of the query are
*  taken into account. The components are processed sequentially one
*  after the other.
*  Example:
*  The query parameter consists of a KEY and a TEXT. Both contain a
*  wildcard at the end. The filter will first remove all entries that
*  do not match the KEY. From the remaining results it will remove all
*  entries that do not match the TEXT.
*  The filter currently supports:
*  - input using the wildcards '*' and '+' anywhere
*  - fully qualified terms for key fields if the search value differs
*    from the actual value of the object
*  Other options are not supported. The given results are not filtered.
    DATA:
      lt_filters TYPE STANDARD TABLE OF string,
      lt_query   TYPE crmt_attr_name_tab,
      lv_alpha   TYPE i,
      lv_delete  TYPE abap_bool,
      lv_filter  TYPE string,
      lv_number  TYPE i.

    FIELD-SYMBOLS:
      <ls_query>     TYPE any,
      <ls_output>    TYPE any,
      <lt_output>    TYPE ANY TABLE,
      <lv_component> TYPE any,
      <lv_value>     TYPE any.

    "get the user's input
    ASSIGN ir_query_parameter->* TO <ls_query>.
    IF sy-subrc NE 0
      OR <ls_query> IS INITIAL.
      RETURN.
    ENDIF.

    "prepare the output
    ASSIGN cr_output->* TO <lt_output>.
    IF sy-subrc NE 0
      OR <lt_output> IS INITIAL.
      RETURN.
    ENDIF.

    "check query parameter
    lt_query = cl_usmd_generic_bolui_assist=>get_structure_components( is_data = <ls_query> ).
    LOOP AT lt_query ASSIGNING <lv_component>.
      ASSIGN COMPONENT <lv_component> OF STRUCTURE <ls_query> TO <lv_value>.
      IF sy-subrc NE 0
        OR <lv_value> IS INITIAL.
        DELETE TABLE lt_query FROM <lv_component>.
        CONTINUE.
      ENDIF.

      IF NOT <lv_value> IS INITIAL AND
         find( val = <lv_value> regex = '[\*|\+]' occ = 1 ) <> -1.
        " User has used wildcard character - we support '*' and '+'.
        " Let's use regular expression for searching - we have to do this:

        " 1. All other special regex characters (except of '*' and '+')
        "    has to be converted into normal literals - this is done
        "    by placing backslash ('\') in front of it. To do it, we can
        "    use command REPLACE with regular expression, how nice!:)
        <lv_value> = replace( val   = <lv_value>
                              regex = '[\\|\.|\[|\]|\{|\}|\?|\||\(|\)|\^|\$]'
                              with  = '\\$0'
                              occ   =   0 ).
        " 2. If * or + is not at the beginning or at the end, we add the
        "    special character for start ^ resp. end $ of the string.
        IF find( val = <lv_value> regex = '[\*|\+]' occ = 1 ) <> 0.
          <lv_value> = '^' && <lv_value>.
        ENDIF.
        IF find( val = <lv_value> regex = '[\*|\+]' occ = -1 ) <> strlen( <lv_value> ) - 1.
          <lv_value> = <lv_value> && '$'.
        ENDIF.

        " 3. Convert all occurences of '*' and '+' into correct regex
        "    expression, which is '.*', resp. '.+'
        <lv_value> = replace( val   = <lv_value>
                              regex = '[\*|\+]'
                              with  = '\.$0'
                              occ   =   0 ).
        "a * at the end enables this component for filtering
        CONTINUE.
      ELSEIF iv_field_name IS NOT INITIAL
        AND io_access IS BOUND
        AND ( <lv_component> EQ 'KEY' OR <lv_component> EQ iv_field_name ).
        TRY.
            IF io_access->get_property_as_string( iv_attr_name = iv_field_name ) NE <lv_value>.
              "the given value is a fully qualified key component that differs
              "from the object's value
              CONTINUE.
            ELSE.
              "drop this component from filtering
              DELETE TABLE lt_query FROM <lv_component>.
            ENDIF.
          CATCH cx_crm_cic_parameter_error.
            "drop this component from filtering
            DELETE TABLE lt_query FROM <lv_component>.
        ENDTRY.
      ENDIF.
    ENDLOOP.

    "filter according to the components
    LOOP AT lt_query ASSIGNING <lv_component>.
      UNASSIGN: <lv_value>.
      CLEAR: lt_filters, lv_alpha, lv_filter.

      "get the filter value
      ASSIGN COMPONENT <lv_component> OF STRUCTURE <ls_query> TO <lv_value>.
      CHECK sy-subrc EQ 0.
      lv_filter = <lv_value>.
      APPEND lv_filter TO lt_filters.

      "If the given filter is nummeric, it might make sense to add an 'alpha
      "conversion' to the value. This has to be defined by the actual object.
      "Example:
      "The company ID has a maxlength equal to 6. If the user searches for
      "companies with the query 10*, the filter has to respect the leading
      "zeros as below.
      "10* => finds everything from 100000 to 109999
      "010* => finds everything from 010000 to 010999
      "0010* => finds everything from 001000 to 001099
      "00010* => finds everything from 000100 to 000199
      IF lv_filter CO '1234567890'.
        lv_alpha = me->ovs_output_filter_alpha(
            iv_field_name      = iv_field_name
            iv_query_component = <lv_component> ).
        IF lv_alpha IS NOT INITIAL.
          "calculate the number of leading zeros to be added
          lv_alpha = lv_alpha - strlen( lv_filter ).
          "add new filters with leading zeros
          DO lv_alpha TIMES.
            lv_filter = |0{ lv_filter }|.
            APPEND lv_filter TO lt_filters.
          ENDDO.
        ENDIF.
      ENDIF.

      "filter according to the wildcard
      LOOP AT <lt_output> ASSIGNING <ls_output>.
        ASSIGN COMPONENT <lv_component> OF STRUCTURE <ls_output> TO <lv_value>.
        "name of key attribute is not 'KEY', check if name of key attribute is given
        IF sy-subrc NE 0 AND iv_field_name_key IS SUPPLIED AND iv_field_name_key IS NOT INITIAL.
          ASSIGN COMPONENT iv_field_name_key OF STRUCTURE <ls_output> TO <lv_value>.
          CHECK sy-subrc EQ 0.
        ENDIF.
        lv_delete = abap_true.
        LOOP AT lt_filters INTO lv_filter.
          IF find( val = <lv_value> regex = lv_filter ) <> -1 .
            lv_delete = abap_false.
            EXIT.
          ENDIF.
        ENDLOOP.
        CHECK lv_delete = abap_true.
        DELETE TABLE <lt_output> FROM <ls_output>.       "#EC CI_ANYSEQ
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD OVS_OUTPUT_FILTER_ALPHA.
*! This method allows to define whether alpha conversion shall be used
*  for the given field and query component, or not. If alpha conversion
*  is desired, RV_ALPHA has to be set to the length of the input field.
*  If not, RV_ALPHA has to be returned empty.
*
*  If alpha conversion is required, this method has to be re-defined
*  by an application specific feeder class.
    CLEAR rv_alpha.
  ENDMETHOD.


  METHOD SET_ACCESS_ATTRIBUTE.
    DATA lo_access LIKE io_access.
    DATA lv_attr_name LIKE iv_attr_name.
    DATA lr_previous_value TYPE REF TO data.

    FIELD-SYMBOLS <value> TYPE any.

    lo_access = me->get_property_access_for_attr( iv_attribute = iv_attr_name  io_access = io_access ).
    CHECK lo_access IS BOUND.
    lv_attr_name = me->get_bol_attribute_name( iv_attr_name ).
    CHECK lv_attr_name IS NOT INITIAL.
    TRY.
        lr_previous_value = lo_access->get_property( lv_attr_name ).
        CHECK lr_previous_value IS BOUND.
        ASSIGN lr_previous_value->* TO <value>.
      CATCH cx_crm_cic_parameter_error.
        RETURN.
    ENDTRY.
    super->set_access_attribute( io_access = io_access  iv_attr_name = iv_attr_name  iv_value = iv_value ).
    CHECK me->mo_how_to IS BOUND.
    me->mo_how_to->set_access_attribute(
      io_access = io_access
      iv_attr_name = iv_attr_name
      io_join_access = lo_access
      iv_join_attr_name = lv_attr_name
      iv_value = iv_value
      iv_previous_value = <value>
    ).
  ENDMETHOD.


METHOD SET_CHANGE_INDICATOR.
  DATA lv_change_indicator TYPE string.
  DATA lv_fieldname TYPE name_komp.
  DATA lv_color TYPE string.
  DATA lv_icon_color TYPE wdy_uie_library_enum_type.
  DATA lv_tooltip TYPE string.
  DATA lv_icon_tooltip TYPE string.

  FIELD-SYMBOLS <lv_change_indicator> TYPE data.
  FIELD-SYMBOLS <lv_color> TYPE data.
  FIELD-SYMBOLS <lv_tooltip>  TYPE data.

  ASSIGN COMPONENT if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator OF STRUCTURE cs_data TO <lv_change_indicator>.
  CHECK sy-subrc = 0.
  lv_change_indicator = <lv_change_indicator>.
  lv_fieldname = if_usmd_generic_bolui_const=>gc_fieldname_prefix-color && if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator.
  ASSIGN COMPONENT lv_fieldname OF STRUCTURE cs_data TO <lv_color>.
  CHECK sy-subrc = 0.
  lv_color = <lv_color>.
  lv_fieldname = if_usmd_generic_bolui_const=>gc_fieldname_prefix-tooltip && if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator.
  ASSIGN COMPONENT lv_fieldname OF STRUCTURE cs_data TO <lv_tooltip>.
  CHECK sy-subrc = 0.
  lv_tooltip = <lv_tooltip>.
  me->mo_highlight_changes->get_color_and_icon(
    EXPORTING iv_saved_change = is_changed_object-saved_change
              iv_unsaved_change = is_changed_object-unsaved_change
              iv_crequest_type = me->mo_mdg_api->mv_crequest_type
              iv_crequest_step = me->mo_mdg_api->mv_wf_step
    IMPORTING ev_color = lv_icon_color
              ev_tooltip = lv_icon_tooltip
  ).

  "Main Entity expected first, so no initialization of joined status by mistake
  IF is_changed_object-object_name NE me->ms_object_key-object_name.
    "This is a joined entity, they have no ranking-> no overwrite of existing CHANGE Indicator allowed
    IF <lv_change_indicator> is ASSIGNED AND ( <lv_change_indicator> is INITIAL OR <lv_change_indicator> = '~Icon/Empty' )
                                         AND is_changed_object-crud IS NOT INITIAL.
      "Only when Nothing set before, we directly set everything
      <lv_change_indicator> = '~Icon/EditedItem'.
      <lv_tooltip> = 'Changed'(010).
      IF lv_icon_tooltip IS NOT INITIAL.
        <lv_tooltip> = |{ <lv_tooltip> } { lv_icon_tooltip }|.
      ENDIF.
      <lv_color> = lv_icon_color.
      cv_data_changed = abap_true.
      RETURN.
    ENDIF.

    "Already an icon (=saved/unsaved state) - in case of saved -> unsaved joined states overrules
    IF lv_color NE lv_icon_color AND lv_icon_color = mo_highlight_changes->get_color_unsaved( ).
      "unsaved wins
      <lv_color> = lv_icon_color.
      <lv_tooltip> = |{ <lv_tooltip> } { lv_icon_tooltip }|.
      cv_data_changed = abap_true.
    ENDIF.
    "Finally Joined Objects leave here - data_changed flag only set or returned as provided
    RETURN.
  ENDIF.

  CASE is_changed_object-crud.
    WHEN if_usmd_conv_som_gov_entity=>gc_crud_create.
      <lv_change_indicator> = '~Icon/File'.
      <lv_tooltip> = 'New'(009).
      IF is_changed_object-unsaved_change = abap_true.
        <lv_color> = lv_icon_color.
      ENDIF.
      IF io_entity <> io_entity->get_root( )
      AND is_changed_object-saved_change = abap_true
      AND iv_is_new_entity = abap_false.
        <lv_color> = lv_icon_color.
      ENDIF.
      IF io_entity = io_entity->get_root( )
      AND is_changed_object-saved_change = abap_true
      AND iv_is_new_entity = abap_false.
        <lv_color> = lv_icon_color.
      ENDIF.
    WHEN if_usmd_conv_som_gov_entity=>gc_crud_update.
      <lv_change_indicator> = '~Icon/EditedItem'.
      <lv_tooltip> = 'Changed'(010).
      <lv_color> = lv_icon_color.
    WHEN if_usmd_conv_som_gov_entity=>gc_crud_delete.
      <lv_change_indicator> = '~Icon/DeletedItem'.
      <lv_tooltip> = 'Deleted'(012).
      <lv_color> = lv_icon_color.
    WHEN OTHERS.
      <lv_color> = lv_icon_color.
  ENDCASE.
  IF lv_icon_tooltip IS NOT INITIAL.
    <lv_tooltip> = |{ <lv_tooltip> } { lv_icon_tooltip }|.
  ENDIF.
  CHECK lv_tooltip <> <lv_tooltip> OR lv_color <> <lv_color> OR lv_change_indicator <> <lv_change_indicator>.
  cv_data_changed = abap_true.
ENDMETHOD.


METHOD SET_COLLECTION.
* Code was deleted because IO_COLLECTION is always a new instance. "2934986
* So, comparison of lo_collection <> me->mo_collection does not work.
  super->set_collection( io_collection ).
ENDMETHOD.


METHOD SET_DEFAULT_TOOLTIP.
  DATA lv_configured_field TYPE NAME_KOMP."LIKE LINE OF me->mt_config_field.
  DATA lv_tooltip_field TYPE name_komp.
  DATA lv_bol_object_name TYPE crmt_ext_obj_name.
  DATA lv_bol_attribute_name TYPE name_komp.
  DATA lv_new_tooltip TYPE string.
  DATA lv_mime_type TYPE skwf_descr.
  DATA ls_field_conf TYPE IF_FPM_LIST_ATS_EXT_CTRL=>YS_CONFIGURED_FIELD.

  FIELD-SYMBOLS <ls_field_usage> LIKE LINE OF it_field_usage.
  FIELD-SYMBOLS <ls_data> TYPE any.
  FIELD-SYMBOLS <lv_tooltip> TYPE string.
  FIELD-SYMBOLS <lv_file_type> TYPE data.


  "Config Fields logic
  DATA ls_join_config   TYPE s_join_config.
  DATA lv_join_field    TYPE name_komp.
  DATA ls_join_attr     LIKE LINE OF mt_join_attr.
  DATA ls_config_fields LIKE LINE OF mt_config_fields.

  "First time build up Config Field table including Joint fields
  IF me->mt_config_fields IS INITIAL.
    INSERT LINES OF mt_config_field INTO TABLE mt_config_fields.

    LOOP AT mt_join_config INTO ls_join_config.
      LOOP AT ls_join_config-fields INTO lv_join_field.
        READ TABLE me->mt_join_attr INTO ls_join_attr WITH TABLE KEY join_attr
                                      COMPONENTS bol_attr_name = lv_join_field
                                                 join_id       = ls_join_config-join_id.
        IF sy-subrc = 0.
          ls_config_fields = ls_join_attr-name.
          INSERT ls_config_fields INTO TABLE mt_config_fields.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  "Now we loop at all available UI-Fields & try to set the default ToolTip
  LOOP AT me->mt_config_fields INTO lv_configured_field.
    READ TABLE it_field_usage ASSIGNING <ls_field_usage> WITH KEY name = lv_configured_field.
    CHECK sy-subrc = 0.
    lv_tooltip_field = me->mo_highlight_changes->add_tlt_prefix( lv_configured_field ).
    CLEAR: lv_new_tooltip, ls_field_conf.
    IF io_extended_ctrl IS BOUND.
      io_extended_ctrl->get_configured_field( EXPORTING iv_name  = lv_configured_field
                                              IMPORTING es_field = ls_field_conf ).
      lv_new_tooltip = ls_field_conf-tooltip_cell.
    ENDIF.
    IF lv_new_tooltip IS INITIAL.
      lv_bol_object_name = me->get_bol_object_name( lv_configured_field ).
      lv_bol_attribute_name = me->get_bol_attribute_name( lv_configured_field ).
      lv_new_tooltip = me->get_label_text(
        iv_name = lv_configured_field
        iv_label_text_usage = <ls_field_usage>-label_text
        iv_bol_object_name = lv_bol_object_name
        iv_bol_attribute_name = lv_bol_attribute_name
      ).
    ENDIF.
    CHECK lv_new_tooltip IS NOT INITIAL.
    LOOP AT ct_data ASSIGNING <ls_data>.
      ASSIGN COMPONENT lv_tooltip_field OF STRUCTURE <ls_data> TO <lv_tooltip>.
      CHECK sy-subrc = 0.
      IF lv_configured_field = 'USMD_FILE_TYPE' OR lv_configured_field = 'FILE_ICON'.
        ASSIGN COMPONENT 'USMD_FILE_TYPE' OF STRUCTURE <ls_data> TO <lv_file_type>.
        IF sy-subrc = 0.
          CALL FUNCTION 'SKWF_MIMETYPE_DESCRIPTION_GET'
            EXPORTING
              mimetype = <lv_file_type>
            IMPORTING
              descript = lv_mime_type.
          lv_new_tooltip = lv_mime_type.
        ENDIF.
      ENDIF.
      CHECK lv_new_tooltip <> <lv_tooltip>.
      <lv_tooltip> = lv_new_tooltip.
      cv_data_changed = abap_true.
    ENDLOOP.
  ENDLOOP.
ENDMETHOD.


METHOD SET_HC_CONFIGURED_FIELDS.

  DATA lv_fieldname TYPE name_komp.

  FIELD-SYMBOLS <lv_config_field> LIKE LINE OF me->mt_config_fields.
  FIELD-SYMBOLS <ls_field_usage> LIKE LINE OF it_field_usage.
  FIELD-SYMBOLS <ls_data> TYPE any.
  FIELD-SYMBOLS <lv_color> TYPE data.
  FIELD-SYMBOLS <lv_tooltip> TYPE data.
  FIELD-SYMBOLS <ls_changed_fields_full_trans> LIKE LINE OF it_changed_field.
  FIELD-SYMBOLS <ls_changed_object> LIKE LINE OF it_changed_objects.
  FIELD-SYMBOLS <lv_value> type any.
  FIELD-SYMBOLS <ls_deleted_fields_full_trans> LIKE LINE OF it_changed_field.
  DATA lv_value type USMD_VALUE.

  assign cs_data to <ls_data>.

  LOOP AT me->mt_config_fields ASSIGNING <lv_config_field> WHERE table_line <> if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator.
    READ TABLE it_field_usage ASSIGNING <ls_field_usage> WITH KEY name = <lv_config_field>.
    CHECK sy-subrc = 0.
    lv_fieldname = me->mo_highlight_changes->add_col_prefix( <lv_config_field> ).
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_data> TO <lv_color>.
    CHECK sy-subrc = 0.
    lv_fieldname = me->mo_highlight_changes->add_tlt_prefix( <lv_config_field> ).
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_data> TO <lv_tooltip>.
    CHECK sy-subrc = 0.
    READ TABLE it_changed_field ASSIGNING <ls_changed_fields_full_trans> WITH KEY ui_field COMPONENTS ui_field = <lv_config_field>.
    IF sy-subrc = 0.
      <lv_color> = <ls_changed_fields_full_trans>-color.
      IF <ls_changed_fields_full_trans>-tooltip IS NOT INITIAL.
        <lv_tooltip> = <ls_changed_fields_full_trans>-tooltip.
      ENDIF.
    ELSE.
      READ TABLE it_deleted_field ASSIGNING <ls_deleted_fields_full_trans> WITH KEY ui_field COMPONENTS ui_field = <lv_config_field>.
      IF sy-subrc = 0.
        <lv_color> = <ls_deleted_fields_full_trans>-color.
        IF <ls_deleted_fields_full_trans>-tooltip IS NOT INITIAL.
          <lv_tooltip> = <ls_deleted_fields_full_trans>-tooltip.
        ENDIF.
      ELSE.
      READ TABLE it_changed_objects ASSIGNING <ls_changed_object> WITH KEY object_name = me->get_bol_object_name( <lv_config_field> ).
      CHECK sy-subrc = 0.
      IF <ls_changed_object>-crud = if_usmd_conv_som_gov_entity=>gc_crud_create.
        IF <ls_changed_object>-saved_change = abap_true.
          IF iv_is_new_entity = abap_false.
            " Set color of changed attribute: the field must be highlighted in color 'saved'.
            <lv_color> = mo_highlight_changes->get_color(
                           iv_value_active = ''
                           iv_value_saved = 'X'
                           iv_value_unsaved = 'X'
                           iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                           iv_crequest_step = me->mo_mdg_api->mv_wf_step
                         ).
          ENDIF.
        ELSEIF <ls_changed_object>-unsaved_change = abap_true.
          " The field must be highlighted in color 'unsaved'
          <lv_color> = mo_highlight_changes->get_color(
                         iv_value_active = ''
                         iv_value_saved = ''
                         iv_value_unsaved = 'X'
                         iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                         iv_crequest_step = me->mo_mdg_api->mv_wf_step
                       ).
        ENDIF.

      "HC_DEL
      "Kind of Transient field - no data from CONV_API & and no special handling by application so use UI values
      ELSEIF <ls_changed_object>-crud = if_usmd_conv_som_gov_entity=>gc_crud_delete AND
              me->mo_highlight_changes->is_highlight_deletion_active( EXPORTING iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                                                                                iv_crequest_step = me->mo_mdg_api->mv_wf_step ) = abap_true.

        " Similar to Create-logic before - but due to separation reason this makes sense separated
          ASSIGN COMPONENT <lv_config_field> OF STRUCTURE <ls_data> TO <lv_value>.
          If sy-subrc = 0.
            write <lv_value> to lv_value.
          ENDIF.

          <lv_color> = mo_highlight_changes->get_color_of_deletion(
                               iv_saved_change   = <ls_changed_object>-saved_change
                               iv_unsaved_change = <ls_changed_object>-unsaved_change
                               iv_crequest_type  = me->mo_mdg_api->mv_crequest_type
                               iv_crequest_step  = me->mo_mdg_api->mv_wf_step
                           ).
          <lv_tooltip> = mo_highlight_changes->get_tooltip_for_deletion(
                                             iv_fieldname = <lv_config_field>
                                             iv_value_active = lv_value
                                             iv_saved_change = <ls_changed_object>-saved_change
                                             iv_unsaved_change = <ls_changed_object>-unsaved_change
                                             iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                                             iv_crequest_step = me->mo_mdg_api->mv_wf_step
                                             it_field_usage = it_field_usage
                                             it_selected_fields = it_selected_fields
                                             is_data            = cs_data
                                           ).
      ENDIF.
    ENDIF.
    ENDIF.
  ENDLOOP.
ENDMETHOD.


METHOD SET_UIBB_EXPLANATION.
*** This method is used to set the explanation text of an UIBB.
*** To set the text, the toolbar API of the OVP is needed.

  DATA lo_cnr_ovp TYPE REF TO if_fpm_cnr_ovp.

* FPM toolbox must exist
  IF me->mo_fpm_toolbox IS BOUND.
*   FPM as part of the toolbox must exist
    IF me->mo_fpm_toolbox->mo_fpm IS BOUND.
      TRY.
*         retrieve the toolbar API of the OVP
          lo_cnr_ovp ?= me->mo_fpm_toolbox->mo_fpm->get_service( cl_fpm_service_manager=>gc_key_cnr_ovp ).
*         set the text
          lo_cnr_ovp->change_uibb_restricted(
            EXPORTING
              iv_fpm_primary_attribute = me->mo_fpm_toolbox->get_element_id_of_uibb( is_instance_key )
              iv_explanation_text      = iv_explanation ).
        CATCH cx_fpm_floorplan cx_sy_move_cast_error cx_sy_ref_is_initial. "#EC NO_HANDLER
      ENDTRY.
    ENDIF.
  ENDIF.

ENDMETHOD.


 METHOD SET_UIBB_EXPLANATION_DOC.
*! This method is used to set the explanation document of an UIBB.
*  To set the document, the toolbar API of the OVP is needed.

   DATA lo_cnr_ovp TYPE REF TO if_fpm_cnr_ovp.

   "FPM toolbox must exist
   IF me->mo_fpm_toolbox IS BOUND.
     "FPM as part of the toolbox must exist
     IF me->mo_fpm_toolbox->mo_fpm IS BOUND.
       TRY.
           "retrieve the toolbar API of the OVP
           lo_cnr_ovp ?= me->mo_fpm_toolbox->mo_fpm->get_service( cl_fpm_service_manager=>gc_key_cnr_ovp ).
           "set the doc
           lo_cnr_ovp->change_uibb_restricted(
             EXPORTING
               iv_fpm_primary_attribute = me->mo_fpm_toolbox->get_element_id_of_uibb( is_instance_key )
               iv_explanation_document  = iv_document ).
         CATCH cx_fpm_floorplan cx_sy_move_cast_error cx_sy_ref_is_initial. "#EC NO_HANDLER
       ENDTRY.
     ENDIF.
   ENDIF.

 ENDMETHOD.


METHOD TAP_CONNECTOR.

  DATA: lo_connector TYPE REF TO cl_mdg_bs_connector_bol_rel,
        lo_entity LIKE me->mo_entity.

  super->tap_connector( is_initial_data = is_initial_data ).

  "EDIT_PAGE issue - display navigation handling
  "If FPM says EDIT but parent Entity is not locked -> use READ_ONLY
  CHECK me->mv_fpm_edit_mode = if_fpm_constants=>gc_edit_mode-edit
    AND me->mo_connector IS BOUND.

  TRY.
      lo_connector ?= mo_connector.
    CATCH cx_sy_move_cast_error .
      RETURN.
  ENDTRY.

  lo_entity = lo_connector->get_parent( ).

  IF lo_entity IS BOUND AND lo_entity->is_locked( ) = abap_false.
    me->mv_fpm_edit_mode = if_fpm_constants=>gc_edit_mode-read_only.
  ENDIF.

ENDMETHOD.


METHOD ADD_STANDARD_ROW_ACTIONS.
  DATA:
    ls_row_action_ref LIKE LINE OF mt_row_action_ref.

  FIELD-SYMBOLS:
    <ls_row_action> LIKE LINE OF me->mt_row_action.



  super->add_standard_row_actions( ).

  APPEND INITIAL LINE TO me->mt_row_action ASSIGNING <ls_row_action>.
  <ls_row_action>-id = cv_event_id_show.
  <ls_row_action>-text = text-002.
*  <ls_row_action>-image_source = '~Icon/Display'. "not GL2.0 conform...
  <ls_row_action>-is_implicit_edit = abap_false.
  <ls_row_action>-visible_ref = me->mv_oca_display_visible_ref.
  ls_row_action_ref-id = <ls_row_action>-id.
  INSERT ls_row_action_ref INTO TABLE me->mt_row_action_ref.

  "default sub-overview-page in edit-mode
  APPEND INITIAL LINE TO mt_row_action ASSIGNING <ls_row_action>.
  <ls_row_action>-id = if_fpm_constants=>gc_event-call_suboverview_page.
  <ls_row_action>-image_source = '~Icon/Edit'.
  <ls_row_action>-is_implicit_edit = abap_true.
  ls_row_action_ref-id = <ls_row_action>-id.
  INSERT ls_row_action_ref INTO TABLE mt_row_action_ref.

  "default sub-overview-page in display-mode
  APPEND INITIAL LINE TO mt_row_action ASSIGNING <ls_row_action>.
  <ls_row_action>-id = cv_event_id_show_sovp.
  <ls_row_action>-text = text-002.
  <ls_row_action>-is_implicit_edit = abap_false.
  ls_row_action_ref-id = <ls_row_action>-id.
  INSERT ls_row_action_ref INTO TABLE mt_row_action_ref.

  "HC_DEL
  APPEND INITIAL LINE TO mt_row_action ASSIGNING <ls_row_action>.
  <ls_row_action>-id = if_usmd_generic_bolui_const=>gc_action_discard_delete.
*  <ls_row_action>-text = 'DISCARD_DEL'.
  <ls_row_action>-tooltip = text-016. "Discard Deletion
  <ls_row_action>-image_source = '~Icon/Undo'.
  <ls_row_action>-is_implicit_edit = abap_true.
  ls_row_action_ref-id = <ls_row_action>-id.
  INSERT ls_row_action_ref INTO TABLE mt_row_action_ref.

ENDMETHOD.


METHOD ADJUST_CHANGED_OBJECT_INFO.
* To be redefined by spec. feeder implementations when there are requirements
* to adjust the information about the changed object and use gen logic on the new state

ENDMETHOD.


METHOD ASSIGN_SEARCH_HELPS.
*! This method assigns search helps to the fields of the List UIBB. It
*  is called once in method GET_DEFINITION. The method can be redefined
*  in inherited classes to adjust/extend the implemented logic.

  DATA:
    lv_shlp TYPE usmd_search_hlp.

  FIELD-SYMBOLS:
    <ls_fdesc> LIKE LINE OF ct_field_description.

  IF ct_field_description IS INITIAL OR
     me->is_design_time( ) = abap_true.
    RETURN.
  ENDIF.

  "Currently, the standard FIN and BP UIs have an own logic regarding
  "search helps so that they are excluded here.
  IF cl_usmd_generic_bolui_assist=>get_bor_object_for_genil_comp(
       iv_genil_component_name = me->ms_object_key-component_name ) IS NOT INITIAL OR
     me->ms_object_key-component_name = 'CLEANS'                                   OR
     me->ms_object_key-component_name = 'MDGF'.
    RETURN.
  ENDIF.

  "Assign search helps to list fields
  "(No search helps will be assigned here for pure technical fields and
  " for fields with search/OVS/WebDynpro help already assigned before)
  LOOP AT ct_field_description ASSIGNING <ls_fdesc>
    WHERE technical_field = abap_false AND
          ddic_shlp_name IS INITIAL    AND
          wd_value_help  IS INITIAL    AND
          ovs_name       IS INITIAL.
    "Read search help assigned to field in data model
    IF me->mo_mdg_api IS BOUND.
      lv_shlp = cl_usmd_generic_bolui_assist=>get_searchhelp_of_field(
                  iv_model     = me->mo_mdg_api->mv_model_name
                  iv_fieldname = <ls_fdesc>-name ).
      IF lv_shlp IS NOT INITIAL.
        <ls_fdesc>-ddic_shlp_name = lv_shlp.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD CHECK_ACTION_USAGE.
  DATA:
    lo_collection LIKE me->mo_collection,
    lo_entity LIKE me->mo_entity,
    lv_change_allowed TYPE abap_bool,
    lx_usmd_gov_api TYPE REF TO cx_usmd_gov_api.



  me->ms_change-action_usage = abap_false.
  super->check_action_usage( CHANGING ct_action_usage = ct_action_usage ).

  CHECK me->mv_check_mutability = abap_true.
  IF me->mv_edit_mode = abap_true.
    TRY.
        lo_entity = me->mo_entity.
        IF lo_entity IS NOT BOUND.
          IF me->mo_collection IS BOUND.
            lo_entity = me->mo_collection->get_current( ).
          ELSEIF me->mo_connector IS BOUND.
            lo_collection ?= me->mo_connector->get_output( ).
            IF lo_collection IS BOUND.
              lo_entity = lo_collection->get_current( ).
            ENDIF.
          ENDIF.
        ENDIF.
        IF lo_entity IS BOUND AND lo_entity->alive( ) = abap_true.
          lv_change_allowed = lo_entity->is_change_allowed( ).
        ELSEIF me->mo_connector IS BOUND.
          lv_change_allowed = me->mo_connector->is_create_allowed( ).
        ELSE.
          IF me->mo_mdg_api IS BOUND.
            lv_change_allowed = me->mo_mdg_api->is_change_allowed( ).
          ELSE.
            lv_change_allowed = abap_true.
          ENDIF.
        ENDIF.
      CATCH cx_usmd_gov_api INTO lx_usmd_gov_api.
        " Remove error message from global message container
        CALL METHOD me->mo_mdg_api->mo_message_container->if_genil_message_container~delete_messages
          EXPORTING
            iv_msg_id     = lx_usmd_gov_api->e_message-msgid
            iv_msg_number = lx_usmd_gov_api->e_message-msgno.
        lv_change_allowed = abap_false.
    ENDTRY.
  ELSE.
    lv_change_allowed = abap_false.
  ENDIF.

  IF lv_change_allowed = abap_true.
    me->modify_cnr_button(
      iv_event_id = if_fpm_constants=>gc_event-local_edit
      iv_ovp_uibb_toolbar = abap_true
      iv_visibility = if_fpm_constants=>gc_visibility-visible
      iv_enabled = lv_change_allowed
    ).
  ELSE.
    me->modify_cnr_button(
      iv_event_id = if_fpm_constants=>gc_event-local_edit
      iv_ovp_uibb_toolbar = abap_true
      iv_visibility = if_fpm_constants=>gc_visibility-not_visible
      iv_enabled = lv_change_allowed
    ).
  ENDIF.
ENDMETHOD.


METHOD CHECK_ACTION_USAGE_SINGLE.
  DATA lo_entity TYPE REF TO cl_crm_bol_entity.
  DATA lx_usmd_gov_api TYPE REF TO cx_usmd_gov_api.

  FIELD-SYMBOLS:
    <ls_excluded_event_per_action> LIKE LINE OF me->mt_excluded_events_per_action.



  super->check_action_usage_single( CHANGING cs_action_usage = cs_action_usage ).
  READ TABLE me->mt_excluded_events_per_action ASSIGNING <ls_excluded_event_per_action>
       WITH TABLE KEY logical_action = me->mv_action
                      event_id = cs_action_usage-id.
  IF sy-subrc = 0.
    me->ms_change-action_usage = abap_true.
    cs_action_usage-enabled = abap_false.
    IF <ls_excluded_event_per_action>-hide = abap_true.
      cs_action_usage-visible = if_fpm_constants=>gc_visibility-not_visible.
    ENDIF.
    RETURN.
  ENDIF.
  IF cs_action_usage-id = cl_mdg_bs_communicator_assist=>gc_event-bol_copy.
    cs_action_usage-visible = cl_wd_uielement=>e_visible-none.
    IF cl_usmd_switch_check=>gv_framework_switch5 = abap_true.
      cs_action_usage-visible = cl_wd_uielement=>e_visible-visible.
    ENDIF.
    cs_action_usage-enabled = abap_false.
    IF lines( me->mt_entity_sel ) EQ 1.
      READ TABLE me->mt_entity_sel INDEX 1 INTO lo_entity.
      IF lo_entity IS BOUND AND lo_entity->alive( ) EQ abap_true.
        IF me->mv_highlight_del_active EQ abap_false.
          cs_action_usage-enabled = abap_true.
        ELSE.
          TRY.
              lo_entity->execute( iv_method_name = cl_mdg_bs_genil=>gc_method_name-is_entity_deleted ).
            CATCH cx_crm_genil_model_error cx_crm_bol_meth_exec_failed.
              "exception means that the entity is not deleted
              cs_action_usage-enabled = abap_true.
          ENDTRY.
        ENDIF.
        IF cs_action_usage-enabled = abap_true AND me->mo_mdg_api IS BOUND AND me->mv_check_mutability = abap_true.
          " The visibility of the Copy button depends on if create allowed.
          TRY.
              cs_action_usage-enabled = me->mo_mdg_api->is_create_allowed( ).
            CATCH cx_usmd_gov_api INTO lx_usmd_gov_api.
              " Remove error message from global message container
              CALL METHOD me->mo_mdg_api->mo_message_container->if_genil_message_container~delete_messages
                EXPORTING
                  iv_msg_id     = lx_usmd_gov_api->e_message-msgid
                  iv_msg_number = lx_usmd_gov_api->e_message-msgno.
              cs_action_usage-enabled = abap_false.
          ENDTRY.
          me->ms_change-action_usage = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CHECK me->mo_mdg_api IS BOUND.
  CHECK me->mv_check_mutability = abap_true.
  CASE cs_action_usage-id.
    WHEN me->mv_action_create
      OR if_usmd_generic_bolui_const=>gc_action_fpm_table_insert.
      IF me->mv_edit_mode = abap_true.
        IF cs_action_usage-enabled = abap_true.
          TRY.
              cs_action_usage-enabled = me->mo_mdg_api->is_create_allowed( ).
            CATCH cx_usmd_gov_api INTO lx_usmd_gov_api.
              " Remove error message from global message container
              CALL METHOD me->mo_mdg_api->mo_message_container->if_genil_message_container~delete_messages
                EXPORTING
                  iv_msg_id     = lx_usmd_gov_api->e_message-msgid
                  iv_msg_number = lx_usmd_gov_api->e_message-msgno.
              cs_action_usage-enabled = abap_false.
          ENDTRY.
          me->ms_change-action_usage = abap_true.
        ENDIF.
      ELSE.
        cs_action_usage-enabled = abap_false.
        me->ms_change-action_usage = abap_true.
      ENDIF.
    WHEN if_usmd_generic_bolui_const=>gc_action_create_root.
      "root creation has to be more strict
      IF me->mv_edit_mode = abap_true
        AND me->mo_connector IS BOUND.
        cs_action_usage-enabled = me->mo_connector->is_create_allowed( ).
        me->ms_change-action_usage = abap_true.
        IF cs_action_usage-enabled EQ abap_true.
          cs_action_usage-visible = cl_wd_uielement=>e_visible-visible.
        ENDIF.
      ELSE.
        cs_action_usage-enabled = abap_false.
        me->ms_change-action_usage = abap_true.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDMETHOD.


METHOD CLAIM_GENIL_MESSAGES.
  DATA lo_message_container TYPE REF TO if_genil_message_container.

  CHECK NOT it_genil_message IS INITIAL.
  CHECK io_entity IS BOUND.
  CHECK io_entity->alive( ) = abap_true.
  lo_message_container = io_entity->get_message_container( ).
  " Check if the message container bound to avoid dump in FPM
  CHECK lo_message_container IS BOUND.

  super->claim_genil_messages(
    EXPORTING
      io_entity        = io_entity
      it_genil_message = it_genil_message
  ).
ENDMETHOD.


METHOD CONSTRUCTOR.
  DATA:
    lo_fpm_toolbox_factory TYPE REF TO cl_bs_fpm_toolbox_factory.



  super->constructor( ).

  lo_fpm_toolbox_factory = cl_bs_fpm_toolbox_factory=>get_instance( ).
  me->mo_fpm_toolbox = lo_fpm_toolbox_factory->get_toolbox( ).
  me->mo_morph_config_supervisor = cl_bs_morph_config_supervisor=>get_instance( ).
ENDMETHOD.


METHOD CONVERT_UTC_TIMESTAMP.
*! This method converts an UTC Timestamp into a Timestamp according to the
*  user's local time zone.
  DATA:
    lv_date TYPE systdatlo,
    lv_time TYPE systtimlo,
    lv_zone TYPE tzonref-tzone.

  CONVERT TIME STAMP iv_timestamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time.
  CONVERT DATE lv_date TIME lv_time INTO TIME STAMP rv_timestamp TIME ZONE lv_zone.

ENDMETHOD.


  METHOD CREATE.
    DATA ls_delayed_change LIKE LINE OF me->mt_delayed_changes.

    ro_entity = super->create( iv_event_id = iv_event_id  is_create_ctrl = is_create_ctrl ).
    CHECK me->mo_how_to IS BOUND AND me->mo_how_to->mv_muted = abap_false.
    me->mo_how_to->set_muted( boolc( iv_event_id IS INITIAL ) ).
    me->mo_how_to->create( ro_entity ).
    me->mo_how_to->set_muted( abap_false ).
    CHECK me->mt_delayed_changes IS NOT INITIAL AND ro_entity IS BOUND.
    LOOP AT me->mt_delayed_changes INTO ls_delayed_change.
      ro_entity->set_property_as_string(
        iv_attr_name = ls_delayed_change-name
        iv_value = ls_delayed_change-value
      ).
    ENDLOOP.
    CHECK sy-subrc = 0.
    cl_crm_bol_core=>get_instance( )->modify( ).
    ro_entity->deactivate_sending( ).
    CLEAR me->mt_delayed_changes.
  ENDMETHOD.


METHOD CREATE_ENTITY.
  IF me->mv_momentum_for_undo > 0.
    DO me->mv_momentum_for_undo TIMES.
      me->get_fpm_instance( )->raise_event_by_id( cl_bs_do_guibb_bol=>gc_event-redo ).
    ENDDO.
    me->mv_momentum_for_undo = 0.
  ENDIF.
  ro_entity = super->create_entity(
    is_initial_data = is_initial_data
    is_create_control = is_create_control
  ).
ENDMETHOD.


METHOD CREATE_STRUCT_RTTI.
*  This method creates the field catalogue for the UIBBs built using
*  this feeder class. It determines description fields automatically
*  for all relevant fields (e.g. fields having domain fixed values or
*  check tables) by using the generic text assistance class.
  DATA:
    lt_components          TYPE cl_abap_structdescr=>component_table,
    lt_components_text     TYPE cl_abap_structdescr=>component_table,
    ls_component           LIKE LINE OF lt_components,
    lt_relevant_fields     TYPE mdg_mdf_t_fieldname,
    lt_text_field_id 	     TYPE mdg_mdf_ts_typename,
    ls_text_field_id       LIKE LINE OF lt_text_field_id,
    lv_attribute_structure TYPE wcf_attr_struct,
    lv_data_type           TYPE typename,
    lv_relevant_field      TYPE fieldname,
    lv_change_indicator    TYPE usmd_list_change_indicator,
    lo_elemdescr           TYPE REF TO cl_abap_elemdescr.

  FIELD-SYMBOLS:
    <ls_component> LIKE LINE OF lt_components.

  "inherit
  super->create_struct_rtti( ).

  "get attribute structure
  lv_attribute_structure = me->mv_struct_name.

  lt_components = me->mo_struct_rtti->get_components( ).

  "use the text helper to add text fields dynamically
  IF me->mo_text_assist IS BOUND.
    "get relevant fields
*    lt_components = me->mo_struct_rtti->get_components( ).
    lt_relevant_fields = me->mo_text_assist->get_text_relevant_attributes( lv_attribute_structure ).
    LOOP AT lt_relevant_fields INTO lv_relevant_field.
      "check if the field is used in the UI
      READ TABLE lt_components INTO ls_component
        WITH KEY name = lv_relevant_field.
      CHECK sy-subrc EQ 0.
      "get the text field information
      lv_data_type = ls_component-type->get_relative_name( ).
      lt_text_field_id = me->mo_text_assist->get_text_attribute(
                             iv_attr_structure = lv_attribute_structure
                             iv_data_type      = lv_data_type
                             iv_attribute      = lv_relevant_field ).
      " Add generated text fields
      LOOP AT lt_text_field_id INTO ls_text_field_id.
        APPEND INITIAL LINE TO lt_components_text ASSIGNING <ls_component>.
        <ls_component>-name = ls_text_field_id.
        <ls_component>-type = cl_abap_elemdescr=>get_string( ).
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  IF me->mv_multi_processing_list EQ abap_false.
    IF lt_components_text IS NOT INITIAL.
      APPEND LINES OF lt_components_text TO lt_components.
    ENDIF.
  ELSE.
*   multiple-records processing: keep entity structure to allow usage of assigned DDIC search help
    CLEAR lt_components.
    CLEAR ls_component.
    ls_component-name       = 'MDG_ENTITY'.
    ls_component-as_include = abap_true.
    ls_component-type       = me->mo_struct_rtti.
    INSERT ls_component INTO TABLE lt_components.
    IF lt_components_text IS NOT INITIAL.
      APPEND LINES OF lt_components_text TO lt_components.
    ENDIF.
  ENDIF.

* add the change indicator field for lists
  IF mv_disable_hc = abap_false.
    APPEND INITIAL LINE TO lt_components ASSIGNING <ls_component>.
    <ls_component>-name = if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator.
    lo_elemdescr ?= cl_abap_elemdescr=>describe_by_data( lv_change_indicator ).
    <ls_component>-type = lo_elemdescr.
  ENDIF.

  me->mo_struct_rtti = cl_abap_structdescr=>create( lt_components ).

ENDMETHOD.


METHOD DELETE_ENTITY.
  DATA:
    lo_message_container TYPE REF TO if_genil_message_container,
    lo_root_message_container TYPE REF TO if_genil_message_container.

  IF me->mv_momentum_for_undo > 0.
    DATA lo_fpm TYPE REF TO cl_fpm.
    lo_fpm ?= me->get_fpm_instance( ).
    IF lo_fpm->mo_current_event->mv_event_id = cl_bs_do_guibb_bol=>gc_event-undo.
      lo_fpm->if_fpm~raise_event_by_id( cl_bs_do_guibb_bol=>gc_event-redo ).
      SUBTRACT 1 FROM me->mv_momentum_for_undo.
    ENDIF.
  ENDIF.
  CHECK io_entity IS BOUND.
  CHECK io_entity->alive( ) = abap_true.
  CHECK io_entity->is_delete_allowed( ) = abap_true.

  lo_message_container = io_entity->get_message_container( ).
  IF lo_message_container IS NOT BOUND.
    lo_message_container = cl_crm_bol_core=>get_instance( )->get_global_message_cont( ).
  ENDIF.
  lo_root_message_container = io_entity->get_root( )->get_message_container( ).

  CALL METHOD super->delete_entity
    EXPORTING
      io_entity  = io_entity
    RECEIVING
      rv_success = rv_success.

  CHECK rv_success = abap_true.
  IF lo_message_container IS BOUND.
    lo_message_container->delete_messages(
      iv_object_name = io_entity->get_name( )
      iv_object_id = io_entity->get_key( )
    ).
  ENDIF.
  IF lo_root_message_container IS BOUND.
    " Delete coresponding messages from the root message container,
    " they have been provided by Genil
    lo_root_message_container->delete_messages(
      iv_object_name = io_entity->get_name( )
      iv_object_id = io_entity->get_key( )
    ).
  ENDIF.
  "HC_DEL: Set Indicator also for Sub-Classes
  IF mo_highlight_changes IS BOUND AND mo_mdg_api IS BOUND AND mv_disable_hc NE abap_true AND
     me->mo_highlight_changes->is_highlight_deletion_active( iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                                                             iv_crequest_step = me->mo_mdg_api->mv_wf_step ) = abap_true.
    mv_highlight_del_active = abap_true.
  ELSE.
    mv_highlight_del_active = abap_false.
  ENDIF.
ENDMETHOD.


METHOD DETERMINE_PBO_STATUS.

  " toh 2962256
  " The coding of this method was commented and the value of variable mv_pbo
  " is always set to FINAL. It's because the logic became obsolete and faulty
  " after SAP Note 2934986 was introduced. The background is following:
  " - method GET_DATA is called by FPM several times after each roundtrip
  "   (it depends on how many events are raised during that roundtrip)
  " - therefore, the paging note 2409026 introduced this logic - here the code
  "   checked whether there is some unfinished event in the queue (that means,
  "   if the GET_DATA method will be called again after this call):
  "   - if yes, then later in methods GET_COLLECTION_DATA_ATS and GET_ENTITY_DATA
  "     the data is not read completely to save some time
  " - however, note 2934986 now skips all those GET_DATA calls that are not necessary,
  "   so now there is one or max two calls of GET_DATA after each roundtrip, no matter
  "   how many events there are in the queue
  " - consequently, we always need to read the data completely including REF fields,
  "   otherwise the data is not displayed correctly. We achieve this by setting
  "   the variable mv_pbo = gc_pbo-final.
  me->mv_pbo = gc_pbo-final.

*    DATA lt_event_queue TYPE if_fpm=>ty_t_event_queue.
*
*    IF me->get_fpm_instance( ) IS BOUND.
*      me->get_fpm_instance( )->read_event_queue( IMPORTING et_event_queue = lt_event_queue ).
*      READ TABLE lt_event_queue TRANSPORTING NO FIELDS WITH KEY state = space.
*      IF sy-subrc EQ 0.
*        READ TABLE lt_event_queue TRANSPORTING NO FIELDS WITH KEY state = if_fpm_constants=>gc_event_result-failed.
*        IF sy-subrc EQ 0.
*          me->mv_pbo = gc_pbo-final.
*        ELSE.
*          me->mv_pbo = gc_pbo-preliminary.
*        ENDIF.
*      ELSE.
*        me->mv_pbo = gc_pbo-final.
*      ENDIF.
*    ENDIF.
ENDMETHOD.


  METHOD DISABLE_HIGHLIGHT_DELETIONS.
*! Disable highlight deletions by calling the corresponding object
*  method for the current object type.
    DATA:
      lo_connector TYPE REF TO cl_mdg_bs_connector_bol_rel,
      lo_root      TYPE REF TO cl_crm_bol_entity,
      ls_parameter TYPE crmt_name_value_pair,
      lt_parameter TYPE crmt_name_value_pair_tab.

    IF me->mo_connector IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.
        lo_connector ?= me->mo_connector.
        IF lo_connector IS BOUND
          AND lo_connector->get_parent( ) IS BOUND.
          lo_root = lo_connector->get_parent( )->get_root( ).
          IF lo_root IS BOUND
            AND lo_root->alive( ) EQ abap_true.
            CLEAR lt_parameter.
            ls_parameter-name = cl_mdg_bs_genil=>gc_method_parameter_name-object_name.
            ls_parameter-value = me->ms_object_key-object_name.
            INSERT ls_parameter INTO TABLE lt_parameter.
            lo_root->execute( iv_method_name = cl_mdg_bs_genil=>gc_method_name-disable_highlight_del
                              it_param       = lt_parameter ).
          ENDIF.
        ENDIF.
      CATCH cx_sy_move_cast_error cx_crm_genil_model_error cx_crm_bol_meth_exec_failed. "#EC NO_HANDLER
        "nothing to do
    ENDTRY.
  ENDMETHOD.


METHOD EVALUATE_PARAMETERS.
  DATA:
    lt_read_only_on_actions TYPE bst_read_only_on_actions,
    ls_labels_of_entity LIKE LINE OF me->mt_labels_of_entities,
    lo_directions TYPE REF TO if_scpl_directions.

  FIELD-SYMBOLS:
    <ls_parameter> LIKE LINE OF it_parameter,
    <data> TYPE any,
    <ls_join> LIKE LINE OF me->mt_join.



  super->evaluate_parameters( it_parameter ).
  IF me->mo_app_parameter IS BOUND.
    me->mo_app_parameter->get_value(
      EXPORTING iv_key = cl_mdg_bs_communicator_assist=>gc_parameter-action
      IMPORTING ev_value = me->mv_action
    ).
    TRANSLATE me->mv_action TO UPPER CASE.
  ENDIF.
  me->mo_morph_config_supervisor->propagate_parameter_list(
    is_uibb_instance = me->ms_instance_key
    it_parameters = it_parameter
  ).
  READ TABLE it_parameter ASSIGNING <ls_parameter>
       WITH KEY name = cl_mdg_bs_guibb_form=>gc_parameter-event_exclusion_per_action.
  IF sy-subrc = 0.
    ASSIGN <ls_parameter>-value->* TO <data>.
    IF sy-subrc = 0.
      me->mt_excluded_events_per_action = <data>.
      READ TABLE me->mt_excluded_events_per_action TRANSPORTING NO FIELDS
           WITH TABLE KEY logical_action = me->mv_action
                          event_id = cv_action_insert.
      IF sy-subrc = 0.
        me->mv_fast_entry_mode = cs_fast_entry_mode-not_active.
      ENDIF.
    ENDIF.
  ENDIF.
  READ TABLE it_parameter ASSIGNING <ls_parameter>
       WITH KEY name = cl_mdg_bs_guibb_form=>gc_parameter-read_mode_per_action.
  IF sy-subrc = 0.
    ASSIGN <ls_parameter>-value->* TO <data>.
    IF sy-subrc = 0.
      lt_read_only_on_actions = <data>.
      READ TABLE lt_read_only_on_actions TRANSPORTING NO FIELDS
           WITH KEY table_line = me->mv_action.
      IF sy-subrc = 0.
        me->mv_edit_mode = abap_false.
      ENDIF.
    ENDIF.
  ENDIF.
  CHECK me->ms_object_key-object_name IS NOT INITIAL.
  TRY.
      lo_directions = cl_scpl_screenplay=>get_license( ).
      lo_directions->select_location( me->mv_labels_scpl_location ).
      ls_labels_of_entity-name = me->ms_object_key-object_name.
      lo_directions->introduce_actor( iv_actor = cl_bs_bol_stylist=>gc_actor-entity_name  iv_text = ls_labels_of_entity-name ).
      lo_directions->and_action( cl_bs_bol_stylist=>gc_scene-labels ).
      lo_directions->closeup_of_actor(
        EXPORTING iv_actor = cl_bs_bol_stylist=>gc_actor-entity_name
        IMPORTING ev_makeup = ls_labels_of_entity-reference
      ).
      lo_directions->cut( ).
      CHECK ls_labels_of_entity-reference IS BOUND.
      INSERT ls_labels_of_entity INTO TABLE me->mt_labels_of_entities.
      LOOP AT me->mt_join ASSIGNING <ls_join>.
        ls_labels_of_entity-name = <ls_join>-object_name.
        lo_directions->introduce_actor( iv_actor = cl_bs_bol_stylist=>gc_actor-entity_name  iv_text = ls_labels_of_entity-name ).
        lo_directions->and_action( cl_bs_bol_stylist=>gc_scene-labels ).
        lo_directions->closeup_of_actor(
          EXPORTING iv_actor = cl_bs_bol_stylist=>gc_actor-entity_name
          IMPORTING ev_makeup = ls_labels_of_entity-reference
        ).
        lo_directions->cut( ).
        CHECK ls_labels_of_entity-reference IS BOUND.
        INSERT ls_labels_of_entity INTO TABLE me->mt_labels_of_entities.
      ENDLOOP.
    CATCH cx_crm_cic_parameter_error cx_crm_unsupported_object.
  ENDTRY.
ENDMETHOD.


METHOD FPM_BOL_HANDLE_MASS_EDIT_MODE.
  IF me->mo_how_to IS BOUND.
    me->mo_how_to->set_muted( abap_true ).
  ENDIF.
  super->fpm_bol_handle_mass_edit_mode(
    io_ext_control = io_ext_control
    it_data = it_data
    iv_event_id = iv_event_id
  ).
  IF me->mo_how_to IS BOUND.
    me->mo_how_to->set_muted( abap_false ).
  ENDIF.
ENDMETHOD.


METHOD GET_ACTIONS.
  FIELD-SYMBOLS:
  <ls_actiondef> LIKE LINE OF mt_actiondef.

  "call parent first
  super->get_actions( ).
  APPEND INITIAL LINE TO me->mt_actiondef ASSIGNING <ls_actiondef>.
  <ls_actiondef>-id = cl_mdg_bs_communicator_assist=>gc_event-bol_copy.
  <ls_actiondef>-tooltip = 'Copy'(006).
  <ls_actiondef>-text = 'Copy'(006).
  <ls_actiondef>-enabled = abap_true.
  <ls_actiondef>-exposable = abap_true.
  <ls_actiondef>-imagesrc = '~Icon/Copy'.
  <ls_actiondef>-disable_when_no_lead_sel = abap_true.
  <ls_actiondef>-is_implicit_edit = abap_true.
  <ls_actiondef>-event_param_strukname = 'BSS_EVENT_PARAMS'.

  "add the root create action
  READ TABLE mt_actiondef
    WITH KEY id = if_usmd_generic_bolui_const=>gc_action_create_root
    ASSIGNING <ls_actiondef>.
  IF sy-subrc NE 0.
    APPEND INITIAL LINE TO mt_actiondef ASSIGNING <ls_actiondef>.
    <ls_actiondef>-id = if_usmd_generic_bolui_const=>gc_action_create_root.
    <ls_actiondef>-text = text-005.
    <ls_actiondef>-imagesrc = '~Icon/NewItem'.
    <ls_actiondef>-visible = cl_wd_uielement=>e_visible-visible.
    <ls_actiondef>-enabled = abap_true.
    <ls_actiondef>-exposable = abap_true.
    <ls_actiondef>-is_implicit_edit = abap_true.
    <ls_actiondef>-event_param_strukname = 'BSS_EVENT_PARAMS'.
  ENDIF.

  APPEND INITIAL LINE TO me->mt_actiondef ASSIGNING <ls_actiondef>.
  <ls_actiondef>-id = 'ZDELFVISIBLE'.
  <ls_actiondef>-tooltip = '見えた'(006).
  <ls_actiondef>-text = 'そこだ'(006).
  <ls_actiondef>-enabled = abap_true.
  <ls_actiondef>-exposable = abap_true.
  <ls_actiondef>-imagesrc = '~Icon/edit'.
  <ls_actiondef>-disable_when_no_lead_sel = abap_true.
  <ls_actiondef>-is_implicit_edit = abap_true.
  <ls_actiondef>-event_param_strukname = 'BSS_EVENT_PARAMS'.

ENDMETHOD.


METHOD GET_ATTR_VALUE_SET.
*! This method determines the attribute value sets (a pair of key and text
*  values) for the given field.
  DATA:
    lo_entity      TYPE REF TO cl_crm_bol_entity,
    lo_genil_model TYPE REF TO if_genil_obj_model,
    lr_structure   TYPE REF TO data,
    lv_structure   TYPE strukname.

  FIELD-SYMBOLS:
    <ls_structure> TYPE any,
    <lv_value>     TYPE any.

  "determine the correct structure name
  CLEAR lv_structure.
  IF io_access IS BOUND.
    lo_entity ?= io_access.
    lv_structure = lo_entity->get_attr_struct_name( ).
  ENDIF.
  IF iv_object_name IS NOT INITIAL
    AND lv_structure IS INITIAL.
    TRY.
        lo_genil_model = cl_crm_genil_model_service=>get_runtime_model( ).
        lv_structure = lo_genil_model->get_attr_struct_name( iv_object_name = iv_object_name ).
      CATCH cx_crm_unsupported_object cx_crm_genil_general_error.
        lv_structure = me->mv_struct_name.
    ENDTRY.
  ENDIF.

  "filter generic fields
  IF lv_structure IS NOT INITIAL.
    CREATE DATA lr_structure TYPE (lv_structure).
    ASSIGN lr_structure->* TO <ls_structure>.
    ASSIGN COMPONENT iv_attr_name OF STRUCTURE <ls_structure> TO <lv_value>.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.
  ENDIF.

  "inherit
  super->get_attr_value_set(
    EXPORTING
      io_access      = io_access
      iv_object_name = iv_object_name
      iv_attr_name   = iv_attr_name
    IMPORTING
      et_value_set   = et_value_set ).
ENDMETHOD.


method GET_CHANGED_TRANSIENT_FIELDS ##NEEDED.
* To be implemented for mapping of transient field usage
* Add relevant entries from Import table to Returning and
* add transientfields fields in transient_mapping table of the line
* those fields automatically take over the tooltip & color of the real changed field
* you can also add new line into the table without object_name but with fieldname
* and saved/unsaved information - then there is no Tooltip set
endmethod.


method GET_DELETED_TRANSIENT_FIELDS       ##NEEDED.
* To be implemented for mapping of transient field usage
* Add relevant entries from Import table to Returning and
* add transientfields fields in transient_mapping table of the line
* those fields automatically take over the tooltip & color of the real deleted field
* you can also add new line into the table without object_name but with fieldname
* and saved/unsaved information - then there is no Tooltip set
endmethod.


METHOD GET_ENTITY_DATA.
*! This method fulfils several tasks.
*  - It handles the correct display of the change request icon
*  - It tries to retrieve values for generic text fields if the
*    related text field is visible in the UI. Texts are read from the
*    genIL text repository respectively the generic text helper.
  DATA:
    lo_entity              TYPE REF TO cl_crm_bol_entity,
    ls_field_ref           LIKE LINE OF mt_field_ref,
    lt_relevant_fields     TYPE mdg_mdf_t_fieldname,
    lt_text_field_id       TYPE mdg_mdf_ts_typename,
    lt_text_values         TYPE crmt_text_value_pair_tab,
    lt_sel                 TYPE usmd_ts_sel,
    lv_attribute_structure TYPE wcf_attr_struct,
    lv_entity              TYPE usmd_entity,
    lv_index               TYPE i,
    lv_relevant_field      TYPE fieldname,
    lv_text_field          TYPE fieldname.

  FIELD-SYMBOLS:
    <ls_text_value> LIKE LINE OF lt_text_values,
    <lv_enabled>    TYPE any,
    <lv_image>      TYPE any,
    <lv_key>        TYPE any,
    <lv_text>       TYPE any,
    <lv_tooltip>    TYPE any,
    <lv_visibility> TYPE any.

  "inherit
  super->get_entity_data(
    EXPORTING io_access = io_access
    CHANGING  cs_data   = cs_data ).
  IF me->mo_how_to IS BOUND.
    me->mo_how_to->set_feeder( me ).
    me->mo_how_to->initialize( io_access ).
    CLEAR me->mv_necessary_momentum.
  ENDIF.

  "handle the change request icon
  READ TABLE mt_field_ref INTO ls_field_ref
    WITH TABLE KEY name = cl_usmd_search_assist=>gc_field_names-crequest_pending.
  IF sy-subrc IS INITIAL.
    ASSIGN COMPONENT:
      ls_field_ref-visibility_ref OF STRUCTURE cs_data TO <lv_visibility>,
      cl_usmd_search_assist=>gc_field_names-sta_tooltip OF STRUCTURE cs_data TO <lv_tooltip>,
      cl_usmd_search_assist=>gc_field_names-crequest_pending OF STRUCTURE cs_data TO <lv_image>,
      ls_field_ref-enabled_ref OF STRUCTURE cs_data TO <lv_enabled>.

    IF mv_ats_list = abap_true.  "ATS list is in use
      IF <lv_visibility> IS NOT INITIAL.

        IF <lv_tooltip> IS ASSIGNED.
          <lv_tooltip> = TEXT-003.  "Pending Change Request
          <lv_image>   = cl_usmd_search_assist=>gc_field_names-icon_in_progress.
        ENDIF.

      ELSE.
        IF <lv_tooltip> IS ASSIGNED.
          <lv_tooltip> = TEXT-004.  "No Pending Change Request
          <lv_image>   = cl_usmd_search_assist=>gc_field_names-icon_empty.
        ENDIF.
      ENDIF.

      <lv_visibility> = abap_true.
      <lv_enabled>    = abap_true.
    ENDIF.
  ENDIF.

  "propert access is required
  CHECK io_access IS BOUND.
  TRY.
      lo_entity ?= io_access.
    CATCH cx_sy_move_cast_error.
      RETURN.
  ENDTRY.
  CHECK lo_entity IS BOUND.

  "convert time stamps
  ASSIGN COMPONENT if_usmd_generic_bolui_const=>gc_fieldname_usmd_created_at
    OF STRUCTURE cs_data TO <lv_text>.
  IF sy-subrc EQ 0 AND <lv_text> IS NOT INITIAL.
    <lv_text> = me->convert_utc_timestamp( <lv_text> ).
  ENDIF.
  ASSIGN COMPONENT if_usmd_generic_bolui_const=>gc_fieldname_usmd_changed_at
    OF STRUCTURE cs_data TO <lv_text>.
  IF sy-subrc EQ 0 AND <lv_text> IS NOT INITIAL.
    <lv_text> = me->convert_utc_timestamp( <lv_text> ).
  ENDIF.

  "prepare reading texts
  CHECK me->mo_text_assist IS BOUND.
  lv_attribute_structure = lo_entity->get_attr_struct_name( ).
  lt_relevant_fields = me->mo_text_assist->get_text_relevant_attributes( lv_attribute_structure ).

  "try to retrieve texts
  LOOP AT lt_relevant_fields INTO lv_relevant_field.
    "check if the field is used in the UI
    READ TABLE me->mt_edit_field TRANSPORTING NO FIELDS
      WITH KEY name = lv_relevant_field.
    CHECK sy-subrc EQ 0.
    "get relevant text fields
    lt_text_field_id = me->mo_text_assist->get_text_attribute(
                           iv_attr_structure = lv_attribute_structure
                           iv_attribute      = lv_relevant_field ).
    CLEAR lv_index.
    LOOP AT lt_text_field_id INTO lv_text_field.
      ADD 1 TO lv_index.
      ASSIGN COMPONENT lv_text_field OF STRUCTURE cs_data TO <lv_text>.
      CHECK sy-subrc EQ 0.
      IF lv_index EQ 1.
        "standard text field reads from genIL text repository
        TRY.
            <lv_text> = io_access->get_property_text( lv_relevant_field ).
          CATCH cx_genil_text_access_error.
            CONTINUE.
        ENDTRY.
      ELSE.
        "additional field read via text helper
        ASSIGN COMPONENT lv_relevant_field OF STRUCTURE cs_data TO <lv_key>.
        CHECK sy-subrc EQ 0.
        "special logic is needed if the relevant field actually relates
        "to an MDG entity type
        CLEAR: lt_sel, lv_entity.
        me->get_selection_for_texts(
          EXPORTING
            io_entity    = lo_entity
            iv_attribute = lv_relevant_field
            iv_value     = <lv_key>
          IMPORTING
            et_sel       = lt_sel
            ev_entity    = lv_entity ).
        IF lv_entity IS NOT INITIAL
          AND lt_sel IS INITIAL.
          "missing information to determine the valid text!
          CONTINUE.
        ENDIF.
        "get texts
        CLEAR lt_text_values.
        me->mo_text_assist->get_text_values_4_attribute(
          EXPORTING
            iv_attr_structure   = lv_attribute_structure
            iv_attribute        = lv_relevant_field
            iv_text_suffix      = substring_after( val = lv_text_field
                                                   sub = lv_relevant_field )
            it_sel              = lt_sel
          IMPORTING
            et_text_values      = lt_text_values ).
        READ TABLE lt_text_values ASSIGNING <ls_text_value>
          WITH KEY key = <lv_key>.
        CHECK sy-subrc EQ 0.
        <lv_text> = <ls_text_value>-text.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDMETHOD.


  METHOD GET_ENTITY_KEY_VALUES.
*! Return the current entity key values either from the given event or
*  entity.
    DATA:
      lv_parameter_name TYPE string,
      lv_attr_name      TYPE name_komp,
      lo_struc_descr    TYPE REF TO cl_abap_structdescr,
      lt_components     TYPE cl_abap_structdescr=>component_table,
      ls_component      LIKE LINE OF lt_components.

    FIELD-SYMBOLS <lv_field> TYPE any.

    CLEAR es_entity_key_values.

    lo_struc_descr ?= cl_abap_structdescr=>describe_by_data( es_entity_key_values ).
    lt_components = lo_struc_descr->get_components( ).
    LOOP AT lt_components INTO ls_component.
      ASSIGN COMPONENT ls_component-name OF STRUCTURE es_entity_key_values TO <lv_field>.
      IF sy-subrc = 0 AND <lv_field> IS ASSIGNED.

        IF io_event IS BOUND.
          lv_parameter_name = ls_component-name.
          me->mo_fpm_toolbox->get_event_context_data(
            EXPORTING
              io_event = io_event
              iv_name = lv_parameter_name
            IMPORTING
              ev_value = <lv_field>
          ).
        ENDIF.
        IF io_entity IS BOUND AND <lv_field> IS INITIAL.
          lv_attr_name = ls_component-name.
          io_entity->get_property_as_value(
            EXPORTING iv_attr_name = lv_attr_name
            IMPORTING ev_result = <lv_field>
          ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


METHOD GET_FIELD_UI_PROP.

  DATA:
    lv_dummy(8)        TYPE c  ##NEEDED,
    lv_name            TYPE name_komp,
    ls_property_origin TYPE s_field_ui_property.

  "Config Fields logic
  DATA ls_join_config   TYPE s_join_config.
  DATA lv_join_field    TYPE name_komp.
  DATA ls_join_attr     LIKE LINE OF mt_join_attr.
  DATA ls_config_fields LIKE LINE OF mt_config_fields.
  DATA :lv_Z0M0041   TYPE zzshgcd,
        lv_Z0BUKRS   TYPE bukrs,
        lv_Z0M0047Q  TYPE char10,
        lo_model     TYPE REF TO if_usmd_model_ext,
        ls_sel       TYPE usmd_s_sel,
        lt_sel       TYPE usmd_ts_sel,
        lv_structure TYPE REF TO data,
        lt_message   TYPE usmd_t_message,
        lv_zdelf     TYPE zdelf.

  FIELD-SYMBOLS : <lt_data> TYPE ANY TABLE.

  "First time build up Config Field table including Joint fields
  IF me->mt_config_fields IS INITIAL.
    INSERT LINES OF mt_config_field INTO TABLE mt_config_fields.

    LOOP AT mt_join_config INTO ls_join_config.
      LOOP AT ls_join_config-fields INTO lv_join_field.
        READ TABLE me->mt_join_attr INTO ls_join_attr WITH TABLE KEY join_attr
                                      COMPONENTS bol_attr_name = lv_join_field
                                                 join_id       = ls_join_config-join_id.
        IF sy-subrc = 0.
          ls_config_fields = ls_join_attr-name.
          INSERT ls_config_fields INTO TABLE mt_config_fields.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  rs_property = super->get_field_ui_prop(
    io_entity         = io_entity
    iv_attr_name      = iv_attr_name
    iv_change_allowed = iv_change_allowed
    is_prop           = is_prop
  ).
  CHECK me->mv_check_mutability = abap_true.
  IF io_entity IS BOUND AND io_entity->is_locked( ) = abap_false.
    rs_property-read_only = abap_true.
  ENDIF.

  "for generic texts check if field property from origin field is 'Hidden'
  IF iv_attr_name CS '__TXT'.
    SPLIT iv_attr_name AT '__TXT' INTO lv_name lv_dummy.

    ls_property_origin = super->get_field_ui_prop(
        io_entity         = io_entity
        iv_attr_name      = lv_name
        iv_change_allowed = iv_change_allowed
    ).
    rs_property-visible = ls_property_origin-visible.
  ENDIF.
  "custom start

  io_entity->get_property_as_value(
      EXPORTING
        iv_attr_name = 'ZDELF' "key of list entity
      IMPORTING
        ev_result    =  lv_zdelf ).

  IF lv_zdelf = abap_true.
    DATA et_event type IF_FPM=>TY_T_EVENT_QUEUE.
    DATA(lo_fpm) = cl_fpm_factory=>get_instance( ).
    CHECK lo_fpm IS BOUND.
    DATA(lt_event) = lo_fpm->get_runtime_info( ).
    lo_fpm->read_event_queue(
     IMPORTING
      et_event_queue = et_event ).

    DATA ls_event type IF_FPM=>ty_s_event_queue_entry.
    loop at et_event into ls_event.
      IF ls_event-id = 'ZDELFVISIBLE'.
       rs_property-visible = '02'.
      return.
      ENDIF.
    endloop.
    rs_property-visible = '01'.
  ENDIF.





*  IF io_entity IS NOT BOUND.
*    RETURN.
*  ELSE.
*    io_entity->get_property_as_value(
*      EXPORTING
*        iv_attr_name = 'Z0M0041' "key of list entity
*      IMPORTING
*        ev_result    = lv_Z0M0041 ).
*
*    io_entity->get_property_as_value(
*      EXPORTING
*        iv_attr_name = 'Z0BUKRS' "key of list entity
*      IMPORTING
*        ev_result    = lv_Z0BUKRS ).
*
*    io_entity->get_property_as_value(
*      EXPORTING
*        iv_attr_name = 'Z0M0047Q' "key of list entity
*      IMPORTING
*        ev_result    = lv_Z0M0047Q ).
*
*    IF lv_Z0M0041 IS INITIAL OR lv_Z0BUKRS IS INITIAL OR lv_Z0M0047Q IS INITIAL.
*      RETURN.
*    ELSE.
*      CALL METHOD cl_usmd_model_ext=>get_instance
*        EXPORTING
*          i_usmd_model = 'Z0'
*        IMPORTING
*          eo_instance  = lo_model.
*
*      CLEAR: ls_sel, lt_sel.
*      ls_sel-fieldname = 'Z0BUKRS'.
*      ls_sel-option = 'EQ'.
*      ls_sel-sign = 'I'.
*      ls_sel-low = lv_Z0BUKRS.
*      INSERT ls_sel INTO TABLE lt_sel.
*
*      ls_sel-fieldname = 'Z0M0041'.
*      ls_sel-option = 'EQ'.
*      ls_sel-sign = 'I'.
*      ls_sel-low = lv_Z0M0041.
*      INSERT ls_sel INTO TABLE lt_sel.
*
*      ls_sel-fieldname = 'Z0M0047Q'.
*      ls_sel-option = 'EQ'.
*      ls_sel-sign = 'I'.
*      ls_sel-low = lv_Z0M0047Q.
*      INSERT ls_sel INTO TABLE lt_sel.
*
*      CALL METHOD lo_model->create_data_reference
*        EXPORTING
*          i_fieldname = 'Z0M0047' "name of list entity
*          i_struct    = lo_model->gc_struct_key_attr
*        IMPORTING
*          er_data     = lv_structure.
*
*      ASSIGN lv_structure->* TO <lt_data>.
*
*      CALL METHOD lo_model->read_char_value
*        EXPORTING
*          i_fieldname = 'Z0M0047'
*          it_sel      = lt_sel
*          i_readmode  = '3'
*        IMPORTING
*          et_data     = <lt_data>.
*
*      CHECK <lt_data> IS ASSIGNED.
*      LOOP AT <lt_data> ASSIGNING FIELD-SYMBOL(<ls_data>).
*        ASSIGN COMPONENT <ls_data> OF STRUCTURE 'ZDELF' TO FIELD-SYMBOL(<zdelf>).
*        IF <zdelf> IS ASSIGNED AND <zdelf> = abap_true.
*          rs_property-visible = '01'.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.
  "custom end


ENDMETHOD.


METHOD GET_GENIL_MESSAGES.
  DATA lo_message_container TYPE REF TO if_genil_message_container.

  super->get_genil_messages(
    EXPORTING
      io_entity        = io_entity
      it_attr          = it_attr
    IMPORTING
      et_genil_message = et_genil_message
  ).

  CHECK et_genil_message[] IS INITIAL.
  CHECK io_entity IS BOUND.
  CHECK io_entity->alive( ) = abap_true.
  lo_message_container = io_entity->get_root( )->get_message_container( ).
  CHECK lo_message_container IS BOUND.
  IF lo_message_container->get_number_of_messages( lo_message_container->mt_all ) > 0.
    " Request messages from message container of the root
    et_genil_message = lo_message_container->get_messages_4_object(
      iv_object_name = io_entity->get_name( )
      iv_object_id   = io_entity->get_key( )
      it_attributes  = it_attr
      iv_for_display = abap_true ).
  ENDIF.

ENDMETHOD.


METHOD GET_INITIAL_DATA.
  "inherit
  rs_initial_data = super->get_initial_data( iv_event_id ).

  CASE iv_event_id.
    WHEN if_usmd_generic_bolui_const=>gc_action_create_root.
      "The root creation needs a specific handling w.r.t. to key fields. If
      "there is a parent and the parent keys are part of the child attributes,
      "related values shall be pre-defined.
      me->get_initial_data_create_root( CHANGING cs_initial_data = rs_initial_data ).

    WHEN OTHERS.
  ENDCASE.
ENDMETHOD.


METHOD GET_INITIAL_DATA_CREATE_ROOT.
*! This method determines initial data for the creation of a root object
*  triggered by a special event. If a parent entity can be determined
*  and if the parent keys are part of the child attributes, the related
*  values are used as pre-defined attributes of the child.
  DATA:
    lo_connector      TYPE REF TO cl_mdg_bs_connector_bol_assoc,
    lo_genil_model    TYPE REF TO if_genil_obj_model,
    lo_parent         TYPE REF TO cl_crm_bol_entity,
    lt_keys           TYPE crmt_attr_name_tab,
    lv_key            TYPE name_komp,
    lv_structure_name TYPE strukname.

  FIELD-SYMBOLS:
    <ls_attributes> TYPE any,
    <lv_value>      TYPE any.

  "determine the parent
  IF me->mo_connector IS BOUND.
    TRY.
        lo_connector ?= me->mo_connector.
      CATCH cx_sy_move_cast_error.
        RETURN.
    ENDTRY.
  ELSE.
    RETURN.
  ENDIF.
  IF lo_connector IS NOT BOUND.
    RETURN.
  ENDIF.
  lo_parent = lo_connector->get_parent( ).
  IF lo_parent IS NOT BOUND.
    RETURN.
  ENDIF.

  "determine the parent keys
  lo_genil_model = cl_crm_genil_model_service=>get_runtime_model( ).
  TRY.
      lv_structure_name = lo_genil_model->get_key_struct_name( lo_parent->get_name( ) ).
    CATCH cx_crm_unsupported_object.
      RETURN.
  ENDTRY.
  lt_keys = cl_usmd_generic_bolui_assist=>get_structure_components( iv_structure_name = lv_structure_name ).

  "determine the childs attribute structure
  CLEAR lv_structure_name.
  TRY.
      lv_structure_name = lo_genil_model->get_attr_struct_name( ms_object_key-object_name ).
    CATCH cx_crm_unsupported_object.
      RETURN.
  ENDTRY.
  CREATE DATA cs_initial_data-default_values TYPE (lv_structure_name).
  ASSIGN cs_initial_data-default_values->* TO <ls_attributes>.
  IF <ls_attributes> IS NOT ASSIGNED.
    RETURN.
  ENDIF.

  "determine and map the keys
  LOOP AT lt_keys INTO lv_key.
    ASSIGN COMPONENT lv_key OF STRUCTURE <ls_attributes> TO <lv_value>.
    IF sy-subrc EQ 0.
      lo_parent->get_property_as_value(
        EXPORTING iv_attr_name = lv_key
        IMPORTING ev_result    = <lv_value> ).
    ENDIF.
  ENDLOOP.

  "Enrich initial data with the information that the event was
  "triggered by the UI to prevent the incomplete key warning. Therefore
  "use the changed by field (not nice, but works...)
  ASSIGN COMPONENT if_usmd_generic_bolui_const=>gc_fieldname_usmd_changed_by
    OF STRUCTURE <ls_attributes> TO <lv_value>.
  IF sy-subrc EQ 0.
    <lv_value> = if_usmd_generic_bolui_const=>gc_no_message.
  ENDIF.
ENDMETHOD.


METHOD GET_LABEL_TEXT.
  FIELD-SYMBOLS <ls_dynamic_label> LIKE LINE OF me->mt_dynamic_labels.
  FIELD-SYMBOLS <ls_labels_of_entity> LIKE LINE OF me->mt_labels_of_entities.
  FIELD-SYMBOLS <ls_labels> TYPE any.
  FIELD-SYMBOLS <lv_label> TYPE string.

  rv_label_text = iv_label_text_usage.
  CHECK ( rv_label_text IS INITIAL OR me->mt_dynamic_labels IS NOT INITIAL OR me->mv_only_dynamic_labels = abap_true )
          AND iv_bol_object_name IS NOT INITIAL AND iv_bol_attribute_name IS NOT INITIAL.

  "Get the generated label
  READ TABLE me->mt_labels_of_entities ASSIGNING <ls_labels_of_entity> WITH TABLE KEY name = iv_bol_object_name.
  CHECK sy-subrc = 0.
  ASSIGN <ls_labels_of_entity>-reference->* TO <ls_labels>.
  CHECK sy-subrc = 0.
  ASSIGN COMPONENT iv_bol_attribute_name OF STRUCTURE <ls_labels> TO <lv_label>.
  CHECK sy-subrc = 0.

  IF rv_label_text IS INITIAL.
    "Use generated label instead of empty one
    rv_label_text = <lv_label>.
  ELSEIF me->mt_dynamic_labels IS NOT INITIAL OR me->mv_only_dynamic_labels = abap_true.
    "For defined cases also existing labels can be overwritten
    READ TABLE me->mt_dynamic_labels ASSIGNING <ls_dynamic_label> WITH TABLE KEY name = iv_bol_object_name.
    CHECK sy-subrc = 0.
    READ TABLE <ls_dynamic_label>-fields TRANSPORTING NO FIELDS WITH KEY table_line = iv_bol_attribute_name.
    CHECK sy-subrc = 0.
    rv_label_text = <lv_label>.
  ENDIF.
ENDMETHOD.


  method GET_MAIN_ENTITY_OF_LINE_BY_IDX.
    "This is the default implementation via Feeder-Collection
    if mo_collection is bound.
      ro_entity_bol = me->mo_collection->get_iterator( )->get_by_index( iv_index ).
    endif.
  endmethod.


METHOD GET_MESSAGES.
  FIELD-SYMBOLS <ls_msg> TYPE CRMT_GENIL_MESSAGE.
  rt_messages = super->get_messages( io_entity = io_entity   iv_index = iv_index ).
  IF me->mv_pbo = gc_pbo-final.
    APPEND LINES OF me->mt_fpm_messages TO rt_messages.
    CLEAR me->mt_fpm_messages.
  ELSE.
    LOOP AT mt_show_multi_message ASSIGNING <ls_msg> WHERE show_once is INITIAL.
      "Assure that stable GenIL MSGs are not collected before final PBO
      DELETE rt_messages WHERE msgid = <ls_msg>-id AND msgno = <ls_msg>-number.
      DELETE mt_show_multi_message.
    ENDLOOP.
    INSERT LINES OF rt_messages INTO TABLE me->mt_fpm_messages.
    CLEAR rt_messages.
  ENDIF.
ENDMETHOD.


  METHOD GET_SELECTION_FOR_TEXTS.
*! Determine the selection criteria for reading texts via the generic
*  text helper implementation. This is needed for text fields of
*  attributes that actually related to entity types in the MDG data
*  model.
    DATA:
      ls_attr2entity TYPE s_attr2entity,
      ls_sel         TYPE usmd_s_sel,
      lv_model       TYPE usmd_model.

    FIELD-SYMBOLS:
      <lv_attribute> TYPE usmd_attribute.

    CLEAR: et_sel, ev_entity.
    IF io_entity IS NOT BOUND
      OR iv_attribute IS INITIAL.
      RETURN.
    ENDIF.

    "check buffer
    READ TABLE me->mt_attr2entity INTO ls_attr2entity
      WITH KEY attribute = iv_attribute.
    IF sy-subrc NE 0.
      "transform attribute to entity type
      ls_attr2entity-attribute = iv_attribute.
      cl_usmd_generic_bolui_assist=>get_application_parameter(
        IMPORTING ev_model = lv_model ).
      ls_attr2entity-entity = cl_usmd_services=>fieldname2entity( i_fieldname = ls_attr2entity-attribute
                                                                  i_model     = lv_model ).
      IF ls_attr2entity-entity IS NOT INITIAL.
        "entity edition based?
        ls_attr2entity-edition = cl_usmd_generic_bolui_assist=>is_edition_based( iv_model  = lv_model
                                                                                 iv_entity = ls_attr2entity-entity ).
        "additional key attributes?
        ls_attr2entity-key_fields = cl_usmd_services=>get_entity_key_attributes( iv_model  = lv_model
                                                                                 iv_entity = ls_attr2entity-entity ).
        IF lines( ls_attr2entity-key_fields ) EQ 1.
          "the entity the only key field
          CLEAR ls_attr2entity-key_fields.
        ENDIF.
      ENDIF.
      "buffer
      INSERT ls_attr2entity INTO TABLE me->mt_attr2entity.
    ENDIF.

    "set entity
    ev_entity = ls_attr2entity-entity.
    IF ev_entity IS INITIAL.
      RETURN.
    ENDIF.

    "check if there is a key for the entity
    IF iv_value IS INITIAL.
      "no -> leave immediately
      RETURN.
    ELSE.
      "yes -> add to selection
      ls_sel-option = usmd0_cs_ra-option_eq.
      ls_sel-sign = usmd0_cs_ra-sign_i.
      ls_sel-fieldname = iv_attribute.   "note 2313404  before ev_entity
      ls_sel-low = iv_value.
      INSERT ls_sel INTO TABLE et_sel.
    ENDIF.

    "add the edition if required
    IF ls_attr2entity-edition EQ abap_true.
      TRY.
          ls_sel-fieldname = usmd0_cs_fld-edition.
          ls_sel-low = io_entity->get_property_as_string( iv_attr_name = |{ ls_sel-fieldname }| ).
          INSERT ls_sel INTO TABLE et_sel.
        CATCH cx_crm_cic_parameter_error.
          CLEAR et_sel.
          RETURN.
      ENDTRY.
    ENDIF.

    "check and add additional keys
    IF ls_attr2entity-key_fields IS INITIAL.
      RETURN.
    ENDIF.
    LOOP AT ls_attr2entity-key_fields ASSIGNING <lv_attribute>.
      CLEAR: ls_sel-fieldname, ls_sel-low.
      CHECK <lv_attribute> NE ev_entity.
      TRY.
          ls_sel-fieldname = <lv_attribute>.
          ls_sel-low = io_entity->get_property_as_string( iv_attr_name = |{ <lv_attribute> }| ).
          CHECK ls_sel-low IS NOT INITIAL.
          INSERT ls_sel INTO TABLE et_sel.
        CATCH cx_crm_cic_parameter_error.
          CONTINUE.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.


METHOD HANDLE_ENTITY_FOR_EDIT_REG.
  DATA: lo_context     TYPE REF TO if_usmd_app_context,
        lt_entity_name TYPE usmd_t_entity.
  DATA  ls_parameter   TYPE usmd_s_value.
  DATA: lo_bol         TYPE REF TO cl_fpm_bol_model,
        ls_tray        TYPE cl_bs_fpm_toolbox=>ty_uibb.

  lo_context = cl_usmd_app_context=>get_context( ).
  IF lo_context IS BOUND.
    lo_context->get_parameter(
      EXPORTING
        iv_parameter_name   = if_usmd_generic_bolui_const=>gc_uibb_id_triggering_edit
      IMPORTING
        ev_parameter_value  = ls_parameter-value
    ).

    CHECK ls_parameter-value IS NOT INITIAL.

    me->mo_fpm_toolbox->tray_of_uibb(
      EXPORTING
        iv_uibb_config_id  = me->ms_instance_key-config_id
*                iv_for_target_page = ABAP_TRUE
      RECEIVING
        rs_tray            = ls_tray
    ).

    "Only if this was the EDIT-triggering UIBB
    IF me->ms_instance_key-config_id = ls_parameter-value OR
       ls_tray-config_id = ls_parameter-value.
      lo_bol ?= me.
      cl_usmd_generic_bolui_assist=>get_entity_names_for_genil_obj(
        EXPORTING
          iv_component_name = lo_bol->ms_object_key-component_name    " GENIL Component Name
          iv_object_name    = lo_bol->ms_object_key-object_name    " External Name of GENIL Object
        RECEIVING
          et_entity_names   = lt_entity_name    " Entity Types
      ).
      me->mo_mdg_api->register_entity_names_for_edit( it_entity_name = lt_entity_name ).
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD HANDLE_HIGHLIGHT_CHANGES.
  DATA lv_is_new_entity TYPE abap_bool.
  DATA lt_parameters TYPE crmt_name_value_pair_tab.
  DATA ls_parameter LIKE LINE OF lt_parameters.
  DATA lv_index TYPE sytabix.
  DATA lo_collection TYPE REF TO if_bol_entity_col.
  DATA lo_main_entity TYPE REF TO cl_crm_bol_entity.
  DATA lo_entity TYPE REF TO cl_crm_bol_entity.
  DATA lr_changed_object TYPE REF TO usmd_s_changed_object.
  DATA lt_changed_objects TYPE usmd_t_changed_object.
  DATA lt_deleted_field TYPE usmd_ts_changed_fields_hc.
  DATA lt_changed_field TYPE usmd_ts_changed_fields_hc.
  DATA ls_changed_field LIKE LINE OF lt_changed_field.
  DATA lo_hndl TYPE REF TO if_fpm_list_ats_line_through.
  DATA lt_line_through_rows TYPE if_fpm_list_ats_line_through=>ty_t_rows.
  DATA ls_line_through TYPE if_fpm_list_ats_line_through=>ty_s_rows.
  DATA lr_changed_trans_mapping LIKE REF TO lt_changed_field.
  DATA lr_del_trans_mapping LIKE REF TO lt_changed_field.
  DATA ls_main_changed_object TYPE usmd_s_changed_object.
  DATA ls_changed_object TYPE usmd_s_changed_object.
  DATA lv_fieldname type string.

  FIELD-SYMBOLS <ls_field_usage> LIKE LINE OF ct_field_usage.
  FIELD-SYMBOLS <ct_data> TYPE INDEX TABLE.
  FIELD-SYMBOLS <ls_data> TYPE any.
  FIELD-SYMBOLS <lo_entity> TYPE REF TO cl_crm_bol_entity.
  FIELD-SYMBOLS <ls_changed_object> LIKE LINE OF lt_changed_objects.
  FIELD-SYMBOLS <ls_changed_attribute> LIKE LINE OF <ls_changed_object>-changed_attributes.
  FIELD-SYMBOLS <ls_join> LIKE LINE OF me->mt_join.
  FIELD-SYMBOLS <ls_join_attr> LIKE LINE OF me->mt_join_attr.
  FIELD-SYMBOLS <lv_change_indicator> type any.
  FIELD-SYMBOLS <lv_tooltip> type any.

  READ TABLE ct_field_usage ASSIGNING <ls_field_usage>
       WITH KEY name = if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator. "#EC WARNOK
  IF me->mo_highlight_changes IS BOUND AND me->mo_mdg_api IS BOUND
  AND me->mo_mdg_api->mv_crequest_type IS NOT INITIAL
  AND me->mv_disable_hc = abap_false
  AND me->mo_highlight_changes->is_highlight_changes_active(
        iv_crequest_type = me->mo_mdg_api->mv_crequest_type
        iv_crequest_step = me->mo_mdg_api->mv_wf_step ) = abap_true.
    IF <ls_field_usage> IS ASSIGNED AND <ls_field_usage>-visibility = if_fpm_constants=>gc_visibility-not_visible.
      <ls_field_usage>-visibility = if_fpm_constants=>gc_visibility-visible.
      cv_field_usage_changed = abap_true.
    ENDIF.
  ELSE.
    IF <ls_field_usage> IS ASSIGNED AND <ls_field_usage>-visibility = if_fpm_constants=>gc_visibility-visible.
      <ls_field_usage>-visibility = if_fpm_constants=>gc_visibility-not_visible.
      cv_field_usage_changed = abap_true.
    ENDIF.
    "HC_DEL - if nothing is active - assure no line striked through
    IF io_extended_control IS BOUND.
      lo_hndl = io_extended_control->get_line_through_handler( ).
      lo_hndl->set_line_through_rows( EXPORTING it_line_through_rows = lt_line_through_rows ).
    ENDIF.
    RETURN.
  ENDIF.
  TRY.
      lv_is_new_entity = me->mo_mdg_api->is_new_entity( ).
    CATCH cx_usmd_gov_api.
      lv_is_new_entity = abap_false.
  ENDTRY.
  " At the creation of (main) entities only unsaved changes are highlighted
  IF lv_is_new_entity = abap_true.
    ls_parameter-name = cl_mdg_bs_genil=>gc_method_parameter_name-saved_changes.
    ls_parameter-value = cl_mdg_bs_genil=>gc_method_parameter_value-false.
    INSERT ls_parameter INTO TABLE lt_parameters.
  ENDIF.

  CREATE OBJECT lo_collection TYPE cl_crm_bol_entity_col.

  ASSIGN ct_data TO <ct_data>.
  LOOP AT <ct_data> ASSIGNING <ls_data>.
    CLEAR: lt_changed_objects, ls_main_changed_object.
    lv_index = sy-tabix.
    IF me->ms_instance_key-component = 'FPM_LIST_UIBB_ATS'.
      ASSIGN COMPONENT 'FPM_KEY_BY_BOL_ENTITY' OF STRUCTURE <ls_data> TO <lo_entity>.
      lo_main_entity = <lo_entity>.
    ELSE.
      lo_main_entity = me->get_main_entity_of_line_by_idx( lv_index ).
    ENDIF.
    CHECK lo_main_entity IS BOUND.
    "Due to Accessibility default the change indicator picture
    ASSIGN COMPONENT if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator OF STRUCTURE <ls_data> TO <lv_change_indicator>.
    If sy-subrc = 0 and <lv_change_indicator> is INITIAL.
      <lv_change_indicator> = '~Icon/Empty'.
      lv_fieldname = if_usmd_generic_bolui_const=>gc_fieldname_prefix-tooltip && if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_data> TO <lv_tooltip>.
      If sy-subrc = 0.
        <lv_tooltip> = 'No Changes'(020).
      ENDIF.
      cv_data_changed = abap_true.
    ENDIF.

    lo_collection->clear( ).
    lo_collection->add( lo_main_entity ).
    LOOP AT mt_join ASSIGNING <ls_join>.
      lo_entity = me->get_joined_entity( io_entity = lo_main_entity  iv_join_id = <ls_join>-id ).
      CHECK lo_entity IS BOUND.
      lo_collection->add( lo_entity ).
    ENDLOOP.
    lo_entity = lo_collection->get_first( ).
    WHILE lo_entity IS BOUND.
      IF lo_entity->alive( ) EQ abap_false.
        lo_entity = lo_collection->get_next( ).
        CONTINUE.
      ENDIF.
      TRY.
          lr_changed_object ?= lo_entity->execute2(
                                 iv_method_name = cl_mdg_bs_genil=>gc_method_name-get_changes
                                 it_param = lt_parameters
                               ).
          IF lr_changed_object IS BOUND AND lo_entity = lo_main_entity.
            me->adjust_changed_object_info( exporting io_entity = lo_entity
                                                      iv_is_new_entity  = lv_is_new_entity
                                                      iv_main_entity    = abap_true
                                            changing  cs_changed_object = lr_changed_object->*
                                                      cs_data = <ls_data> ).
            IF lr_changed_object->* IS NOT INITIAL.
              ls_main_changed_object = lr_changed_object->*.
            ENDIF.
          ENDIF.
        CATCH cx_crm_bol_meth_exec_failed.
          CLEAR lr_changed_object.
      ENDTRY.
      IF lr_changed_object IS BOUND AND lr_changed_object->* IS NOT INITIAL. "Any kind of change reported
        IF lr_changed_object->*-object_name IS NOT INITIAL.
          me->set_change_indicator(
            EXPORTING io_entity = lo_entity
                      iv_is_new_entity = lv_is_new_entity
                      is_changed_object = lr_changed_object->*
            CHANGING cs_data = <ls_data>
                     cv_data_changed = cv_data_changed
          ).
          "HC_DEL
          IF lr_changed_object->*-object_name = me->ms_object_key-object_name AND
              lr_changed_object->*-crud = if_usmd_conv_som_gov_entity=>gc_crud_delete.
            ls_line_through-source_index = lv_index.
            INSERT ls_line_through INTO TABLE lt_line_through_rows.
          ENDIF.
        ENDIF.
        IF lr_changed_object->*-bol_entity IS INITIAL.
          lr_changed_object->*-bol_entity = lo_entity.
        ENDIF.
        APPEND lr_changed_object->* TO lt_changed_objects.
      ELSEIF lr_changed_object IS BOUND AND lr_changed_object->*-changed_attributes IS INITIAL.
        "Add existing Obj.with no Changes - to have no faulty defaulting
        CLEAR ls_changed_object.
        ls_changed_object-object_name = lo_entity->get_name( ).
        ls_changed_object-bol_entity = lo_entity.
        APPEND ls_changed_object TO lt_changed_objects.
      ENDIF.
      lo_entity = lo_collection->get_next( ).
    ENDWHILE.

    "In Main-Crea/DEL Case:Add not existing JoinedObj as changed Objs (without changes) for later defaulting props
    IF ls_main_changed_object-crud = if_usmd_conv_som_gov_entity=>gc_crud_delete OR
        ls_main_changed_object-crud = if_usmd_conv_som_gov_entity=>gc_crud_create.
      LOOP AT mt_join ASSIGNING <ls_join>.
        READ TABLE lt_changed_objects WITH KEY object_name = <ls_join>-object_name TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          CLEAR ls_changed_object.
          ls_changed_object-object_name = <ls_join>-object_name.
          ls_changed_object-crud = ls_main_changed_object-crud.
          ls_changed_object-unsaved_change = ls_main_changed_object-unsaved_change.
          ls_changed_object-saved_change = ls_main_changed_object-saved_change.
          ls_changed_object-bol_entity = me->get_joined_entity( io_entity = me->mo_entity  iv_join_id = <ls_join>-id ).
          APPEND ls_changed_object TO lt_changed_objects.
        ENDIF.
      ENDLOOP.
    ENDIF.


    CLEAR: lt_changed_field, lt_deleted_field.

    LOOP AT lt_changed_objects ASSIGNING <ls_changed_object>.
      " Build up internal table including relevant information for HC UI-changes
      LOOP AT <ls_changed_object>-changed_attributes ASSIGNING <ls_changed_attribute>.
        CLEAR: ls_changed_field.
        ls_changed_field-object_name = <ls_changed_object>-object_name.
        ls_changed_field-field_name = <ls_changed_attribute>-fieldname.
        ls_changed_field-bol_entity = <ls_changed_object>-bol_entity.
        MOVE-CORRESPONDING <ls_changed_attribute> TO ls_changed_field.

        " Convert fieldnames according to joins.
        READ TABLE me->mt_join ASSIGNING <ls_join> WITH KEY object COMPONENTS object_name = <ls_changed_object>-object_name.
        IF sy-subrc = 0 AND <ls_join>-id IS NOT INITIAL.
          READ TABLE me->mt_join_attr ASSIGNING <ls_join_attr> WITH TABLE KEY join_attr
                                      COMPONENTS bol_attr_name = <ls_changed_attribute>-fieldname
                                                 join_id = <ls_join>-id.
          IF sy-subrc = 0.
            ls_changed_field-ui_field = <ls_join_attr>-name.
          ELSE.
            ls_changed_field-ui_field = <ls_changed_attribute>-fieldname.
          ENDIF.
        ELSE.
          ls_changed_field-ui_field = <ls_changed_attribute>-fieldname.
        ENDIF.

        IF <ls_changed_object>-crud = if_usmd_conv_som_gov_entity=>gc_crud_delete AND mv_highlight_del_active = abap_true .
          ls_changed_field-color = me->mo_highlight_changes->get_color_of_deletion(
                                        iv_saved_change   = <ls_changed_object>-saved_change
                                        iv_unsaved_change = <ls_changed_object>-unsaved_change
                                        iv_crequest_type  = me->mo_mdg_api->mv_crequest_type
                                        iv_crequest_step  = me->mo_mdg_api->mv_wf_step ).

          ls_changed_field-tooltip = me->mo_highlight_changes->get_tooltip_for_deletion(
                                        iv_fieldname       = <ls_changed_attribute>-fieldname
                                        iv_value_active    = <ls_changed_attribute>-value_active
                                        iv_saved_change    = <ls_changed_object>-saved_change
                                        iv_unsaved_change  = <ls_changed_object>-unsaved_change
                                        iv_crequest_type   = me->mo_mdg_api->mv_crequest_type
                                        iv_crequest_step   = me->mo_mdg_api->mv_wf_step
                                        it_field_usage     = ct_field_usage
                                        it_selected_fields = it_selected_fields
                                        is_data            = <ls_data>  ).
        ELSE.
          ls_changed_field-color = me->mo_highlight_changes->get_color(
                                           iv_value_active = <ls_changed_attribute>-value_active
                                           iv_value_saved = <ls_changed_attribute>-value_saved
                                           iv_value_unsaved = <ls_changed_attribute>-value_unsaved
                                           iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                                           iv_crequest_step = me->mo_mdg_api->mv_wf_step
                                         ).

          ls_changed_field-tooltip = me->mo_highlight_changes->get_tooltip(
                                             iv_fieldname = ls_changed_field-ui_field
                                             iv_value_active = <ls_changed_attribute>-value_active
                                             iv_value_saved = <ls_changed_attribute>-value_saved
                                             iv_value_unsaved = <ls_changed_attribute>-value_unsaved
                                             iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                                             iv_crequest_step = me->mo_mdg_api->mv_wf_step
                                             it_field_usage = ct_field_usage
                                             it_selected_fields = it_selected_fields
                                             is_data = <ls_data>
                                           ).
        ENDIF.

        IF ls_changed_field-color = me->mo_highlight_changes->get_color_saved( ).
          ls_changed_field-saved = abap_true.
        ENDIF.

        TRY.
            IF <ls_changed_object>-crud = if_usmd_conv_som_gov_entity=>gc_crud_delete AND mv_highlight_del_active = 'X' .
              INSERT ls_changed_field INTO TABLE lt_deleted_field.
            ELSE.
              INSERT ls_changed_field INTO TABLE lt_changed_field.
            ENDIF.
          CATCH cx_sy_itab_duplicate_key.
            CONTINUE.
        ENDTRY.
      ENDLOOP.
    ENDLOOP.

    " Ask redefinitions of Applications for Transient Fields - CHANGE/CREATE Case.
    lr_changed_trans_mapping = me->get_changed_transient_fields( it_changed_fields = lt_changed_field ).
    me->mo_highlight_changes->include_transient_fields(
      EXPORTING  ir_trans_fields_mapping = lr_changed_trans_mapping
      CHANGING   ct_changed_field        = lt_changed_field
    ).

    " Ask redefinitions of Applications for Transient Fields - DELETION Case.
    IF lt_deleted_field IS NOT INITIAL AND mv_highlight_del_active = abap_true .
      lr_del_trans_mapping = me->get_deleted_transient_fields( it_deleted_fields = lt_deleted_field ).
      me->mo_highlight_changes->include_transient_fields(
        EXPORTING  ir_trans_fields_mapping = lr_del_trans_mapping
        CHANGING   ct_changed_field        = lt_deleted_field
      ).
    ENDIF.

    set_hc_configured_fields(
          EXPORTING    it_field_usage     = ct_field_usage
                       it_changed_field   = lt_changed_field
                       it_deleted_field   = lt_deleted_field
                       it_changed_objects = lt_changed_objects
                       it_selected_fields = it_selected_fields
                       iv_is_new_entity   = lv_is_new_entity
          CHANGING     cs_data            = <ls_data>
     ).

  ENDLOOP.

  "HC_DEL
  IF mv_highlight_del_active = abap_true AND io_extended_control IS BOUND.
    lo_hndl = io_extended_control->get_line_through_handler( ).
    lo_hndl->set_line_through_rows( EXPORTING it_line_through_rows = lt_line_through_rows ).
  ENDIF.
ENDMETHOD.


  METHOD HANDLE_SELECTION_DIALOG.
    " To be redefined, e.g. by using generic dialog handling of CL_MDG_BS_GUIBB_DDIC_LIST
    CLEAR et_list_of_fixings.
  ENDMETHOD.


  METHOD IF_BS_BOL_HOW_FEEDER~CURRENT_ENTITY.
    " Usualy called after deletion of an entity that made references in Do's buffer
    " invalid. Example of how to implement if needed:
*    IF me->mo_collection IS BOUND.
*      ro_entity = me->mo_collection->get_current( ).
*    ELSE.
*      ro_entity = me->mo_entity.
*    ENDIF.
  ENDMETHOD.


  METHOD IF_BS_BOL_HOW_FEEDER~DELETE_ENTITY.
    DATA lo_message_container1 TYPE REF TO if_genil_message_container.
    DATA lo_message_container2 TYPE REF TO if_genil_message_container.
    DATA lv_obj_name TYPE CRMT_EXT_OBJ_NAME.
    DATA lv_obj_id TYPE CRMT_GENIL_OBJECT_ID.

    CHECK io_entity IS BOUND.
    lo_message_container1 = io_entity->get_message_container( ).
    lo_message_container2 = io_entity->get_root( )->get_message_container( ).
    lv_obj_name = io_entity->get_name( ).
    lv_obj_id   = io_entity->get_key( ).
    rv_success = me->delete_entity( io_entity ).
    CHECK rv_success = abap_true.
    If lo_message_container1 IS BOUND.
      lo_message_container1->delete_messages(
        exporting
          iv_object_name = lv_obj_name
          iv_object_id   = lv_obj_id
      ).
    ENDIF.
    IF lo_message_container2 IS BOUND.
      lo_message_container2->delete_messages(
        exporting
          iv_object_name = lv_obj_name
          iv_object_id   = lv_obj_id
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
