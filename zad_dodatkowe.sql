With combineData as (
select 
ad_date,
campaign_name,
adset_name,
spend, impressions, reach, clicks, leads, value
from fabd
INNER JOIN facebook_campaign ON facebook_campaign.campaign_id = fabd.campaign_id
INNER JOIN facebook_adset ON facebook_adset.adset_id  = fabd.adset_id 
),
UnionData as (
select
ad_date,
'Facebook ads' as media_source,
campaign_name,
adset_name,
spend, impressions, reach, clicks, leads, value
from combineData
union
select
ad_date,
'Google ads' as media_source,
campaign_name,
adset_name,
spend, impressions, reach, clicks, leads, value
from google_ads_basic_daily gabd 
),
agregetedData as(
select
adset_name,
sum(spend) as total_koszt,
(sum(value) - sum(spend)) * 1.0 / sum(spend) * 100 as ROMI
from UnionData
group by
adset_name
)
select 
adset_name,
max(ROMI) as max_ROMI
from 
agregetedData
where 
total_koszt > 500000
group by
adset_name
order by 
MAX(ROMI) desc limit 1;