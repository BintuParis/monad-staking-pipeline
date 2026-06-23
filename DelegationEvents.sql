SELECT 
    block_time,
    block_number,
    hash as tx_hash,
    "from" as delegator_address,
    value / 1e18 as amount_monad,
    varbinary_to_uint256(varbinary_substring(data, 5, 32)) as val_id,
    'delegate' as action_type
FROM monad.transactions
WHERE to = 0x0000000000000000000000000000000000001000
  AND varbinary_substring(data, 1, 4) = 0x84994fec
  AND success = true

UNION ALL

SELECT 
    block_time,
    block_number,
    hash as tx_hash,
    "from" as delegator_address,
    varbinary_to_uint256(varbinary_substring(data, 37, 32)) / 1e18 as amount_monad,
    varbinary_to_uint256(varbinary_substring(data, 5, 32)) as val_id,
    'undelegate' as action_type
FROM monad.transactions
WHERE to = 0x0000000000000000000000000000000000001000
  AND varbinary_substring(data, 1, 4) = 0x5cf41514
  AND success = true
