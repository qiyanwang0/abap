class ZCL_CALL_METHOD_WANG definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_USMD_SSW_SYST_METHOD_CALLER .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CALL_METHOD_WANG IMPLEMENTATION.


METHOD IF_USMD_SSW_SYST_METHOD_CALLER~CALL_SYSTEM_METHOD.
* Create a follow-up change request with reference to an existing, activated change request
* Copies the object list and most of the CR data

TYPES:BEGIN OF s_application_data,
               id      TYPE if_fdt_types=>id,
               name    TYPE if_fdt_types=>name,
               text    TYPE if_fdt_types=>text,
               cr_user TYPE syuname,
      END OF  s_application_data.

TYPES:BEGIN OF ts_msg_txt_data,
               previous_step       type char24,
               previous_action     type char24,
               condition_alias     type char24,
               new_change_step     type char24,
     END OF ts_msg_txt_data.

TYPES:BEGIN OF ts_msg_txt_data_us,
               row_no           type index,
               condition_alias       type char24,
               user_agent_type     type char24,
               user_value     type char24,
      END OF ts_msg_txt_data_us.

TYPES: BEGIN OF ts_table_data, row_no  TYPE int4,
            col_no                   TYPE int4,
            expression_id            TYPE if_fdt_types=>id,
            r_value                  TYPE REF TO data,
            ts_range                 TYPE if_fdt_range=>ts_range,
       END OF ts_table_data .

 DATA admin_data type REF TO CL_FDT_DECISION_TABLE.
 DATA lt_msg_data TYPE if_fdt_decision_table=>ts_table_data.
 DATA ls_table_data_msg TYPE ts_table_data.
 DATA lt_table_data_msg TYPE TABLE OF ts_table_data.
 DATA ls_msg_data LIKE LINE OF  lt_msg_data.
 DATA ls_table_data1 TYPE ts_table_data.
 DATA ls_msg_txt_data type ts_msg_txt_data.
 DATA ls_msg_txt_data_us type ts_msg_txt_data_us.
 DATA ls_range_msg TYPE if_fdt_range=>s_range.
 DATA lt_msg_txt_data type STANDARD TABLE OF ts_msg_txt_data.
 DATA lt_msg_txt_data_us type STANDARD TABLE OF ts_msg_txt_data_us.
 DATA lt_next_data_us type STANDARD TABLE OF ts_msg_txt_data_us.
 DATA :   l_return_code   LIKE sy-subrc,
          lt_cont         TYPE STANDARD TABLE OF swr_cont,
          ls_cont         TYPE swr_cont.

 FIELD-SYMBOLS : <fs_lv_value> type any,
                 <fs_lv_row> type any,
                 <fs_lt_data> TYPE ANY TABLE.

DATA: lo_fdt_query    TYPE REF TO if_fdt_query.
DATA lo_wf type ref to CL_USMD_WF_SERVICE.
DATA lo_api type ref to if_usmd_gov_api.
DATA lv_crequest type usmd_s_crequest.

CLEAR ev_action.
CLEAR et_message.
CASE iv_service_name.
  WHEN 'Z_GET_APPROVER'.


*    DATA lo_crequest type REF TO if_usmd_crequest_api.
*    CL_USMD_CREQUEST_API=>get_instance(
*     EXPORTING
*       IV_CREQUEST = IV_CR_NUMBER
*       IV_MODEL_NAME = 'MM'
*     IMPORTING
*       RE_INST_CREQUEST_API = lo_crequest
*       ET_MESSAGE = DATA(lt_message)
*
*     ).
*    DATA IT_TABLE TYPE REF TO DATA.
*
*
*    CALL METHOD lo_crequest->read_crequest
*      IMPORTING
*        es_crequest = DATA(w_crequest).
*
*    Check w_crequest is not INITIAL.
*    CALL METHOD lo_crequest->CREATE_DATA_REFERENCE(
*     EXPORTING
*      IV_ENTITY = 'MATERIAL'
*     IMPORTING
*      ER_TABLE = IT_TABLE
*      ).
*
*    FIELD-SYMBOLS <IT_TABLE> TYPE ANY TABLE.
*    ASSIGN IT_TABLE->* TO <IT_TABLE>.
*
*    CALL METHOD lo_crequest->READ_VALUE(
*     EXPORTING
*      I_FIELDNAME = 'MATERIAL'
*      IF_CURRENT_CREQ_ONLY = abap_true
*     IMPORTING
*       ET_DATA = <IT_TABLE>
*
*    ).
*
*    CHECK <IT_TABLE> is ASSIGNED.
  DATA lr_gov_api TYPE REF TO if_usmd_conv_som_gov_api.
     DATA : ls_entity_key  TYPE usmd_gov_api_s_ent_tabl,
      lt_entity_key  TYPE usmd_gov_api_ts_ent_tabl,
      ls_entity_data TYPE usmd_gov_api_s_ent_tabl,
      lt_entity_data TYPE usmd_gov_api_ts_ent_tabl,
      lrs_data       TYPE REF TO data,
             lt_object_dg   TYPE usmd_t_crequest_entity,
      lr_object_dg   TYPE REF TO usmd_s_crequest_entity.

   lr_gov_api = cl_usmd_conv_som_gov_api=>get_instance( 'MM' ).
   lr_gov_api->set_environment( iv_crequest_id = iv_cr_number ).


   FIELD-SYMBOLS:
      <lt_ent_data> TYPE ANY TABLE,
      <ls_ent_data> TYPE any,
      <ls_key>      TYPE any,
      <ls_field>    TYPE any.

    lr_gov_api->get_object_list( IMPORTING et_object_list_db_style = lt_object_dg[] ).

      READ TABLE lt_object_dg REFERENCE INTO lr_object_dg
        WITH KEY usmd_entity = 'MATERIAL'.
      IF sy-subrc = 0.
        DATA(matnr) = lr_object_dg->usmd_value.


      ENDIF.

