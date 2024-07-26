/* the task was :
In the SQL query with CTE, combine data from these tables to obtain:

ad_date: the date of displaying ads on Google and Facebook;
campaign_name: the name of the campaign on Google and Facebook;
spend, impressions, reach, clicks, leads, value: campaign metrics and ad set metrics on specific days.
Similar to the task in the previous topic, create a sample from the resulting combined table (CTE):

ad_date: date of ad display
campaign_name: campaign name
Aggregate values for the following metrics grouped by date and campaign_name:
Total cost,
Number of impressions,
Number of clicks,
Total conversion value.
To accomplish this task, group the table by the ad_date and campaign_name fields.
*/

WITH combine_data as (
select ad_date,
'Facebook ads' as media_source,
 spend, impressions, reach, clicks, leads, value
from public.facebook_ads_basic_daily fabd 
union 
select ad_date,
'Google ads' as media_source,
 spend, impressions, reach, clicks, leads, value
from public.google_ads_basic_daily gabd 
)
select
ad_date, 
media_source,
 sum(spend) as wydatki,
 sum(impressions) as wyswietlenia,
 sum(clicks) as klikniecia,
 sum(value) as wartosc_konwersji
from combine_data 
group by
ad_date, 
media_source;
