WITH main AS
(SELECT
  L1.block_time,
  varbinary_to_uint256(substr(L2.data, 33, 32)) AS epoch,
  varbinary_to_uint256(varbinary_ltrim(l1.topic1)) AS val_id,
  CONCAT('0x', to_hex(varbinary_ltrim(l1.topic2))) as auth_address,
  varbinary_to_uint256(substr(L2.data, 1, 32)) / CAST(1000000000000000000 AS DECIMAL(38,0)) AS stake_amount,
  varbinary_to_uint256(varbinary_substring(l1.data, 1, 32)) / 1000000000000000000 * 100 AS commission,
  L1.tx_hash
FROM monad.logs l1
LEFT JOIN monad.logs l2
ON l1.tx_hash = l2.tx_hash
AND l1.topic0 <> l2.topic0
WHERE
  l1.contract_address = 0x0000000000000000000000000000000000001000
  AND l1.topic0 = 0x6f8045cd38e512b8f12f6f02947c632e5f25af03aad132890ecf50015d97c1b2 -- validatorCreated event
  AND l2.topic0 = 0xe4d4df1e1827dd28252fd5c3cd7ebccd3da6e0aa31f74c828f3c8542af49d840  --initial Delegate event
 ),

latest AS (SELECT val_id, newCommission
FROM (SELECT row_number() over (partition by varbinary_to_uint256(varbinary_ltrim(topic1))
order by block_time desc) as rn,
varbinary_to_uint256(varbinary_ltrim(topic1)) AS val_id, 
cast(varbinary_to_uint256(substr(data, 33, 32)) as double) / 1e18 * 100 AS newCommission
FROM monad.logs
WHERE contract_address = 0x0000000000000000000000000000000000001000
AND topic0 = 0xd1698d3454c5b5384b70aaae33f1704af7c7e055f0c75503ba3146dc28995920)
WHERE rn = 1)

SELECT block_time AS createdTime, epoch AS createdEpoch, m.val_id, auth_address, stake_amount AS initialStake, COALESCE(newCommission, commission) AS current_commission
FROM main m
LEFT JOIN latest l
ON m.val_id = l.val_id
order by 1
