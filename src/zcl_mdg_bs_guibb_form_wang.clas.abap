class ZCL_MDG_BS_GUIBB_FORM_WANG definition
  public
  inheriting from CL_GUIBB_BOL_FORM
  create public .

public section.
  type-pools USMD0 .

  interfaces IF_BS_BOL_HOW_FEEDER .

  types:
    BEGIN OF ty_s_labels_of_entity,
      name TYPE crmt_ext_obj_name,
      reference TYPE REF TO data,
    END OF ty_s_labels_of_entity .
  types:
    ty_t_labels_of_entities TYPE SORTED TABLE OF ty_s_labels_of_entity WITH UNIQUE KEY name .
  types:
    BEGIN OF ty_s_dynamic_label,
      name TYPE crmt_ext_obj_name,
      fields TYPE crmt_attr_name_tab,
    END OF ty_s_dynamic_label .
  types:
    ty_t_dynamic_labels TYPE SORTED TABLE OF ty_s_dynamic_label WITH UNIQUE KEY name .

  constants:
    begin of gc_parameter,
      event_exclusion_per_action type string value 'EVENT_EXCLUSION_PER_ACTION',
      read_mode_per_action type string value 'READ_MODE_PER_ACTION',
    end of gc_parameter .
  constants:
    begin of gc_parameter_type,
      event_exclusion_per_action type FIELD_TYPE value 'BST_EVENT_EXCLUSION',
      read_mode_per_action type FIELD_TYPE value 'BST_READ_ONLY_ON_ACTIONS',
    end of gc_parameter_type .

  methods CONSTRUCTOR .
  methods IS_GET_DATA_NECESSARY
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
    returning
      value(RV_RESULT) type ABAP_BOOL .

  methods IF_FPM_GUIBB_FORM~CHECK_CONFIG
    redefinition .
  methods IF_FPM_GUIBB_FORM~FLUSH
    redefinition .
  methods IF_FPM_GUIBB_FORM~GET_DATA
    redefinition .
  methods IF_FPM_GUIBB_FORM~GET_DEFAULT_CONFIG
    redefinition .
  methods IF_FPM_GUIBB_FORM~GET_DEFINITION
    redefinition .
  methods IF_FPM_GUIBB_FORM~PROCESS_EVENT
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

  data GT_PROPS type CL_CRM_BOL_ENTITY=>GTYPE_ATTR_PROPS_TAB .
  data MO_FPM_TOOLBOX type ref to CL_BS_FPM_TOOLBOX .
  data MO_HIGHLIGHT_CHANGES type ref to IF_USMD_HIGHLIGHT_CHANGES_API .
  data MO_HOW_TO type ref to CL_BS_DO_GUIBB_BOL .
  data MO_MORPH_CONFIG_SUPERVISOR type ref to IF_BS_MORPH_CONFIG_SUPERVISOR .
  data MO_TEXT_ASSIST type ref to CL_USMD_GENERIC_GENIL_TEXT .
  data MR_DATA type ref to DATA .
  data MS_INIT_ERROR type FPMGB_S_T100_MESSAGE .
  data MT_ATTR2ENTITY type TS_ATTR2ENTITY .
  data MT_CONFIG_FIELDS type CRMT_ATTR_NAME_TAB .
  data MT_DELAYED_CHANGES type CL_BS_DO_GUIBB_BOL=>TY_T_DELAYED_CHANGES .
  data MT_DYNAMIC_LABELS type TY_T_DYNAMIC_LABELS .
  data MT_EXCLUDED_EVENTS_PER_ACTION type BST_EVENT_EXCLUSION .
  data MT_LABELS_OF_ENTITIES type TY_T_LABELS_OF_ENTITIES .
  data MV_ACTION type USMD_ACTION .
  data MV_DEFERRED_CREATION type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_DISABLE_HC type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_HIGHLIGHT_DEL_ACTIVE type ABAP_BOOL .
  data MV_KEY_ALIAS_NAME type ABAP_COMPNAME .
  data MV_KEY_NAME type ABAP_COMPNAME .
  data MV_LABELS_SCPL_LOCATION type SCPL_LOCATION_ID value CL_BS_BOL_STYLIST=>GC_LOCATION ##NO_TEXT.
  data MV_ONLY_DYNAMIC_LABELS type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_REFRESH_DATA type ABAP_BOOL value ABAP_TRUE ##NO_TEXT.
  data MV_UNCHANGEABLE_KEYS type STRING .

  methods ASSIGN_SEARCH_HELPS
    changing
      !CT_FIELD_DESCRIPTION type FPMGB_T_FORMFIELD_DESCR .
  methods CHANGE_CONFIG_HIGHLIGHT_DELETE
    importing
      !IT_DELETED_FIELD type USMD_TS_CHANGED_FIELDS_HC
      !IT_CHANGED_OBJECT type USMD_T_CHANGED_OBJECT
      !IT_SELECTED_FIELDS type FPMGB_T_SELECTED_FIELDS
    changing
      !CT_FIELD_USAGE type FPMGB_T_FIELDUSAGE
      !CS_DATA type DATA
      !CV_DATA_CHANGED type ABAP_BOOL .
  methods CONVERT_UTC_TIMESTAMP
    importing
      !IV_TIMESTAMP type TIMESTAMP
    returning
      value(RV_TIMESTAMP) type TIMESTAMP .
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
  methods GET_LABEL_TEXT
    importing
      !IV_NAME type NAME_KOMP
      !IV_LABEL_TEXT_USAGE type STRING
      !IV_BOL_OBJECT_NAME type CRMT_EXT_OBJ_NAME optional
      !IV_BOL_ATTRIBUTE_NAME type NAME_KOMP optional
    returning
      value(RV_LABEL_TEXT) type STRING .
  methods GET_PARAMETERS_FOR_NAVIGATION
    importing
      !IV_WITH_EDITION type ABAP_BOOL default ABAP_FALSE
    returning
      value(RT_PARAMETERS) type TIHTTPNVP .
  methods GET_SELECTION_FOR_TEXTS
    importing
      !IO_ENTITY type ref to CL_CRM_BOL_ENTITY
      !IV_ATTRIBUTE type FIELDNAME
      !IV_VALUE type ANY
    exporting
      !ET_SEL type USMD_TS_SEL
      !EV_ENTITY type USMD_ENTITY .
  methods HANDLE_CANCEL_BUTTON
    importing
      !IO_EVENT type ref to CL_FPM_EVENT .
  methods HANDLE_ENTITY_FOR_EDIT_REG .
  methods HANDLE_HIGHLIGHT_CHANGES
    importing
      !IT_SELECTED_FIELDS type FPMGB_T_SELECTED_FIELDS
    changing
      !CT_FIELD_USAGE type FPMGB_T_FIELDUSAGE
      !CS_DATA type DATA
      !CV_DATA_CHANGED type ABAP_BOOL .
  methods ON_CR_REFRESH
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IV_RAISED_BY_OWN_UI type BOOLE_D optional
    exporting
      !EV_RESULT type FPM_EVENT_RESULT
      !ET_MESSAGES type FPMGB_T_MESSAGES .
  methods ON_DISPLAY_USER
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IV_RAISED_BY_OWN_UI type BOOLE_D optional
    exporting
      !EV_RESULT type FPM_EVENT_RESULT
      !ET_MESSAGES type FPMGB_T_MESSAGES .
  methods ON_MDG_CHANGE_DOCS
    importing
      !IO_EVENT type ref to CL_FPM_EVENT
      !IV_RAISED_BY_OWN_UI type BOOLE_D
    exporting
      !EV_RESULT type FPM_EVENT_RESULT
      !ET_MESSAGES type FPMGB_T_MESSAGES .
  methods PROVIDE_TOOLTIP_AND_COLOR
    importing
      !IS_CHANGED_OBJECT type USMD_S_CHANGED_OBJECT
      !IT_SELECTED_FIELDS type FPMGB_T_SELECTED_FIELDS
      !IV_HIGHLIGHT_DELETION type ABAP_BOOL
    exporting
      !ET_CHANGED_FIELD type USMD_TS_CHANGED_FIELDS_HC
      !ET_DELETED_FIELD type USMD_TS_CHANGED_FIELDS_HC
    changing
      !CS_DATA type DATA
      !CT_FIELD_USAGE type FPMGB_T_FIELDUSAGE .
  methods SET_DEFAULT_TOOLTIP
    importing
      !IT_FIELD_USAGE type FPMGB_T_FIELDUSAGE
      !IO_EXTENDED_CTRL type ref to IF_FPM_FORM_EXT_CTRL optional
    changing
      !CS_DATA type DATA
      !CV_DATA_CHANGED type ABAP_BOOL .
  methods SET_JOIN_CHILDREN_DATA
    importing
      !IO_ENTITY type ref to CL_CRM_BOL_ENTITY
      !IV_JOIN_ID type JOIN_ID optional
      !IS_DATA type DATA .
  methods SET_TAG
    importing
      !IV_TAG type WDY_TAG_NAME
      !I_VALUE type ANY .
  methods SET_UIBB_EXPLANATION
    importing
      !IV_EXPLANATION type FPM_EXPLANATION
      !IS_INSTANCE_KEY type FPM_S_UIBB_INSTANCE_KEY optional .
  methods SET_UIBB_EXPLANATION_DOC
    importing
      !IV_DOCUMENT type FPM_EXPLANATION_DOCUMENT
      !IS_INSTANCE_KEY type FPM_S_UIBB_INSTANCE_KEY optional .
  methods SET_VALUE_BY_MDG_NAME
    importing
      !IV_MDG_FIELDNAME type STRING
      !IV_VALUE type DATA
    changing
      !CS_DATA type DATA .

  methods CHECK_ACTION_USAGE
    redefinition .
  methods CHECK_ACTION_USAGE_SINGLE
    redefinition .
  methods CHECK_FIELD_USAGE
    redefinition .
  methods CHECK_FIELD_USAGE_SINGLE
    redefinition .
  methods CLAIM_GENIL_MESSAGES
    redefinition .
  methods CREATE
    redefinition .
  methods CREATE_STRUCT_RTTI
    redefinition .
  methods EVALUATE_PARAMETERS
    redefinition .
  methods GET_ACTIONS
    redefinition .
  methods GET_ATTR_TEXT
    redefinition .
  methods GET_ATTR_VALUE_SET
    redefinition .
  methods GET_ENTITY_DATA
    redefinition .
  methods GET_FIELD_PROPS_FOR_USAGE
    redefinition .
  methods GET_FIELD_UI_PROP
    redefinition .
  methods GET_GENIL_MESSAGES
    redefinition .
  methods LOCK
    redefinition .
  methods MODIFY_CNR_BUTTON
    redefinition .
  methods RAISE_LOCAL_EVENT_BY_ID
    redefinition .
  methods SET_ACCESS_ATTRIBUTE
    redefinition .
  methods SET_COLLECTION
    redefinition .
  methods TAP_CONNECTOR
    redefinition .
private section.

  data MO_MDG_API type ref to IF_USMD_CONV_SOM_GOV_API .
  data MO_MODEL_MAPPER type ref to CL_USMD_MODEL_MAPPING_SERVICE .
  data MO_ALL_FIELDS type FPMGB_T_FORMFIELD_DESCR .
  data MT_ENTITIES type USMD_T_ENTITY .
  data MT_MAPPING type USMD_TS_MAP_STRUC .
  data MO_COMP_NONTRANSIENT type ABAP_COMPDESCR_TAB .
ENDCLASS.



CLASS ZCL_MDG_BS_GUIBB_FORM_WANG IMPLEMENTATION.


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


  METHOD IF_BS_BOL_HOW_FEEDER~SET_ACCESS_ATTRIBUTE.
    DATA ls_delayed_change LIKE LINE OF me->mt_delayed_changes.

    me->set_access_attribute( io_access = io_access  iv_attr_name = iv_attr_name  iv_value = iv_value ).
    rv_gain_momentum = boolc( me->mv_unchangeable_keys IS NOT INITIAL AND contains( val = me->mv_unchangeable_keys  sub = iv_attr_name ) ).
    CHECK io_access IS NOT BOUND.
    ls_delayed_change-name = iv_attr_name.
    ls_delayed_change-value = iv_value.
    APPEND ls_delayed_change TO me->mt_delayed_changes.
  ENDMETHOD.


METHOD IF_FPM_GUIBB_FORM~CHECK_CONFIG.
  super->if_fpm_guibb_form~check_config(
    EXPORTING io_layout_config = io_layout_config
              io_layout_config_gl2 = io_layout_config_gl2
    IMPORTING et_messages = et_messages
  ).
  me->mo_morph_config_supervisor->validate_configuration(
    EXPORTING io_form_config = io_layout_config_gl2
    IMPORTING et_messages = et_messages
  ).
ENDMETHOD.


