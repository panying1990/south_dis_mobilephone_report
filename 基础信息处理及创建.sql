-- 创建基础客户信息表并插入
DROP TABLE
IF
	EXISTS client_info;
CREATE TABLE client_info (
client_id VARCHAR ( 255 ) COMMENT '客户编码',
client_name VARCHAR ( 255 ) COMMENT '客户名称',
client_type VARCHAR ( 255 ) COMMENT '客户类型',
client_province VARCHAR ( 255 ) COMMENT '客户所在省',
client_address VARCHAR ( 255 ) COMMENT '客户详细地址',
sale_manager VARCHAR ( 255 ) COMMENT '客户经理',
sale_allpath VARCHAR ( 255 ) COMMENT '销售区域全路径',
sale_dis VARCHAR ( 255 ) COMMENT '销售最小区域'
) COMMENT = '客户信息表';
INSERT INTO client_info ( client_id, client_name, client_type, client_province, client_address, sale_manager, sale_allpath, sale_dis ) SELECT
客户编码,客户名称,客户类型,行政省,详细地址,客户经理,销售区域全路径,销售区域 from
	client_data_template;
-- 创建拜访信息记录表
DROP TABLE
IF
	EXISTS visit_log;
CREATE TABLE visit_log (
visit_date DATE COMMENT '拜访日期',
visit_plan_type VARCHAR ( 255 ) COMMENT '拜访类型',
sale_manager VARCHAR ( 255 ) COMMENT '拜访人',
sale_allpath VARCHAR ( 255 ) COMMENT '销售区域全路径',
sale_dis VARCHAR ( 255 ) COMMENT '销售最小区域',
sale_plan VARCHAR ( 255 ) COMMENT '拜访计划',
client_id VARCHAR ( 255 ) COMMENT '客户编号',
client_name VARCHAR ( 255 ) COMMENT '客户名称',
client_address VARCHAR ( 255 ) COMMENT '客户详细地址',
client_type VARCHAR ( 255 ) COMMENT '客户类型',
visit_status VARCHAR ( 255 ) COMMENT '拜访状态',
visit_minute INT COMMENT '拜访持续时长' 
) COMMENT '拜访记录表';
INSERT INTO visit_log (
visit_date,
visit_plan_type,
sale_manager,
sale_allpath,
sale_dis,
sale_plan,
client_id,
client_name,
client_address,
client_type,
visit_status,
visit_minute 
) SELECT
`拜访日期`,
`拜访流程`,
`拜访人`,
`销售区域全路径`,
`销售区域`,
`计划类型`,
`客户编码`,
`拜访客户`,
`客户位置`,
`客户类型`,
`拜访完成`,
`拜访用时(分钟)` 
FROM
	visit_data_template 
WHERE
	拜访完成 = '已完成';
	

-- 创建南战区终端任务表记录
DROP TABLE
IF
	EXISTS southtask_log;
CREATE TABLE southtask_log (
visit_date DATETIME COMMENT '拜访日期',
sale_manager VARCHAR ( 255 ) COMMENT '拜访人',
sale_allpath VARCHAR ( 255 ) COMMENT '销售区域全路径',
sale_dis VARCHAR ( 255 ) COMMENT '销售最小区域',
client_id VARCHAR ( 255 ) COMMENT '客户编号',
client_name VARCHAR ( 255 ) COMMENT '客户名称',
client_type VARCHAR ( 255 ) COMMENT '客户类型',
display_duitou VARCHAR ( 255 ) COMMENT '堆头',
display_huojia VARCHAR ( 255 ) COMMENT '货架',
display_ph_pt VARCHAR ( 255 ) COMMENT '喷绘/PT版',
display_pop VARCHAR ( 255 ) COMMENT '海报',
display_other VARCHAR ( 255 ) COMMENT '其他',
price_run25 VARCHAR ( 255 ) COMMENT '常润茶25袋价格',
price_jing25 VARCHAR ( 255 ) COMMENT '常菁茶25袋价格',
price_run40 VARCHAR ( 255 ) COMMENT '常润茶40袋价格',
price_jing40 VARCHAR ( 255 ) COMMENT '常菁茶40袋价格',
price_laili VARCHAR ( 255 ) COMMENT '来利价格',
activity_status VARCHAR ( 255 ) COMMENT '是否参加活动',
activity_describe VARCHAR ( 255 ) COMMENT '活动描述',
activity_gifts VARCHAR ( 255 ) COMMENT '活动是否有赠品',
activity_giftsdescribe VARCHAR ( 255 ) COMMENT '赠品情况描述'
) COMMENT = '南战区终端任务表';
INSERT INTO southtask_log (
visit_date,
sale_manager,
sale_allpath,
sale_dis,
client_id,
client_name,
client_type,
display_duitou,
display_huojia,
display_ph_pt,
display_pop,
display_other,
price_run25,
price_jing25,
price_run40,
price_jing40,
price_laili,
activity_status,
activity_describe,
activity_gifts,
activity_giftsdescribe
) SELECT
`上报时间`,
`拜访人`,
`销售区域全路径`,
`销售区域`,
`客户编码`,
`拜访客户`,
`客户类型`,
tt.陈列,
tt.`Unnamed: 11`,
tt.`Unnamed: 12`,
tt.`Unnamed: 13`,
tt.`Unnamed: 14`,
tt.零售价,
tt.`Unnamed: 16`,
tt.`Unnamed: 17`,
tt.`Unnamed: 18`,
tt.`Unnamed: 19`,
tt.活动,
tt.`Unnamed: 21`,
tt.`Unnamed: 22`,
tt.`Unnamed: 23`
FROM
	termtask_temp_template tt 
WHERE
	拜访完成 = '已完成' ;
	
	
-- 创建库存明细表
DROP TABLE
IF
	EXISTS store_log;
CREATE TABLE store_log (
report_date DATETIME COMMENT '库存上报日期',
sale_manager VARCHAR ( 255 ) COMMENT '上报人 即拜访人',
sale_allpath VARCHAR ( 255 ) COMMENT '销售区域全路径',
sale_dis VARCHAR ( 255 ) COMMENT '销售最小区域',
client_id VARCHAR ( 255 ) COMMENT '客户编号',
client_name VARCHAR ( 255 ) COMMENT '客户名称',
client_type VARCHAR ( 255 ) COMMENT '客户类型',
product_name VARCHAR ( 255 ) COMMENT '商品名称',
prodstore_volume INT COMMENT '商品库存量' 
) COMMENT = '库存明细表';
INSERT INTO store_log ( report_date, sale_manager, sale_allpath, sale_dis, client_id, client_name, client_type, product_name, prodstore_volume ) SELECT
a.* 
FROM
	(
SELECT
	a.`上报日期` AS report_date,
	a.上报人 AS sale_manager,
	b.sale_allpath AS sale_allpath,
	a.`客户区域` AS sale_dis,
	a.`客户编码` AS client_id,
	a.`客户` AS client_name,
	a.客户类型 AS client_type,
	a.`商品名称` AS product_name,
	a.`库存数量` AS prodstore_volume 
FROM
	store_temp_template a,
	client_info b 
WHERE
	a.`客户编码` = b.client_id 
	) a ;
