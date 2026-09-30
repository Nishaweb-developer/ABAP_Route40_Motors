@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vehicle Interface View'
define root view entity ZI_Vehicle
  as select from zvehicle
{
  key vehicle_id    as VehicleId,
      plate_no      as PlateNo,
      model         as Model,
      make_year     as MakeYear,
      owner_name    as OwnerName,
      owner_phone   as OwnerPhone
}
