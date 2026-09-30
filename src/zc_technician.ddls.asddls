@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Technician Projection View'
define root view entity ZC_Technician
provider contract transactional_query
  as projection on ZI_TECHNICIAN
{
  key TechId,
      Name,
      Nationality,
      Department,
      JoinDate
}
