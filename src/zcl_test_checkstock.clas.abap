CLASS zcl_test_checkstock DEFINITION
  PUBLIC FINAL CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_test_checkstock IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF zi_svcbooking
      ENTITY SvcBooking
        UPDATE FIELDS ( SvcType )
        WITH VALUE #( ( BookingId = 'B002' SvcType = 'BRAKE OIL - RETEST' ) )
      FAILED   DATA(failed)
      REPORTED DATA(reported).

    out->write( |After MODIFY -> Failed: { lines( failed-svcbooking ) } Reported: { lines( reported-svcbooking ) }| ).

    COMMIT ENTITIES
      RESPONSE OF zi_svcbooking
      FAILED   DATA(commit_failed)
      REPORTED DATA(commit_reported).

    out->write( |After COMMIT -> Failed: { lines( commit_failed-svcbooking ) } Reported: { lines( commit_reported-svcbooking ) }| ).

    LOOP AT commit_reported-svcbooking INTO DATA(msg).
      IF msg-%msg IS BOUND.
        out->write( msg-%msg->if_message~get_text( ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
