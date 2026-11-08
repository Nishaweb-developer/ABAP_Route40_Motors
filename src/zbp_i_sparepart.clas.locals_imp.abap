CLASS lhc_SparePart DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

      METHODS reserveOne FOR MODIFY
      IMPORTING keys FOR ACTION SparePart~reserveOne.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR SparePart RESULT result.

ENDCLASS.

CLASS lhc_SparePart IMPLEMENTATION.
      METHOD reserveOne.
    READ ENTITIES OF zi_sparepart IN LOCAL MODE
      ENTITY SparePart
        FIELDS ( QtyStock )
        WITH CORRESPONDING #( keys )
      RESULT DATA(parts).

    LOOP AT parts INTO DATA(part).
      IF part-QtyStock < 1.
        APPEND VALUE #( %tky = part-%tky ) TO failed-sparepart.
        APPEND VALUE #( %tky = part-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Part is out of stock' ) )
          TO reported-sparepart.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zi_sparepart IN LOCAL MODE
        ENTITY SparePart
          UPDATE FIELDS ( QtyStock )
          WITH VALUE #( ( %tky     = part-%tky
                          QtyStock = part-QtyStock - 1 ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
