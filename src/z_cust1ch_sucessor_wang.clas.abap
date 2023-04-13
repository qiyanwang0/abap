class Z_CUST1CH_SUCESSOR_WANG definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_USMD_SSW_SYST_METHOD_CALLER .
protected section.
private section.
ENDCLASS.



CLASS Z_CUST1CH_SUCESSOR_WANG IMPLEMENTATION.


METHOD IF_USMD_SSW_SYST_METHOD_CALLER~CALL_SYSTEM_METHOD.
* Create a follow-up change request with reference to an existing, activated change request
* Copies the object list and most of the CR data
  CONSTANTS:
    gc_crtype               TYPE usmd_crequest_type VALUE 'CUST2P1'. "Change Request type for the new change request (material change)
  DATA:
    lt_message              TYPE usmd_t_message,
    lo_crequest_api         TYPE REF TO if_usmd_crequest_api,
    lt_attribute            TYPE usmd_ts_fieldname,
    ls_attribute            TYPE usmd_fieldname.
* Clear exporting parameter
  CLEAR ev_action.
  CLEAR et_message.
  CASE iv_service_name.
    WHEN 'Z_SUCESSOR_CR_BP'.
* Get instance of CR API
      CALL METHOD cl_usmd_crequest_api=>get_instance
        IMPORTING
          et_message           = lt_message
          re_inst_crequest_api = lo_crequest_api.
      IF lt_message[] IS NOT INITIAL.
        et_message[] = lt_message[].
        RETURN.
      ENDIF.


* Create request now as copy
* Copy also priority, due date and reason
      ls_attribute = if_usmd_crequest_api=>gcs_crequest_attribute-priority.
      INSERT ls_attribute INTO TABLE lt_attribute.
      ls_attribute = if_usmd_crequest_api=>gcs_crequest_attribute-due_date.
      INSERT ls_attribute INTO TABLE lt_attribute.
      ls_attribute = if_usmd_crequest_api=>gcs_crequest_attribute-reason.
      INSERT ls_attribute INTO TABLE lt_attribute.
      CALL METHOD lo_crequest_api->create_crequest_by_reference
        EXPORTING
          iv_reference_id       = iv_cr_number
          iv_crequest_type      = gc_crtype
          it_crequest_attribute = lt_attribute
          if_attachments        = abap_true
          if_objectlist         = abap_true
          if_notes              = abap_true
        IMPORTING
*         ev_crequest_id        = lv_crequest_id "New CR number
          et_message            = lt_message.
      IF lt_message[] IS NOT INITIAL.
        et_message[] = lt_message[].
        RETURN.
      ENDIF.
* save the newly created CR

      lo_crequest_api->READ_OBJECTLIST(
       IMPORTING
        et_entity  = DATA(lt_entity_objlist)
        et_message = DATA(lt_message_cr)
         ).


      CALL METHOD lo_crequest_api->save_crequest
        EXPORTING
          if_commit  = space
        IMPORTING
          et_message = lt_message.
      IF lt_message[] IS NOT INITIAL.
        et_message[] = lt_message[].
        RETURN.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDMETHOD.
ENDCLASS.
