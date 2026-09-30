CLASS zcl_cleanup_vehicle_data DEFINITION
  PUBLIC FINAL CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_cleanup_vehicle_data IMPLEMENTATION.
 METHOD if_oo_adt_classrun~main.

   " Technicians
    INSERT ztechnician FROM TABLE @( VALUE #(
      ( tech_id = 'T001' name = 'Khalid Ibrahim'  nationality = 'Saudi'  department = 'Engine Repair'       join_date = '20220115' )
      ( tech_id = 'T002' name = 'Ravi Kumar'      nationality = 'Indian' department = 'Electrical'          join_date = '20230310' )
      ( tech_id = 'T003' name = 'Mohammed Nasser' nationality = 'Saudi'  department = 'Brakes & Suspension' join_date = '20210701' )
    ) ).

    " Deliveries (references Part, Site — P001/P002/S001/S002 already exist)
    INSERT zdelivery FROM TABLE @( VALUE #(
      ( delivery_id = 'D001' part_id = 'P001' site_id = 'S001' po_number = 'PO1001' po_qty = 20 delivered_qty = 20 delivered_at = '20260815' )
      ( delivery_id = 'D002' part_id = 'P002' site_id = 'S001' po_number = 'PO1002' po_qty = 10 delivered_qty = 6  delivered_at = '20260820' )
      ( delivery_id = 'D003' part_id = 'P001' site_id = 'S002' po_number = 'PO1003' po_qty = 15 delivered_qty = 0  delivered_at = '20260101' )
    ) ).

    " Invoices (references Booking — B001/B002 already exist)
    INSERT zinvoice FROM TABLE @( VALUE #(
      ( invoice_id = 'INV001' booking_id = 'B001' seller_name = 'Route 40 Motors' vat_number = '310123456700003' invoice_date = '20260901' total_amount = '450.00'  vat_amount = '67.50'  waers = 'SAR' qr_tlv = '' )
      ( invoice_id = 'INV002' booking_id = 'B002' seller_name = 'Route 40 Motors' vat_number = '310123456700003' invoice_date = '20260905' total_amount = '2200.00' vat_amount = '330.00' waers = 'SAR' qr_tlv = '' )
    ) ).

    out->write( 'Technician, Delivery, and Invoice data seeded' ).

  ENDMETHOD.
ENDCLASS.
