@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Interface View'
define root view entity ZI_Delivery
  as select from zdelivery

  association [0..1] to ZI_Site      as _Site      on $projection.SiteId = _Site.SiteId
  association [0..1] to ZI_SPAREPART as _SparePart on  $projection.PartId = _SparePart.PartId
                                                     and $projection.SiteId = _SparePart.SiteId
{
  key delivery_id    as DeliveryId,
      part_id        as PartId,
      site_id        as SiteId,
      po_number      as PoNumber,
      po_qty         as PoQty,
      delivered_qty  as DeliveredQty,
      po_qty - delivered_qty as OpenQty,
      delivered_at   as DeliveredAt,
      _Site,
      _SparePart
}
