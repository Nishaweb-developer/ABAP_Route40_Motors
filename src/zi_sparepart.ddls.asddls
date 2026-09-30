@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Spare Part Interface View'
define root view entity ZI_SPAREPART
  as select from zsparepart
{
  key part_id      as PartId,
  key site_id      as SiteId,
      part_name    as PartName,
      qty_stock    as QtyStock,
      unit_price   as UnitPrice,
      waers        as Waers
}