METHOD IF_FPM_GUIBB_FORM~FLUSH.
  DATA:
    lr_data TYPE REF TO data,
    lt_change_log LIKE it_change_log.

  FIELD-SYMBOLS:
    <ls_change_log> LIKE LINE OF lt_change_log,
    <is_data> TYPE any,
    <ls_data> TYPE any,
    <lv_key_value> TYPE any,
    <lv_key_alias_value> TYPE any.



  IF it_change_log IS NOT INITIAL AND me->mv_deferred_creation = abap_true.
    me->mo_how_to->create( me->mo_entity ).
    me->mv_deferred_creation = abap_false.
    me->mo_how_to->set_muted( abap_false ).
  ENDIF.
  IF me->mv_key_alias_name IS NOT INITIAL.
    lt_change_log = it_change_log.
    READ TABLE lt_change_log ASSIGNING <ls_change_log>
         WITH KEY name = me->mv_key_alias_name.
    IF sy-subrc = 0.
      ASSIGN is_data->* TO <is_data>.
      CREATE DATA lr_data LIKE <is_data>.
      ASSIGN lr_data->* TO <ls_data>.
      <ls_data> = <is_data>.
      ASSIGN COMPONENT me->mv_key_name OF STRUCTURE <ls_data> TO <lv_key_value>.
      ASSIGN COMPONENT me->mv_key_alias_name OF STRUCTURE <ls_data> TO <lv_key_alias_value>.
      <lv_key_value> = <lv_key_alias_value>.
      <ls_change_log>-name = me->mv_key_name.
      ASSIGN COMPONENT me->mv_key_name OF STRUCTURE <is_data> TO <lv_key_value>.
      GET REFERENCE OF <lv_key_value> INTO <ls_change_log>-old_value.
      super->if_fpm_guibb_form~flush(
        it_change_log = lt_change_log
        is_data       = lr_data
      ).
    ELSE.
      super->if_fpm_guibb_form~flush(
        it_change_log = it_change_log
        is_data       = is_data
      ).
    ENDIF.
  ELSE.
    super->if_fpm_guibb_form~flush(
      it_change_log = it_change_log
      is_data       = is_data
    ).
  ENDIF.

  IF it_change_log IS NOT INITIAL.
    me->mv_refresh_data = abap_true.
  ENDIF.
ENDMETHOD.


METHOD IF_FPM_GUIBB_FORM~GET_DATA.
  DATA:
    ls_initial_data        TYPE fpm_bol_initial_data,
    lo_rtti                TYPE REF TO cl_abap_structdescr,
    ls_component           LIKE LINE OF lo_rtti->components,
    lv_action              TYPE usmd_action,
    lv_dialog_box_id       TYPE string,
    lv_dialog_action_id    TYPE string,
    lv_crtype_popup_closed TYPE boole_d,
    lt_event               TYPE if_fpm=>ty_t_event_queue.

  FIELD-SYMBOLS:
    <ls_default_values>  TYPE any,
    <lv_default_value>   TYPE any,
    <lv_value>           TYPE any,
    <lv_key_value>       TYPE any,
    <lv_key_alias_value> TYPE any.

  IF me->is_get_data_necessary( io_event = io_event ) = abap_false.
    me->handle_cancel_button( io_event = io_event ).
    RETURN.
  ENDIF.

  IF io_event->mv_event_id = if_fpm_constants=>gc_event-leave_initial_screen
  OR io_event->mv_event_id = if_fpm_constants=>gc_event-call_default_edit_page
  OR io_event->mv_event_id = if_fpm_constants=>gc_event-call_suboverview_page
  OR io_event->mv_event_id = if_fpm_constants=>gc_event-local_edit
  OR io_event->mv_event_id = '_CREA_'
  OR me->mv_fpm_edit_mode <> iv_edit_mode.
    me->mv_refresh_data = abap_true.
  ENDIF.
  IF me->mv_fpm_edit_mode <> if_fpm_constants=>gc_edit_mode-read_only
  AND io_event->mv_event_id = if_fpm_constants=>gc_event-done_and_back_to_main.
    me->mv_refresh_data = abap_true.
  ENDIF.
  IF iv_raised_by_own_ui = abap_true
  AND io_event->mv_is_implicit_edit = abap_true.
    me->mv_refresh_data = abap_true.
  ENDIF.

  "HC_DEL: Set Indicator also for Sub-Classes
  IF mo_highlight_changes IS BOUND AND mo_mdg_api IS BOUND AND mv_disable_hc NE abap_true AND
     me->mo_highlight_changes->is_highlight_deletion_active( iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                                                             iv_crequest_step = me->mo_mdg_api->mv_wf_step ) = abap_true.
    mv_highlight_del_active = abap_true.
  ELSE.
    mv_highlight_del_active = abap_false.
  ENDIF.

  super->if_fpm_guibb_form~get_data(
    EXPORTING
      io_event                = io_event
      it_selected_fields      = it_selected_fields
      iv_raised_by_own_ui     = iv_raised_by_own_ui
      iv_edit_mode            = iv_edit_mode
    IMPORTING
      et_messages             = et_messages
      ev_data_changed         = ev_data_changed
      ev_field_usage_changed  = ev_field_usage_changed
      ev_action_usage_changed = ev_action_usage_changed
    CHANGING
      cs_data                 = cs_data
      ct_field_usage          = ct_field_usage
      ct_action_usage         = ct_action_usage
  ).

  me->set_default_tooltip(
    EXPORTING it_field_usage = ct_field_usage
              io_extended_ctrl = io_extended_ctrl
    CHANGING cs_data = cs_data
             cv_data_changed = ev_data_changed
  ).

  IF me->mv_key_alias_name IS NOT INITIAL.
    ASSIGN COMPONENT me->mv_key_name OF STRUCTURE cs_data TO <lv_key_value>.
    ASSIGN COMPONENT me->mv_key_alias_name OF STRUCTURE cs_data TO <lv_key_alias_value>.
    IF me->mo_mdg_api->is_tmp_key( me->mo_mdg_api->get_main_entity( ) ) = abap_true.
      IF <lv_key_alias_value> IS NOT INITIAL.
        CLEAR <lv_key_alias_value>.
        ev_data_changed = abap_true.
      ENDIF.
    ELSE.
      IF <lv_key_alias_value> <> <lv_key_value>.
        <lv_key_alias_value> = <lv_key_value>.
        ev_data_changed = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.

  IF me->mo_mdg_api IS BOUND.
    IF me->mo_mdg_api->mv_crequest_type_slg = abap_false AND me->mo_mdg_api->mv_crequest_locked = abap_false.
      me->mv_refresh_data = abap_true.
    ELSE.
      me->mv_refresh_data = abap_false.
    ENDIF.
  ELSE.
    me->mv_refresh_data = abap_false.
  ENDIF.

  IF io_event->mv_event_id = if_fpm_constants=>gc_event-leave_initial_screen
  AND me->mo_entity IS BOUND AND me->mo_entity->is_changeable( ) = abap_true.
    ls_initial_data = me->get_initial_data( io_event->mv_event_id ).
    IF ls_initial_data-default_values IS BOUND.
      ASSIGN ls_initial_data-default_values->* TO <ls_default_values>.
      IF sy-subrc = 0 AND <ls_default_values> IS NOT INITIAL.
        lo_rtti ?= cl_abap_structdescr=>describe_by_data_ref( ls_initial_data-default_values ).
        LOOP AT lo_rtti->components INTO ls_component.
          ASSIGN COMPONENT ls_component-name OF STRUCTURE <ls_default_values> TO <lv_default_value>.
          CHECK <lv_default_value> IS NOT INITIAL.
          ASSIGN COMPONENT ls_component-name OF STRUCTURE cs_data TO <lv_value>.
          CHECK sy-subrc = 0 AND <lv_value> IS INITIAL.
          <lv_value> = <lv_default_value>.
        ENDLOOP.
        me->mo_entity->set_properties( cs_data ).
        me->set_join_children_data(
          io_entity = me->mo_entity
          is_data = cs_data
        ).
        ev_data_changed = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.

  IF io_event->mv_event_id = if_fpm_constants=>gc_event-close_dialog AND
     cl_usmd_generic_bolui_assist=>is_generic_component( iv_component_name = me->ms_object_key-component_name ) EQ abap_true.
    "If the CR Type popup was displayed at start of application (since CR type was missing)
    "and is closed now, we should check whether we should raise a FPM_EDIT event although
    "the current event is neither FPM_START nor FPM_LEAVE_INITIAL_SCREEN.
    io_event->mo_event_data->get_value(
      EXPORTING iv_key   = if_fpm_constants=>gc_dialog_box-id
      IMPORTING ev_value = lv_dialog_box_id ).
    IF lv_dialog_box_id = cl_mdg_bs_communicator_assist=>gc_dialog_box-multiple_cr_types.
      io_event->mo_event_data->get_value(
        EXPORTING iv_key   = if_fpm_constants=>gc_dialog_box-dialog_buton_key
        IMPORTING ev_value = lv_dialog_action_id ).
      IF lv_dialog_action_id = if_fpm_constants=>gc_dialog_action_id-ok.
        me->mo_fpm_toolbox->mo_fpm->read_event_queue( IMPORTING et_event_queue = lt_event ).
        READ TABLE lt_event TRANSPORTING NO FIELDS
          WITH KEY id    = cl_mdg_bs_communicator_assist=>gc_event-defere_start
                   state = space.
        IF sy-subrc = 0.
          lv_crtype_popup_closed = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ( io_event->mv_event_id = if_fpm_constants=>gc_event-leave_initial_screen OR
       io_event->mv_event_id = if_fpm_constants=>gc_event-start OR
       lv_crtype_popup_closed = abap_true )
      AND cl_usmd_generic_bolui_assist=>is_generic_component( iv_component_name = me->ms_object_key-component_name ) EQ abap_true.
    me->mo_app_parameter->get_value(
      EXPORTING iv_key   = 'ACTION'
      IMPORTING ev_value = lv_action
    ).
    IF me->mo_entity IS BOUND.
      IF me->mo_entity->is_changeable( ) = abap_true
      OR lv_action = 'BLOCK' OR lv_action = 'DELETE' OR lv_action = 'CHANGE'.
        me->raise_local_event_by_id( if_fpm_constants=>gc_event-edit ).
      ENDIF.
    ENDIF.
  ENDIF.

  me->handle_cancel_button( io_event = io_event ).

  me->handle_highlight_changes(
    EXPORTING it_selected_fields = it_selected_fields
    CHANGING cs_data = cs_data
             ct_field_usage = ct_field_usage
             cv_data_changed = ev_data_changed
  ).
FIELD-SYMBOLS <ls_data> type any.
ASSIGN cs_data to <ls_data>.
ASSIGN COMPONENT 'Z0LAND141__TXT3' of STRUCTURE <ls_data> to FIELD-SYMBOL(<ls_value>).
<ls_value> = 'https://google.co.jp'.
ev_data_changed = abap_true.

ENDMETHOD.


METHOD IF_FPM_GUIBB_FORM~GET_DEFAULT_CONFIG.

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
                                   OR    text = cl_mdg_bs_genil=>gc_method_name-get_changes
                                   OR    id   = if_usmd_generic_bolui_const=>gc_action_display_user.
    lv_index = sy-tabix.
    APPEND <ls_actiondef> TO lt_actiondef.
    DELETE mt_actiondef INDEX lv_index."FROM <ls_actiondef>.
  ENDLOOP.

  "inherit
  super->if_fpm_guibb_form~get_default_config(
      io_layout_config     = io_layout_config
      io_layout_config_gl2 = io_layout_config_gl2 ) .

  APPEND LINES OF lt_actiondef TO mt_actiondef.
ENDMETHOD.


METHOD IF_FPM_GUIBB_FORM~GET_DEFINITION.

  DATA lv_string            TYPE string.
  DATA lv_text_field_name   TYPE name_komp.
  DATA lo_elem_descr        TYPE REF TO cl_abap_elemdescr.
  DATA lo_elem_descr_tlt    TYPE REF TO cl_abap_elemdescr.
  DATA ls_component         TYPE abap_componentdescr.
  DATA ls_field_descr       TYPE fpmgb_s_formfield_descr.
  DATA lt_component         TYPE abap_component_tab.
  DATA lt_field_descr_col   TYPE fpmgb_t_formfield_descr.
  DATA lt_field_descr_tlt   TYPE fpmgb_t_formfield_descr.

  FIELD-SYMBOLS <ls_field_description>     TYPE fpmgb_s_formfield_descr.
  FIELD-SYMBOLS <ls_field_description_txt> TYPE fpmgb_s_formfield_descr.

  "Check for issue during the initialize phase. If there are any, report
  "them and prevent further processing.
  IF me->ms_init_error IS NOT INITIAL.
    es_message = me->ms_init_error.
    RETURN.
  ENDIF.

  "inherit
  super->if_fpm_guibb_form~get_definition(
    IMPORTING
      es_message               = es_message
      eo_field_catalog         = eo_field_catalog
      et_field_description     = et_field_description
      et_action_definition     = et_action_definition
      et_special_groups        = et_special_groups
      ev_additional_error_info = ev_additional_error_info
      et_dnd_definition        = et_dnd_definition ).

  mo_all_fields = et_field_description .
  SORT mo_all_fields BY name. "contains transient fields and fields of joined structures

