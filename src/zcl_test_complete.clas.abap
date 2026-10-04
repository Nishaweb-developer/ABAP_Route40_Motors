CLASS zcl_test_complete DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_test_complete IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    MODIFY ENTITIES OF zi_svcbooking
      ENTITY SvcBooking
        EXECUTE completeService FROM VALUE #( ( BookingId = 'B001' ) )
      FAILED   DATA(failed)
      REPORTED DATA(reported).

    out->write( |Failed: { lines( failed-svcbooking ) }  Reported: { lines( reported-svcbooking ) }| ).

    LOOP AT reported-svcbooking INTO DATA(rep).
      IF rep-%msg IS BOUND.
        out->write( rep-%msg->if_message~get_text( ) ).
      ENDIF.
    ENDLOOP.

    COMMIT ENTITIES
      RESPONSE OF zi_svcbooking
      FAILED   DATA(c_failed)
      REPORTED DATA(c_reported).

    out->write( |After COMMIT -> Failed: { lines( c_failed-svcbooking ) }| ).
  ENDMETHOD.
ENDCLASS.
