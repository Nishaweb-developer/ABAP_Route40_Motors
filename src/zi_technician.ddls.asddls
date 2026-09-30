@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Technician Interface View'
define root view entity ZI_TECHNICIAN
  as select from ztechnician
{
  key tech_id       as TechId,
      name          as Name,
      nationality   as Nationality,
      department    as Department,
      join_date     as JoinDate
}