* Handle Highlight Changes
  IF me->is_design_time( ) = abap_false AND mv_disable_hc = abap_false.

    lo_elem_descr ?= cl_abap_elemdescr=>describe_by_name( if_usmd_mc_assist_ui=>gc_de_wdui_table_cell_design ).
    lo_elem_descr_tlt ?= cl_abap_elemdescr=>describe_by_data( lv_string ).
    lt_component  = eo_field_catalog->get_components( ).

    LOOP AT et_field_description ASSIGNING <ls_field_description> WHERE technical_field = abap_false.

* add field for colour
      IF cl_usmd_switch_check=>gv_framework_switch5 = abap_true.
        CLEAR ls_field_descr.
        ls_field_descr-name = me->mo_highlight_changes->add_col_prefix( <ls_field_description>-name ).
        ls_field_descr-technical_field = abap_true.
        INSERT ls_field_descr INTO TABLE lt_field_descr_col.
        <ls_field_description>-semantic_color_ref = ls_field_descr-name .

        DO 3 TIMES.
          CASE sy-index.
            WHEN 1.
              lv_text_field_name = <ls_field_description>-name && '__TXT'.
            WHEN 2.
              lv_text_field_name = <ls_field_description>-name && '__TXT2'.
            WHEN OTHERS.
              lv_text_field_name = <ls_field_description>-name && '__TXT3'.
          ENDCASE.
          READ TABLE et_field_description ASSIGNING <ls_field_description_txt>
             WITH KEY name = lv_text_field_name.
          IF sy-subrc = 0.
            <ls_field_description_txt>-semantic_color_ref = ls_field_descr-name.
          ENDIF.
        ENDDO.

        CLEAR ls_component.
        ls_component-name = ls_field_descr-name.
        ls_component-type = lo_elem_descr.
        INSERT ls_component INTO TABLE lt_component.
      ENDIF.

* add field for tooltip
      CLEAR ls_field_descr.
      ls_field_descr-name = me->mo_highlight_changes->add_tlt_prefix( <ls_field_description>-name ).
      ls_field_descr-technical_field = abap_true.
      INSERT ls_field_descr INTO TABLE lt_field_descr_tlt.
      <ls_field_description>-tooltip_ref = ls_field_descr-name.
      <ls_field_description>-tooltip_ref_enforced = abap_true.

      CLEAR ls_component.
      ls_component-name = ls_field_descr-name.
      ls_component-type = lo_elem_descr_tlt.
      INSERT ls_component INTO TABLE lt_component.
    ENDLOOP.

    APPEND LINES OF lt_field_descr_col TO et_field_description.
    APPEND LINES OF lt_field_descr_tlt TO et_field_description.

* add column field to field catalog
    eo_field_catalog  = cl_abap_structdescr=>create( lt_component ).
  ENDIF.

  "in design time hidden (invisible) fields must not be added to the field catalog
  IF me->is_design_time( ) EQ abap_true.
    LOOP AT et_field_description ASSIGNING <ls_field_description>
      WHERE visibility EQ if_fpm_constants=>gc_visibility-not_visible.
      <ls_field_description>-technical_field = abap_true.
    ENDLOOP.
  ENDIF.

  "Assign search helps
  me->assign_search_helps( CHANGING ct_field_description = et_field_description ).

ENDMETHOD.


METHOD IF_FPM_GUIBB_FORM~PROCESS_EVENT.
*! This method is the handler for events triggered on the UI (e.g. via
*  buttons and/or links).
  CASE io_event->mv_event_id.
    WHEN cl_usmd_cr_guibb_general_data=>cv_action_refresh.
      me->on_cr_refresh(
        EXPORTING
          io_event            = io_event
          iv_raised_by_own_ui = iv_raised_by_own_ui
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages ).

    WHEN if_usmd_generic_bolui_const=>gc_action_display_user.
      me->on_display_user(
      EXPORTING
        io_event            = io_event
        iv_raised_by_own_ui = iv_raised_by_own_ui
      IMPORTING
        ev_result           = ev_result
        et_messages         = et_messages ).

    WHEN cl_mdg_bs_communicator_assist=>gc_event-filter_cr_types1.
      "This Event is e.g. fired before a CR-Type PopUp is opened

      "Check if specific entity have to be registered for processing
      me->handle_entity_for_edit_reg( ).

    WHEN 'MDG_CHANGE_DOCS'.
        me->on_mdg_change_docs(
          EXPORTING
            io_event            = io_event
            iv_raised_by_own_ui = iv_raised_by_own_ui
          IMPORTING
            ev_result           = ev_result
            et_messages         = et_messages ).

    WHEN OTHERS.
      super->if_fpm_guibb_form~process_event(
        EXPORTING
          io_event            = io_event
          iv_raised_by_own_ui = iv_raised_by_own_ui
        IMPORTING
          ev_result           = ev_result
          et_messages         = et_messages ).
  ENDCASE.

  IF iv_raised_by_own_ui = abap_true AND io_event->mv_is_implicit_edit = abap_true.
    me->mv_refresh_data = abap_true.
  ENDIF.
ENDMETHOD.


METHOD IF_FPM_GUIBB~GET_PARAMETER_LIST.
  FIELD-SYMBOLS:
    <ls_parameter_description> LIKE LINE OF rt_parameter_descr.



  rt_parameter_descr = super->if_fpm_guibb~get_parameter_list( ).
  me->mo_morph_config_supervisor->enhance_parameter_list( CHANGING ct_parameters = rt_parameter_descr ).
  APPEND INITIAL LINE TO rt_parameter_descr ASSIGNING <ls_parameter_description>.
  <ls_parameter_description>-name = gc_parameter-read_mode_per_action.
  <ls_parameter_description>-type = gc_parameter_type-read_mode_per_action.
  <ls_parameter_description>-render_plug_in = abap_true.
  APPEND INITIAL LINE TO rt_parameter_descr ASSIGNING <ls_parameter_description>.
  <ls_parameter_description>-name = gc_parameter-event_exclusion_per_action.
  <ls_parameter_description>-type = gc_parameter_type-event_exclusion_per_action.
  <ls_parameter_description>-render_plug_in = abap_true.
ENDMETHOD.


METHOD IF_FPM_GUIBB~INITIALIZE.
  DATA:
    lv_stuff          TYPE do_stuff,
    lr_component_name TYPE REF TO crmt_component_name,
    lr_object_name    TYPE REF TO crmt_ext_obj_name,
    ls_parameter      LIKE LINE OF it_parameter,
    lt_entities       LIKE me->mt_entities,
    lt_mapping        LIKE me->mt_mapping,
    lv_model          TYPE usmd_model,
    lv_set            TYPE crmt_genil_appl,
    lo_struct_rtti    TYPE REF TO  cl_abap_structdescr.

  FIELD-SYMBOLS:
    <ls_join> LIKE LINE OF me->mt_join.



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
    "determine current model
    cl_usmd_generic_bolui_assist=>get_application_parameter(
      EXPORTING it_parameter = it_parameter
      IMPORTING ev_model     = lv_model ).
    "determine related component set
    lv_set = cl_usmd_generic_bolui_assist=>get_default_genil_comp_set( iv_component = lr_component_name->* ).
    "check structures
    TRY.
        IF cl_crm_genil_model_service=>get_runtime_model( iv_application = lv_set )->get_key_struct_name( lr_object_name->* ) IS INITIAL.
          MESSAGE e001(usmd_generic_bolui)
            WITH lr_object_name->* lr_component_name->* lv_model
            INTO me->ms_init_error-plaintext.
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
        me->mo_model_mapper = cl_usmd_model_mapping_service=>get_instance( ).
        me->mo_text_assist = cl_usmd_generic_genil_text=>get_instance( iv_model = me->mo_mdg_api->mv_model_name ).
      ENDIF.
    CATCH cx_usmd_conv_som_gov_api ##NO_HANDLER.
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

  IF me->mo_model_mapper IS BOUND AND me->is_design_time( ) = abap_false.
    me->mo_model_mapper->get_entities_for_structure(
      EXPORTING iv_strucname = me->mv_struct_name
      IMPORTING et_entities = me->mt_entities
                et_mapping_table = me->mt_mapping
    ).
    LOOP AT me->mt_join ASSIGNING <ls_join>.
      me->mo_model_mapper->get_entities_for_structure(
        EXPORTING iv_strucname = cl_crm_genil_model_service=>get_runtime_model( )->get_attr_struct_name( <ls_join>-object_name )
        IMPORTING et_entities = lt_entities
                  et_mapping_table = lt_mapping
      ).
      APPEND LINES OF lt_entities TO me->mt_entities.
      APPEND LINES OF lt_mapping TO me->mt_mapping.
    ENDLOOP.
  ENDIF.

  IF mo_highlight_changes IS NOT BOUND.
    mo_highlight_changes = cl_usmd_highlight_changes_api=>get_instance( ).
  ENDIF.

  IF me->mo_highlight_changes IS BOUND AND
     me->mo_highlight_changes->get_hc_status_by_usr_appl_para( ) = abap_false.
    mv_disable_hc = abap_true.
  ENDIF.

  IF mv_struct_name IS NOT INITIAL.
    lo_struct_rtti ?= cl_abap_structdescr=>describe_by_name( mv_struct_name ).
*  mv_struct_name does not contain fields of joined entities
    mo_comp_nontransient = lo_struct_rtti->components.
    SORT mo_comp_nontransient BY name.
  ENDIF.

  CLEAR me->mt_attr2entity.

ENDMETHOD.


  METHOD IS_GET_DATA_NECESSARY.
*! In the generic user interfaces it might be required to supress the
*  GET_DATA handling.
*
*  The parent implementation tries to LOCK the current entity. This can
*  trigger the implicit creation of a change request (ENQUEUE_ENTITY in
*  GOV API). In special situations this processing is not valid:
*  - the change request type is not yet defined
*  - the edition is not yet defined (for edition based entities)
*  - the MDG Communicator has decided to call the pop-up for selecting
*    the change request (and / or edition).
    DATA:
      lt_events TYPE if_fpm=>ty_t_event_queue.

    "set default to true
    rv_result = abap_true.

    "then check whether it's needed to supress GET_DATA or not
    IF me->mo_mdg_api IS BOUND
      AND cl_usmd_generic_bolui_assist=>is_generic_component( iv_component_name = ms_object_key-component_name ) EQ abap_true.
      "... generic UI, so get event queue
      me->mo_fpm_toolbox->mo_fpm->read_event_queue( IMPORTING et_event_queue = lt_events ).
      IF me->mo_mdg_api->mv_crequest_type IS INITIAL.
        "1st case: FPM_START => DEFER_START (but no pop-up)
        IF io_event->mv_event_id = if_fpm_constants=>gc_event-start.
          "In that case prevention is needed since the entity could use
          "external keys that are still empty at this point in time. We
          "would not be able to lock the entity w/o a valid key.
          READ TABLE lt_events TRANSPORTING NO FIELDS
             WITH KEY id    = if_fpm_constants=>gc_event-start
                      state = if_fpm_constants_internal=>gc_event_state-completed.
          IF sy-subrc EQ 0.
            READ TABLE lt_events TRANSPORTING NO FIELDS
              WITH KEY id    = cl_mdg_bs_communicator_assist=>gc_event-defere_start
                       state = space.
            IF sy-subrc EQ 0.
              rv_result = abap_false.
              RETURN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      "2nd case: FPM_START => DO_NOTHING => OPEN_DIALOG_BOX
      IF io_event->mv_event_id = cl_mdg_bs_communicator_assist=>gc_event-do_noting.
        "This case identifies the creation of a new object. The MDG
        "Communicator has decided that the pop-up for selecting the CR
        "type (and / or edition) is needed.
        READ TABLE lt_events TRANSPORTING NO FIELDS
          WITH KEY id    = if_fpm_constants=>gc_event-start
                   state = if_fpm_constants_internal=>gc_event_state-completed.
        IF sy-subrc EQ 0.
          READ TABLE lt_events TRANSPORTING NO FIELDS
            WITH KEY id    = cl_mdg_bs_communicator_assist=>gc_event-do_noting
                     state = if_fpm_constants_internal=>gc_event_state-completed.
          IF sy-subrc EQ 0.
            READ TABLE lt_events TRANSPORTING NO FIELDS
              WITH KEY id    = cl_fpm_event=>gc_event_open_dialog_box
                       state = space.
            IF sy-subrc EQ 0.
              rv_result = abap_false.
              RETURN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      "3rd case: DO_NOTHING => OPEN_DIALOG_BOX
      IF io_event->mv_event_id = cl_mdg_bs_communicator_assist=>gc_event-do_noting.
        "This case identifies the change of an existing object. The MDG
        "Communicator has decided that the pop-up for selecting the CR
        "type (and / or edition) is needed.
        READ TABLE lt_events TRANSPORTING NO FIELDS
          WITH KEY id    = cl_mdg_bs_communicator_assist=>gc_event-do_noting
                   state = if_fpm_constants_internal=>gc_event_state-completed.
        IF sy-subrc EQ 0.
          READ TABLE lt_events TRANSPORTING NO FIELDS
            WITH KEY id    = cl_fpm_event=>gc_event_open_dialog_box
                     state = space.
          IF sy-subrc EQ 0.
            rv_result = abap_false.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


