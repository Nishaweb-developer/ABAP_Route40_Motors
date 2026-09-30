@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Saudization band'
define root view entity ZI_SaudiBand
  as select from ZI_SaudiPct
{
  key Department,
  TotalTechs,
  SaudiTechs,
  SaudiPct,
  case when SaudiPct < 10 then cast( 'Red' as abap.char(10) )
       when SaudiPct < 20 then cast( 'Low Green' as abap.char(10) )
       when SaudiPct < 30 then cast( 'Mid Green' as abap.char(10) )
       when SaudiPct < 40 then cast( 'High Green' as abap.char(10) )
       else cast( 'Platinum' as abap.char(10) ) end as Band,
  case when SaudiPct < 10 then 1
       when SaudiPct < 20 then 2
       else 3 end as BandCriticality
}
