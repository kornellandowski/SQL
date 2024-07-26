/*
Use the CTE from the previous task in a new (second) CTE to create a sample with the following data:

ad_month: the first day of the month of the ad date (obtained from ad_date);
utm_campaign, total_cost, impressions, clicks, conversion_value, CTR, CPC, CPM, ROMI — the same fields with the same conditions as in the previous task.
Perform a final selection with the following fields:
ad_month;
utm_campaign, total_cost, impressions, clicks, conversion_value, CTR, CPC, CPM, ROMI;
For each utm_campaign in each month, add a new field: 'Difference between CPM, CTR, and ROMI' in the current month compared to the previous month in percentage.
*/


With union_data as (
select
ad_date,
'Facebook ads' as media_source,
url_parameters,
coalesce (spend,0) as spend, coalesce (impressions,0) as impressions, coalesce (reach,0) as reach, coalesce (clicks,0) as clicks, coalesce (leads,0) as leads, coalesce (value,0) as value
from fabd
union
select
ad_date,
'Google ads' as media_source,
url_parameters,
coalesce (spend,0) as spend, coalesce (impressions,0) as impressions, coalesce (reach,0) as reach, coalesce (clicks,0) as clicks, coalesce (leads,0) as leads, coalesce (value,0) as value
from google_ads_basic_daily gabd 
),
data_month as (
select
date_trunc ('Month',ad_date) AS ad_month,
case 
when lower(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)')) = 'nan' then null
else lower(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)'))
end AS utm_campaign,
sum(spend) as total_spend,
sum(impressions) as total_impresion,
sum(clicks) as total_clicks,
sum(leads) as total_leads,
sum(reach) as total_reach,
sum(value) as total_value,
case 
	when sum(impressions) = 0 then null 
	else sum(clicks)* 1.0 / sum(impressions) *100 
end as CTR,
case 
	when sum(clicks) = 0 then null 
	else sum(spend)* 1.0 / sum(clicks) 
end as cpc,
case 
	when sum(impressions) = 0 then null 
	else sum(spend) * 1.0 / sum(impressions)*1000 
end as cpm,
case 
	when sum(spend) = 0 then null 
	else (sum(value) - sum(spend)) * 1.0 / sum(spend) * 100
end as romi
from union_data
group by
ad_date,
url_parameters,
media_source
),
previous_data as (
select
ad_month,
utm_campaign,
cpm,
ctr,
romi,
LAG (cpm,1) OVER (
PARTITION BY utm_campaign
ORDER BY ad_month) AS prev_cpm,
LAG (ctr,1) OVER (
PARTITION BY utm_campaign
ORDER BY ad_month) AS prev_ctr,
LAG (romi,1) OVER (
PARTITION BY utm_campaign
ORDER BY ad_month) AS prev_romi
from data_month
)
select
ad_month,
utm_campaign,
prev_cpm,
cpm,
((cpm::float-prev_cpm::float)/nullif(prev_cpm::float,0))*100 AS diff_cpm,
prev_ctr,
ctr,
((ctr::float-prev_ctr::float)/nullif(prev_ctr::float,0))*100 AS diff_ctr,
prev_romi,
romi,
((romi::float-prev_romi::float)/nullif(prev_romi::float,0))*100 AS diff_romi
from previous_data
