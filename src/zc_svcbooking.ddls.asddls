@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Booking Consumption View'
@Metadata.allowExtensions: true

define root view entity ZC_SvcBooking
  provider contract transactional_query
  as projection on ZI_SVCBOOKING
{
  key BookingId,

      VehicleId,
      PartId,
      SiteId,
      TechId,

      SvcType,
      SvcDate,
      DueDate,

      Status,
      StatusText,
      StatusCriticality,

          _Vehicle.PlateNo   as PlateNo,
      _Vehicle.Model     as VehicleModel,
      _SparePart.PartName as PartName,
      _Site.City         as SiteCity,
      _Technician.Name   as TechnicianName,

      /* Associations */
      _Vehicle    : redirected to ZC_Vehicle,
      _SparePart  : redirected to ZC_SparePart,
      _Site       : redirected to ZC_Site,
      _Technician : redirected to ZC_Technician
}
