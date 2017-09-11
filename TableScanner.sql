declare @cursor as cursor
declare @table_name varchar(1000)
declare @column_name varchar(1000)
declare @schema_name varchar(1000)
--declare @column_type varchar(1000)
declare @search varchar(1000)
--declare @sql varchar(max)
declare @query nvarchar(max)
declare @count nvarchar(max)
declare @rowcount int
declare @output table 
(
	table_name varchar(1000),
	column_name varchar(1000),
	row_count int,
	query nvarchar(max)
)

set @search = 'Text'

set @cursor = cursor for
select c.TABLE_NAME, c.COLUMN_NAME, t.TABLE_SCHEMA
from INFORMATION_SCHEMA.COLUMNS c
inner join information_schema.TABLES t
	on t.TABLE_NAME = c.TABLE_NAME
where c.DATA_TYPE like '%char'
	and t.TABLE_TYPE = 'BASE TABLE'
	
open @cursor
fetch next from @cursor into @table_name, @column_name, @schema_name

while @@FETCH_STATUS = 0
begin 
	select @query = 
	'select * from [' + @schema_name + '].[' + @table_name 
	+ '] (nolock) where [' + @column_name + ']  like ''%'
	+ @search + '%'''
	
	select @count = REPLACE(@query, 'select *', 'select @rowcountout = count(*)')
	
	begin try
	exec sp_executesql @count, N'@rowcountout int output', @rowcountout = @rowcount output
	end try
	begin catch
		select 'ERROR',@query
	end catch

	--select @rowcount

	if (@rowcount > 0)
	begin
		insert into @output
		select @table_name, @column_name, @rowcount, @query
	end
	fetch next from @cursor into @table_name, @column_name, @schema_name
end

select * from @output

close @cursor
deallocate @cursor




















 





	
	


