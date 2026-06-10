WITH stake_actions AS (
    SELECT
        validatorId AS id,
        delegator,
        amount / 1e18 AS stake,
        block_time
    FROM QUERY_6569926

    UNION ALL

    SELECT
        validatorId AS id,
        delegator,
        -amount / 1e18 AS stake,
        block_time
    FROM QUERY_6570705

),


daily_flow AS (

    SELECT
        date(block_time) AS daily,
        id,
        SUM(stake) AS net_total,
        SUM(CASE WHEN delegator in (select delegator from query_7564667) THEN stake ELSE 0 END) as net_vdp
    FROM stake_actions
    GROUP BY 1,2
),
running_flow AS (
select daily, id, sum(net_total) over (partition by id order by daily rows between unbounded preceding and current row) as total_stake,
 sum(net_vdp) over (partition by id order by daily rows between unbounded preceding and current row) as vdp_stake
 from daily_flow
),

lifespan AS (
select id, min(daily) as start_date,
current_date as end_date
from daily_flow
group by 1
),

date_grid AS (
select s.id, date(u.timestamp) as c_date
from lifespan s
cross join utils.days u
where date(u.timestamp) >= start_date 
and date(u.timestamp) <= end_date
),

joined AS (
select c_date as daily, g.id, total_stake, vdp_stake
from date_grid g
left join running_flow f
on g.c_date = f.daily
and g.id = f.id ),

bbd AS (
select daily, id, last_value(total_stake) ignore nulls over(partition by id order by daily asc) as total_stake, last_value(vdp_stake) ignore nulls over(partition by id order by daily asc 
rows between unbounded preceding and current row) as vdp_stake
from joined
)

select daily, id, coalesce(total_stake,0) as total_stake, coalesce(vdp_stake,0) as vdp_stake, coalesce(total_stake,0) - coalesce(vdp_stake,0) as organic_stake
from bbd
order by daily desc, id
