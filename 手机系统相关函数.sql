-- 统一格式
CREATE DEFINER=`root`@`localhost` FUNCTION `get_same`(input_info int) RETURNS int(11)
BEGIN
	DECLARE out_int integer DEFAULT 0;
	if input_info is null then set out_int = 0;
	elseif input_info = 0 then set out_int = 0;
	else set out_int = 1;
	end if;

	RETURN out_int;
END

-- 拆分销售区域全路径
CREATE DEFINER=`root`@`localhost` FUNCTION `getarea`(sale_allpath varchar(255),area_level int) RETURNS varchar(150) CHARSET utf8mb4 COLLATE utf8mb4_bin
BEGIN
  declare out_area varchar(150) default '' ;
	if (area_level = 2) then 
	set out_area = substring_index(substring_index(sale_allpath,'/',area_level),'/',-1);
  elseif (area_level = 3) then 
	set out_area = substring_index(substring_index(sale_allpath,'/',area_level),'/',-1);
	elseif (area_level = 4) then 
	set out_area = substring_index(substring_index(sale_allpath,'/',area_level),'/',-1);
	else set out_area = '';
	end if;
	RETURN out_area;
END

-- 处理陈列信息
CREATE DEFINER=`root`@`localhost` FUNCTION `getchenlie`(display_info varchar(255)) RETURNS int(11)
BEGIN
  declare out_int INTEGER default null;
	if (display_info regexp '有') then 
	set out_int = 1;
	else set out_int = 0;
	end if;
	RETURN out_int;
END


-- 获得拜访时间
CREATE DEFINER=`root`@`localhost` FUNCTION `getminute`(visit_minute varchar(255),down int(11),up int(11)) RETURNS int(11)
BEGIN
  declare out_int INTEGER default null;
	if (visit_minute BETWEEN down and up) then 
	set out_int = 1;
	else set out_int = 0;
	end if;
	RETURN out_int;
END

-- 整理产品名称
CREATE DEFINER=`root`@`localhost` FUNCTION `getprod`(product_name varchar(255),name_temp varchar(150),prodstore_volume int(11)) RETURNS int(11)
begin
	declare out_int int(11) default 0;
	if product_name = name_temp THEN
	set out_int = prodstore_volume;
	ELSE set out_int = 0;
	end if;
	RETURN out_int;
END

-- 终端类型划分
CREATE DEFINER=`root`@`localhost` FUNCTION `typemake`(client_type varchar(255)) RETURNS varchar(50) CHARSET utf8mb4 COLLATE utf8mb4_bin
BEGIN
	declare out_var varchar(50)  default null;
	if client_type IN ( '经销商', '分销商', '连锁总部', '批发商' ) THEN
	set out_var = 'client';
	else set out_var = 'term';
	end if;
	RETURN out_var;

END