CLASS lhc_SvcBooking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR SvcBooking RESULT result.

    METHODS checkStock FOR VALIDATE ON SAVE
       keys FOR SvcBooking~checkStock.

       METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
  REQUEST requested_authorizations FOR SvcBooking RESULT result.


ENDCLASS.

CLASS lhc_SvcBooking IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD checkStock.
  READ ENTITIES OF zi_svcbooking IN LOCAL MODE
    ENTITY SvcBooking
      FIELDS ( PartId SiteId )
      WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

  DATA qty TYPE zsparepart-qty_stock.

  LOOP AT bookings INTO DATA(booking).
    CLEAR qty.
    SELECT SINGLE qty_stock FROM zsparepart
      WHERE part_id = @booking-PartId
        AND site_id = @booking-SiteId
      INTO @qty.

*    IF sy-subrc <> 0.
*
*      APPEND VALUE #( %tky = booking-%tky ) TO failed-svcbooking.
*      APPEND VALUE #( %tky = booking-%tky
*                      %msg = NEW_MESSAGE_WITH_TEXT( text = 'Part not found for this site' ) )
*        TO reported-svcbooking.
IF sy-subrc <> 0.
  APPEND VALUE #( %tky = booking-%tky ) TO failed-svcbooking.
  APPEND VALUE #( %tky = booking-%tky
                  %msg = new_message_with_text(
                           text = |Part '{ booking-PartId }' not found for site '{ booking-SiteId }'| ) )
    TO reported-svcbooking.
    ELSEIF qty = 0.
      APPEND VALUE #( %tky = booking-%tky ) TO failed-svcbooking.
      APPEND VALUE #( %tky = booking-%tky
                      %msg = NEW_MESSAGE_WITH_TEXT( text = 'Part is out of stock' ) )
        TO reported-svcbooking.
    ENDIF.
  ENDLOOP.
ENDMETHOD.

  METHOD get_global_authorizations.
  result-%create = if_abap_behv=>auth-allowed.
  result-%update = if_abap_behv=>auth-allowed.
  result-%delete = if_abap_behv=>auth-allowed.
ENDMETHOD.


ENDCLASS.
