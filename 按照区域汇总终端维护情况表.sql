-- 按最小销售区域汇总的终端维护情况表：
DROP TABLE
IF
	EXISTS client_visit_summary;
CREATE TABLE client_visit_summary (
sale_dis_second varchar(255) comment '二级销售区域',
sale_dis_third varchar(255) comment '三级销售区域',
dis_client_count INT COMMENT '三级销售区域的全部终端数',
dis_manager_count float COMMENT '最小销售区域的责任业务代表数',
client_visit_count INT COMMENT '统计时间范围内区域内拜访的客户数',
client_id_count INT COMMENT '用户负责区域范围内拜访客户数',
client_visit_per VARCHAR ( 255 ) COMMENT '维护率 区域内拜访门店户数/区域终端数',
client_businessvisit INT COMMENT '用户负责区域范围内拜访商业客户户数',
client_termvisit INT COMMENT '用户负责区域范围内拜访终端客户户数',
clientvisit_distance_5min INT COMMENT '区域范围内拜访客户时间少于5min的户数',
min5_visit_per VARCHAR ( 255 ) COMMENT '5min拜访率 区域范围内拜访时间<5min/用户负责区域范围内拜访客户数',
clientvisit_distance_1hour INT COMMENT '区域范围内拜访客户时间大于5min少于1hour的户数',
hour1_visit_per VARCHAR ( 255 ) COMMENT '5min少于1hour拜访率 区域范围内拜访时间大于5min少于1hour/用户负责区域范围内拜访客户数',
clientvisit_distance_overhour INT COMMENT '区域范围内拜访客户时间大于1hour的户数',
overhour_visit_per VARCHAR ( 255 ) COMMENT '大于1hour拜访率 区域范围内拜访时间大于1hour/用户负责区域范围内拜访客户数',
clientvisit_onetime INT COMMENT '区域范围内拜访客户次数1次户数',
clientvisit_twotimes INT COMMENT '区域范围内拜访客户次数2次户数',
clientvisit_threetimes INT COMMENT '区域范围内拜访客户客户次数>2次户数',
display_duanhuo_lasttime INT COMMENT '区域范围内拜访客户有库存上报户数',
duanhuo_per VARCHAR ( 255 ) COMMENT '断货率 区域范围内上报库存户数/用户负责区域范围内拜访客户数',
display_pop_lasttime INT COMMENT '区域范围内拜访客户有pop上报户数',
display_ph_pt_lasttime INT COMMENT '区域范围内拜访客户有ph和pt版上报户数',
display_chenlie_lasttime INT COMMENT '区域范围内拜访客户有陈列报户数' 
) COMMENT = '最小销售区域汇总拜访行为及终端维护情况表';
INSERT INTO client_visit_summary (
sale_dis_second,
sale_dis_third,
dis_manager_count,
client_visit_count,
client_id_count,
client_visit_per,
client_businessvisit,
client_termvisit,
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
	a.sale_dis_third,
	count(a.client_id) as sale_third_count,
	sum( case when a.sale_duty_dis = 'Y' then 1 else 0 end ) AS client_id_count,
	sum( case when a.sale_duty_dis = 'Y' then 1 else 0 end ) AS submanager_visit_count,
	sum( sale_managers_visit) AS sale_managers_visit,
	sum( sale_managers_businessvisit) AS sale_managers_businessvisit,
	sum( sale_managers_termvisit) AS sale_managers_termvisit,
	sum( clientvisit_distance_5min) AS clientvisit_distance_5min,
	sum( clientvisit_distance_1hour) AS clientvisit_distance_1hour,
	sum( clientvisit_distance_overhour) AS clientvisit_distance_overhour,
	sum( clientvisit_onetime) AS clientvisit_onetime,
	sum( clientvisit_twotimes) AS clientvisit_twotimes,
	sum( clientvisit_threetimes) AS clientvisit_threetimes,
	sum( get_same(display_duanhuo_lasttime)) AS display_duanhuo_lasttime,
	sum( get_same(display_pop_lasttime)) AS display_pop_lasttime,
	sum( get_same(display_ph_pt_lasttime)) AS display_ph_pt_lasttime,
	sum( get_same(display_chenlie_lasttime)) As display_chenlie_lasttime 
FROM
	(
SELECT
	getarea(b.sale_allpath, 3) as sale_dis_second,
	getarea(b.sale_allpath, 4) as sale_dis_third,
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
	b.store_sum as display_duanhuo_lasttime
FROM
	staff_visit_client_base b)a
		GROUP BY a.sale_dis_second,
	a.sale_dis_secon,)a
	left join (select getarea(a.sale_allpath, 3) as sale_dis_second,
	getarea(a.sale_allpath, 4) as sale_dis_third,count(distinct a.client_id) as manager_client_count from client_info a group by sale_dis_second,sale_dis_third ) c
	on concat(a.sale_dis_second,a.sale_dis_third) = concat(c.sale_dis_second,c.sale_dis_third);

	

