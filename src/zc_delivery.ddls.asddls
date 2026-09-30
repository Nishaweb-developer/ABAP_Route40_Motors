@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Projection View'
@Metadata.allowExtensions: true
define root view entity ZC_Delivery
  provider contract transactional_query
  as projection on ZI_Delivery
{
  key DeliveryId,
      PartId,
      SiteId,
      PoNumber,
      PoQty,
      DeliveredQty,
      OpenQty,
      DeliveredAt,
      _Site       : redirected to ZC_Site,
      _SparePart  : redirected to ZC_SparePart
}
