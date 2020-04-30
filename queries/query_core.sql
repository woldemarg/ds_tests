SELECT `date`, 
       `spent_time` AS `time`, 
       `project_id`, 
       `worker_id`, 
       'spent' AS `type` 
FROM   `public.dailylog` 
WHERE  `project_id` <> '' 
UNION 
SELECT `date`, 
       `estimated_time` AS `time`, 
       `project_id`, 
       `worker_id`, 
       'estimated' AS `type` 
FROM   `public.dailyplan` 
WHERE  `project_id` <> '') 
WHERE `date` BETWEEN '2020-02-17' AND '2020-02-21' 
AND `type` = 
CASE 
WHEN `date` < '2020-02-21' THEN 
  'spent' 
ELSE 
  'estimated' 
end;