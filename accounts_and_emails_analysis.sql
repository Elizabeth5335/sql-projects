-- SQL query for account and email engagement analysis. Aggregates account creation counts and email metrics
-- (sends, opens, clicks) by date, country, send interval, verification status, and subscription status. 
-- Calculates country-level totals and rankings to identify top 10 markets by account volume and email activity.

-- general data (date from session, country from session_params, other from account)
WITH account_session_join AS (
  SELECT s.date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed,
        a.id AS account_id
  FROM `data-analytics-mate.DA.session` s
  JOIN `data-analytics-mate.DA.session_params` sp USING(ga_session_id)
  JOIN `data-analytics-mate.DA.account_session` acs USING(ga_session_id)
  JOIN `data-analytics-mate.DA.account` a
  ON a.id = acs.account_id
),
-- main email metrics
email_data AS(
  SELECT
  DATE_ADD(date, INTERVAL es.sent_date DAY) AS date,
  country, send_interval, is_verified, is_unsubscribed,
  COUNT(DISTINCT es.id_message) as sent_msg,
  COUNT(DISTINCT eo.id_message) as open_msg,
  COUNT(DISTINCT ev.id_message) as visit_msg
  FROM account_session_join acj
  JOIN `data-analytics-mate.DA.email_sent` es
  ON es.id_account = acj.account_id
  LEFT JOIN `data-analytics-mate.DA.email_open` eo  USING(id_message)
  LEFT JOIN `data-analytics-mate.DA.email_visit` ev USING(id_message)
  GROUP BY DATE_ADD(date, INTERVAL es.sent_date DAY), country, send_interval , is_verified, is_unsubscribed
),
-- main account metrics
account_data AS(
  SELECT date, country, send_interval, is_verified, is_unsubscribed,
  COUNT(DISTINCT account_id) as account_cnt
  FROM account_session_join
  GROUP BY date, country, send_interval, is_verified, is_unsubscribed
),


-- union of main metrics
union_data AS(
  SELECT
  date,
  country,
  send_interval,
  is_verified,
  is_unsubscribed,
  sent_msg,
  open_msg,
  visit_msg,
  null as account_cnt
  FROM email_data
  UNION ALL
  SELECT
  date,
  country,
  send_interval,
  is_verified,
  is_unsubscribed,
  null as sent_msg,
  null as open_msg,
  null as visit_msg,
  account_cnt
  FROM account_data
),


-- count additional metrics (country totals)
country_totals AS (
  SELECT *,
  SUM(sent_msg) OVER(PARTITION BY country) AS total_country_sent_cnt,
  SUM(account_cnt) OVER(PARTITION BY country) AS total_country_account_cnt
  FROM union_data
),


-- count rank


ranked_data AS(
  SELECT *,
  DENSE_RANK() OVER(ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt,
  DENSE_RANK() OVER(ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt
  FROM country_totals
)


-- final output
SELECT  
  *
FROM ranked_data
WHERE rank_total_country_account_cnt <= 10 OR rank_total_country_sent_cnt <= 10
