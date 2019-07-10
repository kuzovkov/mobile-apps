package kuzovkov.lab1;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.Toast;

import java.io.FileInputStream;
import  java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

import static kuzovkov.lab1.FileStorage.*;
import static kuzovkov.lab1.Helper.*;
import static kuzovkov.lab1.Const.*;

public class FormActivity extends ActionBarActivity {

    public final static String FORM_DATA = "kuzovkov.lab1.form_data";
    public String[] savedData = null;
    private static final int CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE = 100;
    private static final int CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE = 200;
    private Uri fileUri;
    public static final int MEDIA_TYPE_IMAGE = 1;
    public static final int MEDIA_TYPE_VIDEO = 2;

    /*создание file Uri для записи аудио или видео*/
    private static Uri getOutputMediaFileUri(int type){
        return Uri.fromFile(getOutputMediaFile(type));
    }

    /*создание файла для записи аудио или видео*/
    private static File getOutputMediaFile(int type){
        File mediaStorageDir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), APP_IMAGE_FOLDER);
        if (!mediaStorageDir.exists()){
            if (!mediaStorageDir.mkdirs()){
                Log.d("Анкета", "failed to create directory");
                return null;
            }
        }
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        File mediaFile;
        if (type == MEDIA_TYPE_IMAGE){
            mediaFile = new File(mediaStorageDir.getPath() + File.separator + PHOTO_FILENAME);
        }else if(type == MEDIA_TYPE_VIDEO){
            mediaFile = new File(mediaStorageDir.getPath() + File.separator + "VID_" + timeStamp + ".mp4");
        }else{
            return null;
        }

        return mediaFile;
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_form);
        savedData = loadData();
        if (savedData != null){
            fillBySavedData(savedData);
        }

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

    /*заполнение полей формы прочитанными данными*/
    public void fillBySavedData(String[] data){
        ((EditText)findViewById(R.id.editName)).setText(data[0]);
        ((EditText)findViewById(R.id.editLastname)).setText(data[1]);
        ((EditText)findViewById(R.id.editEmail)).setText(data[2]);
        if (data[3].equals("male")){
            ((RadioButton)findViewById(R.id.male)).setChecked(true);
            ((RadioButton)findViewById(R.id.female)).setChecked(false);
        }else{
            ((RadioButton)findViewById(R.id.male)).setChecked(false);
            ((RadioButton)findViewById(R.id.female)).setChecked(true);
        }
        ((EditText)findViewById(R.id.editDate)).setText(data[4]);
    }

    /*очистка формы*/
    public void clearForm(){
        ((EditText)findViewById(R.id.editName)).setText("");
        ((EditText)findViewById(R.id.editLastname)).setText("");
        ((EditText)findViewById(R.id.editEmail)).setText("");
        ((RadioButton)findViewById(R.id.male)).setChecked(true);
        ((RadioButton)findViewById(R.id.female)).setChecked(false);
        ((EditText)findViewById(R.id.editDate)).setText("");
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_form, menu);
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

    /*получени данных с формы*/
    private String[] getFormData(){
        String[] data = new String[6];
        data[0] = ((EditText)findViewById(R.id.editName)).getText().toString();
        data[1] = ((EditText)findViewById(R.id.editLastname)).getText().toString();
        data[2] = ((EditText)findViewById(R.id.editEmail)).getText().toString();
        data[3] = (((RadioButton)findViewById(R.id.male)).isChecked())? "male" : "female";
        data[4] = ((EditText)findViewById(R.id.editDate)).getText().toString();
        data[5] = ( savedData == null )? getCurrDateTime() : savedData[5];
        return data;
    }

    /*обработчик кнопки СДЕЛАТЬ СНИМОК*/
    public void makePhoto(View v){
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        fileUri = getOutputMediaFileUri(MEDIA_TYPE_IMAGE);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri);
        startActivityForResult(intent, CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent imagedata){
        if (requestCode == CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE){
            if (resultCode == RESULT_OK){
                Log.d("Lab1","resultCode==RESULT_OK");
                showMessage(getApplicationContext(), "Image saved");
            }else if (resultCode == RESULT_CANCELED){
                showMessage(getApplicationContext(), getResources().getString(R.string.cancel_photo));
            }else{
                showMessage(getApplicationContext(), getResources().getString(R.string.fail_photo));
            }
        }

        if (requestCode == CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE){
            if (resultCode == RESULT_OK){
                showMessage(getApplicationContext(), "Video saved");
            }else if (resultCode == RESULT_CANCELED){
                showMessage(getApplicationContext(), getResources().getString(R.string.cancel_video));
            }else{
                showMessage(getApplicationContext(), getResources().getString(R.string.fail_video));
            }
        }
    }

    /*обработчик кнопки ГОТОВО, проверяет данные и передает другой активности*/
    public void checkData(View v){
        String[] data =  getFormData();
        /*проверка имени*/
        if (!checkValid(data[0],namePattern)){
            showMessage(getApplicationContext(), getResources().getString(R.string.not_valid_name));
            return;
        }
        /*проверка фамилии*/
        if (!checkValid(data[1],namePattern)){
            showMessage(getApplicationContext(), getResources().getString(R.string.not_valid_lastname));
            return;
        }
        /*проверка email*/
        if (!checkValid(data[2],emailPattern)){
            showMessage(getApplicationContext(), getResources().getString(R.string.not_valid_email));
            return;
        }
        /*проверка даты*/
        if (!checkValid(data[4],datePattern)){
            showMessage(getApplicationContext(), getResources().getString(R.string.not_valid_date));
            return;
        }
        /*еще проверка даты*/
        try{
            data[4] = convDate(data[4]);
        }catch(Exception e){
            showMessage(getApplicationContext(), getResources().getString(R.string.not_valid_date));
            return;
        }

        Intent intent = new Intent(this,ResultActivity.class);
        intent.putExtra(FORM_DATA, data);
        startActivity(intent);
    }
}
