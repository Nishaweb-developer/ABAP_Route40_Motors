@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vehicle Projection View'
define root view entity ZC_Vehicle
provider contract transactional_query
  as projection on ZI_Vehicle
{
  key VehicleId,
      PlateNo,
      Model,
      MakeYear,
      OwnerName,
      OwnerPhone
}
