/*
In the CTE query, combine data from the above tables to obtain:

ad_date: the date of displaying ads on Google and Facebook;
url_parameters: the part of the campaign's URL containing UTM parameters;
spend, impressions, reach, clicks, leads, value: campaign and ad metrics on specific days. If a table lacks values for any of these metrics (i.e., the value is NULL), set the value to zero.

Based on the results obtained using CTE, retrieve the following data:

ad_date: the date of the ad;
utm_campaign: the value of the utm_campaign parameter from the utm_parameters field, meeting the following conditions:
All letters are lowercase.
If the value of utm_campaign in utm_parameters is equal to 'nan', it should be null in the result table.

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
)
select
ad_date,
media_source,
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