METHOD LOCK.
  DATA:
    lo_entity LIKE me->mo_entity.



  IF me->mo_mdg_api IS BOUND.
    IF me->mo_mdg_api->mv_crequest_type IS INITIAL.
      rv_success = abap_false.
    ELSE.
      lo_entity ?= io_access.
      IF lo_entity->is_change_allowed( ) = abap_true.
        rv_success = super->lock( io_access ).
      ELSE.
        rv_success = abap_false.
      ENDIF.
    ENDIF.
  ELSE.
    rv_success = super->lock( io_access ).
  ENDIF.
ENDMETHOD.


method MODIFY_CNR_BUTTON.
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
endmethod.


METHOD ON_CR_REFRESH.
  DATA:
    lt_objects TYPE crmt_ext_obj_name_tab,
    lr_delta_reference TYPE REF TO if_usmd_delta_buffer_read,
    lt_entity_names TYPE usmd_t_entity,
    lv_entity_name LIKE LINE OF lt_entity_names,
    lt_delta_entity_names TYPE usmd_t_entity,
    lr_inserted_data TYPE REF TO data,
    lr_updated_data TYPE REF TO data,
    lr_deleted_data TYPE REF TO data,
    ls_join_usage like LINE OF mt_join_usage.


  CHECK mo_entity IS BOUND.
  "find the related BOL/GenIL object names that have been updated somehow
  "within the appropriate event parameter
  me->mo_fpm_toolbox->get_event_data(
    EXPORTING
      io_event = io_event
      iv_name  = 'OBJECT_NAMES'
    IMPORTING
      ev_value = lt_objects
  ).
  "if there's no list of updated objects available with the event's
  "parameters refresh all objects, hence trigger a re-read of my entity now
  IF lt_objects IS INITIAL.
    IF me->mo_entity IS BOUND AND me->mo_entity->alive( ) = abap_true.
      me->mo_entity->reread( ).
    ENDIF.
  ELSE.
    "if the list is available check if my object is part of it and hence
    "had some data changes in MDGAF buffers only - if so trigger a re-read
    READ TABLE lt_objects TRANSPORTING NO FIELDS
         WITH KEY table_line = me->ms_object_key-object_name.
    CHECK sy-subrc = 0.
    "if this UIBB's object is listed this means that at least one of its
    "related MDG entities has been updated - to find out which entities
    "have been updated and in which way (creation, deletion or change)
    "get the reference of the suitable API which was delivered by the
    "check method of the CR API (within this method there might have been
    "called any kind of enrichment, like address validation)
    me->mo_fpm_toolbox->get_event_data(
      EXPORTING
        io_event = io_event
        iv_name  = 'DELTA_REFERENCE'
      IMPORTING
        ev_value = lr_delta_reference
    ).
    "if there's no reference to the delta API don't proceed, since this
    "makes any analyses impossible
    CHECK lr_delta_reference IS BOUND.
    "now ask the API to determine all related MDG entities that have any
    "kind of delta (creation, deletion or changes)
    lr_delta_reference->get_entity_types( IMPORTING et_entity = lt_delta_entity_names ).
    "without any delta in no entities don't proceed - nothing to do then
    "(should not occur at all, though)
    CHECK lt_delta_entity_names IS NOT INITIAL.
    "map the UIBB's GenIL object name to related MDG model entities via
    "the according mapping tables - first customizing entries then (if no
    "entries are found there) those of delivery tables
    "//TODO the following mapping should be done by ConvAPI
    SELECT entity_name FROM mdg_bs_gil_nod_c APPENDING TABLE lt_entity_names
           WHERE component = me->ms_object_key-component_name
           AND object_name = me->ms_object_key-object_name.
    IF sy-subrc <> 0.
      SELECT entity_name FROM mdg_bs_gil_nod APPENDING TABLE lt_entity_names
             WHERE component = me->ms_object_key-component_name
             AND object_name = me->ms_object_key-object_name.
    ENDIF.
    "if no mapping is defined for this particular GenIL object there's no
    "chance to find out whether this UIBB's BOL object needs a re-read trigger,
    "hence stop processing now
    CHECK sy-subrc = 0.
    "for each entity that belongs to the UIBB's BOL object find out whether there's
    "any delta information available (means: is listed in the "delta" entities)
    LOOP AT lt_entity_names INTO lv_entity_name.
      READ TABLE lt_delta_entity_names TRANSPORTING NO FIELDS
           WITH KEY table_line = lv_entity_name.
      CHECK sy-subrc = 0.
      "if there's a delta available for one of the MDG entities corresponding to
      "the UIBB's BOL object find out which kind of delta that is
      lr_delta_reference->read_data(
        EXPORTING
          i_entity      = lv_entity_name
        IMPORTING
          er_t_data_ins = lr_inserted_data
          er_t_data_upd = lr_updated_data
          er_t_data_del = lr_deleted_data
      ).
      "for creations or deletions the appropriate relation of this object's parent
      "needs to be re-read - in that case this is done via wiring/tap connector
      IF lr_inserted_data IS BOUND OR lr_deleted_data IS BOUND.
        me->tap_connector( ).
      ELSE.
        "otherwise only the BOL entity needs to be re-read to retrieve the changed
        "data from MDGAF (via bridge)
        If mt_join_usage IS INITIAL.
          "fallback scenario - only refresh main BOL Object
          me->mo_entity->reread( ).
          me->mv_refresh_data = abap_true.
        ELSE.
          "At least in case of configured JOINS this table should include refs to all relevant BOL-objects
          LOOP AT mt_join_usage INTO ls_join_usage.
            CHECK ls_join_usage-entity IS BOUND.
            ls_join_usage-entity->reread( ).
            me->mv_refresh_data = abap_true.
          ENDLOOP.
        ENDIF.
      ENDIF.
      "no matter if there are further MDG entities that have been changed somehow
      "and do relate to this UIBB's BOL object, ONE reread is sufficient, hence
      "stop looping at the rest of affected MDG entities
      EXIT.
    ENDLOOP.
  ENDIF.
ENDMETHOD.


METHOD ON_DISPLAY_USER.
*! The method handles the display user event. It determines the user name
*  and triggers the CR related event to show the user profile in a pop-up.
*  The link to the user's profile has to be displayed in a transient text
*  field. The field's name has to follow the general rules for those kind
*  of fields. It has to be a concatenation of the actual key field with the
*  suffix of the genIL text assistance class.
  DATA:
    lo_event     TYPE REF TO cl_fpm_event,
    lr_parameter TYPE REF TO data,
    lv_key_field TYPE name_komp,
    lv_user      TYPE string.

  FIELD-SYMBOLS:
    <ls_parameter> TYPE wdr_event_parameter,
    <lt_parameter> TYPE wdr_event_parameter_list,
    <lv_fieldname> TYPE any.

  "ensure to raise the event only once (multiple forms on OVP/edit page
  "could all process the event!)
  IF iv_raised_by_own_ui EQ abap_false.
    ev_result = if_fpm_constants=>gc_event_result-ok.
    RETURN.
  ELSE.
    ev_result = if_fpm_constants=>gc_event_result-failed.
  ENDIF.

  "entity is required
  IF me->mo_entity IS NOT BOUND
    OR me->mo_text_assist IS NOT BOUND.
    RETURN.
  ENDIF.

  "get event data
  CREATE DATA lr_parameter TYPE wdr_event_parameter_list.
  io_event->mo_event_data->get_value(
    EXPORTING
      iv_key   = 'WDEVENT_PARAMS'
    IMPORTING
      er_value = lr_parameter ).
  IF lr_parameter IS NOT BOUND.
    RETURN.
  ENDIF.

  "get the field name that triggered the action
  ASSIGN lr_parameter->* TO <lt_parameter>.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.
  READ TABLE <lt_parameter> ASSIGNING <ls_parameter>
    WITH KEY name = 'FIELDNAME'.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.
  ASSIGN <ls_parameter>-value->* TO <lv_fieldname>.
  IF sy-subrc NE 0
    OR <lv_fieldname> IS INITIAL.
    RETURN.
  ENDIF.

  "get the related field that carries the key for the user name
  lv_key_field = substring_before( val = <lv_fieldname> sub = me->mo_text_assist->gv_text_suffix ).
  IF lv_key_field IS INITIAL.
    RETURN.
  ENDIF.

  "get the key value for the user name
  me->mo_entity->get_property_as_value(
    EXPORTING iv_attr_name = lv_key_field
    IMPORTING ev_result    = lv_user ).
  IF lv_user IS INITIAL.
    RETURN.
  ENDIF.

  "trigger the CR user profile pop-up event
  lo_event = me->raise_local_event_by_id( cl_usmd_cr_user_popup=>cv_event_id_show_user_profile ).
  IF lo_event IS BOUND.
    "hand-over the user
    lo_event->mo_event_data->set_value(
        iv_key   = cl_usmd_cr_user_popup=>cv_user
        iv_value = lv_user ).
  ELSE.
    RETURN.
  ENDIF.

  "indicate completed event handling
  ev_result = if_fpm_constants=>gc_event_result-ok.
ENDMETHOD.


METHOD ON_MDG_CHANGE_DOCS.
* Handles the change docs button which has to be added by the customer
* Example is implemented in SF/CARR UI
* Navigate to WD application 'USMD_CHANGE_DOCUMENT'.
  DATA:
    lt_parameters      TYPE tihttpnvp,
    lo_fpm             TYPE REF TO if_fpm,
    lo_fpm_navigate_to TYPE REF TO if_fpm_navigate_to,
    ls_wd_launcher     TYPE fpm_s_launch_webdynpro,
    ls_additional_parameters TYPE apb_lpd_s_add_wd_parameters,
    lf_bool            TYPE abap_bool .

  ev_result = if_fpm_constants=>gc_event_result-failed.
* Make sure that the event is only processed by one instance of this class
  io_event->mo_event_data->get_value( EXPORTING iv_key = 'ALREADY_PROCESSED'
                                      IMPORTING ev_value = lf_bool ).
  IF lf_bool = abap_true.
    RETURN.
  ENDIF.

  lt_parameters = me->get_parameters_for_navigation( ).
  IF lt_parameters IS INITIAL.
    RETURN.
  ENDIF.

  lo_fpm = cl_fpm_factory=>get_instance( ).
  lo_fpm_navigate_to = lo_fpm->get_navigate_to( iv_instance_sharing = space ).

  ls_wd_launcher-parameter        = lt_parameters .
  ls_wd_launcher-system_alias     = cl_usmd2_cust_access_service=>get_portal_obn_system( ).
  ls_wd_launcher-wd_application   = 'USMD_CHANGE_DOCUMENT' .
  ls_wd_launcher-wd_namespace     = 'SAP'.

  ls_additional_parameters-navigation_mode      = 'EXT_HEAD'.
  ls_additional_parameters-history_mode         = '0'.
  ls_additional_parameters-parameter_forwarding = 'P'.

  CALL METHOD lo_fpm_navigate_to->launch_webdynpro_abap
    EXPORTING
      is_webdynpro_fields      = ls_wd_launcher
      is_additional_parameters = ls_additional_parameters.

  io_event->mo_event_data->set_value( EXPORTING
       iv_key   = 'ALREADY_PROCESSED'
       iv_value = abap_true ).
  ev_result = if_fpm_constants=>gc_event_result-ok.
ENDMETHOD.


METHOD PROVIDE_TOOLTIP_AND_COLOR.
  DATA ls_changed_field TYPE usmd_s_changed_fields_hc.

  FIELD-SYMBOLS <ls_changed_attribute> TYPE usmd_s_changed_obj_attr.
  FIELD-SYMBOLS <ls_join> LIKE LINE OF me->mt_join.
  FIELD-SYMBOLS <ls_join_attr> LIKE LINE OF me->mt_join_attr.

  LOOP AT is_changed_object-changed_attributes ASSIGNING <ls_changed_attribute>.
    CLEAR: ls_changed_field.
    ls_changed_field-object_name = is_changed_object-object_name.
    ls_changed_field-field_name = <ls_changed_attribute>-fieldname.
    ls_changed_field-bol_entity = is_changed_object-bol_entity.
    MOVE-CORRESPONDING <ls_changed_attribute> TO ls_changed_field ##ENH_OK.

    " Convert fieldnames according to joins.
    READ TABLE me->mt_join ASSIGNING <ls_join> WITH KEY object COMPONENTS object_name = is_changed_object-object_name.
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
    IF is_changed_object-crud = if_usmd_conv_som_gov_entity=>gc_crud_delete  AND iv_highlight_deletion = abap_true .
      ls_changed_field-color = mo_highlight_changes->get_color_of_deletion(
                           iv_saved_change   = is_changed_object-saved_change
                           iv_unsaved_change = is_changed_object-unsaved_change
                           iv_crequest_type  = me->mo_mdg_api->mv_crequest_type
                           iv_crequest_step  = me->mo_mdg_api->mv_wf_step
                       ).
      ls_changed_field-tooltip = mo_highlight_changes->get_tooltip_for_deletion(
                                         iv_fieldname = ls_changed_field-ui_field
                                         iv_value_active = <ls_changed_attribute>-value_active
                                         iv_saved_change = is_changed_object-saved_change
                                         iv_unsaved_change = is_changed_object-unsaved_change
                                         iv_crequest_type = me->mo_mdg_api->mv_crequest_type
                                         iv_crequest_step = me->mo_mdg_api->mv_wf_step
                                         it_field_usage = ct_field_usage
                                         it_selected_fields = it_selected_fields
                                         is_data            = cs_data
                                       ).
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
                                         is_data            = cs_data
                                       ).
    ENDIF.
    IF ls_changed_field-color = mo_highlight_changes->get_color_saved( ).
      ls_changed_field-saved = abap_true.
    ENDIF.
    TRY.
        IF is_changed_object-crud = if_usmd_conv_som_gov_entity=>gc_crud_delete AND iv_highlight_deletion = abap_true  .
          INSERT ls_changed_field INTO TABLE et_deleted_field.
        ELSE.
          INSERT ls_changed_field INTO TABLE et_changed_field.
        ENDIF.
      CATCH cx_sy_itab_duplicate_key.
        CONTINUE.
    ENDTRY.
  ENDLOOP.

