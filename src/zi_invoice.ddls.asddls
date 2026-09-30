@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Interface View'
define root view entity ZI_INVOICE
  as select from zinvoice

  association [0..1] to ZI_SVCBOOKING as _Booking on $projection.BookingId = _Booking.BookingId
{
  key invoice_id     as InvoiceId,
      booking_id     as BookingId,
      seller_name    as SellerName,
      vat_number     as VatNumber,
      invoice_date   as InvoiceDate,
      total_amount   as TotalAmount,
      vat_amount     as VatAmount,
      waers          as Waers,
      qr_tlv         as QrTlv,
      _Booking
}
