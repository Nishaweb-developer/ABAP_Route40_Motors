CLASS lhc_SvcBooking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR SvcBooking RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR SvcBooking RESULT result.

    METHODS checkStock FOR VALIDATE ON SAVE
      IMPORTING keys FOR SvcBooking~checkStock.

    METHODS normalizeKeys FOR DETERMINE ON MODIFY
      IMPORTING keys FOR SvcBooking~normalizeKeys.

    METHODS completeService FOR MODIFY
      IMPORTING keys FOR ACTION SvcBooking~completeService RESULT result.


ENDCLASS.

CLASS lhc_SvcBooking IMPLEMENTATION.

    METHOD completeService.
    READ ENTITIES OF zi_svcbooking IN LOCAL MODE
      ENTITY SvcBooking
        FIELDS ( BookingId PartId SiteId Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings INTO DATA(b).

      " --- 1. already completed? ---
      IF b-Status = 3.
        APPEND VALUE #( %tky = b-%tky ) TO failed-svcbooking.
        APPEND VALUE #( %tky = b-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Booking is already completed' ) )
          TO reported-svcbooking.
        CONTINUE.
      ENDIF.

      " --- 2. stock and price in one select ---
      SELECT SINGLE qty_stock, unit_price, waers
        FROM zsparepart
        WHERE part_id = @b-PartId
          AND site_id = @b-SiteId
        INTO @DATA(ls_part).

      IF sy-subrc <> 0 OR ls_part-qty_stock < 1.
        APPEND VALUE #( %tky = b-%tky ) TO failed-svcbooking.
        APPEND VALUE #( %tky = b-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Part is out of stock' ) )
          TO reported-svcbooking.
        CONTINUE.
      ENDIF.

      " --- 3. invoice already exists for this booking? ---
      DATA(lv_invoice_id) = CONV zinvoice-invoice_id( |INV-{ b-BookingId }| ).

      READ ENTITIES OF zi_invoice
        ENTITY Invoice
          FIELDS ( InvoiceId )
          WITH VALUE #( ( InvoiceId = lv_invoice_id ) )
        RESULT DATA(existing_inv).

      " --- 4. reduce stock ---
      MODIFY ENTITIES OF zi_sparepart
        ENTITY SparePart
          UPDATE FIELDS ( QtyStock )
          WITH VALUE #( ( PartId   = b-PartId
                          SiteId   = b-SiteId
                          QtyStock = ls_part-qty_stock - 1 ) )
        FAILED DATA(sp_failed).

      IF sp_failed-sparepart IS NOT INITIAL.
        APPEND VALUE #( %tky = b-%tky ) TO failed-svcbooking.
        APPEND VALUE #( %tky = b-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Stock update failed' ) )
          TO reported-svcbooking.
        CONTINUE.
      ENDIF.

      " --- 5. set booking status to completed ---
      MODIFY ENTITIES OF zi_svcbooking IN LOCAL MODE
        ENTITY SvcBooking
          UPDATE FIELDS ( Status )
          WITH VALUE #( ( %tky = b-%tky Status = 3 ) ).

      " --- 6. ZATCA invoice (only once per booking) ---
      IF existing_inv IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_sub) = CONV zcl_zatca_tlv=>ty_amount( ls_part-unit_price ).
      DATA(lv_vat) = CONV zcl_zatca_tlv=>ty_amount( lv_sub * zcl_zatca_tlv=>c_vat_rate ).
      DATA(lv_tot) = CONV zcl_zatca_tlv=>ty_amount( lv_sub + lv_vat ).

      DATA(lv_qr) = zcl_zatca_tlv=>encode( VALUE #(
        seller_name = zcl_zatca_tlv=>c_seller_name
        vat_number  = zcl_zatca_tlv=>c_vat_number
        timestamp   = zcl_zatca_tlv=>iso_timestamp_now( )
        total       = zcl_zatca_tlv=>fmt_amount( lv_tot )
        vat_amount  = zcl_zatca_tlv=>fmt_amount( lv_vat ) ) ).

      MODIFY ENTITIES OF zi_invoice
        ENTITY Invoice
          CREATE FIELDS ( InvoiceId BookingId SellerName VatNumber InvoiceDate
                          TotalAmount VatAmount Waers QrTlv )
          WITH VALUE #( ( %cid        = |CID_{ b-BookingId }|
                          InvoiceId   = lv_invoice_id
                          BookingId   = b-BookingId
                          SellerName  = zcl_zatca_tlv=>c_seller_name
                          VatNumber   = zcl_zatca_tlv=>c_vat_number
                          InvoiceDate = cl_abap_context_info=>get_system_date( )
                          TotalAmount = lv_tot
                          VatAmount   = lv_vat
                          Waers       = ls_part-waers
                          QrTlv       = lv_qr ) )
        FAILED DATA(inv_failed).

      IF inv_failed-invoice IS NOT INITIAL.
        APPEND VALUE #( %tky = b-%tky ) TO failed-svcbooking.
        APPEND VALUE #( %tky = b-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Invoice creation failed' ) )
          TO reported-svcbooking.
      ENDIF.

    ENDLOOP.

    READ ENTITIES OF zi_svcbooking IN LOCAL MODE
      ENTITY SvcBooking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(result_rows).

    result = VALUE #( FOR r IN result_rows ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
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

      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-svcbooking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message_with_text(
                                 text = |Part '{ booking-PartId }' not found for site '{ booking-SiteId }'| ) )
          TO reported-svcbooking.
      ELSEIF qty = 0.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-svcbooking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message_with_text( text = 'Part is out of stock' ) )
          TO reported-svcbooking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD normalizeKeys.
    READ ENTITIES OF zi_svcbooking IN LOCAL MODE
      ENTITY SvcBooking
        FIELDS ( PartId SiteId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    DATA updates TYPE TABLE FOR UPDATE zi_svcbooking.
    LOOP AT bookings INTO DATA(b).
      IF b-PartId <> to_upper( b-PartId ) OR b-SiteId <> to_upper( b-SiteId ).
        APPEND VALUE #( %tky   = b-%tky
                        PartId = to_upper( b-PartId )
                        SiteId = to_upper( b-SiteId ) ) TO updates.
      ENDIF.
    ENDLOOP.
    CHECK updates IS NOT INITIAL.

    MODIFY ENTITIES OF zi_svcbooking IN LOCAL MODE
      ENTITY SvcBooking
        UPDATE FIELDS ( PartId SiteId )
        WITH updates.
  ENDMETHOD.



ENDCLASS.