WHEN 'Z_GET_APPROVER1'.

lo_api = cl_usmd_gov_api=>get_instance( IV_MODEL_NAME = 'MM' ).
lo_api->GET_CREQUEST_ATTRIBUTES(
 EXPORTING
  iv_crequest_id = iv_cr_number
 RECEIVING
  rs_crequest = lv_crequest
 ).
DATA(lv_crtype) = lv_crequest-USMD_CREQ_TYPE.

cl_usmd_wf_service=>get_cr_top_wf( EXPORTING id_crequest = iv_cr_number
                                   IMPORTING et_workflow = DATA(lt_top_wf)
                                             ed_rtcode = DATA(lv_rcode) ).
CHECK lt_top_wf is not INITIAL.

READ TABLE lt_top_wf INDEX 1 into DATA(ls_top_wf).

CALL FUNCTION 'SAP_WAPI_READ_CONTAINER'
   EXPORTING
      workitem_id      = ls_top_wf-WI_ID
   IMPORTING
      return_code      = l_return_code
   TABLES
      simple_container = lt_cont.

loop at lt_cont into ls_cont.
  IF ls_cont-element = 'STEP_ACTION'.
   DATA(lv_step_act) = ls_cont-value.
   DATA(lv_step) = lv_step_act+0(2).
  ENDIF.
endloop.

CHECK lv_step is not INITIAL.

CALL METHOD cl_fdt_query=>get_instance
           RECEIVING
             ro_query = lo_fdt_query.

DATA lv_single_table TYPE IF_FDT_TYPES=>NAME.
DATA lv_user_table TYPE IF_FDT_TYPES=>NAME.
CONCATENATE 'DT_SINGLE_VAL_' lv_crtype into lv_single_table.
CONCATENATE 'DT_USER_AGT_GRP_' lv_crtype into lv_user_table.

* get application id
         CALL METHOD lo_fdt_query->get_ids
           EXPORTING
             iv_name       = lv_single_table
           IMPORTING
             ets_object_id = DATA(lt_id).
         READ TABLE lt_id INTO DATA(lv_app_id) INDEX 1.


 admin_data ?= CL_FDT_CONVENIENCE=>get_admin_data( lv_app_id ).

 admin_data->IF_FDT_DECISION_TABLE~GET_TABLE_DATA(
  IMPORTING
    ETS_DATA = lt_msg_data
 ).


 LOOP AT lt_msg_data INTO ls_msg_data.
  ls_table_data_msg-row_no = ls_msg_data-row_no.
  ls_table_data_msg-col_no = ls_msg_data-col_no.
  ls_table_data_msg-expression_id = ls_msg_data-expression_id.
  ls_table_data_msg-r_value = ls_msg_data-r_value.
  ls_table_data_msg-ts_range = ls_msg_data-ts_range.
  APPEND ls_table_data_msg TO lt_table_data_msg.
  CLEAR ls_table_data_msg.
 ENDLOOP.

 SORT lt_table_data_msg BY row_no col_no.

 LOOP AT lt_table_data_msg INTO ls_table_data_msg.
   ls_table_data1 = ls_table_data_msg.
   CASE ls_table_data1-col_no.
*   previous_step
      when 1.
         IF ls_table_data1-ts_range IS NOT INITIAL.
            READ TABLE ls_table_data1-ts_range INTO ls_range_msg INDEX 1.
            IF sy-subrc = 0.
             ASSIGN ls_range_msg-r_low_value->* TO <fs_lv_value>.
                   ls_msg_txt_data-previous_step  = <fs_lv_value>.
            ENDIF.
         ENDIF.
*    previous_action
        when 2.
           IF ls_table_data1-ts_range IS NOT INITIAL.
              READ TABLE ls_table_data1-ts_range INTO ls_range_msg INDEX 1.
               IF sy-subrc = 0.
                ASSIGN ls_range_msg-r_low_value->* TO <fs_lv_value>.
                 ls_msg_txt_data-previous_action = <fs_lv_value>.
               ENDIF.
            ENDIF.
