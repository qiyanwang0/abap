class Z_ACC_IDOC_CUSTOM_WANG definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_USMD_IDOC_OUT .
protected section.
private section.
ENDCLASS.



CLASS Z_ACC_IDOC_CUSTOM_WANG IMPLEMENTATION.


  method IF_EX_USMD_IDOC_OUT~MODIFY_IDOC_DATA.
*   check cs_idoc_control is not INITIAL.
*   data ls_data type edidd.
*   ls_data-SEGNAM = 'ZMDGACC01'.
*   ls_data-SDATA = '009CUSTOM FIELD'.
*   ls_data-HLEVEL = '1'.
*   append ls_data to ct_idoc_data.

  endmethod.
ENDCLASS.
