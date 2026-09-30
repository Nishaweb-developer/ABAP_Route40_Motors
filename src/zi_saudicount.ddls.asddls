@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Saudi counts per department'
define view entity ZI_SaudiCount
  as select from ztechnician
{
  key department as Department,
  count(*) as TotalTechs,
  sum( case when upper( nationality ) = 'SAUDI' then 1 else 0 end ) as SaudiTechs
}
group by department
