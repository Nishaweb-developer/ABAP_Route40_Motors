@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Saudization percentage'
define view entity ZI_SaudiPct
  as select from ZI_SaudiCount
{
  key Department,
  TotalTechs,
  SaudiTechs,
  division( cast( SaudiTechs as abap.dec(15,2) ) * 100,
            cast( TotalTechs as abap.dec(15,2) ), 2 ) as SaudiPct
}
