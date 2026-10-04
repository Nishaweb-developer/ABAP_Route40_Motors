CLASS zcl_zatca_test DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_zatca_test IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA(lv_b64) = zcl_zatca_tlv=>encode( VALUE #(
      seller_name = `Route 40 Motors`
      vat_number  = `300000000000003`
      timestamp   = `2026-10-04T10:30:00Z`
      total       = `115.00`
      vat_amount  = `15.00` ) ).

    out->write( |Base64: { lv_b64 }| ).

    CONSTANTS lc_ref TYPE string VALUE `AQ9Sb3V0ZSA0MCBNb3RvcnMCDzMwMDAwMDAwMDAwMDAwMwMUMjAyNi0xMC0wNFQxMDozMDowMFoEBjExNS4wMAUFMTUuMDA=`.

    out->write( COND string(
      WHEN lv_b64 = lc_ref THEN `MATCHES the reference value`
      ELSE `DIFFERENT from the reference value` ) ).

    out->write( `--- decoded ---` ).
    LOOP AT zcl_zatca_tlv=>decode( lv_b64 ) INTO DATA(ls_tag).
      out->write( |Tag { ls_tag-tag }: { ls_tag-value }| ).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
