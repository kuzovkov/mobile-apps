package kuzovkov.lab1;

import android.content.Context;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import static kuzovkov.lab1.Const.*;

/**
 * Created by sania on 2/26/2015.
 */
public class FileStorage {

    public static void saveStrToFile(String str)throws FileNotFoundException, IOException {
        FileOutputStream fos = new FileOutputStream(FILENAME);
        fos.write(str.getBytes());
        fos.close();
    }

    public static void saveArrStrToFile(String[] arr)throws FileNotFoundException, IOException {

        String str = StringArray2String(arr);
        File f = new File(FILENAME);
        FileOutputStream fos = new FileOutputStream(f);
        fos.write(str.getBytes());
        fos.close();
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
