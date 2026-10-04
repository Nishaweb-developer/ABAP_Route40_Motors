CLASS zcl_zatca_tlv DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_amount TYPE p LENGTH 15 DECIMALS 2.

    TYPES: BEGIN OF ty_invoice,
             seller_name TYPE string,
             vat_number  TYPE string,
             timestamp   TYPE string,
             total       TYPE string,
             vat_amount  TYPE string,
           END OF ty_invoice.

    TYPES: BEGIN OF ty_tag,
             tag   TYPE i,
             value TYPE string,
           END OF ty_tag,
           tt_tag TYPE STANDARD TABLE OF ty_tag WITH EMPTY KEY.

    CONSTANTS:
      c_seller_name TYPE string VALUE `Route 40 Motors`,
      c_vat_number  TYPE string VALUE `300000000000003`,
      c_vat_rate    TYPE ty_amount VALUE '0.15'.

    CLASS-METHODS encode
      IMPORTING is_invoice       TYPE ty_invoice
      RETURNING VALUE(rv_base64) TYPE string.

    CLASS-METHODS decode
      IMPORTING iv_base64      TYPE string
      RETURNING VALUE(rt_tags) TYPE tt_tag.

    CLASS-METHODS fmt_amount
      IMPORTING iv_amount      TYPE ty_amount
      RETURNING VALUE(rv_text) TYPE string.

    CLASS-METHODS iso_timestamp_now
      RETURNING VALUE(rv_ts) TYPE string.

  PRIVATE SECTION.
    CLASS-METHODS tlv
      IMPORTING iv_tag          TYPE i
                iv_value        TYPE string
      RETURNING VALUE(rv_bytes) TYPE xstring.

ENDCLASS.


CLASS zcl_zatca_tlv IMPLEMENTATION.

  METHOD tlv.
    DATA lv_tag_x TYPE x LENGTH 1.
    DATA lv_len_x TYPE x LENGTH 1.

    DATA(lv_val) = xco_cp=>string( iv_value )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.

    DATA(lv_len) = xstrlen( lv_val ).
    IF lv_len > 255.
      lv_val = lv_val(255).
      lv_len = 255.
    ENDIF.

    lv_tag_x = iv_tag.
    lv_len_x = lv_len.

    CONCATENATE lv_tag_x lv_len_x lv_val INTO rv_bytes IN BYTE MODE.
  ENDMETHOD.


  METHOD encode.
    DATA lv_all TYPE xstring.

    DATA(lv_1) = tlv( iv_tag = 1 iv_value = is_invoice-seller_name ).
    DATA(lv_2) = tlv( iv_tag = 2 iv_value = is_invoice-vat_number ).
    DATA(lv_3) = tlv( iv_tag = 3 iv_value = is_invoice-timestamp ).
    DATA(lv_4) = tlv( iv_tag = 4 iv_value = is_invoice-total ).
    DATA(lv_5) = tlv( iv_tag = 5 iv_value = is_invoice-vat_amount ).

    CONCATENATE lv_1 lv_2 lv_3 lv_4 lv_5 INTO lv_all IN BYTE MODE.

    rv_base64 = cl_web_http_utility=>encode_x_base64( lv_all ).
  ENDMETHOD.


  METHOD decode.
    DATA(lv_x)     = cl_web_http_utility=>decode_x_base64( iv_base64 ).
    DATA(lv_total) = xstrlen( lv_x ).
    DATA lv_pos    TYPE i VALUE 0.
    DATA lv_tag    TYPE i.
    DATA lv_len    TYPE i.
    DATA lv_val_x  TYPE xstring.
    DATA lv_next   TYPE i.
    DATA lv_start  TYPE i.

    WHILE lv_pos + 2 <= lv_total.
      lv_tag  = lv_x+lv_pos(1).
      lv_next = lv_pos + 1.
      lv_len  = lv_x+lv_next(1).

      IF lv_pos + 2 + lv_len > lv_total.
        EXIT.
      ENDIF.

      CLEAR lv_val_x.
      IF lv_len > 0.
        lv_start = lv_pos + 2.
        lv_val_x = lv_x+lv_start(lv_len).
      ENDIF.

      APPEND VALUE #(
        tag   = lv_tag
        value = xco_cp=>xstring( lv_val_x )->as_string( xco_cp_character=>code_page->utf_8 )->value
      ) TO rt_tags.

      lv_pos = lv_pos + 2 + lv_len.
    ENDWHILE.
  ENDMETHOD.


  METHOD fmt_amount.
    rv_text = |{ iv_amount DECIMALS = 2 }|.
  ENDMETHOD.


  METHOD iso_timestamp_now.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_time) = cl_abap_context_info=>get_system_time( ).
    rv_ts = |{ lv_date(4) }-{ lv_date+4(2) }-{ lv_date+6(2) }T{ lv_time(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }Z|.
  ENDMETHOD.

ENDCLASS.
