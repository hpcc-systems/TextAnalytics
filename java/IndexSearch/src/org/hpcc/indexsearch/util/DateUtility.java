package org.hpcc.indexsearch.util;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

public class DateUtility {
	private static DateFormat fmtyyyymmdd = new SimpleDateFormat("yyyyMMdd");
	private static DateFormat fmtyyyy = new SimpleDateFormat("yyyy");
	private static DateFormat fmtmonthname = new SimpleDateFormat("MMMMM yyyy");
	private static DateFormat fmtmmddyyyy = new SimpleDateFormat("MM/dd/yyyy");
	
	public static void main(String[] args) {
		
		try {
	/*	System.out.println(ParseDate("12/1/2001",null));
		System.out.println(ParseDate("12/31/2001",null));
		System.out.println(ParseDate("1/30/2001",null));
		System.out.println(ParseDate("1/30/99",null));
		System.out.println(ParseDate("12/30/01",null));
		*/
			System.out.println(LastDayOfMonth(-1));
			System.out.println(GetMonthYearName(new Date()));
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}
	
	public enum DateRange {
		  THIS_MONTH,		  
		  THIS_WEEK,
		  THIS_YEAR,
		  IN_THE_LAST_X_DAYS,
		  AFTER,
		  BETWEEN
		  
		}

	public static String GetMonthYearName(Date dt)
	{
		return fmtmonthname.format(dt);
	}
	public static String GetYear(Date dt)
	{
		return fmtyyyy.format(dt);
	}
	public static String GetDateYYYYMMDD(Date dt) {		           
        return fmtyyyymmdd.format(dt);        
	}
	public static String GetDateMMDDYYYY(Date dt) {		           
        return fmtmmddyyyy.format(dt);        
	}
	
	public static Integer DaysBetween(Date date1,Date date2)
	{
		return Math.round((date2.getTime()-date1.getTime()) / 86400000);
	}
	
	public static Date ParseDate(String dt, Date defdate) throws Exception{	
		try {
			DateFormat df = new SimpleDateFormat("MM/dd/yyyy");
			if (dt.length() > 3 && dt.substring(dt.length()-3, dt.length()-2).equals("/"))
			{
				df=new SimpleDateFormat("MM/dd/yy");
			} else if (dt.length() > 17 
					&& dt.substring(dt.length()-3, dt.length()-2).equals(":")
					&& dt.substring(4,5).equals("/"))				
			{
				df=new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
			}
			
			Date newdate=df.parse(dt);	
			
			return newdate;
		} catch (Exception e)
		{
			try {
				DateFormat df = new SimpleDateFormat("yyyyMMdd"); 
				Date newdate=df.parse(dt);
				return newdate;
			} catch (Exception e2)
			{
				if (defdate != null)
				{
					return defdate;
				}
				else
				{
					throw e;
				}
			}
		}
	}
	
	public static ArrayList<String> GetEDFSDateRange(DateRange rng,Date a,Date b)
	{
		if (DateRange.THIS_MONTH.equals(rng))
		{
			return GetEDFSDateRange(FirstDayOfMonth(),new Date());
		}
		else if (DateRange.THIS_WEEK.equals(rng))
		{
			return GetEDFSDateRange(FirstDayOfWeek(),new Date());
		}
		else if (DateRange.THIS_YEAR.equals(rng))
		{
			return GetEDFSDateRange(FirstDayOfYear(),new Date());
		}
		else if (DateRange.BETWEEN.equals(rng))
		{
			return GetEDFSDateRange(a,b);
		}
		else if (DateRange.AFTER.equals(rng))
		{
			return GetEDFSDateRange(a,new Date());
		}
		else
		{
			return GetEDFSDateRange(new Date(),new Date());
		}
	}

	public static ArrayList<String> GetEDFSDateRange(Date begin,Date end)
	{
		ArrayList<String> dates=new ArrayList<String>();
		GregorianCalendar gcal = new GregorianCalendar();
		GregorianCalendar gcalend = new GregorianCalendar();
		gcalend.setTime(end);
		gcalend.set(Calendar.HOUR,0);
		gcalend.set(Calendar.MINUTE,0);
		gcalend.set(Calendar.SECOND,0);
		gcalend.set(Calendar.MILLISECOND,0);
		end=gcalend.getTime();
		gcal.setTime(begin);
		gcal.set(Calendar.HOUR,0);
		gcal.set(Calendar.MINUTE,0);
		gcal.set(Calendar.SECOND,0);
		gcal.set(Calendar.MILLISECOND,0);
		dates.add(GetDateYYYYMMDD(begin));
		Date dt=begin;
		
		int i=0;		
		while (i < 367 && dt.before(end))
		{
			gcal.add(Calendar.DATE, 1);
			dt=gcal.getTime();			
			dates.add(GetDateYYYYMMDD(dt));
			i++;
		}
		return dates;	
	}

	public static Date DaysAgo(int daysago)
	{
		GregorianCalendar gcal = new GregorianCalendar();
		gcal.add(Calendar.DATE, daysago * -1);
		return gcal.getTime();
	}
	public static Date FirstDayOfWeek() 
	{
		return FirstDayOfWeek(0);
	}
	public static Date FirstDayOfWeek(int minusweeks) 
	{
		GregorianCalendar gcal = new GregorianCalendar();
		gcal.set(Calendar.HOUR,0);
		gcal.set(Calendar.MINUTE,0);
		gcal.set(Calendar.SECOND,0);
		gcal.set(Calendar.WEEK_OF_YEAR,gcal.get(Calendar.WEEK_OF_YEAR)+(minusweeks));
		gcal.set(Calendar.MILLISECOND,0);
		  gcal.set(Calendar.DAY_OF_WEEK, gcal.getFirstDayOfWeek());
		  return gcal.getTime();
	}
	
	public static Date FirstDayOfMonth(Date inDate)
	{
		return FirstDayOfMonth(0,inDate);
	}
	public static Date FirstDayOfMonth()
	{
		return FirstDayOfMonth(0,new Date());
	}
	public static Date FirstDayOfMonth(int minusmonths)
	{
		return FirstDayOfMonth(minusmonths,new Date());
	}

	public static Date FirstDayOfMonth(int minusmonths,Date inDate)
	{
		GregorianCalendar gcal = new GregorianCalendar();
		gcal.setTime(inDate);
		gcal.set(Calendar.MONTH,gcal.get(Calendar.MONTH)+minusmonths);
		gcal.set(Calendar.HOUR,0);
		gcal.set(Calendar.MINUTE,0);
		gcal.set(Calendar.SECOND,0);
		gcal.set(Calendar.MILLISECOND,0);
		gcal.set(Calendar.DAY_OF_MONTH,1);
		return gcal.getTime();	
	}

	
	public static Date FirstDayOfYear()
	{
		return FirstDayOfYear(0);
	}
	public static Date FirstDayOfYear(int minusyears)
	{
		GregorianCalendar gcal = new GregorianCalendar();
	//	gcal.set(Calendar.YEAR,year);
		gcal.set(Calendar.HOUR,0);
		gcal.set(Calendar.MINUTE,0);
		gcal.set(Calendar.SECOND,0);
		gcal.set(Calendar.MILLISECOND,0);
		gcal.set(Calendar.YEAR,gcal.get(Calendar.YEAR)+ minusyears );
		gcal.set(Calendar.DAY_OF_YEAR,1);
		return gcal.getTime();
	}
	public static Date LastDayOfYear()
	{
		return LastDayOfYear(0);
	}

	public static Date LastDayOfYear(int minusyears)
	{
		GregorianCalendar gcal = new GregorianCalendar();
		gcal.set(Calendar.HOUR,0);
		gcal.set(Calendar.MINUTE,0);
		gcal.set(Calendar.SECOND,0);
		gcal.set(Calendar.MILLISECOND,0);
		gcal.set(Calendar.YEAR,gcal.get(Calendar.YEAR)+ minusyears );
		gcal.set(Calendar.DAY_OF_YEAR,gcal.getMaximum(Calendar.DAY_OF_YEAR)-1);
		return gcal.getTime();
	}
	
	public static Date LastDayOfMonth()
	{
		return LastDayOfMonth(new Date(),0);
	}
	public static Date LastDayOfMonth(Date dt)
	{
		return LastDayOfMonth(dt,0);
	}
	public static Date LastDayOfMonth(int minusmonths)
	{
		return LastDayOfMonth(new Date(),minusmonths);
	}
	public static Date LastDayOfMonth(Date dt,int minusmonths)
	{
		GregorianCalendar gcal = new GregorianCalendar();
		gcal.setTime(dt);
		gcal.set(Calendar.MONTH,gcal.get(Calendar.MONTH) + minusmonths);
		gcal.set(Calendar.HOUR,0);
		gcal.set(Calendar.MINUTE,0);
		gcal.set(Calendar.SECOND,0);
		gcal.set(Calendar.MILLISECOND,0);
		gcal.set(Calendar.DAY_OF_MONTH,gcal.getMaximum(Calendar.DAY_OF_MONTH));
		return gcal.getTime();
	}
	
	public static Date LastDayOfWeek()
	{
		return LastDayOfWeek(0);
	}
	public static Date LastDayOfWeek(int minusweeks)
	{
		GregorianCalendar gcal = new GregorianCalendar();
		gcal.set(Calendar.HOUR,0);
		gcal.set(Calendar.MINUTE,0);
		gcal.set(Calendar.SECOND,0);
		gcal.set(Calendar.MILLISECOND,0);
		gcal.set(Calendar.WEEK_OF_YEAR,gcal.get(Calendar.WEEK_OF_YEAR)+(minusweeks));

		gcal.set(Calendar.DAY_OF_WEEK,gcal.getMaximum(Calendar.DAY_OF_WEEK));
		return gcal.getTime();
	}
	
}
