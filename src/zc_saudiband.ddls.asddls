@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Saudization dashboard'
@Metadata.allowExtensions: true
define root view entity ZC_SaudiBand
  provider contract transactional_query
  as projection on ZI_SaudiBand
{
  key Department,
  TotalTechs,
  SaudiTechs,
  SaudiPct,
  Band,
  BandCriticality
}
