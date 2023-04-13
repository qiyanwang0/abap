class Z_BS_BP_GUIBB_ROOT_1_WANG definition
  public
  inheriting from CL_BS_BP_GUIBB_FORM
  create public .

public section.

  methods CONSTRUCTOR .

  methods IF_BS_BOL_HOW_FEEDER~CURRENT_ENTITY
    redefinition .
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
    BEGIN OF ty_group,
    group TYPE bu_group,
    nrrng TYPE bu_nrrng,
  END OF ty_group .
  types:
    ty_groups TYPE STANDARD TABLE OF ty_group .

  data MT_GROUPS type TY_GROUPS .
  data MO_REPORTING type ref to IF_BS_INOB_REPORTING .
  data MV_SOLO_BP type SYSUUID_X16 .
  data MO_MORPH_REPORTING type ref to IF_BS_MORPH_REPORTING .

  methods GET_VALUE_SET_AUTH_GROUP
    importing
      !IO_ACCESS type ref to IF_BOL_BO_PROPERTY_ACCESS
      !IV_ATTR_NAME type NAME_KOMP
    exporting
      !ET_VALUE_SET type WDR_CONTEXT_ATTR_VALUE_LIST .
  methods MANIPULATE_STRUCT_RTTI
    importing
      !IT_COMPONENTS type CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE
    returning
      value(RO_STRUCT_RTTI) type ref to CL_ABAP_STRUCTDESCR .
  methods GET_VALUE_SET_TITLE_KEY
    importing
      !IO_ACCESS type ref to IF_BOL_BO_PROPERTY_ACCESS
      !IV_ATTR_NAME type NAME_KOMP
    exporting
      !ET_VALUE_SET type WDR_CONTEXT_ATTR_VALUE_LIST .
  methods ADAPT_APPLICATION_TITLE .
  methods ON_ROOT_KEY_CHANGED
    for event ROOT_KEY_CHANGED of CL_BS_GENIL_BUPA .
  methods GET_VALUE_SET_SEX
    importing
      !IO_ACCESS type ref to IF_BOL_BO_PROPERTY_ACCESS
      !IV_ATTR_NAME type NAME_KOMP
    exporting
      !ET_VALUE_SET type WDR_CONTEXT_ATTR_VALUE_LIST .

  methods CHECK_FIELD_USAGE_SINGLE
    redefinition .
  methods CREATE_STRUCT_RTTI
    redefinition .
  methods GET_ACTIONS
    redefinition .
  methods GET_ATTR_VALUE_SET
    redefinition .
  methods GET_DEFAULT_DISPLAY_TYPE
    redefinition .
  methods GET_ENTITY_DATA
    redefinition .
  methods GET_FIELD_UI_PROP
    redefinition .
  methods GET_INITIAL_DATA
    redefinition .
  methods SET_APPLICATION_TITLE
    redefinition .
  methods SET_VALUE_BY_MDG_NAME
    redefinition .
  methods get_changed_transient_fields REDEFINITION.
private section.
ENDCLASS.



CLASS Z_BS_BP_GUIBB_ROOT_1_WANG IMPLEMENTATION.


METHOD SET_VALUE_BY_MDG_NAME.
  DATA:
    lv_mdg_fieldname LIKE iv_mdg_fieldname,
    lv_category TYPE bu_type.



  lv_mdg_fieldname = iv_mdg_fieldname.
  CASE lv_mdg_fieldname.
    WHEN 'MCNAME1_STRING'
    OR 'MCNAME2_STRING'.
      me->mo_global_context->get_value(
        EXPORTING iv_id = 'BPCATEGORY'
        IMPORTING ev_data = lv_category
      ).
      IF lv_category IS INITIAL AND me->mo_entity IS BOUND
      AND me->mo_entity->alive( ) = abap_true.
        me->mo_entity->get_property_as_value(
          EXPORTING iv_attr_name = 'CATEGORY'
          IMPORTING ev_result = lv_category
        ).
      ENDIF.
      IF lv_mdg_fieldname = 'MCNAME1_STRING'.
        CASE lv_category.
          WHEN '1'. lv_mdg_fieldname = 'NAME_LAST'.
          WHEN '2'. lv_mdg_fieldname = 'NAME_ORG1'.
          WHEN '3'. lv_mdg_fieldname = 'NAME_GRP1'.
        ENDCASE.
      ELSE.
        CASE lv_category.
          WHEN '1'. lv_mdg_fieldname = 'NAM_FIRST'.
          WHEN '2'. lv_mdg_fieldname = 'NAME_ORG2'.
          WHEN '3'. lv_mdg_fieldname = 'NAME_GRP2'.
        ENDCASE.
      ENDIF.
  ENDCASE.
  super->set_value_by_mdg_name(
    EXPORTING iv_mdg_fieldname = lv_mdg_fieldname
              iv_value = iv_value
    CHANGING cs_data = cs_data
  ).
ENDMETHOD.


