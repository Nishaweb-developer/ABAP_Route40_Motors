@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Spare Part Projection View'
define root view entity ZC_SparePart
provider contract transactional_query
  as projection on ZI_SPAREPART
{
  key PartId,
  key SiteId,
      PartName,
      QtyStock,
      UnitPrice,
      Waers
}
