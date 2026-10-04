@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice QR by Booking'

define view entity ZI_INVOICE_QR
  as select from zinvoice
{
  key booking_id as BookingId,
      qr_tlv     as QrTlv
}
