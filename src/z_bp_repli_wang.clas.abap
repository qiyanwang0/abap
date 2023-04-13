class Z_BP_REPLI_WANG definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_MDG_SE_BP_BULK_REPLRQ_OUT .
protected section.
private section.
ENDCLASS.



CLASS Z_BP_REPLI_WANG IMPLEMENTATION.


  method IF_MDG_SE_BP_BULK_REPLRQ_OUT~OUTBOUND_PROCESSING.
    check in is not INITIAL.
  endmethod.
ENDCLASS.
