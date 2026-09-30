@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Booking Interface View'

define root view entity ZI_SVCBOOKING
  as select from zsvcbooking

  association [0..1] to ZI_Vehicle
    as _Vehicle
    on $projection.VehicleId = _Vehicle.VehicleId

  association [0..1] to ZI_Site
    as _Site
    on $projection.SiteId = _Site.SiteId

  association [0..1] to ZI_TECHNICIAN
    as _Technician
    on $projection.TechId = _Technician.TechId

  association [0..1] to ZI_SPAREPART
    as _SparePart
    on  $projection.PartId = _SparePart.PartId
    and $projection.SiteId = _SparePart.SiteId

{
  key booking_id as BookingId,

      vehicle_id  as VehicleId,
      part_id     as PartId,
      svc_date    as SvcDate,
      svc_type    as SvcType,
      status      as Status,
      due_date    as DueDate,
      site_id     as SiteId,
      tech_id     as TechId,

      cast(
        case status
          when 0 then 'Open'
          when 1 then 'In Progress'
          when 2 then 'Awaiting Parts'
          when 3 then 'Completed'
          else 'Unknown'
        end
        as abap.char(20)
      ) as StatusText,

      cast(
        case status
          when 0 then 0
          when 1 then 2
          when 2 then 1
          when 3 then 3
          else 0
        end
        as abap.int1
      ) as StatusCriticality,

      _Vehicle,
      _Site,
      _Technician,
      _SparePart
}
