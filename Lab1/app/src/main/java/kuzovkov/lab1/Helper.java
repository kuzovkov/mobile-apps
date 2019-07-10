package kuzovkov.lab1;

import android.content.Context;
import android.widget.Toast;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.regex.*;
import static kuzovkov.lab1.Const.*;

/**
 * Created by sania on 2/26/2015.
 */
public class Helper {


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
        return  time;
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
            parths =  datestr.split("/");
        }
        int day = Integer.parseInt(parths[0]);
        int month = Integer.parseInt(parths[1]);
        int year = Integer.parseInt(parths[2]);
        Calendar c = new GregorianCalendar(year,month-1,day);
        Date date = c.getTime();
        SimpleDateFormat format2 = new SimpleDateFormat(DATE_FORMAT);
        return format2.format(date);
    }

}
