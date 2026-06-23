-- validator address, total_stake, vdp, non-vdp, vdp_tier, commission_rate
-- don't use for analysis. 

select id, auth_address, current_commission from query_6349457

select id, 
-- total stake per validator
sum(daily_total)

select id,
Min_by(daily_total, daily) as earliest_vdpStake,
MAX_by(daily_total, daily) AS current_vdpStake,
max(daily_total) as maxStake,
min(daily_total) as minStake
from query_7654100
where delegator in (select delegator from query_7564667) 
group by 1
order by 1 */

-- Thoughts: Considering Monad Tier has changed over time does it make sense to box the Tiers? 

/* select id, daily, delegator, daily_total
from query_7654100
where delegator in (select delegator from query_7564667) 
order by 1,2,3 */
