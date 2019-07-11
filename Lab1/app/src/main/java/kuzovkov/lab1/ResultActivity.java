package kuzovkov.lab1;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Environment;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.NetworkInterface;

import static kuzovkov.lab1.FileStorage.*;
import static kuzovkov.lab1.Helper.*;
import static kuzovkov.lab1.MyHttp.*;
import static kuzovkov.lab1.Const.*;

public class ResultActivity extends ActionBarActivity {

    public String[] data;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_result);
        Intent intent = getIntent();
        String[] data = intent.getStringArrayExtra(FormActivity.FORM_DATA);
        /*получение данных с интента и заполнение текстовых полей*/
        if (data == null){
            data = loadData();
        }
        if (data == null) return;
        ((TextView)findViewById(R.id.nameLastname)).setText(data[0]+" "+data[1]);
        ((TextView)findViewById(R.id.res_date_value)).setText(data[4]);
        ((TextView)findViewById(R.id.res_email_value)).setText(data[2]);
        ((TextView)findViewById(R.id.registered_value)).setText(data[5]);
        this.data = data;
        showPhoto();
    }

    /*чтение из файла сохраненных данных*/
    public String[] loadData(){
        /*чтение из файла*/
        try{
            byte[] buf = new byte[4096];
            FileInputStream fis = openFileInput(FILENAME);
            fis.read(buf);
            String s = new String(buf);
            return s.split(SEPARATOR);
        }catch(Exception e){
            return null;
        }
    }

    /*показ фото если есть или аватарки */
    private void showPhoto(){
        if (this.data[3].equals("male")){
            ((ImageView)findViewById(R.id.avatar)).setImageResource(R.drawable.male);
            ((TextView)findViewById(R.id.registered)).setText(R.string.registered_male);
        }else{
            ((ImageView)findViewById(R.id.avatar)).setImageResource(R.drawable.female);
            ((TextView)findViewById(R.id.registered)).setText(R.string.registered_female);
        }

        File mediaStorageDir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), APP_IMAGE_FOLDER);
        File mediaFile = new File(mediaStorageDir.getPath() + File.separator + PHOTO_FILENAME);
        Uri uri = Uri.fromFile(mediaFile);
        if (mediaFile.exists()){
            ((ImageView)findViewById(R.id.avatar)).setImageURI(uri);
        }
    }

    /*удаление фото если есть*/
    private  boolean deletePhoto(){
        File mediaStorageDir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), APP_IMAGE_FOLDER);
        File mediaFile = new File(mediaStorageDir.getPath() + File.separator + PHOTO_FILENAME);
        if (mediaFile.exists()){
            mediaFile.delete();
            return true;
        }
        return false;
    }

    /*обработчик кнопки СОХРАНИТЬ, запись данных в файл*/
    public void saveData(View v){
        /*запись в файл*/
        try{
            FileOutputStream fos = openFileOutput(FILENAME, Context.MODE_PRIVATE);
            fos.write(StringArray2String(this.data).getBytes());
            fos.close();
            showMessage(getApplicationContext(),getResources().getString(R.string.save_ok_local));
            saveIntoServer();
        }catch(IOException e){
            showMessage(getApplicationContext(),e.toString());
        }
    }

    /*обработчик кнопки ОЧИСТИТЬ, удаление файла с данными*/
    public void clearData(View v){
        boolean delFile = deleteFile(FILENAME);
        boolean delPhoto =  deletePhoto();
        deleteFromServer();
        if (!delFile && !delPhoto){
            showMessage(getApplicationContext(),getResources().getString(R.string.nothing_save));
        }else{
            showMessage(getApplicationContext(),getResources().getString(R.string.clear_ok));
            showPhoto();
        }
    }

    /*обработчик кнопки ПОСМОТРЕТЬ ВСЕ, удаление файла с данными*/
    public void viewOnSite(View v){
        Intent intent = new Intent(this, ListWebActivity.class);
        startActivity(intent);
    }

    /*обработчик кнопки КУРС ВАЛЮТЫ*/
    public void excRate(View v){
        Intent intent = new Intent(this, ExcRateActivity.class);
        startActivity(intent);
    }

    /*проверка сети*/
    public boolean isNetworkOk(){
        ConnectivityManager connMgr = (ConnectivityManager)getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = connMgr.getActiveNetworkInfo();
        return ( networkInfo != null && networkInfo.isConnected() )? true: false;
    }

    /*отправка данных на сервер*/
    public void saveIntoServer(){
        if (isNetworkOk()){
            String strData = StringArray2String(this.data);
            String url = SERVER_API2;
            String optype = "save";
            File mediaStorageDir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), APP_IMAGE_FOLDER);
            File mediaFile = new File(mediaStorageDir.getPath() + File.separator + PHOTO_FILENAME);
            String filename = (mediaFile.exists())? mediaFile.getPath() : "";
            new netTask().execute("post", url, optype, StringArray2String(this.data), filename);
        }else{
            showMessage(getApplicationContext(), getResources().getString(R.string.network_fail));
        }
    }

    /*удаление записи на сервере*/
    public void deleteFromServer(){
        if (isNetworkOk()){
            String strData = StringArray2String(this.data);
            String url = SERVER_API2;
            String optype = "delete";
            String filename = "";
            new netTask().execute("post", url, optype, StringArray2String(this.data), filename);
        }else{
            showMessage(getApplicationContext(), getResources().getString(R.string.network_fail));
        }

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_result, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    private class netTask extends  MyHttp{
        @Override
        protected void onPostExecute(String result){
            if(result != null ) {
                if (result.equals("Command execute success"))
                    showMessage(getApplicationContext(), getResources().getString(R.string.save_ok_server));
                else
                    showMessage(getApplicationContext(), getResources().getString(R.string.server_send_fail));
            }
        }
    }


}
