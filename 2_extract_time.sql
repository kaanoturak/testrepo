use google_capstone
drop table if exists bike_time
  select bike_time.* 
  into bike_time
  from(
select 
    distinct(ride_id)
	,rideable_type
	,member_casual
	,end_lat
	,end_lng
	,datepart(day, started_at)                                       as day_no     -- for info --
	,convert(date , started_at)                                      as ride_date  -- for info --
	,dense_rank () over (order by convert(date , started_at))        as rd_num
	,datename(weekday, started_at)                                   as day_name
	,datepart(week, started_at)                                      as week_no
	,datename(dayofyear, started_at)                                 as day_no_yearly
	,datename(month, started_at)                                     as month_name
	,dense_rank()over(order by(left(convert(date,started_at),7)))    as rm_num
	,datepart(month, started_at)                                     as month_no  
	,(((datediff(second, started_at, ended_at))-1)/60 + 1)           as rl_min       --All per minute ride prices are rounded up to the nearest minute--
	,datediff(second, started_at, ended_at)                          as rl_sec
	,datediff(hour, started_at, ended_at)                            as rl_hour
	,datepart(hour , started_at)                                     as start_hour
	
	,case 
	    when  end_lng='' or end_lat=''   then 'dock_fee' --- 
			else 'no_fee'
				end 'docking'
	
	,case 
	    when (datepart(month, started_at))=12 or  (datepart(month, started_at))=1  or  (datepart(month, started_at))=2  then 'Winter' 
	  	when (datepart(month, started_at))=3 or  (datepart(month, started_at))=4  or (datepart(month, started_at))=5  then 'Spring' 
		when (datepart(month, started_at))=6 or  (datepart(month, started_at))=7  or  (datepart(month, started_at))=8  then 'Summer' 
			else 'Autumn'
				end 'season'
	
	,case 
	    when rideable_type='electric_bike' then 'electric_bike'  
			else 'classic_bike'   --Docked bikes are classic bikes--
				end 'rideable_type_new'
	
	,case 
	    when member_casual ='casual' and  (datediff(minute, started_at, ended_at))>180 then 'day_pass'
	    when member_casual ='casual' and  (datediff(minute, started_at, ended_at))<180 then 'single_ride'
			else 'annual'
				end 'pass_plan'
	
	,case 
	     when  member_casual='member'  then round((datediff(minute, started_at, ended_at)),0)/45*0.33
		 when  member_casual='casual'  and rideable_type='classic_bike' then (1+((datediff(minute, started_at, ended_at))*0.16))
		 when  member_casual='casual'  and rideable_type='docked_bike' then (1+((datediff(minute, started_at, ended_at))*0.16))
		 when  member_casual='casual'  and rideable_type='electric_bike' then (1+((datediff(minute, started_at, ended_at))*0.39))
			 else 'false'
				 end 'ipr_in_usd'
  
  from dbo.bike

         where (datediff(second, started_at, ended_at) )>0               --- rides shorter than 0 seconds are filtered out, there are incorrect records in the dataset-- 
   
         )  bike_time


		 
      


  
