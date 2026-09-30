CLASS zcl_seed_vehicle_data DEFINITION
  PUBLIC FINAL CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_seed_vehicle_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    INSERT zvehicle FROM TABLE @( VALUE #(
      ( vehicle_id  = '0001'
        plate_no    = 'ABC-123'
        model       = 'Toyota Hilux'
        make_year   = 2022
        owner_name  = 'Ahmed Al-Farsi'
        owner_phone = '0501234567' )

      ( vehicle_id  = '0002'
        plate_no    = 'XYZ-789'
        model       = 'Ford Ranger'
        make_year   = 2021
        owner_name  = 'Sara Khaled'
        owner_phone = '0559876543' )
    ) ).

    out->write( 'Vehicles inserted' ).

  ENDMETHOD.
ENDCLASS.
