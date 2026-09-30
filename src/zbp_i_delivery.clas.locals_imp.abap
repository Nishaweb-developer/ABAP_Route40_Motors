CLASS lhc_Delivery DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Delivery RESULT result.

    METHODS receiveRemaining FOR MODIFY
       keys FOR ACTION Delivery~receiveRemaining RESULT result.

    METHODS checkQty FOR VALIDATE ON SAVE
       keys FOR Delivery~checkQty.

ENDCLASS.

CLASS lhc_Delivery IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

    METHOD checkQty.
    READ ENTITIES OF zi_delivery IN LOCAL MODE
      ENTITY Delivery
        FIELDS ( PartId SiteId PoQty DeliveredQty )
        WITH CORRESPONDING #( keys )
      RESULT DATA(deliveries).

    LOOP AT deliveries INTO DATA(d).

      IF d-DeliveredQty > d-PoQty.
        APPEND VALUE #( %tky = d-%tky ) TO failed-delivery.
        APPEND VALUE #( %tky = d-%tky
                        %element-DeliveredQty = if_abap_behv=>mk-on
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Delivered quantity exceeds PO quantity' ) )
          TO reported-delivery.
      ENDIF.

      SELECT SINGLE @abap_true FROM zsparepart
        WHERE part_id = @d-PartId
          AND site_id = @d-SiteId
        INTO @DATA(part_exists).
      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = d-%tky ) TO failed-delivery.
        APPEND VALUE #( %tky = d-%tky
                        %element-PartId = if_abap_behv=>mk-on
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Part not found for this site' ) )
          TO reported-delivery.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD receiveRemaining.
    READ ENTITIES OF zi_delivery IN LOCAL MODE
      ENTITY Delivery
        FIELDS ( PartId SiteId PoQty DeliveredQty )
        WITH CORRESPONDING #( keys )
      RESULT DATA(deliveries).

    LOOP AT deliveries INTO DATA(d).

      DATA(open_qty) = d-PoQty - d-DeliveredQty.
      IF open_qty <= 0.
        APPEND VALUE #( %tky = d-%tky ) TO failed-delivery.
        APPEND VALUE #( %tky = d-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Delivery is already fully received' ) )
          TO reported-delivery.
        CONTINUE.
      ENDIF.

      SELECT SINGLE qty_stock FROM zsparepart
        WHERE part_id = @d-PartId
          AND site_id = @d-SiteId
        INTO @DATA(stock).
      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = d-%tky ) TO failed-delivery.
        APPEND VALUE #( %tky = d-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Part not found for this site' ) )
          TO reported-delivery.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zi_sparepart
        ENTITY SparePart
          UPDATE FIELDS ( QtyStock )
          WITH VALUE #( ( PartId   = d-PartId
                          SiteId   = d-SiteId
                          QtyStock = stock + open_qty ) )
        FAILED   DATA(sp_failed)
        REPORTED DATA(sp_reported).

      IF sp_failed-sparepart IS NOT INITIAL.
        APPEND VALUE #( %tky = d-%tky ) TO failed-delivery.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zi_delivery IN LOCAL MODE
        ENTITY Delivery
          UPDATE FIELDS ( DeliveredQty DeliveredAt )
          WITH VALUE #( ( %tky         = d-%tky
                          DeliveredQty = d-PoQty
                          DeliveredAt  = cl_abap_context_info=>get_system_date( ) ) ).

    ENDLOOP.

    READ ENTITIES OF zi_delivery IN LOCAL MODE
      ENTITY Delivery
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(result_rows).

    result = VALUE #( FOR r IN result_rows ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

ENDCLASS.
