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
WHERE  `project_id` <> '';