ENDMETHOD.


METHOD RAISE_LOCAL_EVENT_BY_ID.
  DATA:
    lt_event_queue TYPE if_fpm=>ty_t_event_queue.



  IF me->mo_mdg_api IS BOUND.
    "don't allow the raising of an "automatic" EDIT-event if the UI just left initial
    "screen and is about displaying inactive data for a given CR
    IF me->mo_mdg_api->mv_crequest_id IS NOT INITIAL
    AND iv_event_id = if_fpm_constants=>gc_event-edit.
      IF me->mo_entity IS BOUND
      AND me->mo_entity->is_changeable( ) = abap_false.
        me->mo_fpm_toolbox->mo_fpm->read_event_queue( IMPORTING et_event_queue = lt_event_queue ).
        READ TABLE lt_event_queue TRANSPORTING NO FIELDS
             WITH KEY id = if_fpm_constants=>gc_event-leave_initial_screen.
        IF sy-subrc = 0.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  ro_event = super->raise_local_event_by_id( iv_event_id ).
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


METHOD SET_COLLECTION.
  DATA:
    lo_collection LIKE me->mo_collection,
    lo_entity LIKE me->mo_entity.

  lo_collection = me->mo_collection.
  lo_entity = me->mo_entity.
  super->set_collection( io_collection ).
  "MO_ENTITY not yet set but Single Collection provided - take this as default
  IF me->mo_entity IS NOT BOUND AND io_collection is BOUND AND io_collection->size( ) = 1.
    me->mo_entity = io_collection->find( iv_index = 1 ).
  ENDIF.
  IF lo_entity <> me->mo_entity.
    me->mv_refresh_data = abap_true.
    CHECK me->mo_entity IS BOUND AND me->mo_entity->alive( ) = abap_true.
    DATA ls_delayed_change LIKE LINE OF me->mt_delayed_changes.
    LOOP AT me->mt_delayed_changes INTO ls_delayed_change.
      me->mo_entity->set_property_as_string( iv_attr_name = ls_delayed_change-name  iv_value = ls_delayed_change-value ).
    ENDLOOP.
    CLEAR me->mt_delayed_changes.
  ENDIF.
ENDMETHOD.


METHOD SET_DEFAULT_TOOLTIP.
  DATA lv_configured_field LIKE LINE OF me->mt_config_fields.
  DATA lv_tooltip_field TYPE name_komp.
  DATA lv_bol_object_name TYPE crmt_ext_obj_name.
  DATA lv_bol_attribute_name TYPE name_komp.
  DATA lv_new_tooltip TYPE string.
  DATA lt_field_conf TYPE IF_FPM_GUIBB_ADV_FORM_TYPES=>TY_T_CONFIGURED_FIELD.
  DATA ls_field_conf LIKE LINE OF lt_field_conf.

  FIELD-SYMBOLS <ls_field_usage> LIKE LINE OF it_field_usage.
  FIELD-SYMBOLS <lv_tooltip> TYPE string.

  LOOP AT me->mt_config_fields INTO lv_configured_field.
    READ TABLE it_field_usage ASSIGNING <ls_field_usage> WITH KEY name = lv_configured_field.
    CHECK sy-subrc = 0.
    lv_tooltip_field = me->mo_highlight_changes->add_tlt_prefix( lv_configured_field ).
    CLEAR: lv_new_tooltip, lt_field_conf, ls_field_conf.
    IF io_extended_ctrl IS BOUND.
      io_extended_ctrl->get_configured_fields( EXPORTING iv_name  = lv_configured_field
                                               IMPORTING et_field = lt_field_conf ).
      READ TABLE lt_field_conf with key name = lv_configured_field INTO ls_field_conf.
      If sy-subrc = 0.
        lv_new_tooltip = ls_field_conf-tooltip.
      ENDIF.
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
    ASSIGN COMPONENT lv_tooltip_field OF STRUCTURE cs_data TO <lv_tooltip>.
    CHECK sy-subrc = 0 AND lv_new_tooltip <> <lv_tooltip>.
    <lv_tooltip> = lv_new_tooltip.
    cv_data_changed = abap_true.
  ENDLOOP.
ENDMETHOD.


METHOD SET_JOIN_CHILDREN_DATA.
  DATA:
    ls_join LIKE LINE OF mt_join,
    lo_entity TYPE REF TO cl_crm_bol_entity,
    lo_collection TYPE REF TO if_bol_entity_col.

  FIELD-SYMBOLS:
    <ls_join_data> TYPE any.



  CHECK io_entity IS BOUND.

  LOOP AT mt_join INTO ls_join USING KEY parent
       WHERE parent_id = iv_join_id.
    lo_collection = io_entity->get_related_entities(
      iv_relation_name = ls_join-relation_name
    ).
    CHECK lo_collection IS BOUND.
    lo_entity = lo_collection->get_first( ).
    CHECK lo_entity IS BOUND.
    ASSIGN COMPONENT ls_join-include_name OF STRUCTURE is_data TO <ls_join_data>.
    CHECK sy-subrc = 0.
    lo_entity->set_properties( <ls_join_data> ).
    me->set_join_children_data(
      io_entity  = lo_entity
      iv_join_id = ls_join-id
      is_data    = is_data
    ).
  ENDLOOP.
ENDMETHOD.


METHOD SET_TAG.
*** This method is used to set a Web Dynpro Tag to a specific value. A
*** possible use case for that is the BCV integration.

  DATA: lo_cnr_ovp TYPE REF TO if_fpm_cnr_ovp.

* get OVP
  CHECK me->mo_fpm_toolbox IS BOUND
    AND me->mo_fpm_toolbox->mo_fpm IS BOUND.
  lo_cnr_ovp ?= me->mo_fpm_toolbox->mo_fpm->get_service( cl_fpm_service_manager=>gc_key_cnr_ovp ).

* set tag
  IF lo_cnr_ovp IS BOUND.
    lo_cnr_ovp->set_tag_value(
      iv_tag  = iv_tag
      i_value = i_value ).
  ENDIF.

ENDMETHOD.


METHOD SET_UIBB_EXPLANATION.
*** This method is used to set the explanation text of an UIBB.
*** To set the text, the toolbar API of the OVP is needed.

  DATA lo_cnr_ovp TYPE REF TO if_fpm_cnr_ovp.
  DATA ls_instance_key LIKE is_instance_key.

* FPM toolbox must exist
  IF me->mo_fpm_toolbox IS BOUND.
*   FPM as part of the toolbox must exist
    IF me->mo_fpm_toolbox->mo_fpm IS BOUND.
      IF is_instance_key IS INITIAL.
        ls_instance_key = me->ms_instance_key.
      ELSE.
        ls_instance_key = is_instance_key.
      ENDIF.
      TRY.
*         retrieve the toolbar API of the OVP
          lo_cnr_ovp ?= me->mo_fpm_toolbox->mo_fpm->get_service( cl_fpm_service_manager=>gc_key_cnr_ovp ).
