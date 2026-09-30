@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Projection View'
define root view entity ZC_Invoice
provider contract transactional_query
  as projection on ZI_INVOICE
{
  key InvoiceId,
      BookingId,
      SellerName,
      VatNumber,
      InvoiceDate,
      TotalAmount,
      VatAmount,
      Waers,
      QrTlv,
      _Booking    : redirected to ZC_SvcBooking
}
