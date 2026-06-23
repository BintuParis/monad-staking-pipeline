WITH stake_actions AS (

    SELECT
        validatorId AS id,
        delegator,
        amount / 1e18 AS stake,
        block_time
    FROM QUERY_6569926 -- dune query id for decoded delegation events

    UNION ALL

    SELECT
        validatorId AS id,
        delegator,
        -amount / 1e18 AS stake,
        block_time
    FROM QUERY_6570705 -- dune query id for decoded undelegation events

),

daily_validator_flow AS (

    SELECT
        date(block_time) AS daily,
        id,
        SUM(stake) AS net_stake_change
    FROM stake_actions
    GROUP BY 1,2

)

SELECT
    daily,
    id,
    SUM(net_stake_change) OVER (
        PARTITION BY id
        ORDER BY daily
    ) AS total_validator_stake
FROM daily_validator_flow
order by 1 desc
