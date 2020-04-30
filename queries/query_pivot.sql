SELECT   `pm_name`      AS 'PM', 
         `project_name` AS 'Проект', 
         `worker_name`  AS 'ФИО', 
         ifnull(sum( 
         CASE 
                  WHEN `dow` = 'Пн' THEN `hours` 
         end), '') AS 'Пн', 
         ifnull(sum( 
         CASE 
                  WHEN `dow` = 'Вт' THEN `hours` 
         end), '') AS 'Вт', 
         ifnull(sum( 
         CASE 
                  WHEN `dow` = 'Cр' THEN `hours` 
         end),'') AS 'Ср', 
         ifnull(sum( 
         CASE 
                  WHEN `dow` = 'Чт' THEN `hours` 
         end), '') AS 'Чт', 
         ifnull(sum( 
         CASE 
                  WHEN `dow` = 'Пт' THEN `hours` 
         end), '') AS 'Пт' 
FROM     ( 
                   SELECT    `pm_name`, 
                             `date`, 
                             substr('ВсПнВтСрЧтПтСб', 1 + 2 * strftime('%w', `date`), 2) AS dow,
                             `hours`, 
                             t6.`project_id`, 
                             `project_name`, 
                             `worker_id`, 
                             `worker_name`, 
                             `vacancy_name`, 
                             `type` 
                   FROM      ( 
                                       SELECT    `date`, 
                                                 `hours`, 
                                                 t3.`project_id`, 
                                                 `project_name`, 
                                                 t3.`worker_id`, 
                                                 `worker_name`, 
                                                 `vacancy_name`, 
                                                 `type` 
                                       FROM      ( 
                                                           SELECT    `date`, 
                                                                     `hours`, 
                                                                     `project_id`, 
                                                                     `name` AS `project_name`, 
                                                                     `worker_id`, 
                                                                     `worker_name`, 
                                                                     `type` 
                                                           FROM      ( 
                                                                               SELECT    `date`,
                                                                                         `hours`,
                                                                                         `project_id`,
                                                                                         `worker_id`,
                                                                                         `name` AS `worker_name`,
                                                                                         `type` 
                                                                               FROM      ( 
                                                                                                SELECT `date`,
                                                                                                       cast(substr(`time`,2,1) AS integer) AS `hours`,
                                                                                                       `project_id`,
                                                                                                       `worker_id`,
                                                                                                       `type`
                                                                                                FROM   (
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
                                                                                                WHERE  `date` BETWEEN '2020-02-17' AND    '2020-02-21' 
                                                                                                AND    `type` =
                                                                                                       CASE
                                                                                                              WHEN `date` < '2020-02-21' THEN 'spent' 
                                                                                                              ELSE 'estimated'
                                                                                                       end) t1
                                                                               LEFT JOIN `public.worker`
                                                                               ON        t1.`worker_id` = `public.worker`.`id`) t2
                                                           LEFT JOIN `public.project` 
                                                           ON        t2.`project_id` = `public.project`.`id`) t3
                                       LEFT JOIN 
                                                 ( 
                                                            SELECT     `project_id`, 
                                                                       `worker_id`, 
                                                                       `name` AS `vacancy_name` 
                                                            FROM       `public.projectworker` 
                                                            INNER JOIN `public.vacancy` 
                                                            ON         `public.projectworker`.`vacancy_on_project_id` = `public.vacancy`.`id`
                                                            AND        '2020-02-21' BETWEEN `public.projectworker`.`start_date` AND        `public.projectworker`.`end_date`) t4
                                       ON        t3.`project_id` = t4.`project_id` 
                                       AND       t3.`worker_id` = t4.`worker_id` 
                                       ORDER BY  t3.`project_id`, 
                                                 t3.`worker_id`) t6 
                   LEFT JOIN 
                             ( 
                                       SELECT    `project_id`, 
                                                 `name` AS `pm_name` 
                                       FROM      ( 
                                                            SELECT     `project_id`, 
                                                                       `worker_id`, 
                                                                       `name` AS `vacancy_name` 
                                                            FROM       `public.projectworker` 
                                                            INNER JOIN `public.vacancy` 
                                                            ON         `public.projectworker`.`vacancy_on_project_id` = `public.vacancy`.`id`
                                                            AND        '2020-02-21' BETWEEN `public.projectworker`.`start_date` AND        `public.projectworker`.`end_date` 
                                                            AND        `vacancy_name` = 'PM') t5
                                       LEFT JOIN `public.worker` 
                                       ON        t5.`worker_id` = `public.worker`.`id`) t7 
                   ON        t6.`project_id` = t7.`project_id` 
                   ORDER BY  `date`, 
                             `project_name`, 
                             `worker_name`) 
GROUP BY `pm_name`, 
         `project_name`, 
         `worker_name`;