*     condition_alias
          when 8.
            IF ls_table_data1-r_value IS NOT INITIAL.
              ASSIGN ls_table_data1-r_value->* TO <fs_lv_value>.
               ls_msg_txt_data-condition_alias  = <fs_lv_value>.
            ENDIF.
*     new_change_step
          when 9.
            IF ls_table_data1-r_value IS NOT INITIAL.
             ASSIGN ls_table_data1-r_value->* TO <fs_lv_value>.
             ls_msg_txt_data-new_change_step = <fs_lv_value>.
            ENDIF.
         endcase.
           AT END OF row_no .
            APPEND ls_msg_txt_data TO lt_msg_txt_data.
            CLEAR ls_msg_txt_data.
           ENDAT.
   endloop.

Clear ls_msg_txt_data.
Loop at lt_msg_txt_data into ls_msg_txt_data.
  IF ls_msg_txt_data-previous_step = lv_step.
    DATA(lv_con) = ls_msg_txt_data-condition_alias.
  ENDIF.

ENDLOOP.

CHECK lv_con is not INITIAL.

CLEAR : ls_msg_txt_data, lt_msg_txt_data, lt_msg_data, ls_msg_data, lt_id, lv_app_id,
        ls_table_data_msg, lt_table_data_msg, ls_table_data1, ls_range_msg.
UNASSIGN <fs_lv_value>.


* get application id
         CALL METHOD lo_fdt_query->get_ids
           EXPORTING
             iv_name       = lv_user_table
           IMPORTING
             ets_object_id = lt_id.
         READ TABLE lt_id INTO lv_app_id INDEX 1.


 admin_data ?= CL_FDT_CONVENIENCE=>get_admin_data( lv_app_id ).

 admin_data->IF_FDT_DECISION_TABLE~GET_TABLE_DATA(
  IMPORTING
    ETS_DATA = lt_msg_data ).


 LOOP AT lt_msg_data INTO ls_msg_data.
  ls_table_data_msg-row_no = ls_msg_data-row_no.
  ls_table_data_msg-col_no = ls_msg_data-col_no.
  ls_table_data_msg-expression_id = ls_msg_data-expression_id.
  ls_table_data_msg-r_value = ls_msg_data-r_value.
  ls_table_data_msg-ts_range = ls_msg_data-ts_range.
  APPEND ls_table_data_msg TO lt_table_data_msg.
  CLEAR ls_table_data_msg.
 ENDLOOP.

 SORT lt_table_data_msg BY row_no col_no.

 LOOP AT lt_table_data_msg INTO ls_table_data_msg.
   ls_table_data1 = ls_table_data_msg.
   CASE ls_table_data1-col_no.
*   condition_alias
      when 1.
         IF ls_table_data1-ts_range IS NOT INITIAL.
            loop at ls_table_data1-ts_range into ls_range_msg.
              ASSIGN : ls_range_msg-r_low_value->* TO <fs_lv_value>,
                      ls_table_data1-row_no TO <fs_lv_row>.
                    ls_msg_txt_data_us-condition_alias = <fs_lv_value>.
                    ls_msg_txt_data_us-row_no = <fs_lv_row>.
                    append ls_msg_txt_data_us to lt_msg_txt_data_us.
            ENDLOOP.
          ENDIF.
*    User agent type
        when 4.
           IF ls_table_data1-r_value IS NOT INITIAL.
             loop at lt_msg_txt_data_us into ls_msg_txt_data_us.
               IF ls_table_data_msg-row_no = ls_msg_txt_data_us-row_no.
                 ASSIGN ls_table_data1-r_value->* TO <fs_lv_value>.
                 ls_msg_txt_data_us-user_agent_type = <fs_lv_value>.
                 MODIFY lt_msg_txt_data_us from ls_msg_txt_data_us.
               ENDIF.
             endloop.
           ENDIF.
*     User value
          when 5.
            IF ls_table_data1-r_value IS NOT INITIAL.
              loop at lt_msg_txt_data_us into ls_msg_txt_data_us.
               IF ls_table_data_msg-row_no = ls_msg_txt_data_us-row_no.
                 ASSIGN ls_table_data1-r_value->* TO <fs_lv_value>.
                 ls_msg_txt_data_us-user_value = <fs_lv_value>.
                 MODIFY lt_msg_txt_data_us from ls_msg_txt_data_us.
               ENDIF.
             endloop.
            ENDIF.
         endcase.
   endloop.

clear ls_msg_txt_data_us.
LOOP AT lt_msg_txt_data_us INTO ls_msg_txt_data_us WHERE condition_alias = lv_con.
  append ls_msg_txt_data_us to lt_next_data_us.
ENDLOOP.


ENDCASE.

ENDMETHOD.
ENDCLASS.
