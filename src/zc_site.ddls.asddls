@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Site Projection View'
define root view entity ZC_Site
 provider contract transactional_query
  as projection on ZI_Site
{
  key SiteId,
      SiteName,
      City
}