METHOD SET_APPLICATION_TITLE.
  "coding to set application title moved to technical UIBB
  "(feeder CL_BS_BP_GUIBB_ORIGIN)
  IF me->mv_adjust_application_title = abap_true
  AND me->mo_entity IS BOUND.
    me->mo_entity->reread( ).
  ENDIF.
  super->set_application_title( iv_for_target_page ).
ENDMETHOD.


METHOD ON_ROOT_KEY_CHANGED.
  CHECK me->mo_entity IS BOUND AND me->mo_entity->alive( ) = abap_true.
  me->mo_entity->reread( iv_invalidate_children = abap_true ).
ENDMETHOD.


METHOD MANIPULATE_STRUCT_RTTI.
  "Currently the UI framework (FPM) does not allow to dynamically hide useless
  "F4-helps, hence with that method the application UIBB feeder for root
  "will take care of this issue by dynamically "switching" the type description
  "of the relevant fields (e.g. Business Partner ID) during runtime. For each
  "of the relevant "field's type (data element) there's a pendant with prefix
  "BS_UI_" that is exactly the same as the original type besides having no
  "F4-help definition
  DATA:
    lt_components LIKE it_components,
    lt_include_components LIKE it_components,
    lo_structure_type TYPE REF TO cl_abap_structdescr,
    lv_type_name TYPE string.

  FIELD-SYMBOLS:
    <ls_component> LIKE LINE OF it_components.



  "the types of the component are about to being changed, hence copy
  "the entries to a local table (importing parameter cannot be changed)
  lt_components = it_components.
  LOOP AT lt_components ASSIGNING <ls_component>.
    IF <ls_component>-as_include = abap_true.
      "if the entry describes a type that is a structure itself then manipulate
      "its components then same way (recursively call this method for all
      "included structures)

*      If the include is customer specific then ignore    Note # 2061839
      CHECK <ls_component>-type->absolute_name <> '\TYPE=INCL_EEW_BUT000'.
      lo_structure_type ?= <ls_component>-type.
      lt_include_components = lo_structure_type->get_components( ).
      <ls_component>-type ?= me->manipulate_struct_rtti( lt_include_components ).
    ELSE.
      "this is the main check: if one of the data elements is the type of the
      "current structure component then replace it with its pendant that has
      "no F4-help declared in dictionary (prefix "BS_UI_")
      IF <ls_component>-type->absolute_name = '\TYPE=BU_PARTNER'.
        lv_type_name = |BS_UI_{ <ls_component>-type->get_relative_name( ) }|.
        <ls_component>-type ?= cl_abap_typedescr=>describe_by_name( lv_type_name ).
      ENDIF.
    ENDIF.
  ENDLOOP.
  "now create the RTTI description of the structure depending on its (manipulated)
  "components

  ro_struct_rtti = cl_abap_structdescr=>create( lt_components ).
ENDMETHOD.


METHOD IF_FPM_GUIBB_FORM~PROCESS_EVENT.
  super->if_fpm_guibb_form~process_event(
    EXPORTING
      io_event            = io_event
      iv_raised_by_own_ui = iv_raised_by_own_ui
    IMPORTING
      ev_result           = ev_result
      et_messages         = et_messages
  ).

  CASE io_event->mv_event_id.
    WHEN if_fpm_constants=>gc_event-cancel.
      IF me->mo_entity IS BOUND.
        me->mo_entity->reread( iv_invalidate_children = abap_true ).
      ENDIF.
  ENDCASE.
ENDMETHOD.


METHOD IF_FPM_GUIBB_FORM~GET_DEFINITION.
*! Get teh definition of the feeder class.
  FIELD-SYMBOLS:
    <ls_field_description> LIKE LINE OF et_field_description.

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

  LOOP AT et_field_description ASSIGNING <ls_field_description>.
    CASE <ls_field_description>-name.
      WHEN 'AUTHORIZATIONGROUP'
        OR 'BIRTHDT_STATUSPRS'
        OR 'GENDERPRS'.
        <ls_field_description>-is_nullable = abap_false.

      WHEN 'LOC_NO_1'
        OR 'LOC_NO_2'
        OR 'CHK_DIGIT'.
        <ls_field_description>-null_as_blank = abap_true.

      WHEN OTHERS.
        CHECK <ls_field_description>-tag_name = 'NATIONALITY'
           OR <ls_field_description>-tag_name = 'COUNTRYORIGIN'.
        <ls_field_description>-ddic_shlp_name = 'BS_SEARCH_COUNTRY'.
    ENDCASE.
  ENDLOOP.
ENDMETHOD.


  METHOD IF_FPM_GUIBB_FORM~GET_DATA.
