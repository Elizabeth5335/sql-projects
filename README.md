# sql-project
## Email and Account Analytics

### Task Overview
Build a SQL data pipeline and visualization dashboard to analyze account creation dynamics and email engagement metrics across multiple dimensions (country, send interval, verification status, subscription status).

### Requirements

**Data Dimensions (grouping fields):**
- `date` — date (account creation date for accounts, email send date for emails)
- `country` — user country
- `send_interval` — send frequency interval set by account
- `is_verified` — account verification status
- `is_unsubscribed` — subscription status

**Primary Metrics:**
- `account_cnt` — number of accounts created
- `sent_msg` — number of emails sent
- `open_msg` — number of emails opened
- `visit_msg` — number of email clicks

**Additional Metrics:**
- `total_country_account_cnt` — total accounts created per country
- `total_country_sent_cnt` — total emails sent per country
- `rank_total_country_account_cnt` — country ranking by account creation volume
- `rank_total_country_sent_cnt` — country ranking by email sending volume

### SQL Implementation Details
- Calculate account and email metrics separately to preserve unique dimensions and avoid date field conflicts
- Use UNION to combine results
- Filter final output to top 10 countries by either `rank_total_country_account_cnt` or `rank_total_country_sent_cnt`
- Use CTEs to organize query logic into logical sections
- Apply window functions for ranking calculations

### Visualization (Looker Studio)
Dashboard displays:
- Country-level totals: `account_cnt`, `total_country_sent_cnt`, `rank_total_country_account_cnt`, `rank_total_country_sent_cnt`
- Time series: `sent_msg` trend over time

[Link to results and visualizations](https://docs.google.com/document/d/1SMU6QQruBqSGhsOgy7o4md9fgfrgs255XtM_lYP_Aos/edit?usp=sharing)
