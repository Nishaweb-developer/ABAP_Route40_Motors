CLASS zcl_seed_remaining_data DEFINITION
  PUBLIC FINAL CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_seed_remaining_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    " Deliveries (references Part, Site)
    INSERT zdelivery FROM TABLE @( VALUE #(
      ( delivery_id = 'D001' part_id = 'P001' site_id = 'S001' po_number = 'PO1001' po_qty = 20 delivered_qty = 20 delivered_at = '20260815' )
      ( delivery_id = 'D002' part_id = 'P002' site_id = 'S001' po_number = 'PO1002' po_qty = 10 delivered_qty = 6  delivered_at = '20260820' )
      ( delivery_id = 'D003' part_id = 'P001' site_id = 'S002' po_number = 'PO1003' po_qty = 15 delivered_qty = 0  delivered_at = '20260101' )
    ) ).

    " Invoices (references Booking)
    INSERT zinvoice FROM TABLE @( VALUE #(
      ( invoice_id = 'INV001' booking_id = 'B001' seller_name = 'Route 40 Motors' vat_number = '310123456700003' invoice_date = '20260901' total_amount = '450.00'  vat_amount = '67.50'  waers = 'SAR' qr_tlv = '' )
      ( invoice_id = 'INV002' booking_id = 'B002' seller_name = 'Route 40 Motors' vat_number = '310123456700003' invoice_date = '20260905' total_amount = '2200.00' vat_amount = '330.00' waers = 'SAR' qr_tlv = '' )
    ) ).

    out->write( 'Delivery and Invoice data seeded' ).

  ENDMETHOD.
ENDCLASS.
