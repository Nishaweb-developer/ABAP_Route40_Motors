@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice'
define root view entity ZI_Invoice
  as select from zinvoice
  association [0..1] to ZI_SVCBOOKING as _Booking
    on $projection.BookingId = _Booking.BookingId
{
  key invoice_id   as InvoiceId,
      booking_id   as BookingId,
      seller_name  as SellerName,
      vat_number   as VatNumber,
      invoice_date as InvoiceDate,
      @Semantics.amount.currencyCode: 'Waers'
      total_amount as TotalAmount,
      @Semantics.amount.currencyCode: 'Waers'
      vat_amount   as VatAmount,
     
    
      _Booking,
            waers        as Waers,
      qr_tlv       as QrTlv
      
}