*         set the text
          lo_cnr_ovp->change_uibb_restricted(
            EXPORTING
              iv_fpm_primary_attribute = me->mo_fpm_toolbox->get_element_id_of_uibb( ls_instance_key )
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
    DATA ls_instance_key LIKE is_instance_key.

    "FPM toolbox must exist
    IF me->mo_fpm_toolbox IS BOUND.
      "FPM as part of the toolbox must exist
      IF me->mo_fpm_toolbox->mo_fpm IS BOUND.
        IF is_instance_key IS INITIAL.
          ls_instance_key = me->ms_instance_key.
        ELSE.
          ls_instance_key = is_instance_key.
        ENDIF.
        TRY.
            "retrieve the toolbar API of the OVP
            lo_cnr_ovp ?= me->mo_fpm_toolbox->mo_fpm->get_service( cl_fpm_service_manager=>gc_key_cnr_ovp ).
            "set the text
            lo_cnr_ovp->change_uibb_restricted(
              EXPORTING
                iv_fpm_primary_attribute = me->mo_fpm_toolbox->get_element_id_of_uibb( ls_instance_key )
                iv_explanation_document  = iv_document ).
          CATCH cx_fpm_floorplan cx_sy_move_cast_error cx_sy_ref_is_initial. "#EC NO_HANDLER
        ENDTRY.
      ENDIF.
    ENDIF.

  ENDMETHOD.


METHOD SET_VALUE_BY_MDG_NAME.
  DATA:
    ls_mapping LIKE LINE OF me->mt_mapping.

  FIELD-SYMBOLS:
    <lv_value> TYPE any.



  CHECK me->mo_mdg_api IS BOUND.
  READ TABLE me->mt_mapping INTO ls_mapping
       WITH KEY fieldname = iv_mdg_fieldname ##WARN_OK.
  CHECK sy-subrc = 0.
  ASSIGN COMPONENT ls_mapping-fld_source OF STRUCTURE cs_data TO <lv_value>.
  CHECK sy-subrc = 0.
  <lv_value> = iv_value.
ENDMETHOD.


METHOD TAP_CONNECTOR.
*** The method processes the output of the current connector. If the
*** connector contains a collection, processing is done via the generic
*** FPM based implementation. If the collection is not yet set, it is
*** checked if a creation (navigation into the current page via NEW
*** button) needs to be handled. If so, a new root entity  as well as
*** a new collection including the entity is created.
  DATA:
    lo_collection    TYPE REF TO cl_crm_bol_entity_col,
    ls_initial_data  TYPE fpm_bol_initial_data.


  IF me->mv_object_kind NE if_genil_obj_model=>root_object
    OR ( me->mo_connector IS BOUND AND me->mo_connector->get_output( ) IS NOT INITIAL ).
    super->tap_connector( is_initial_data = is_initial_data ).
  ELSE.
    IF me->mo_collection IS NOT BOUND
      AND cl_usmd_generic_bolui_assist=>is_create_required( ) EQ abap_true.
      IF is_initial_data IS INITIAL.
        ls_initial_data = me->get_initial_data( ).
      ELSE.
        ls_initial_data = is_initial_data.
      ENDIF.
      me->mo_entity = me->create_root_entity(
          iv_object_name    = ms_object_key-object_name
          ir_default_values = ls_initial_data-default_values ).
      CREATE OBJECT lo_collection.
      lo_collection->if_bol_bo_col~add( me->mo_entity ).
      me->set_collection( lo_collection ).
    ENDIF.
  ENDIF.

  "EDIT_PAGE issue - display navigation handling
  "If FPM says EDIT but current Entity is not locked -> use READ_ONLY
  CHECK me->mv_fpm_edit_mode = if_fpm_constants=>gc_edit_mode-edit
  AND   me->mo_entity IS BOUND
  AND   ( me->mo_entity->alive( ) = abap_false OR
          me->mo_entity->is_locked( ) = abap_false ).
  me->mv_fpm_edit_mode = if_fpm_constants=>gc_edit_mode-read_only.
ENDMETHOD.


  METHOD IF_BS_BOL_HOW_FEEDER~CURRENT_ENTITY ##NEEDED.
    " Usualy called after deletion of an entity that made references in Do's buffer
    " invalid. Example of how to implement if needed:
*    ro_entity = me->mo_entity.
  ENDMETHOD.


METHOD ASSIGN_SEARCH_HELPS.
*! This method assigns search helps to the fields of the Form UIBB. It
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

  "Assign search helps to form fields
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


METHOD CHANGE_CONFIG_HIGHLIGHT_DELETE.
  DATA lv_fieldname TYPE name_komp.
  DATA lv_value TYPE usmd_value.

  FIELD-SYMBOLS <lv_config_field> LIKE LINE OF me->mt_config_fields.
  FIELD-SYMBOLS <ls_field_usage> LIKE LINE OF ct_field_usage.
  FIELD-SYMBOLS <lv_color> TYPE data.
  FIELD-SYMBOLS <lv_tooltip> TYPE data.
  FIELD-SYMBOLS <ls_deleted_fields_full_trans> LIKE LINE OF it_deleted_field.
  FIELD-SYMBOLS <ls_changed_object> LIKE LINE OF it_changed_object.
  FIELD-SYMBOLS <lv_value> TYPE any.

  "As For deletion - always all Fields are "changed" - it make sense to go via configured field list
  LOOP AT me->mt_config_fields ASSIGNING <lv_config_field> WHERE table_line <> if_usmd_generic_bolui_const=>gc_fieldname_chg_indicator.
    READ TABLE ct_field_usage ASSIGNING <ls_field_usage> WITH KEY name = <lv_config_field>.
    CHECK sy-subrc = 0 AND <ls_field_usage>-visibility = if_fpm_constants=>gc_visibility-visible.
    lv_fieldname = me->mo_highlight_changes->add_col_prefix( <lv_config_field> ).
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE cs_data TO <lv_color>.
    CHECK sy-subrc = 0.
    lv_fieldname = me->mo_highlight_changes->add_tlt_prefix( <lv_config_field> ).
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE cs_data TO <lv_tooltip>.
    CHECK sy-subrc = 0.

    READ TABLE it_deleted_field ASSIGNING <ls_deleted_fields_full_trans> WITH KEY ui_field COMPONENTS ui_field = <lv_config_field>.
    IF sy-subrc = 0.
      <lv_color> = <ls_deleted_fields_full_trans>-color.
      IF <ls_deleted_fields_full_trans>-tooltip IS NOT INITIAL.
        <lv_tooltip> = <ls_deleted_fields_full_trans>-tooltip.
      ENDIF.
    ELSE.
      READ TABLE it_changed_object ASSIGNING <ls_changed_object> WITH KEY object_name = me->get_bol_object_name( <lv_config_field> ).
      CHECK sy-subrc = 0.
      "Kind of Transient field - no data from CONV_API & and no special handling by application so use UI values
      IF <ls_changed_object>-crud = if_usmd_conv_som_gov_entity=>gc_crud_delete .
        ASSIGN COMPONENT <lv_config_field> OF STRUCTURE cs_data TO <lv_value>.
        IF sy-subrc = 0.
          WRITE <lv_value> TO lv_value.
        ENDIF.
        If <ls_changed_object>-changed_attributes is INITIAL.
*       "Set to read only - jointUseCase - obj. isHandle but parent Deleted (normal ChangesLogic not working)
          <ls_field_usage>-read_only = abap_true.
        ELSE.

          <lv_color> = mo_highlight_changes->get_color_of_deletion(
                               iv_saved_change   = <ls_changed_object>-saved_change
                               iv_unsaved_change = <ls_changed_object>-unsaved_change
                               iv_crequest_type  = mo_mdg_api->mv_crequest_type
                               iv_crequest_step  = mo_mdg_api->mv_wf_step
                           ).
          <lv_tooltip> = mo_highlight_changes->get_tooltip_for_deletion(
                                             iv_fieldname = <lv_config_field>
                                             iv_value_active = lv_value
                                             iv_saved_change = <ls_changed_object>-saved_change
                                             iv_unsaved_change = <ls_changed_object>-unsaved_change
                                             iv_crequest_type = mo_mdg_api->mv_crequest_type
                                             iv_crequest_step = mo_mdg_api->mv_wf_step
                                             it_field_usage = ct_field_usage
                                             it_selected_fields = it_selected_fields
                                             is_data            = cs_data
                                           ).
        ENDIF.
      ENDIF.
    ENDIF.
    cv_data_changed = abap_true.
  ENDLOOP.

ENDMETHOD.


METHOD CHECK_ACTION_USAGE.
  DATA:
    lv_change_allowed TYPE abap_bool,
    lx_usmd_gov_api TYPE REF TO cx_usmd_gov_api.



  me->ms_change-action_usage = abap_false.
  " CHECK me->mv_refresh_data = abap_true. Not required anymore; CHECK leads to screen inconsistencies
  super->check_action_usage( CHANGING ct_action_usage = ct_action_usage ).

  IF me->mv_edit_mode = abap_true.
    TRY.
        IF me->mo_entity IS BOUND.
          lv_change_allowed = me->mo_entity->is_change_allowed( ).
        ELSE.
          IF me->mo_mdg_api IS BOUND.
            lv_change_allowed = me->mo_mdg_api->is_create_allowed( ).
          ELSE.
            lv_change_allowed = abap_false.
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
  DATA:
    lx_usmd_gov_api TYPE REF TO cx_usmd_gov_api.

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

  CHECK me->mo_mdg_api IS BOUND.
  IF cs_action_usage-id = me->mv_action_create.
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
  ENDIF.
ENDMETHOD.


METHOD CHECK_FIELD_USAGE.

  DATA:
    lv_name        TYPE name_komp,
    lv_suffix      TYPE string,
    lv_dummy(8)    TYPE c ##needed,
    ls_field_usage TYPE fpmgb_s_fieldusage,
    lf_ending      TYPE string.

  FIELD-SYMBOLS <ls_field_usage> TYPE fpmgb_s_fieldusage.
  FIELD-SYMBOLS <ls_join_usage> LIKE LINE OF me->mt_join_usage.
  FIELD-SYMBOLS <ls_join> LIKE LINE OF me->mt_join.

  IF me->mt_config_fields IS INITIAL.
    super->check_field_usage( CHANGING ct_field_usage = ct_field_usage ).
    LOOP AT me->mt_join_usage ASSIGNING <ls_join_usage>.
      READ TABLE me->mt_join ASSIGNING <ls_join> WITH KEY id = <ls_join_usage>-join_id.
      IF sy-subrc = 0.
        lv_suffix = <ls_join>-suffix.
      ELSE.
        CLEAR lv_suffix.
      ENDIF.
      LOOP AT <ls_join_usage>-attributes INTO lv_name.
        lv_name = lv_name && lv_suffix.
        APPEND lv_name TO me->mt_config_fields.
      ENDLOOP.
    ENDLOOP.
    SORT me->mt_config_fields.
    DELETE ADJACENT DUPLICATES FROM me->mt_config_fields.
  ELSE.
    super->check_field_usage( CHANGING ct_field_usage = ct_field_usage ).
  ENDIF.

* The text field always has to have the same visibility as the input field or textview it belongs to
  lf_ending = '__TXT' .
  DO 2 TIMES.
    LOOP AT ct_field_usage ASSIGNING <ls_field_usage> WHERE name CS lf_ending.
      SPLIT <ls_field_usage>-name AT lf_ending INTO lv_name lv_dummy.
      READ TABLE ct_field_usage INTO ls_field_usage WITH KEY name = lv_name.
      IF sy-subrc = 0 AND ( ls_field_usage-visibility NE <ls_field_usage>-visibility ) .
        <ls_field_usage>-visibility = ls_field_usage-visibility .
      ENDIF.
    ENDLOOP.
    lf_ending = '__TEXT'.
  ENDDO.
ENDMETHOD.


METHOD CHECK_FIELD_USAGE_SINGLE.
  IF cs_field_usage-name = me->mv_key_alias_name.
    cs_field_usage-name = me->mv_key_name.
    super->check_field_usage_single( CHANGING cs_field_usage = cs_field_usage ).
    cs_field_usage-name = me->mv_key_alias_name.
  ELSE.
    super->check_field_usage_single( CHANGING cs_field_usage = cs_field_usage ).
  ENDIF.
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
  CHECK me->mo_how_to IS BOUND.
  me->mo_how_to->set_muted( boolc( iv_event_id IS INITIAL ) ).
  me->mv_deferred_creation = is_create_ctrl-deferred_sending.
  CHECK me->mt_delayed_changes IS NOT INITIAL AND ro_entity IS BOUND.
  LOOP AT me->mt_delayed_changes INTO ls_delayed_change.
    ro_entity->set_property_as_string(
      iv_attr_name = ls_delayed_change-name
      iv_value = ls_delayed_change-value
    ).
  ENDLOOP.
  CLEAR me->mt_delayed_changes.
ENDMETHOD.


METHOD CREATE_STRUCT_RTTI.
*  This method creates the field catalogue for the UIBBs using
*  this feeder class. It determines description fields automatically
*  for all relevant fields (e.g. fields having domain fixed values or
*  check tables) by using the generic text assistance class.

  DATA:
    lo_description         TYPE REF TO cl_abap_structdescr,
    ls_description         LIKE LINE OF lo_description->components,
    lo_genil_model         TYPE REF TO if_genil_obj_model,
    lt_components          TYPE cl_abap_structdescr=>component_table,
    lt_components_text     TYPE cl_abap_structdescr=>component_table,
    ls_component           LIKE LINE OF lt_components,
    lt_relevant_fields     TYPE mdg_mdf_t_fieldname,
    lt_text_field_id 	     TYPE mdg_mdf_ts_typename,
    ls_text_field_id       LIKE LINE OF lt_text_field_id,
    lv_attribute_structure TYPE wcf_attr_struct,
    lv_data_type           TYPE typename,
    lv_key_structure       TYPE string,
    lv_relevant_field      TYPE fieldname.

  FIELD-SYMBOLS:
    <ls_component> LIKE LINE OF lt_components.

  "inherit
  super->create_struct_rtti( ).

  "get genIL runtime model
  lo_genil_model = cl_crm_genil_model_service=>get_runtime_model( ).

  "get key and attribute structures
  TRY.
      lv_attribute_structure = me->mv_struct_name.
      lv_key_structure = lo_genil_model->get_key_struct_name( me->ms_object_key-object_name ).
    CATCH cx_crm_unsupported_object.                    "#EC NO_HANDLER
  ENDTRY.

  lt_components = me->mo_struct_rtti->get_components( ).

  "use the text helper to add text fields dynamically
  IF me->mo_text_assist IS BOUND.
    "get relevant fields
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
    "add text fields for the audit fields
    LOOP AT lt_components INTO ls_component
      WHERE name = if_usmd_generic_bolui_const=>gc_fieldname_usmd_changed_by
         OR name = if_usmd_generic_bolui_const=>gc_fieldname_usmd_created_by.
      APPEND INITIAL LINE TO lt_components_text ASSIGNING <ls_component>.
      <ls_component>-name = ls_component-name && me->mo_text_assist->gv_text_suffix.
      <ls_component>-type = cl_abap_elemdescr=>get_string( ).
    ENDLOOP.
  ENDIF.

  IF cl_abap_classdescr=>describe_by_object_ref( me )->get_relative_name( ) <> 'CL_USMD_MC_FEEDER_LIST' AND
     cl_abap_classdescr=>describe_by_object_ref( me )->get_relative_name( ) <> 'CL_USMD_MC_FEEDER_FORM'.
    IF lt_components_text IS NOT INITIAL.
      APPEND LINES OF lt_components_text TO lt_components.
      me->mo_struct_rtti = cl_abap_structdescr=>create( lt_components ).
    ENDIF.
  ELSE.
*   mutiple-records processing: keep entity structure to allow usage of assigned DDIC search help
    CLEAR lt_components.
    CLEAR ls_component.
    ls_component-name       = 'MDG_ENTITY'.
    ls_component-as_include = abap_true.
    ls_component-type       = me->mo_struct_rtti.
    INSERT ls_component INTO TABLE lt_components.
    IF lt_components_text IS NOT INITIAL.
      APPEND LINES OF lt_components_text TO lt_components.
    ENDIF.
    me->mo_struct_rtti = cl_abap_structdescr=>create( lt_components ).
  ENDIF.

  "handle key aliases if needed
  CHECK me->mv_key_alias_name IS NOT INITIAL.
  IF me->mv_key_name IS INITIAL.
    lo_description ?= cl_abap_structdescr=>describe_by_name( lv_key_structure ).
    READ TABLE lo_description->components INTO ls_description INDEX 1.
    me->mv_key_name = ls_description-name.
  ENDIF.

  CLEAR lt_components.
  APPEND INITIAL LINE TO lt_components ASSIGNING <ls_component>.
  <ls_component>-name = 'WITHOUT_KEY_ALIAS'.
  <ls_component>-type = me->mo_struct_rtti.
  <ls_component>-as_include = abap_true.
  APPEND INITIAL LINE TO lt_components ASSIGNING <ls_component>.
  <ls_component>-name = me->mv_key_alias_name.
  <ls_component>-type = me->mo_struct_rtti->get_component_type( me->mv_key_name ).

  me->mo_struct_rtti = cl_abap_structdescr=>create( lt_components ).
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
       WITH KEY name = gc_parameter-event_exclusion_per_action.
  IF sy-subrc = 0.
    ASSIGN <ls_parameter>-value->* TO <data>.
    IF sy-subrc = 0.
      me->mt_excluded_events_per_action = <data>.
    ENDIF.
  ENDIF.
  READ TABLE it_parameter ASSIGNING <ls_parameter>
       WITH KEY name = gc_parameter-read_mode_per_action.
  IF sy-subrc = 0.
    ASSIGN <ls_parameter>-value->* TO <data>.
    IF sy-subrc = 0.
      lt_read_only_on_actions = <data>.
      READ TABLE lt_read_only_on_actions TRANSPORTING NO FIELDS
           WITH KEY table_line = me->mv_action ##WARN_OK.
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
    CATCH cx_crm_cic_parameter_error cx_crm_unsupported_object ##NO_HANDLER.
  ENDTRY.
ENDMETHOD.


METHOD GET_ACTIONS.
*! This method defines actions for the UI. Actions are used by buttons
*  and/or fields within the UI configuration.
  FIELD-SYMBOLS:
    <ls_actiondef> LIKE LINE OF mt_actiondef.

  "inherit
  super->get_actions( ).

*  add an action to display the user profile (e.g. for audit fields)
  APPEND INITIAL LINE TO mt_actiondef ASSIGNING <ls_actiondef>.
  <ls_actiondef>-id = if_usmd_generic_bolui_const=>gc_action_display_user.
  <ls_actiondef>-enabled = abap_true.
  <ls_actiondef>-visible = cl_wd_uielement=>e_visible-visible.
  <ls_actiondef>-exposable = abap_true.

*  action for displaying change documents (custom button)
  APPEND INITIAL LINE TO mt_actiondef ASSIGNING <ls_actiondef>.
  <ls_actiondef>-id = 'MDG_CHANGE_DOCS'.
  <ls_actiondef>-enabled = abap_true.
  <ls_actiondef>-visible = cl_wd_uielement=>e_visible-visible.
  <ls_actiondef>-exposable = abap_true.

ENDMETHOD.


METHOD GET_ATTR_TEXT.
  DATA:
    lv_attr_name LIKE iv_attr_name.



  IF iv_attr_name = me->mv_key_alias_name.
    lv_attr_name = me->mv_key_name.
  ELSE.
    lv_attr_name = iv_attr_name.
  ENDIF.
  rv_text = super->get_attr_text(
      io_access    = io_access
      iv_attr_name = lv_attr_name
  ).
ENDMETHOD.


METHOD GET_ATTR_VALUE_SET.
  DATA:
    lv_attr_name  LIKE iv_attr_name.

  FIELD-SYMBOLS:
    <join_attr>    TYPE s_join_attr.

  "filter generic text fields
  IF me->mo_text_assist IS BOUND.
    CHECK iv_attr_name NS mo_text_assist->gv_text_suffix.
    CHECK iv_attr_name NS mo_text_assist->gv_text_suffix_mdg_l.
    CHECK iv_attr_name NS mo_text_assist->gv_text_suffix_mdg_m.
    CHECK iv_attr_name NS mo_text_assist->gv_text_suffix_mdg_s.
  ENDIF.

  "filter according to edit fields
  IF iv_attr_name = me->mv_key_alias_name.
    lv_attr_name = me->mv_key_name.
  ELSE.
    lv_attr_name = iv_attr_name.
  ENDIF.

* Transient fields were added in method CREATE_STRUCT_RTTI and must not be processed in the GENIL layer
  READ TABLE me->mt_edit_field TRANSPORTING NO FIELDS "Also contains transient fields. Joined ETs are not contained
        WITH TABLE KEY name = lv_attr_name.
  IF sy-subrc = 0.
    READ TABLE mo_comp_nontransient TRANSPORTING NO FIELDS WITH KEY name = lv_attr_name BINARY SEARCH.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.
  ELSE.
    READ TABLE me->mt_join_attr ASSIGNING <join_attr>
          WITH KEY join_attr COMPONENTS bol_attr_name = lv_attr_name.
    IF sy-subrc = 0.
      READ TABLE mo_all_fields TRANSPORTING NO FIELDS WITH KEY name = <join_attr>-name BINARY SEARCH.
      IF sy-subrc NE 0.
        RETURN.
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

  super->get_attr_value_set(
    EXPORTING
      io_access      = io_access
      iv_object_name = iv_object_name
      iv_attr_name   = lv_attr_name
    IMPORTING
      et_value_set   = et_value_set ).

ENDMETHOD.


method GET_CHANGED_TRANSIENT_FIELDS ##NEEDED.
* To be implemented for mapping of transient field usage & change of highlight information of changed filds
* Add relevant entries from Import table to Returning and
* add transientfields fields in transient_mapping table of the line
* those fields automatically take over the tooltip & color of the real changed field
* you can also add new line into the table without object_name but with fieldname
* and saved/unsaved information and your own Tooltip

endmethod.


method GET_DELETED_TRANSIENT_FIELDS ##NEEDED.
* To be implemented for mapping of transient field usage & change of highlight information of deleted fields
* Add relevant entries from Import table to Returning and
* add transientfields fields in transient_mapping table of the line
* those fields automatically take over the tooltip & color of the real deleted field
* you can also add new line into the table without object_name but with fieldname
* and saved/unsaved information and your own Tooltip

endmethod.


METHOD GET_ENTITY_DATA.
*! This method fulfils several tasks. It tries to:
*   - convert the generic MDG timestamps for audit information into
*     the local user's format.
*   - retrieve values for generic text fields if the related text field
*     is visible in the UI.
  DATA:
    lo_entity              TYPE REF TO cl_crm_bol_entity,
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
    <ls_edit_field> LIKE LINE OF me->mt_edit_field,
    <ls_text_value> LIKE LINE OF lt_text_values,
    <lv_key>        TYPE any,
    <lv_text>       TYPE any.

  "inherit
  super->get_entity_data(
    EXPORTING io_access = io_access
    CHANGING  cs_data   = cs_data ).
  IF me->mo_how_to IS BOUND.
    me->mo_how_to->set_feeder( me ).
    me->mo_how_to->initialize( io_access ).
  ENDIF.

  "propert access is required
  CHECK io_access IS BOUND.
  TRY.
      lo_entity ?= io_access.
    CATCH cx_sy_move_cast_error.
      RETURN.
  ENDTRY.
  CHECK lo_entity IS BOUND
    AND me->mo_text_assist IS BOUND.

  "handle audit fields
  LOOP AT me->mt_edit_field ASSIGNING <ls_edit_field>.
    CHECK <ls_edit_field>-name EQ if_usmd_generic_bolui_const=>gc_fieldname_usmd_created_at
       OR <ls_edit_field>-name EQ if_usmd_generic_bolui_const=>gc_fieldname_usmd_changed_at
       OR <ls_edit_field>-name EQ if_usmd_generic_bolui_const=>gc_fieldname_usmd_created_by && me->mo_text_assist->gv_text_suffix
       OR <ls_edit_field>-name EQ if_usmd_generic_bolui_const=>gc_fieldname_usmd_changed_by && me->mo_text_assist->gv_text_suffix.
    "get key value
    ASSIGN COMPONENT <ls_edit_field>-name OF STRUCTURE cs_data TO <lv_text>.
    CHECK sy-subrc EQ 0.
    "handle fields
    CASE <ls_edit_field>-name.
      WHEN if_usmd_generic_bolui_const=>gc_fieldname_usmd_created_at
        OR if_usmd_generic_bolui_const=>gc_fieldname_usmd_changed_at.
        "convert time stamps
        IF <lv_text> IS NOT INITIAL.
          <lv_text> = me->convert_utc_timestamp( <lv_text> ).
        ENDIF.
      WHEN OTHERS.
        "get user name
        lv_relevant_field = substring_before( val = <ls_edit_field>-name sub = mo_text_assist->gv_text_suffix ).
        ASSIGN COMPONENT lv_relevant_field OF STRUCTURE cs_data TO <lv_key>.
        CHECK sy-subrc EQ 0
          AND <lv_key> IS NOT INITIAL.
        <lv_text> = cl_usmd_cr_ui_service=>get_user_full_name( <lv_key> ).
    ENDCASE.
  ENDLOOP.

  "prepare reading texts
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
        CLEAR: lt_sel, lv_entity, lt_text_values.
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


METHOD GET_FIELD_PROPS_FOR_USAGE.
  DATA:
    lt_field_usage LIKE it_field_usage,
    ls_field_usage LIKE LINE OF lt_field_usage.



  IF me->mv_key_alias_name IS NOT INITIAL.
    lt_field_usage = it_field_usage.
    READ TABLE lt_field_usage INTO ls_field_usage
         WITH KEY name = me->mv_key_alias_name.
    IF sy-subrc = 0.
      READ TABLE lt_field_usage TRANSPORTING NO FIELDS
           WITH KEY name = me->mv_key_name.
      IF sy-subrc <> 0.
        ls_field_usage-name = me->mv_key_name.
        ls_field_usage-enabled = abap_false.
        ls_field_usage-visibility = if_fpm_constants=>gc_visibility-not_visible.
        INSERT ls_field_usage INTO TABLE lt_field_usage.
      ENDIF.
    ENDIF.
    super->get_field_props_for_usage(
      it_field_usage = lt_field_usage
      io_entity      = io_entity
    ).
  ELSE.
    super->get_field_props_for_usage(
      it_field_usage = it_field_usage
      io_entity      = io_entity
    ).
  ENDIF.
ENDMETHOD.


METHOD GET_FIELD_UI_PROP.
  rs_property = super->get_field_ui_prop(
    io_entity         = io_entity
    iv_attr_name      = iv_attr_name
    iv_change_allowed = iv_change_allowed
    is_prop           = is_prop
  ).
  IF io_entity IS BOUND AND io_entity->is_locked( ) = abap_false.
    rs_property-read_only = abap_true.
  ENDIF.
ENDMETHOD.


METHOD GET_GENIL_MESSAGES.
  DATA:
    lt_attribute_names LIKE it_attr,
    ls_genil_message LIKE LINE OF et_genil_message.
  DATA lo_message_container TYPE REF TO if_genil_message_container.

  FIELD-SYMBOLS:
    <lv_attribute_name> LIKE LINE OF lt_attribute_names.



  lt_attribute_names = it_attr.
  IF me->mv_key_alias_name IS NOT INITIAL
  AND me->mv_key_name IS NOT INITIAL.
    READ TABLE lt_attribute_names ASSIGNING <lv_attribute_name>
         WITH KEY table_line = me->mv_key_alias_name.
    IF sy-subrc = 0.
      <lv_attribute_name> = me->mv_key_name.
    ENDIF.
  ENDIF.
  super->get_genil_messages(
    EXPORTING
      io_entity        = io_entity
      it_attr          = lt_attribute_names
    IMPORTING
      et_genil_message = et_genil_message
  ).
  IF me->mv_key_alias_name IS NOT INITIAL
  AND me->mv_key_name IS NOT INITIAL.
    ls_genil_message-attr_name = me->mv_key_alias_name.
    MODIFY et_genil_message FROM ls_genil_message TRANSPORTING attr_name
           WHERE attr_name = me->mv_key_name.
  ENDIF.

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
      it_attributes  = lt_attribute_names
      iv_for_display = abap_true ).
  ENDIF.

