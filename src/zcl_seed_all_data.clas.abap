CLASS zcl_seed_all_data DEFINITION
  PUBLIC FINAL CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_seed_all_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    " 1. Sites
    INSERT zsite FROM TABLE @( VALUE #(
      ( site_id = 'S001' site_name = 'ROUTE 40 MOTORS' city = 'JEDDAH' )
      ( site_id = 'S002' site_name = 'ROUTE 40 MOTORS' city = 'DAMMAN' )
      ( site_id = 'S003' site_name = 'ROUTE 40 MOTORS' city = 'RIYADH' )
    ) ).

    " 2. Spare parts (references Site)
    INSERT zsparepart FROM TABLE @( VALUE #(
      ( part_id = 'P001' site_id = 'S001' part_name = 'ENGINE OIL FILTER' qty_stock = 15 unit_price = '4500.00' waers = 'SAR' )
      ( part_id = 'P001' site_id = 'S002' part_name = 'ENGINE OIL FILTER' qty_stock = 0  unit_price = '4500.00' waers = 'SAR' )
      ( part_id = 'P002' site_id = 'S001' part_name = 'BRAKE PAD SET'     qty_stock = 6  unit_price = '22000.00' waers = 'SAR' )
      ( part_id = 'P002' site_id = 'S002' part_name = 'BRAKE PAD SET'     qty_stock = 0  unit_price = '22000.00' waers = 'SAR' )
    ) ).

    " 3. Technicians
    INSERT ztechnician FROM TABLE @( VALUE #(
      ( tech_id = 'T001' name = 'Khalid Ibrahim'  nationality = 'Saudi'  department = 'Engine Repair'       join_date = '20220115' )
      ( tech_id = 'T002' name = 'Ravi Kumar'      nationality = 'Indian' department = 'Electrical'          join_date = '20230310' )
      ( tech_id = 'T003' name = 'Mohammed Nasser' nationality = 'Saudi'  department = 'Brakes & Suspension' join_date = '20210701' )
    ) ).

    " 4. Service Bookings (references Vehicle, Part, Site — vehicles already exist as V001/V002)
    INSERT zsvcbooking FROM TABLE @( VALUE #(
      ( booking_id = 'B001' vehicle_id = 'V001' part_id = 'P001' svc_date = '20260901' svc_type = 'OIL CHANGE' status = 0 due_date = '20260910' site_id = 'S001' )
      ( booking_id = 'B002' vehicle_id = 'V002' part_id = 'P002' svc_date = '20260905' svc_type = 'BRAKE OIL'  status = 0 due_date = '20260915' site_id = 'S002' )
    ) ).

    " 5. Deliveries (references Part, Site)
    INSERT zdelivery FROM TABLE @( VALUE #(
      ( delivery_id = 'D001' part_id = 'P001' site_id = 'S001' po_number = 'PO1001' po_qty = 20 delivered_qty = 20 delivered_at = '20260815' )
      ( delivery_id = 'D002' part_id = 'P002' site_id = 'S001' po_number = 'PO1002' po_qty = 10 delivered_qty = 6  delivered_at = '20260820' )
      ( delivery_id = 'D003' part_id = 'P001' site_id = 'S002' po_number = 'PO1003' po_qty = 15 delivered_qty = 0  delivered_at = '20260101' )
    ) ).

    " 6. Invoices (references Booking)
    INSERT zinvoice FROM TABLE @( VALUE #(
      ( invoice_id = 'INV001' booking_id = 'B001' seller_name = 'Route 40 Motors' vat_number = '310123456700003' invoice_date = '20260901' total_amount = '450.00'  vat_amount = '67.50'  waers = 'SAR' qr_tlv = '' )
      ( invoice_id = 'INV002' booking_id = 'B002' seller_name = 'Route 40 Motors' vat_number = '310123456700003' invoice_date = '20260905' total_amount = '2200.00' vat_amount = '330.00' waers = 'SAR' qr_tlv = '' )
    ) ).

    out->write( 'All remaining tables seeded successfully' ).

  ENDMETHOD.
ENDCLASS.
