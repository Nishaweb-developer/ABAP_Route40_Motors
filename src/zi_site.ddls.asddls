@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Site Interface View'
define root view entity ZI_Site
  as select from zsite
{
  key site_id    as SiteId,
      site_name  as SiteName,
      city       as City
}