ENDMETHOD.


METHOD GET_LABEL_TEXT.
  DATA lv_bol_attribute_name LIKE iv_bol_attribute_name.

  FIELD-SYMBOLS <ls_dynamic_label> LIKE LINE OF me->mt_dynamic_labels.
  FIELD-SYMBOLS <ls_labels_of_entity> LIKE LINE OF me->mt_labels_of_entities.
  FIELD-SYMBOLS <ls_labels> TYPE any.
  FIELD-SYMBOLS <lv_label> TYPE string.

  rv_label_text = iv_label_text_usage.
  CHECK ( rv_label_text IS INITIAL OR me->mt_dynamic_labels IS NOT INITIAL OR me->mv_only_dynamic_labels = abap_true )
          AND iv_bol_object_name IS NOT INITIAL AND iv_bol_attribute_name IS NOT INITIAL.
  IF iv_bol_attribute_name = me->mv_key_alias_name.
    lv_bol_attribute_name = me->mv_key_name.
  ELSE.
    lv_bol_attribute_name = iv_bol_attribute_name.
  ENDIF.

  "Get the generated label
  READ TABLE me->mt_labels_of_entities ASSIGNING <ls_labels_of_entity> WITH TABLE KEY name = iv_bol_object_name.
  CHECK sy-subrc = 0.
  ASSIGN <ls_labels_of_entity>-reference->* TO <ls_labels>.
  CHECK sy-subrc = 0.
  ASSIGN COMPONENT lv_bol_attribute_name OF STRUCTURE <ls_labels> TO <lv_label>.
  CHECK sy-subrc = 0.

  IF rv_label_text IS INITIAL.
    "Use generated label instead of empty one
    rv_label_text = <lv_label>.
  ELSEIF me->mt_dynamic_labels IS NOT INITIAL OR me->mv_only_dynamic_labels = abap_true.
    "For defined cases also existing labels can be overwritten
    READ TABLE me->mt_dynamic_labels ASSIGNING <ls_dynamic_label> WITH TABLE KEY name = iv_bol_object_name.
    CHECK sy-subrc = 0.
    READ TABLE <ls_dynamic_label>-fields TRANSPORTING NO FIELDS WITH KEY table_line = lv_bol_attribute_name.
    CHECK sy-subrc = 0.
    rv_label_text = <lv_label>.
  ENDIF.
