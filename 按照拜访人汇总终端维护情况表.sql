-- 按用户汇总销售人员拜访动作以及归属于个人的终端表现情况：
DROP TABLE
IF
	EXISTS sale_visit_summary;
CREATE TABLE sale_visit_summary (
sale_dis_second VARCHAR ( 255 ) COMMENT '业务代表归属区域',
sale_manager VARCHAR ( 255 ) COMMENT '业务代表 拜访人 协防人',
manager_client_count INT COMMENT '归属于用户的区域终端数',
manager_visit_count INT COMMENT '统计时间范围内用户拜访的客户数',
client_id_count INT COMMENT '用户负责区域范围内拜访客户数',
sale_managers_visit INT COMMENT '用户负责区域范围内拜访客户次数',
submanager_visit_count INT COMMENT '用户非负责区域范围内拜访客户数',
submanager_visit_per VARCHAR ( 255 ) COMMENT '协防率 用户非负责区域范围内拜访客户数/统计时间范围内用户拜访的客户数',
manager_visit_per VARCHAR ( 255 ) COMMENT '维护率 用户负责区域范围内拜访客户数/归属于用户的区域终端数',
sale_managers_businessvisit INT COMMENT '用户负责区域范围内拜访商业客户户数',
sale_managers_termvisit INT COMMENT '用户负责区域范围内拜访终端客户户数',
clientvisit_distance_5min INT COMMENT '用户负责区域范围内拜访客户时间少于5min的户数',
min5_visit_per VARCHAR ( 255 ) COMMENT '5min拜访率 用户负责区域范围内拜访时间<5min/用户负责区域范围内拜访客户数',
clientvisit_distance_1hour INT COMMENT '用户负责区域范围内拜访客户时间大于5min少于1hour的户数',
hour1_visit_per VARCHAR ( 255 ) COMMENT '5min少于1hour拜访率 用户负责区域范围内拜访时间大于5min少于1hour/用户负责区域范围内拜访客户数',
clientvisit_distance_overhour INT COMMENT '用户负责区域范围内拜访客户时间大于1hour的户数',
overhour_visit_per VARCHAR ( 255 ) COMMENT '大于1hour拜访率 用户负责区域范围内拜访时间大于1hour/用户负责区域范围内拜访客户数',
clientvisit_onetime INT COMMENT '用户负责区域范围内拜访客户次数1次户数',
clientvisit_twotimes INT COMMENT '用户负责区域范围内拜访客户次数2次户数',
clientvisit_threetimes INT COMMENT '用户负责区域范围内拜访客户客户次数>2次户数',
display_duanhuo_lasttime INT COMMENT '用户负责区域范围内拜访客户有库存上报户数',
duanhuo_per VARCHAR ( 255 ) COMMENT '断货率 用户负责区域范围内上报库存户数/用户负责区域范围内拜访客户数',
display_pop_lasttime INT COMMENT '用户负责区域范围内拜访客户有pop上报户数',
display_ph_pt_lasttime INT COMMENT '用户负责区域范围内拜访客户有ph和pt版上报户数',
display_chenlie_lasttime INT COMMENT '用户负责区域范围内拜访客户有陈列报户数' 
) COMMENT = '用户汇总销售人员拜访动作以及归属于个人的终端表现情况表';
INSERT INTO sale_visit_summary (
sale_dis_second,
sale_manager,
manager_client_count,
manager_visit_count,
client_id_count,
sale_managers_visit,
submanager_visit_count,
submanager_visit_per,
manager_visit_per,
sale_managers_businessvisit,
sale_managers_termvisit,
clientvisit_distance_5min,
min5_visit_per,
clientvisit_distance_1hour,
hour1_visit_per,
clientvisit_distance_overhour,
overhour_visit_per,
clientvisit_onetime,
clientvisit_twotimes,
clientvisit_threetimes,
display_duanhuo_lasttime,
duanhuo_per,
display_pop_lasttime,
display_ph_pt_lasttime,
display_chenlie_lasttime 
) SELECT
a.sale_dis_second,
a.sale_manager,
c.manager_client_count,
a.manager_visit_count,
a.client_id_count,
a.sale_managers_visit,
a.submanager_visit_count,
concat( round( a.submanager_visit_count / a.manager_visit_count * 100, 0 ), '%' ) AS submanager_visit_per,
concat( round( a.client_id_count / c.manager_client_count * 100, 0 ), '%' ) AS manager_visit_per,
a.sale_managers_businessvisit,
a.sale_managers_termvisit,
a.clientvisit_distance_5min,
concat( round( a.clientvisit_distance_5min / a.client_id_count * 100, 0 ), '%' ) AS min5_visit_per,
a.clientvisit_distance_1hour,
concat( round( a.clientvisit_distance_1hour / a.client_id_count * 100, 0 ), '%' ) AS hour1_visit_per,
a.clientvisit_distance_overhour,
concat( round( a.clientvisit_distance_overhour / a.client_id_count * 100, 0 ), '%' ) AS overhour_visit_per,
a.clientvisit_onetime,
a.clientvisit_twotimes,
a.clientvisit_threetimes,
a.display_duanhuo_lasttime,
concat( round( ( a.client_id_count - a.display_duanhuo_lasttime ) / a.client_id_count * 100, 0 ), '%' ) AS duanhuo_per,
a.display_pop_lasttime,
a.display_ph_pt_lasttime,
a.display_chenlie_lasttime 
FROM
	(
SELECT
  a.sale_dis_second,
	a.sale_manager,
	count(a.client_id) as manager_visit_count,
	sum( case when a.sale_duty_dis = 'Y' then 1 else 0 end ) AS client_id_count,
	sum( case when a.sale_duty_dis = 'N' then 1 else 0 end ) AS submanager_visit_count,
	sum( IF ( a.sale_duty_dis = 'Y', sale_managers_visit, 0 ) ) AS sale_managers_visit,
	sum( IF ( a.sale_duty_dis = 'Y', sale_managers_businessvisit, 0 ) ) AS sale_managers_businessvisit,
	sum( IF ( a.sale_duty_dis = 'Y', sale_managers_termvisit, 0 ) ) AS sale_managers_termvisit,
	sum( IF ( a.sale_duty_dis = 'Y', clientvisit_distance_5min, 0 ) ) AS clientvisit_distance_5min,
	sum( IF ( a.sale_duty_dis = 'Y', clientvisit_distance_1hour, 0 ) ) AS clientvisit_distance_1hour,
	sum( IF ( a.sale_duty_dis = 'Y', clientvisit_distance_overhour, 0 ) ) AS clientvisit_distance_overhour,
	sum( IF ( a.sale_duty_dis = 'Y', clientvisit_onetime, 0 ) ) AS clientvisit_onetime,
	sum( IF ( a.sale_duty_dis = 'Y', clientvisit_twotimes, 0 ) ) AS clientvisit_twotimes,
	sum( IF ( a.sale_duty_dis = 'Y', clientvisit_threetimes, 0 ) ) AS clientvisit_threetimes,
	sum( IF ( a.sale_duty_dis = 'Y', get_same(display_duanhuo_lasttime), 0 ) ) AS display_duanhuo_lasttime,
	sum( IF ( a.sale_duty_dis = 'Y', display_pop_lasttime, 0 ) ) AS display_pop_lasttime,
	sum( IF ( a.sale_duty_dis = 'Y', display_ph_pt_lasttime, 0 ) ) AS display_ph_pt_lasttime,
	sum( IF ( a.sale_duty_dis = 'Y', display_chenlie_lasttime, 0 ) ) As display_chenlie_lasttime 
FROM
	(
SELECT
	getarea(b.sale_allpath, 3) as sale_dis_second,
  b.sale_manager,
  b.client_id,
	b.sale_managers_visit,
	b.sale_managers_businessvisit,
	b.sale_managers_termvisit,
	b.clientvisit_distance_5min,
	b.clientvisit_distance_1hour,
	b.clientvisit_distance_overhour,
	b.clientvisit_onetime,
	b.clientvisit_twotimes,
	b.clientvisit_threetimes,
	b.display_chenlie_lasttime,
	b.display_ph_pt_lasttime,
	b.display_pop_lasttime,
	b.store_sum as display_duanhuo_lasttime,
	if(b.sale_manager = a.sale_manager,'Y','N') AS sale_duty_dis
FROM
	staff_visit_client_base b
	LEFT JOIN (
			select client_id, sale_manager from client_info where getarea(sale_allpath, 2)='华南' and sale_manager not regexp '停用') a ON b.client_id=a.client_id)a
		GROUP BY a.sale_dis_second,
	a.sale_manager)a
	left join (select a.sale_manager,count(distinct a.client_id) as manager_client_count from client_info a group by a.sale_manager having sale_manager not regexp '停用') c
	on a.sale_manager = c.sale_manager;

	
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			