*! Get current data.
    DATA:
      lo_connector TYPE REF TO cl_bs_bp_connector_bol_rel.

    "inherit first
    super->if_fpm_guibb_form~get_data(
      EXPORTING
        io_event                = io_event
        it_selected_fields      = it_selected_fields
        iv_raised_by_own_ui     = iv_raised_by_own_ui
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

    "event specific handling
    CASE io_event->mv_event_id.
      WHEN if_fpm_constants=>gc_event-done_and_back_to_main
        OR if_fpm_constants=>gc_event-call_default_edit_page
        OR if_fpm_constants=>gc_event-cancel.
        IF me->mo_entity IS BOUND.
          me->mo_entity->reread( iv_invalidate_children = abap_true ).
        ENDIF.
      WHEN if_fpm_constants=>gc_event-change_content_area.
        "The navigation to the edit page for relation partners might
        "have to lock the partner
        IF me->ms_instance_key-config_id EQ 'BS_BP_DETAILS'
          AND me->ms_instance_key-instance_id EQ 'RELATION'
          AND me->mo_entity IS BOUND
          AND me->mo_entity->alive( ) EQ abap_true
          AND me->mo_entity->is_locked( ) EQ abap_false
          AND me->mo_connector IS BOUND.
          lo_connector ?= me->mo_connector.
          IF lo_connector IS BOUND
            AND lo_connector->get_parent( ) IS BOUND
            AND lo_connector->get_parent( )->alive( ) EQ abap_true
            AND lo_connector->get_parent( )->is_locked( ) EQ abap_true.
            me->mo_entity->lock( ).
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


METHOD IF_FPM_GUIBB_FORM~FLUSH.
  DATA:
    lv_business_partner TYPE bu_partner,
    lv_category TYPE bu_type,
    lv_group TYPE bu_group,
    ls_group LIKE LINE OF me->mt_groups,
    ls_nriv TYPE nriv,
    lv_title TYPE ad_title,
    ls_tsad3 TYPE tsad3,
    lv_sex TYPE bu_sexid,
    ls_join_usage TYPE s_join_usage,
    lt_change_log TYPE fpmgb_t_changelog.

  FIELD-SYMBOLS:
    <lv_value> TYPE any,
    <ls_change_log> LIKE LINE OF it_change_log,
    <lv_group> TYPE bu_group.



  REFRESH lt_change_log.
  lt_change_log = it_change_log.

*   check for a change of the BP grouping
  READ TABLE lt_change_log WITH KEY name = 'GROUPING' ASSIGNING <ls_change_log>.
  IF sy-subrc = 0.
*     get value of the BP grouping
    ASSIGN <ls_change_log>-new_value->* TO <lv_group>.
    CHECK <lv_group> IS ASSIGNED.
    lv_group = <lv_group>.

    IF me->mt_groups IS INITIAL.
      SELECT bu_group nrrng FROM tb001 APPENDING TABLE me->mt_groups.
    ENDIF.

    READ TABLE me->mt_groups WITH KEY group = lv_group INTO ls_group.

    CALL FUNCTION 'NUMBER_GET_INFO'
      EXPORTING
        nr_range_nr        = ls_group-nrrng
        object             = 'BU_PARTNER'
      IMPORTING
        interval           = ls_nriv
      EXCEPTIONS
        interval_not_found = 1
        object_not_found   = 2
        OTHERS             = 3.

    IF sy-subrc = 0.
      IF ls_nriv-externind = space.  "SPACE means internal number assignment
       " With grouping having internal number assignment clear field "BP Number".
        me->set_access_attribute( io_access = me->mo_entity  iv_attr_name = 'PARTNER'  iv_value = '' ).
      ENDIF.
      READ TABLE lt_change_log WITH KEY name = 'BP_ID' TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        READ TABLE lt_change_log WITH KEY name = 'PARTNER' TRANSPORTING NO FIELDS.
      ENDIF.
      IF sy-subrc = 0.
        DELETE lt_change_log INDEX sy-tabix.
      ENDIF.
    ENDIF.
  ENDIF.

  super->if_fpm_guibb_form~flush(
    it_change_log = lt_change_log
    is_data       = is_data
  ).

  IF lt_change_log IS NOT INITIAL.
    me->mo_reporting->switch_to_scene( 'BP MAINTENANCE' ).
    READ TABLE lt_change_log ASSIGNING <ls_change_log>
         WITH KEY name = 'PARTNER'.
    IF sy-subrc = 0.
      ASSIGN <ls_change_log>-new_value->* TO <lv_value>.
      lv_business_partner = <lv_value>.
      me->mo_reporting->value_was_changed(
        iv_incident = 'BP'
        iv_value    = lv_business_partner
      ).
    ENDIF.
    READ TABLE lt_change_log ASSIGNING <ls_change_log>
         WITH KEY name = 'CATEGORY'.
    IF sy-subrc = 0.
      ASSIGN <ls_change_log>-new_value->* TO <lv_value>.
      lv_category = <lv_value>.
      me->mo_reporting->value_was_changed(
        iv_incident = 'CATEGORY'
        iv_value    = lv_category
      ).
    ENDIF.
  ENDIF.
  CHECK me->mo_entity IS BOUND AND me->mo_entity->alive( ) = abap_true.
  mo_entity->get_property_as_value(
    EXPORTING iv_attr_name = 'CATEGORY'
    IMPORTING ev_result    = lv_category
  ).
  IF lv_category = '1'.
    READ TABLE lt_change_log ASSIGNING <ls_change_log>
         WITH KEY name = 'TITLE_KEY'.
    IF sy-subrc = 0.
      ASSIGN <ls_change_log>-new_value->* TO <lv_value>.
      lv_title = <lv_value>.
      IF lv_title IS NOT INITIAL.
        CALL FUNCTION 'ADDR_TSAD3_READ'
          EXPORTING
            title_key = lv_title
          IMPORTING
            tsad3_out = ls_tsad3
          EXCEPTIONS
            OTHERS    = 1.
        IF sy-subrc = 0 AND ls_tsad3-sex IS NOT INITIAL. " Only needed if gender is known
          IF ls_tsad3-sex = '1'.
            lv_sex = '2'.
          ELSE.
            lv_sex = '1'.
          ENDIF.
        ENDIF.
        IF lv_sex IS NOT INITIAL. " Only update sex if gender is known
          LOOP AT me->mt_join_usage INTO ls_join_usage.
          CHECK ls_join_usage-entity->get_name( ) = cl_bs_genil_bupa=>gc_object_name-person.
          DATA ls_join_attr LIKE LINE OF me->mt_join_attr.
          READ TABLE me->mt_join_attr INTO ls_join_attr
               WITH KEY join_attr COMPONENTS bol_attr_name = 'SEX' join_id = ls_join_usage-join_id.
          CHECK sy-subrc = 0.
          me->set_access_attribute( io_access = me->mo_entity  iv_attr_name = ls_join_attr-name  iv_value = lv_sex ).
        ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  me->mo_morph_reporting->morph_spot_changed(
    iv_morph_spot_name = cl_bs_bp_ovp_assist=>gc_morph_spot_name-bp_category
    iv_morph_spot_value = |{ lv_category }|
  ).
ENDMETHOD.


METHOD IF_BS_BOL_HOW_FEEDER~CURRENT_ENTITY.
  CHECK me->ms_instance_key-instance_id IS NOT INITIAL.
  ro_entity = me->mo_entity.
ENDMETHOD.


METHOD GET_VALUE_SET_TITLE_KEY.
  DATA:
    lo_property_access  TYPE REF TO if_bol_bo_property_access,
    lt_valid_title_keys TYPE STANDARD TABLE OF tsad3,
    ls_value_set LIKE LINE OF et_value_set.

  FIELD-SYMBOLS:
    <ls_value_set> LIKE LINE OF et_value_set.



  lo_property_access = me->get_property_access( ).
  CHECK lo_property_access IS BOUND.
  CASE lo_property_access->get_property_as_string( 'CATEGORY' ).
    WHEN '1'.
      SELECT * FROM tsad3 INTO TABLE lt_valid_title_keys WHERE person = abap_true.
    WHEN '2'.
      SELECT * FROM tsad3 INTO TABLE lt_valid_title_keys WHERE organizatn = abap_true.
    WHEN '3'.
      SELECT * FROM tsad3 INTO TABLE lt_valid_title_keys WHERE xgroup = abap_true.
  ENDCASE.
  LOOP AT et_value_set INTO ls_value_set.
    READ TABLE lt_valid_title_keys TRANSPORTING NO FIELDS
               WITH KEY title = ls_value_set-value.
    CHECK sy-subrc <> 0.
    DELETE et_value_set.
  ENDLOOP.
  SORT et_value_set BY text.
ENDMETHOD.


METHOD GET_VALUE_SET_SEX.
  DATA:
    ls_value_set LIKE LINE OF et_value_set.

  "The space is also the once of the single values from the value range
  "of the corresponding DDIC Domain
  LOOP AT et_value_set INTO ls_value_set
    WHERE value = space.
    DELETE et_value_set.
  ENDLOOP.
  SORT et_value_set BY text.

ENDMETHOD.


METHOD GET_VALUE_SET_AUTH_GROUP.
  DATA:
    lv_actvt      TYPE activ_auth,
    lo_entity     TYPE REF TO cl_crm_bol_entity,
    lv_bp_id      TYPE bu_partner.



  lo_entity ?= io_access.
  CHECK lo_entity IS BOUND.

  IF lo_entity->is_changeable( ) EQ abap_true.
    lv_bp_id = lo_entity->get_root( )->get_property_as_string( 'PARTNER' ).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_bp_id
      IMPORTING
        output = lv_bp_id.
*   Find out if BP is being created or changed (prop IS_NEW is unfortunately not set in any case)
    IF cl_mdg_bs_fnd_bp_services=>is_new_partner( iv_bp_id = lv_bp_id ) EQ abap_true.
      lv_actvt = '01'.  "BP is being created
    ELSE.
      lv_actvt = '02'.  "BP is being changed
    ENDIF.
    CALL METHOD cl_mdg_bs_fnd_bp_services=>filter_begru_list_by_auth
      EXPORTING
        iv_actvt = lv_actvt
      CHANGING
        ct_begru = et_value_set.
  ENDIF.

ENDMETHOD.


METHOD GET_INITIAL_DATA.
  DATA:
    lt_search_criteria TYPE fpmgb_t_search_criteria,
    ls_search_criterion LIKE LINE OF lt_search_criteria.

  FIELD-SYMBOLS:
    <ls_default_values> TYPE any,
    <lv_value> TYPE any.



  rs_initial_data = super->get_initial_data( iv_event_id ).
  CHECK rs_initial_data-default_values IS BOUND
  AND iv_event_id = if_fpm_constants=>gc_event-leave_initial_screen.

  ASSIGN rs_initial_data-default_values->* TO <ls_default_values>.
  me->mo_global_context->get_value(
    EXPORTING iv_id   = cl_bs_bp_ovp_assist=>gc_context_id-search_criteria
    IMPORTING ev_data = lt_search_criteria
  ).
  READ TABLE lt_search_criteria INTO ls_search_criterion
       WITH KEY search_attribute = 'MCNAME1_STRING'.
  IF sy-subrc <> 0.
    READ TABLE lt_search_criteria INTO ls_search_criterion
         WITH KEY search_attribute = 'MCNAME1'.
  ENDIF.
  IF sy-subrc <> 0.
    READ TABLE lt_search_criteria INTO ls_search_criterion
         WITH KEY search_attribute = 'NAME_ORG1'.
  ENDIF.
  IF sy-subrc = 0 AND ls_search_criterion-low IS NOT INITIAL.
    ASSIGN COMPONENT 'NAME1' OF STRUCTURE <ls_default_values> TO <lv_value>.
    IF sy-subrc = 0 AND <lv_value> IS INITIAL.
      <lv_value> = ls_search_criterion-low.
    ENDIF.
  ENDIF.

  READ TABLE lt_search_criteria INTO ls_search_criterion
       WITH KEY search_attribute = 'MCNAME2_STRING'.
  IF sy-subrc <> 0.
    READ TABLE lt_search_criteria INTO ls_search_criterion
         WITH KEY search_attribute = 'MCNAME2'.
  ENDIF.
  IF sy-subrc <> 0.
    READ TABLE lt_search_criteria INTO ls_search_criterion
         WITH KEY search_attribute = 'NAME_ORG2'.
  ENDIF.
  IF sy-subrc = 0 AND ls_search_criterion-low IS NOT INITIAL.
    ASSIGN COMPONENT 'NAME2' OF STRUCTURE <ls_default_values> TO <lv_value>.
    IF sy-subrc = 0 AND <lv_value> IS INITIAL.
      <lv_value> = ls_search_criterion-low.
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD GET_FIELD_UI_PROP.
*** This method controls the field UI properties.
  DATA:
    lv_action TYPE string.

* call parent class
  rs_property = super->get_field_ui_prop(
    io_entity         = io_entity
    iv_attr_name      = iv_attr_name
    iv_change_allowed = iv_change_allowed
    is_prop           = is_prop ).

  IF me->mo_entity IS BOUND AND me->mo_entity->get_parent( ) IS BOUND.
    IF iv_attr_name = 'BP_ID' OR iv_attr_name = 'PARTNER'
    OR iv_attr_name = 'GROUPING'.
      rs_property-read_only = abap_true.
      rs_property-visible = if_fpm_constants=>gc_visibility-not_visible.
    ENDIF.
  ENDIF.

*** Enable the fields for BLOCK and DELETE
  CHECK me->mo_app_parameter IS BOUND.
  me->mo_app_parameter->get_value(
    EXPORTING
      iv_key   = 'ACTION'
    IMPORTING
      ev_value = lv_action ).

  CHECK ( lv_action EQ cl_mdg_bs_communicator_assist=>gc_action-block OR
          lv_action EQ cl_mdg_bs_communicator_assist=>gc_action-delete )
    AND me->mo_entity IS BOUND.

  IF lv_action EQ cl_mdg_bs_communicator_assist=>gc_action-block
    AND iv_attr_name EQ 'CENTRALBLOCK'
    AND me->mo_entity->is_change_allowed( ) EQ abap_true.
    rs_property-read_only = abap_false.
    RETURN.
  ENDIF.

  IF lv_action EQ cl_mdg_bs_communicator_assist=>gc_action-delete
    AND iv_attr_name EQ 'CENTRALARCHIVINGFLAG'
    AND me->mo_entity->is_change_allowed( ) EQ abap_true.
    rs_property-read_only = abap_false.
  ENDIF.
ENDMETHOD.


METHOD GET_ENTITY_DATA.
  DATA:
    ls_join_usage TYPE s_join_usage,
    lo_entity TYPE REF TO cl_crm_bol_entity,
    lv_category TYPE bu_type.

  FIELD-SYMBOLS:
    <lv_data> TYPE any,
    <lv_key>  TYPE any.



  super->get_entity_data(
    EXPORTING io_access = io_access
    CHANGING cs_data = cs_data
  ).

  CHECK io_access IS BOUND.

  ASSIGN COMPONENT 'TITLE_KEY__TEXT' OF STRUCTURE cs_data TO <lv_data>.
  IF sy-subrc = 0 AND <lv_data> IS NOT INITIAL.
    <lv_data> = io_access->get_property_text( 'TITLE_KEY' ).
  ENDIF.

  ASSIGN COMPONENT 'NATIONALITYPRS__TEXT' OF STRUCTURE cs_data TO <lv_data>.
  IF sy-subrc = 0 AND <lv_data> IS INITIAL.
    ASSIGN COMPONENT 'NATIONALITYPRS' OF STRUCTURE cs_data TO <lv_key>.
    IF sy-subrc = 0 AND <lv_key> IS NOT INITIAL.
      IF me->mo_entity IS BOUND.
        <lv_data> = me->mo_entity->get_related_entity( cl_bs_genil_bupa=>gc_relation_name-person )->get_property_text( 'NATIONALITY' ).
      ENDIF.
    ENDIF.
  ENDIF.

  ASSIGN COMPONENT 'COUNTRYORIGINPRS__TEXT' OF STRUCTURE cs_data TO <lv_data>.
  IF sy-subrc = 0 AND <lv_data> IS INITIAL.
    ASSIGN COMPONENT 'COUNTRYORIGINPRS' OF STRUCTURE cs_data TO <lv_key>.
    IF sy-subrc = 0 AND <lv_key> IS NOT INITIAL.
      IF me->mo_entity IS BOUND.
        <lv_data> = me->mo_entity->get_related_entity( cl_bs_genil_bupa=>gc_relation_name-person )->get_property_text( 'COUNTRYORIGIN' ).
      ENDIF.
    ENDIF.
  ENDIF.

  ASSIGN COMPONENT 'CORRESPONDLANGUAGEPRS__TEXT' OF STRUCTURE cs_data TO <lv_data>.
  IF sy-subrc = 0 AND <lv_data> IS INITIAL.
    ASSIGN COMPONENT 'CORRESPONDLANGUAGEPRS' OF STRUCTURE cs_data TO <lv_key>.
    IF sy-subrc = 0 AND <lv_key> IS NOT INITIAL.
      IF me->mo_entity IS BOUND.
        <lv_data> = me->mo_entity->get_related_entity( cl_bs_genil_bupa=>gc_relation_name-person )->get_property_text( 'CORRESPONDLANGUAGE' ).
      ENDIF.
    ENDIF.
  ENDIF.

  io_access->get_property_as_value(
    EXPORTING iv_attr_name = 'CATEGORY'
    IMPORTING ev_result    = lv_category
  ).
  IF lv_category IS NOT INITIAL.
    me->mo_reporting->value_was_changed(
      iv_scene_name = 'CBA_DIMENSIONS'
      iv_incident   = 'CATEGORY'
      iv_value      = lv_category
    ).
    me->mo_morph_reporting->morph_spot_changed(
      iv_morph_spot_name = cl_bs_bp_ovp_assist=>gc_morph_spot_name-bp_category
      iv_morph_spot_value = |{ lv_category }|
    ).
  ENDIF.
ENDMETHOD.


METHOD GET_DEFAULT_DISPLAY_TYPE.
  CASE iv_name.
    WHEN 'LEGALORG'.
      rv_display_type = if_fpm_guibb_constants=>gc_display_type-drop_down_list_box.
    WHEN 'LEGALFORM'.
      rv_display_type = if_fpm_guibb_constants=>gc_display_type-drop_down_list_box.
    WHEN 'GROUPING'.
      rv_display_type = if_fpm_guibb_constants=>gc_display_type-drop_down_list_box.
    WHEN OTHERS.
      rv_display_type = super->get_default_display_type( iv_name ).
  ENDCASE.
ENDMETHOD.


METHOD GET_CHANGED_TRANSIENT_FIELDS.
  DATA ls_changed_field LIKE LINE OF it_changed_fields.

  CHECK it_changed_fields IS NOT INITIAL.
  CREATE DATA rrt_trans_fields_mapping.
  READ TABLE it_changed_fields INTO ls_changed_field
       WITH KEY object_name = cl_bs_genil_bupa=>gc_object_name-root
                field_name = 'PARTNER'.
  IF sy-subrc = 0.
    APPEND 'BP_ID' TO ls_changed_field-transient_mapping.
    INSERT ls_changed_field INTO TABLE rrt_trans_fields_mapping->*.
  ENDIF.
ENDMETHOD.


METHOD GET_ATTR_VALUE_SET.
  "The description fields are only the text fields without the value tables
  CHECK iv_attr_name NP '*__TEXT'.

  super->get_attr_value_set(
    EXPORTING
      io_access    = io_access
      iv_attr_name = iv_attr_name
    IMPORTING
      et_value_set = et_value_set
  ).

  CASE iv_attr_name.
    WHEN 'TITLE_KEY'.
      me->get_value_set_title_key(
        EXPORTING
          io_access    = io_access
          iv_attr_name = iv_attr_name
        IMPORTING
          et_value_set = et_value_set
      ).

    WHEN 'AUTHORIZATIONGROUP'.
      me->get_value_set_auth_group(
        EXPORTING
          io_access    = io_access
          iv_attr_name = iv_attr_name
        IMPORTING
          et_value_set = et_value_set
      ).

    WHEN 'SEX'.
      me->get_value_set_sex(
        EXPORTING
          io_access    = io_access
          iv_attr_name = iv_attr_name
        IMPORTING
          et_value_set = et_value_set
      ).

    WHEN OTHERS.
      RETURN.
  ENDCASE.
ENDMETHOD.


METHOD GET_ACTIONS.
  FIELD-SYMBOLS:
    <ls_actiondef> LIKE LINE OF mt_actiondef,
    <ls_fixed_value> LIKE LINE OF <ls_actiondef>-extended-fixed_values.



  super->get_actions( ).

  APPEND INITIAL LINE TO mt_actiondef ASSIGNING <ls_actiondef>.
  <ls_actiondef>-id = 'CREATE_PER'.
  <ls_actiondef>-text = text-001.
  <ls_actiondef>-enabled = abap_true.
  <ls_actiondef>-visible = cl_wd_uielement=>e_visible-visible.
  <ls_actiondef>-exposable = abap_true.
  <ls_actiondef>-imagesrc = '~Icon/NewItem'.
  <ls_actiondef>-disable_when_no_lead_sel = abap_false.
  <ls_actiondef>-event_param_strukname = 'BSS_EVENT_PARAMS'.
  APPEND INITIAL LINE TO mt_actiondef ASSIGNING <ls_actiondef>.
  <ls_actiondef>-id = 'CREATE_ORG'.
  <ls_actiondef>-text = text-002.
  <ls_actiondef>-enabled = abap_true.
  <ls_actiondef>-visible = cl_wd_uielement=>e_visible-visible.
  <ls_actiondef>-exposable = abap_true.
  <ls_actiondef>-imagesrc = '~Icon/NewItem'.
  <ls_actiondef>-disable_when_no_lead_sel = abap_false.
  <ls_actiondef>-event_param_strukname = 'BSS_EVENT_PARAMS'.
  APPEND INITIAL LINE TO mt_actiondef ASSIGNING <ls_actiondef>.
  <ls_actiondef>-id = 'CREATE_GRP'.
  <ls_actiondef>-text = text-003.
  <ls_actiondef>-enabled = abap_true.
  <ls_actiondef>-visible = cl_wd_uielement=>e_visible-visible.
  <ls_actiondef>-exposable = abap_true.
  <ls_actiondef>-imagesrc = '~Icon/NewItem'.
  <ls_actiondef>-disable_when_no_lead_sel = abap_false.
  <ls_actiondef>-event_param_strukname = 'BSS_EVENT_PARAMS'.
  APPEND INITIAL LINE TO mt_actiondef ASSIGNING <ls_actiondef>.
  <ls_actiondef>-id = if_fpm_constants=>gc_event-cancel.
  <ls_actiondef>-text = text-005.
  <ls_actiondef>-enabled = abap_false.
  <ls_actiondef>-visible = cl_wd_uielement=>e_visible-visible.
  <ls_actiondef>-exposable = abap_true.
  <ls_actiondef>-disable_when_no_lead_sel = abap_false.
  <ls_actiondef>-imagesrc = '~Icon/Cancel'.
*  <ls_actiondef>-TOGGLE_STATE
*  <ls_actiondef>-TOOLTIP
*  <ls_actiondef>-IMAGESRC
*  <ls_actiondef>-EXTENDED-DDIC_SHLP_NAME
*  <ls_actiondef>-EXTENDED-OVS_NAME
*  <ls_actiondef>-EXTENDED-DATA_TYPE
*  <ls_actiondef>-HELP_TEXT
*  <ls_actiondef>-EVENT_PARAM_STRUKNAME
*  <ls_actiondef>-ACTION_TYPE
  APPEND INITIAL LINE TO mt_actiondef ASSIGNING <ls_actiondef>.
  <ls_actiondef>-id = cl_bs_bp_ovp_assist=>gc_event-back.
  <ls_actiondef>-text = text-006.
  <ls_actiondef>-enabled = abap_true.
  <ls_actiondef>-visible = cl_wd_uielement=>e_visible-visible.
  <ls_actiondef>-exposable = abap_true.
  <ls_actiondef>-disable_when_no_lead_sel = abap_false.
  <ls_actiondef>-imagesrc = '~Icon/MoveLeft'.
ENDMETHOD.


METHOD CREATE_STRUCT_RTTI.
  DATA:
    lt_components TYPE cl_abap_structdescr=>component_table.

  FIELD-SYMBOLS:
    <ls_component> LIKE LINE OF lt_components.



  me->mv_key_name = 'PARTNER'.
  me->mv_key_alias_name = 'BP_ID'.

  super->create_struct_rtti( ).

  lt_components = me->mo_struct_rtti->get_components( ).
  me->mo_struct_rtti = me->manipulate_struct_rtti( lt_components ).
  CLEAR lt_components.

  APPEND INITIAL LINE TO lt_components ASSIGNING <ls_component>.
  <ls_component>-name = cv_comp_bol_data.
  <ls_component>-type = me->mo_struct_rtti.
  <ls_component>-as_include = abap_true.

  APPEND INITIAL LINE TO lt_components ASSIGNING <ls_component>.
  <ls_component>-name = 'TITLE_KEY__TEXT'.
  <ls_component>-type = cl_abap_elemdescr=>get_string( ).

  APPEND INITIAL LINE TO lt_components ASSIGNING <ls_component>.
  <ls_component>-name = 'NATIONALITYPRS__TEXT'.
  <ls_component>-type = cl_abap_elemdescr=>get_string( ).

  APPEND INITIAL LINE TO lt_components ASSIGNING <ls_component>.
  <ls_component>-name = 'COUNTRYORIGINPRS__TEXT'.
  <ls_component>-type = cl_abap_elemdescr=>get_string( ).

  APPEND INITIAL LINE TO lt_components ASSIGNING <ls_component>.
  <ls_component>-name = 'CORRESPONDLANGUAGEPRS__TEXT'.
  <ls_component>-type = cl_abap_elemdescr=>get_string( ).

  me->mo_struct_rtti = cl_abap_structdescr=>create( lt_components ).
ENDMETHOD.


METHOD CONSTRUCTOR.
  DATA ls_dynamic_label LIKE LINE OF me->mt_dynamic_labels.

  super->constructor( ).
  me->mo_reporting = cl_bs_inob_observation_center=>get_instance( )->establish_reporter( me ).
  me->mo_morph_reporting = cl_bs_morph_reporting=>get_instance( ).
  SET HANDLER on_root_key_changed FOR ALL INSTANCES ACTIVATION abap_true.
  ls_dynamic_label-name = cl_bs_genil_bupa=>gc_object_name-root.
  SPLIT 'PARTNER,GROUPING,SEARCHTERM1,SEARCHTERM2' AT ',' INTO TABLE ls_dynamic_label-fields.
  INSERT ls_dynamic_label INTO TABLE me->mt_dynamic_labels.
  ls_dynamic_label-name = cl_bs_genil_bupa=>gc_object_name-person.
  SPLIT 'FIRSTNAME,LASTNAME,BIRTHDATE' AT ',' INTO TABLE ls_dynamic_label-fields.
  INSERT ls_dynamic_label INTO TABLE me->mt_dynamic_labels.
ENDMETHOD.


METHOD CHECK_FIELD_USAGE_SINGLE.
  super->check_field_usage_single( CHANGING cs_field_usage = cs_field_usage ).
  IF me->ms_instance_key-instance_id = 'RELATION'.
    IF cs_field_usage-name = 'BP_ID' OR cs_field_usage-name = 'PARTNER'
    OR cs_field_usage-name = 'GROUPING'.
      cs_field_usage-read_only = abap_true.
      cs_field_usage-visibility = if_fpm_constants=>gc_visibility-not_visible.
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD ADAPT_APPLICATION_TITLE.
*  DATA:
*    lv_application_title TYPE string.
*
*
*
*  CHECK me->mv_adapt_application_title = abap_true.
*  me->mv_adapt_application_title = abap_false.
*  IF me->mo_entity IS BOUND.
*    CASE me->mo_entity->get_property_as_string( 'CATEGORY' ).
*      WHEN '1'.
*        lv_application_title = text-001.
*      WHEN '2'.
*        lv_application_title = text-002.
*      WHEN '3'.
*        lv_application_title = text-003.
*    ENDCASE.
*    lv_application_title = |{ lv_application_title }: { me->mo_entity->get_property_as_string( 'PARTNER' ) }| &&
*                           |, { me->mo_entity->get_property_as_string( 'DESCRIPTION' ) }|.
*    me->mo_historical_context->set_value(
*      iv_id = cl_bs_bp_ovp_assist=>gc_context_id-application_title
*      iv_data = lv_application_title
*    ).
*  ELSE.
*    me->mo_historical_context->get_value(
*      EXPORTING iv_id = cl_bs_bp_ovp_assist=>gc_context_id-application_title
*      IMPORTING ev_data = lv_application_title
*    ).
*  ENDIF.
*  CHECK lv_application_title IS NOT INITIAL.
**  me->mo_fpm_toolbox->mo_fpm->set_application_title( lv_application_title ).
*  me->mo_fpm_toolbox->set_title( lv_application_title ).
ENDMETHOD.
ENDCLASS.