ENDMETHOD.


METHOD GET_PARAMETERS_FOR_NAVIGATION.
*! This method prepares the navigation to other USMD applications using
*  the shared memory. It determines the keys of the current entity and
*  creates the required share memory entries. The resulting shared memory
*  ID and RFC destination values are returned as navigation parameter table.
  DATA:
    lt_components TYPE crmt_attr_name_tab,
    lt_value      TYPE usmd_t_value,
    lt_value_list TYPE usmd_ts_seqnr_value,
    lv_entity     TYPE usmd_entity,
    lv_model      TYPE usmd_model,
    lv_rfc_dest   TYPE rfcdest,
    lv_shm_guid   TYPE shm_inst_name,
    lf_key_struc  TYPE strukname.

  FIELD-SYMBOLS:
    <ls_parameter> LIKE LINE OF rt_parameters,
    <ls_value>     TYPE usmd_s_value,
    <lv_field>     TYPE name_komp.

  CLEAR rt_parameters.
  IF me->mo_entity IS NOT BOUND.
    RETURN.
  ENDIF.

  "USMD app needs model and entity
  cl_usmd_generic_bolui_assist=>get_application_parameter(
    IMPORTING
      ev_entity = lv_entity
      ev_model  = lv_model ).
  APPEND INITIAL LINE TO lt_value ASSIGNING <ls_value>.
  <ls_value>-fieldname = if_usmd_generic_bolui_const=>gc_usmd_fieldname.
  <ls_value>-value     = lv_entity.
  APPEND INITIAL LINE TO lt_value ASSIGNING <ls_value>.
  <ls_value>-fieldname = if_usmd_generic_bolui_const=>gc_fieldname_usmd_model.
  <ls_value>-value     = lv_model.

  "USMD app needs the entity keys
  lf_key_struc = me->get_object_model( )->get_key_struct_name( ms_object_key-object_name ).
  lt_components = cl_usmd_generic_bolui_assist=>get_structure_components( iv_structure_name = lf_key_struc ).
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  LOOP AT lt_components ASSIGNING <lv_field>.
    APPEND INITIAL LINE TO lt_value ASSIGNING <ls_value>.
    <ls_value>-fieldname = <lv_field>.
    me->mo_entity->get_property_as_value(
      EXPORTING
        iv_attr_name = <lv_field>
      IMPORTING
        ev_result    = <ls_value>-value ).
  ENDLOOP.

  "check if edition is desired
  IF iv_with_edition EQ abap_true.
    APPEND INITIAL LINE TO lt_value ASSIGNING <ls_value>.
    <ls_value>-fieldname = if_usmd_generic_bolui_const=>gc_fieldname_usmd_edition.
    <ls_value>-value     = cl_usmd_generic_bolui_assist=>get_mdg_api( )->mv_edition.
  ENDIF.

  "get shared memory instance and RFC destination
  cl_usmd_wd_parameter_access=>set_configuration(
    EXPORTING
      it_data       = lt_value
      it_value_list = lt_value_list
    IMPORTING
      e_guid        = lv_shm_guid
      e_rfcdest     = lv_rfc_dest ).

  "navigation parameter: shared memory
  APPEND INITIAL LINE TO rt_parameters ASSIGNING <ls_parameter>.
  <ls_parameter>-name  = if_usmd_generic_bolui_const=>gc_param_shm_instance.
  <ls_parameter>-value = lv_shm_guid.

  "navigation parameter: rfc destination
  APPEND INITIAL LINE TO rt_parameters ASSIGNING <ls_parameter>.
  <ls_parameter>-name  = if_usmd_generic_bolui_const=>gc_param_rfc_dest.
  <ls_parameter>-value = lv_rfc_dest.
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
    ls_sel-option    = usmd0_cs_ra-option_eq.
    ls_sel-sign      = usmd0_cs_ra-sign_i.
    ls_sel-fieldname = ev_entity.
    ls_sel-low       = iv_value.
    INSERT ls_sel INTO TABLE et_sel.
  ENDIF.

  "add the edition if required
  IF ls_attr2entity-edition EQ abap_true.
    TRY.
        ls_sel-fieldname = usmd0_cs_fld-edition.
        ls_sel-low       = io_entity->get_property_as_string( iv_attr_name = |{ ls_sel-fieldname }| ).
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
        ls_sel-low       = io_entity->get_property_as_string( iv_attr_name = |{ <lv_attribute> }| ).
        CHECK ls_sel-low IS NOT INITIAL.
        INSERT ls_sel INTO TABLE et_sel.
      CATCH cx_crm_cic_parameter_error.
        CONTINUE.
    ENDTRY.
  ENDLOOP.

ENDMETHOD.


method HANDLE_CANCEL_BUTTON.
  DATA:
    lv_action TYPE bs_action.

  "as per decision taken from an FPM-UX-discussion the cancel button shall
  "be invisible as long as during a creation the SAVE event was not triggered, yet
  me->mo_app_parameter->get_value(
    EXPORTING iv_key   = 'ACTION'
    IMPORTING ev_value = lv_action
  ).
  CHECK lv_action = 'CREATE'.

  IF io_event->mv_event_id = if_fpm_constants=>gc_event-leave_initial_screen OR
     io_event->mv_event_id = if_fpm_constants=>gc_event-edit  .
    me->modify_cnr_button(
      iv_event_id = if_fpm_constants=>gc_event-cancel
      iv_enabled = abap_false
      iv_visibility = cl_wd_uielement=>e_visible-none
    ).
  ENDIF.

  IF io_event->mv_event_id = if_fpm_constants=>gc_event-save.
    me->modify_cnr_button(
      iv_event_id = if_fpm_constants=>gc_event-cancel
      iv_enabled = abap_true
      iv_visibility = cl_wd_uielement=>e_visible-visible
    ).
  ENDIF.
endmethod.


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
  DATA lt_parameters TYPE crmt_name_value_pair_tab.
  DATA ls_parameter LIKE LINE OF lt_parameters.
  DATA lo_collection TYPE REF TO if_bol_entity_col.
  DATA lo_entity TYPE REF TO cl_crm_bol_entity.
  DATA lr_changed_object TYPE REF TO usmd_s_changed_object.
  DATA lt_changed_objects TYPE usmd_t_changed_object.
  DATA lt_deleted_field TYPE usmd_ts_changed_fields_hc.
  DATA lt_changed_field TYPE usmd_ts_changed_fields_hc.
  DATA lr_changed_trans_mapping LIKE REF TO lt_changed_field.
  DATA lr_del_trans_mapping LIKE REF TO lt_changed_field.
  DATA lv_fieldname TYPE name_komp.
  DATA ls_main_changed_object TYPE usmd_s_changed_object.
  DATA ls_changed_object TYPE usmd_s_changed_object.

  FIELD-SYMBOLS <ls_changed_object> LIKE LINE OF lt_changed_objects.
  FIELD-SYMBOLS <lv_color> TYPE data.
  FIELD-SYMBOLS <lv_tooltip> TYPE data.
  FIELD-SYMBOLS <ls_field_usage> LIKE LINE OF ct_field_usage.
  FIELD-SYMBOLS <ls_join> LIKE LINE OF me->mt_join.
  FIELD-SYMBOLS <ls_changed_field> LIKE LINE OF lt_changed_field.

  CHECK me->mo_entity IS BOUND AND me->mv_disable_hc = abap_false
  AND me->mo_highlight_changes IS BOUND AND me->mo_mdg_api IS BOUND
  AND me->mo_mdg_api->mv_crequest_type IS NOT INITIAL
  AND me->mo_highlight_changes->is_highlight_changes_active(
        iv_crequest_type = me->mo_mdg_api->mv_crequest_type
        iv_crequest_step = me->mo_mdg_api->mv_wf_step ) = abap_true.

  ls_parameter-name = cl_mdg_bs_genil=>gc_method_parameter_name-contained_changes.
  ls_parameter-value = cl_mdg_bs_genil=>gc_method_parameter_value-false.
  INSERT ls_parameter INTO TABLE lt_parameters.
  " At the creation of (main) entities only unsaved changes are highlighted
  TRY.
      IF me->mo_mdg_api->is_new_entity( ) = abap_true.
        ls_parameter-name = cl_mdg_bs_genil=>gc_method_parameter_name-saved_changes.
        ls_parameter-value = cl_mdg_bs_genil=>gc_method_parameter_value-false.
        INSERT ls_parameter INTO TABLE lt_parameters.
      ENDIF.
    CATCH cx_usmd_gov_api ##NO_HANDLER.
  ENDTRY.

  CREATE OBJECT lo_collection TYPE cl_crm_bol_entity_col.
  lo_collection->add( me->mo_entity ).
  LOOP AT mt_join ASSIGNING <ls_join>.
    lo_entity = me->get_joined_entity( io_entity = me->mo_entity  iv_join_id = <ls_join>-id ).
    CHECK lo_entity IS BOUND.
    lo_collection->add( lo_entity ).
  ENDLOOP.
  lo_entity = lo_collection->get_first( ).
  WHILE lo_entity IS BOUND.
    TRY.
        lr_changed_object ?= lo_entity->execute2(
                               iv_method_name = cl_mdg_bs_genil=>gc_method_name-get_changes
                               it_param = lt_parameters
                             ).
        IF lr_changed_object IS BOUND AND lo_entity = me->mo_entity.
          IF lr_changed_object->* IS NOT INITIAL.
            ls_main_changed_object = lr_changed_object->*.
          ENDIF.
        ENDIF.
      CATCH cx_crm_bol_meth_exec_failed.
        CLEAR lr_changed_object.
    ENDTRY.
    IF lr_changed_object IS BOUND AND lr_changed_object->*-changed_attributes IS NOT INITIAL. "Any kind of change reported
      IF lr_changed_object->*-changed_attributes IS NOT INITIAL .
        IF lr_changed_object->*-bol_entity IS INITIAL.
          lr_changed_object->*-bol_entity = lo_entity.
        ENDIF.
        APPEND lr_changed_object->* TO lt_changed_objects.
      ENDIF.
    ELSEIF lr_changed_object IS BOUND AND lr_changed_object->*-changed_attributes IS INITIAL.
      "Add existing Obj.with no Changes - to have no faulty defaulting props
      CLEAR ls_changed_object.
      ls_changed_object-object_name = lo_entity->get_name( ).
      ls_changed_object-bol_entity = lo_entity.
      APPEND ls_changed_object TO lt_changed_objects.
    ENDIF.
    lo_entity = lo_collection->get_next( ).
  ENDWHILE.

  "In Main-DEL Case:Add not existing JoinedObj as changed Objs (without changes) for later defaulting props
  IF ls_main_changed_object-crud = if_usmd_conv_som_gov_entity=>gc_crud_delete.
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


  LOOP AT lt_changed_objects ASSIGNING <ls_changed_object>.
    provide_tooltip_and_color( EXPORTING  is_changed_object  = <ls_changed_object>
                                          it_selected_fields = it_selected_fields
                                          iv_highlight_deletion = mv_highlight_del_active
                               IMPORTING  et_changed_field   = lt_changed_field
                                          et_deleted_field   = lt_deleted_field
                                 CHANGING cs_data            = cs_data
                                          ct_field_usage     = ct_field_usage ).
  ENDLOOP.
  " Ask redefinitionsof Applications for Transient Fields.
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

  LOOP AT lt_changed_field ASSIGNING <ls_changed_field>.
    READ TABLE ct_field_usage ASSIGNING <ls_field_usage> WITH KEY name = <ls_changed_field>-ui_field.
    CHECK sy-subrc = 0 AND <ls_field_usage>-visibility = if_fpm_constants=>gc_visibility-visible.
    lv_fieldname = me->mo_highlight_changes->add_col_prefix( <ls_changed_field>-ui_field ).
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE cs_data TO <lv_color>.
    IF sy-subrc = 0 AND <lv_color> <> <ls_changed_field>-color.
      <lv_color> = <ls_changed_field>-color.
      cv_data_changed = abap_true.
    ENDIF.
    IF <ls_changed_field>-tooltip IS NOT INITIAL.
      lv_fieldname = me->mo_highlight_changes->add_tlt_prefix( <ls_changed_field>-ui_field ).
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE cs_data TO <lv_tooltip>.
      IF sy-subrc = 0 AND <lv_tooltip> <> <ls_changed_field>-tooltip.
        <lv_tooltip> = <ls_changed_field>-tooltip.
        cv_data_changed = abap_true.
      ENDIF.
    ENDIF.
  ENDLOOP.

  "HC_DEL: Deletions, Include Defaulting logic via configured fields
  IF mv_highlight_del_active = abap_false OR lt_deleted_field IS INITIAL.
    RETURN.
  ENDIF.

  change_config_highlight_delete( EXPORTING
                                         it_deleted_field   = lt_deleted_field
                                         it_changed_object  = lt_changed_objects
                                         it_selected_fields = it_selected_fields
                                CHANGING cs_data            = cs_data
                                         cv_data_changed    = cv_data_changed
                                         ct_field_usage     = ct_field_usage ).

ENDMETHOD.
ENDCLASS.
