-- 创建基础区域拜访及终端维护情况表
DROP TABLE
IF
	EXISTS client_visit_base;
CREATE TABLE client_visit_base (
sale_dis VARCHAR ( 255 ) COMMENT '拜访区域',
client_id_count INT COMMENT '拜访户数',
client_visit_count INT COMMENT '拜访次数',
client_businessvisit INT COMMENT '商业拜访次数',
client_termvisit INT COMMENT '终端拜访次数',
clientvisit_distance_5min INT COMMENT '停留5min内的拜访户数',
clientvisit_distance_1hour INT COMMENT '停留5min-1hour内的拜访户数',
clientvisit_distance_overhour INT COMMENT '停留>1hour内的拜访户数',
clientvisit_onetime INT COMMENT '拜访1次的户数',
clientvisit_twotimes INT COMMENT '拜访2次的户数',
clientvisit_threetimes INT COMMENT '拜访3次的户数',
display_chenlie_lasttime INT COMMENT '有陈列的户数',
display_ph_pt_lasttime INT COMMENT '有ph&pt的户数',
display_pop_lasttime INT COMMENT '有ph&pt的户数',
display_duanhuo_lasttime INT COMMENT '有断货的户数'
) COMMENT = '手机系统统计周报基础表';
INSERT INTO client_visit_base (
sale_dis,
client_id_count,
client_visit_count,
client_businessvisit,
client_termvisit,
clientvisit_distance_5min,
clientvisit_distance_1hour,
clientvisit_distance_overhour,
clientvisit_onetime,
clientvisit_twotimes,
clientvisit_threetimes,
display_chenlie_lasttime,
display_ph_pt_lasttime,
display_pop_lasttime,
display_duanhuo_lasttime
)SELECT
		a.sale_dis,
		count( a.client_id ) AS client_id_count,
		sum( a.client_visit_count) AS client_visit_count,
		sum( a.client_businessvisit ) AS client_businessvisit,
		sum( a.client_termvisit ) AS client_termvisit,
		sum( a.clientvisit_distance_5min ) AS clientvisit_distance_5min,
		sum( a.clientvisit_distance_1hour ) AS clientvisit_distance_1hour,
		sum( a.clientvisit_distance_overhour ) AS clientvisit_distance_overhour,
		sum( a.clientvisit_onetime ) AS clientvisit_onetime,
		sum( a.clientvisit_twotimes ) AS clientvisit_twotimes,
		sum( a.clientvisit_threetimes ) AS clientvisit_threetimes,
		sum( a.display_chenlie_lasttime ) AS display_chenlie_lasttime,
		sum( a.display_ph_pt_lasttime ) AS display_ph_pt_lasttime,
		sum( a.display_pop_lasttime ) AS display_pop_lasttime,
		sum( a.other_info_lasttime ) AS display_duanhuo_lasttime 
	FROM
	(
		SELECT
			d.client_id,
			d.sale_dis,
			d.client_type,
			d.client_visit_count,
			d.client_businessvisit,
			d.client_termvisit,
			d.clientvisit_distance_5min,
			d.clientvisit_distance_1hour,
			d.clientvisit_distance_overhour,
			d.clientvisit_onetime,
			d.clientvisit_twotimes,
			d.clientvisit_threetimes,
		CASE
				
				WHEN g.display_chenlie_lasttime IS NULL THEN
				0 ELSE g.display_chenlie_lasttime 
			END AS display_chenlie_lasttime,
		CASE
				
				WHEN g.display_ph_pt_lasttime IS NULL THEN
				0 ELSE g.display_ph_pt_lasttime 
			END AS display_ph_pt_lasttime,
		CASE
				
				WHEN g.display_pop_lasttime IS NULL THEN
				0 ELSE g.display_pop_lasttime 
			END AS display_pop_lasttime,
		CASE
				
				WHEN a.store_sum > 0 THEN
				1 ELSE 0 
			END AS other_info_lasttime 
		FROM
			(
			SELECT
				d.client_id,
				d.sale_dis,
				d.client_type,
				d.client_visit_count,
			CASE
					
					WHEN d.client_type IN ( '经销商', '分销商', '连锁总部', '批发商' ) THEN
					sum( d.client_visit_count ) ELSE 0 
				END AS client_businessvisit,
			CASE
					
					WHEN d.client_type NOT IN ( '经销商', '分销商', '连锁总部', '批发商' ) THEN
					sum( d.client_visit_count ) ELSE 0 
				END AS client_termvisit,
				d.clientvisit_distance_5min,
				d.clientvisit_distance_1hour,
				d.clientvisit_distance_overhour,
			CASE
					
					WHEN d.client_visit_count = 1 THEN
					1 ELSE 0 
				END AS clientvisit_onetime,
			CASE
					
					WHEN d.client_visit_count = 2 THEN
					1 ELSE 0 
				END AS clientvisit_twotimes,
			CASE
					
					WHEN d.client_visit_count > 2 THEN
					1 ELSE 0 
				END AS clientvisit_threetimes 
			FROM
				(
				SELECT
					d.client_id,
					d.sale_dis,
					d.client_type,
					count( d.client_id ) AS client_visit_count,
				CASE WHEN d.visit_minute < 6 THEN 1 ELSE 0 END AS clientvisit_distance_5min,
				CASE WHEN d.visit_minute > 5 AND d.visit_minute < 61 THEN 1 ELSE 0 END AS clientvisit_distance_1hour,        CASE WHEN d.visit_minute > 60 THEN 1 ELSE 0 END AS clientvisit_distance_overhour 
					FROM
						visit_log d 
					GROUP BY
						d.client_id,
						d.sale_dis,
						d.client_type 
					) d 
				GROUP BY
					d.client_id,
					d.sale_dis,
					d.client_type 
		) d -- 拜访数据汇总
		LEFT JOIN 
		(
				SELECT
					g.client_id,
					g.sale_dis,
					g.client_type,
				CASE
						
						WHEN g.display_huojia = '有' 
						OR g.display_duitou = '有' THEN
							1 ELSE 0 
						END AS display_chenlie_lasttime,
					CASE
							
							WHEN g.display_ph_pt = '有' THEN
							1 ELSE 0 
						END AS display_ph_pt_lasttime,
					CASE
							
							WHEN g.display_pop = '有' THEN
							1 ELSE 0 
						END AS display_pop_lasttime 
					FROM
						southtask_log g 
					GROUP BY
						g.client_id,
						g.sale_dis,
						g.client_type 
	) g -- 南战区终端任务表数据汇总
		ON d.client_id = g.client_id
		LEFT JOIN -- 左链接库存数据
		(
					SELECT
						a.client_id,
						a.sale_dis,
						a.client_type,
						a.changrun25 + a.changrun40 + a.changjing25 + a.changjing40 + a.laili24 AS store_sum 
					FROM
						(
						SELECT
							a.client_id,
							a.sale_dis,
							a.client_type,
						CASE
								
								WHEN a.product_name = '常润茶20+5' THEN
								a.prodstore_volume ELSE 0 
							END AS changrun25,
						CASE
								
								WHEN a.product_name = '常润茶40' THEN
								a.prodstore_volume ELSE 0 
							END AS changrun40,
						CASE
								
								WHEN a.product_name = '常菁茶20+5' THEN
								a.prodstore_volume ELSE 0 
							END AS changjing25,
						CASE
								
								WHEN a.product_name = '常菁茶40' THEN
								a.prodstore_volume ELSE 0 
							END AS changjing40,
						CASE
								
								WHEN a.product_name = '来利24' THEN
								a.prodstore_volume ELSE 0 
							END AS laili24 
						FROM
							store_log a 
						) a 
					GROUP BY
						a.client_id,
						a.sale_dis,
						a.client_type 
		) a -- 库存数据汇总
		ON d.client_id = a.client_id 
	) a 
	GROUP BY
		a.sale_dis;