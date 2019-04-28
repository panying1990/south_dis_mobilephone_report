-- 创建基础人员拜访情况表
DROP TABLE
IF
	EXISTS staff_visit_client_base;
CREATE TABLE staff_visit_client_base (
sale_allpath VARCHAR ( 255 ) COMMENT '拜访客户全路径',
sale_manager VARCHAR ( 255 ) COMMENT '拜访员工',
client_id INT COMMENT '客户编码',
sale_managers_visit INT COMMENT '拜访次数',
sale_managers_businessvisit INT COMMENT '商业拜访次数',
sale_managers_termvisit INT COMMENT '终端拜访次数',
clientvisit_distance_5min INT COMMENT '停留5min内的拜访户数',
clientvisit_distance_1hour INT COMMENT '停留5min-1hour内的拜访户数',
clientvisit_distance_overhour INT COMMENT '停留>1hour内的拜访户数',
clientvisit_onetime INT COMMENT '拜访1次的户数',
clientvisit_twotimes INT COMMENT '拜访2次的户数',
clientvisit_threetimes INT COMMENT '拜访3次的户数',
display_chenlie_lasttime INT COMMENT '有陈列的户数',
display_ph_pt_lasttime INT COMMENT '有ph&pt的户数',
display_pop_lasttime INT COMMENT '有ph&pt的户数',
store_sum INT COMMENT '库存产品数'
) COMMENT = '手机系统统计周报基础表';
INSERT INTO staff_visit_client_base (
sale_allpath,
sale_manager,
client_id,
sale_managers_visit,
sale_managers_businessvisit,
sale_managers_termvisit,
clientvisit_distance_5min,
clientvisit_distance_1hour,
clientvisit_distance_overhour,
clientvisit_onetime,
clientvisit_twotimes,
clientvisit_threetimes,
display_chenlie_lasttime,
display_ph_pt_lasttime,
display_pop_lasttime,
store_sum
) SELECT
a.sale_allpath,
a.sale_manager,
a.client_id,
a.sale_managers_visit,
a.sale_managers_businessvisit,
a.sale_managers_termvisit,
a.clientvisit_distance_5min,
a.clientvisit_distance_1hour,
a.clientvisit_distance_overhour,
a.clientvisit_onetime,
a.clientvisit_twotimes,
a.clientvisit_threetimes,
a.display_chenlie_lasttime,
a.display_ph_pt_lasttime,
a.display_pop_lasttime,
a.store_sum
FROM
	(
		SELECT
			d.client_id,
			d.sale_allpath,
			d.sale_manager,
			d.sale_managers_visit,
			d.sale_managers_businessvisit,
			d.sale_managers_termvisit,
			d.clientvisit_distance_5min,
			d.clientvisit_distance_1hour,
			d.clientvisit_distance_overhour,
			d.clientvisit_onetime,
			d.clientvisit_twotimes,
			d.clientvisit_threetimes,
		  g.display_chenlie_lasttime,
		  g.display_ph_pt_lasttime,
		  g.display_pop_lasttime,
      a.store_sum 
			FROM
				(
				SELECT
					  d.client_id,
						d.sale_allpath,
						d.sale_manager,
					d.sale_managers_visit,
				CASE WHEN typemake(d.client_type)='client' THEN sum(d.sale_managers_visit) ELSE 0 
					END AS sale_managers_businessvisit,
				CASE WHEN typemake(d.client_type)='term' THEN
						sum(d.sale_managers_visit) ELSE 0 
					END AS sale_managers_termvisit,
					d.clientvisit_distance_5min,
					d.clientvisit_distance_1hour,
					d.clientvisit_distance_overhour,
				CASE
						
						WHEN d.sale_managers_visit = 1 THEN
						1 ELSE 0 
					END AS clientvisit_onetime,
				CASE
						
						WHEN d.sale_managers_visit = 2 THEN
						1 ELSE 0 
					END AS clientvisit_twotimes,
				CASE
						
						WHEN d.sale_managers_visit > 2 THEN
						1 ELSE 0 
					END AS clientvisit_threetimes 
				FROM
					(
					SELECT
					  d.client_id,
						d.sale_allpath,
						d.sale_manager,
						d.client_type,
			      count(d.client_id) as sale_managers_visit,
					  getminute(d.visit_minute,0,5) as clientvisit_distance_5min,
					  getminute(d.visit_minute,5,61) as clientvisit_distance_1hour, 
					  getminute(d.visit_minute,60,400) as clientvisit_distance_overhour 
						FROM
							visit_log d
						GROUP BY
						 d.client_id,
						 d.sale_allpath,
						 d.sale_manager
						 having
						 getarea(sale_allpath,2) = '华南'
						) d 
					GROUP BY
						d.client_id,
						d.sale_allpath,
						d.sale_manager
					) d -- 拜访数据汇总
					LEFT JOIN 
				  	(SELECT
					  g.client_id,
						g.sale_manager,
					  g.sale_allpath,
						getchenlie(concat(display_huojia,g.display_duitou)) as display_chenlie_lasttime,
						getchenlie(display_ph_pt) as display_ph_pt_lasttime,
						getchenlie(display_pop) as display_pop_lasttime
						FROM
							southtask_log g
						GROUP BY
						  g.client_id,
						  g.sale_manager,
					    g.sale_allpath
						having
						 getarea(g.sale_allpath,2) = '华南'
						) g -- 南战区终端任务表数据汇总
						ON CONCAT( d.sale_manager, d.client_id ) = CONCAT( g.sale_manager, g.client_id)
						LEFT JOIN -- 左链接库存数据
						(
						SELECT
							 a.client_id,
							 a.sale_manager,
							 a.sale_allpath,
							a.changrun25 + a.changrun40 + a.changjing25 + a.changjing40 + a.laili24 AS store_sum 
						FROM
							(
							SELECT
                a.client_id,
								a.sale_manager,
								a.sale_allpath,
								getprod(a.product_name,'常润茶20+5',a.prodstore_volume) as changrun25,
								getprod(a.product_name,'常润茶40',a.prodstore_volume) as changrun40,
								getprod(a.product_name,'常菁茶20+5',a.prodstore_volume) as changjing25,
								getprod(a.product_name,'常菁茶40',a.prodstore_volume) as changjing40,
								getprod(a.product_name,'来利24',a.prodstore_volume) as laili24
							FROM
								store_log a )
								a
							GROUP BY
								a.client_id,
							  a.sale_manager,
							  a.sale_allpath
							) a -- 库存数据汇总
						ON CONCAT( d.sale_manager, d.client_id ) = CONCAT( a.sale_manager, a.client_id))a ;