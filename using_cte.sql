/*
Task Description:

By combining data from four tables, identify the campaign with the highest Return on Marketing Investment (ROMI) among all campaigns with total expenditures exceeding 500,000. 
Within this campaign, identify the ad set group (adset_name) with the highest ROMI.
*/

With combine_data as (
select 
ad_date,
campaign_name,
adset_name,
spend, impressions, reach, clicks, leads, value
from fabd
INNER JOIN facebook_campaign ON facebook_campaign.campaign_id = fabd.campaign_id
INNER JOIN facebook_adset ON facebook_adset.adset_id  = fabd.adset_id 
),
union_data as (
select
ad_date,
'Facebook ads' as media_source,
campaign_name,
adset_name,
spend, impressions, reach, clicks, leads, value
from combine_data 
union
select
ad_date,
'Google ads' as media_source,
campaign_name,
adset_name,
spend, impressions, reach, clicks, leads, value
from google_ads_basic_daily gabd 
),
agregeted_data as(
select
adset_name,
sum(spend) as total_koszt,
(sum(value) - sum(spend)) * 1.0 / sum(spend) * 100 as ROMI
from union_data
group by
adset_name
)
select 
adset_name,
max(ROMI) as max_ROMI
from 
agregeted_data
where 
total_koszt > 500000
group by
adset_name
order by 
MAX(ROMI) desc limit 1;
