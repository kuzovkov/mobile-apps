package kuzovkov.cursval;

import android.content.Context;
import android.widget.Toast;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.regex.*;

/**
 * Created by sania on 3/15/2015.
 */
public class Helper {
    public static final String DATETIME_FORMAT = "hh:mm:ss dd/MM/yyyy";
    public static final String DATE_FORMAT = "dd/MM/yyyy";
    public static final String SEPARATOR = ";";


    /*паттерн для проверки email*/
    public static final Pattern emailPattern = Pattern.compile
            ("[a-zA-Z]{1}[a-zA-Z\\d\\u002E\\u005F]+@([a-zA-Z]+\\u002E){1,2}((net)|(com)|(org)|(ru))");
    /*паттерн для проверки имени и фамилии*/
    public static final Pattern namePattern = Pattern.compile
            ("[a-zA-Z\\u0410-\\u044f]{3,20}");
    /*паттерн для проверки даты*/
    public static final Pattern datePattern = Pattern.compile
            ("[0-9]{1,2}[./][0-9]{1,2}[./][0-9]{4}");
    /*получение строки с текущимми датой и временем*/
    public static String getCurrDateTime(){
        Date date = new Date();
        SimpleDateFormat format1 = new SimpleDateFormat(DATETIME_FORMAT);
        String time = format1.format(date);
        return time;
    }

    /*получение строки с текущей датой*/
    public static String getCurrDate(){
        Date date = new Date();
        SimpleDateFormat format1 = new SimpleDateFormat(DATE_FORMAT);
        String dateStr = format1.format(date);
        return dateStr;
    }

    /*получение строки с датой отстоящей от текущей на заданное количество дней*/
    public static String getDate(int day){
        Long time = new Date().getTime();
        time += day * 1000 * 3600 * 24;
        Date date = new Date(time);
        SimpleDateFormat format1 = new SimpleDateFormat(DATE_FORMAT);
        String dateStr = format1.format(date);
        return dateStr;
    }

    /*вывод сообщения пользователю(тоста)*/
    public static void showMessage(Context context, String text){
        int duration = Toast.LENGTH_LONG;
        Toast toast = Toast.makeText(context,text,duration);
        toast.show();
    }
    /*проверка строки на соответсвие регулярному выражению*/
    public static boolean checkValid(String text, Pattern pattern) {
        Matcher matcher = pattern.matcher(text);
        return (matcher.matches())? true:false;
    }
    /*проверка даты путем попытки преобразования в объект Calendar*/
    public static String convDate(String datestr){
        String[] parths = datestr.split("\\.");
        if (parths.length < 3){
            parths = datestr.split("/");
        }
        int day = Integer.parseInt(parths[0]);
        int month = Integer.parseInt(parths[1]);
        int year = Integer.parseInt(parths[2]);
        Calendar c = new GregorianCalendar(year,month-1,day);
        Date date = c.getTime();
        SimpleDateFormat format2 = new SimpleDateFormat(DATE_FORMAT);
        return format2.format(date);
    }

    public static Date makeDate(String datestr){
        String[] parths = datestr.split("\\.");
        if (parths.length < 3){
            parths = datestr.split("/");
        }
        int day = Integer.parseInt(parths[0]);
        int month = Integer.parseInt(parths[1]);
        int year = Integer.parseInt(parths[2]);
        Calendar c = new GregorianCalendar(year,month-1,day);
        Date date = c.getTime();
        return date;
    }

    public static boolean checkDateInterval(String date1, String date2){
        if (!checkValid(date1, datePattern) || !checkValid(date2, datePattern)) return false;
        try{
            Date d1 = makeDate(date1);
            Date d2 = makeDate(date2);
            Date now = new Date();
            if ( now.getTime() < d2.getTime()) return false;
            if ( d1.getTime() > d2.getTime()) return false;

        }catch(Exception e){
            return false;
        }
        return true;
    }

    /*преобразование массива строк в строку*/
    public static String StringArray2String(String[] arr){
        StringBuffer sb = new StringBuffer();
        for ( int i = 0; i < arr.length; i++ ){
            sb.append(arr[i]);
            if ( i < arr.length -1 ) sb.append(SEPARATOR);
        }
        return sb.toString();
    }
    /*преобразование строки в массив строк*/
    public static String[] String2StringArray(String str){
        String separator = SEPARATOR;
        String[] arr = str.split(separator);
        return arr;
    }

}
