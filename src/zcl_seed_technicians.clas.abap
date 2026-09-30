CLASS zcl_seed_technicians DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_seed_technicians IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lt_tech TYPE STANDARD TABLE OF ztechnician WITH DEFAULT KEY.
    lt_tech = VALUE #( join_date = '20240101'
      ( tech_id = 'T101' name = 'Tech 101' nationality = 'SAUDI'    department = 'MECHANICAL' )
      ( tech_id = 'T102' name = 'Tech 102' nationality = 'SAUDI'    department = 'MECHANICAL' )
      ( tech_id = 'T103' name = 'Tech 103' nationality = 'INDIAN'   department = 'MECHANICAL' )
      ( tech_id = 'T104' name = 'Tech 104' nationality = 'PAKISTANI' department = 'MECHANICAL' )
      ( tech_id = 'T105' name = 'Tech 105' nationality = 'EGYPTIAN' department = 'ELECTRICAL' )
      ( tech_id = 'T106' name = 'Tech 106' nationality = 'INDIAN'   department = 'ELECTRICAL' )
      ( tech_id = 'T107' name = 'Tech 107' nationality = 'FILIPINO' department = 'ELECTRICAL' )
      ( tech_id = 'T108' name = 'Tech 108' nationality = 'SAUDI'    department = 'BODY_PAINT' )
      ( tech_id = 'T109' name = 'Tech 109' nationality = 'INDIAN'   department = 'BODY_PAINT' )
      ( tech_id = 'T110' name = 'Tech 110' nationality = 'EGYPTIAN' department = 'BODY_PAINT' )
      ( tech_id = 'T111' name = 'Tech 111' nationality = 'PAKISTANI' department = 'BODY_PAINT' ) ).
    MODIFY ztechnician FROM TABLE @lt_tech.
    out->write( |Rows written: { sy-dbcnt }| ).
  ENDMETHOD.
ENDCLASS.
