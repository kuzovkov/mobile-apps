package kuzovkov.cursval;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Application;
import android.app.Dialog;
import android.app.Notification;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.FragmentActivity;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ExpandableListView;
import android.widget.Spinner;
import android.widget.TextView;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Map;
import static kuzovkov.cursval.Consts.*;


public class StartActivity extends FragmentActivity implements AdapterView.OnItemSelectedListener, NoticeDialogFragment.NoticeDialogListener{

    public static Map<String,String> valutesMap = null; /*отображение задающее соответствие кодов и названий валют*/
    public String[] valutes = null; /*массив названий валют*/
    public static String codeValute;
    public static String nameValute;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_start);
        ((Button)findViewById(R.id.button)).setEnabled(false);
        getValuteCodes();
        fillDates();

    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_start, menu);
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

    /*получение списка валют*/
    private void getValuteCodes(){
        ((Button)findViewById(R.id.button)).setEnabled(false);
        if (isNetworkOk()){
            String url1 = CBR_ParserXML.urlValutes1;
            ((TextView)findViewById(R.id.text)).setText(getResources().getString(R.string.valutes_download));
            new getValutes().execute("get", url1, "windows-1251");
        }else{
            Helper.showMessage(getApplicationContext(),getResources().getString(R.string.network_not_avail));
        }
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        String ValuteNameSelected = valutes[position];
        for ( String code: valutesMap.keySet() ){
            if ( valutesMap.get(code).equals(ValuteNameSelected) ){
                codeValute = code;
                nameValute = valutesMap.get(code);
            }
        }
        saveItem("CODE_VALUTE", codeValute);
        saveItem("NAME_VALUTE", nameValute);
    }

    @Override
    public void onNothingSelected(AdapterView<?> parent) {
        codeValute = codeValuteDefault;
        nameValute = nameValuteDefault;
    }

    /*вложенный класс для получения списка валют с сайта центробанка*/
    private class getValutes extends HttpReq{

        @Override
        protected void onPostExecute(String xmlContent){

            if ( xmlContent == null ){
                alertFailValutes();
                return;
            }
            saveItem("VALUTES_XML_CONTENT", xmlContent);
            ((TextView)findViewById(R.id.text)).setText(getResources().getString(R.string.select_valutes));
            try{
                valutesMap = CBR_ParserXML.parseValutes(xmlContent);
                fillSpinner(valutesMap);

            }catch(Exception e){
                Helper.showMessage(getApplicationContext(), getResources().getString(R.string.parse_error));
            }
        }
    }

    /*вложенный класс для получения динамики курса валюты с сайта центробанка*/
    private class getCurses extends HttpReq{

        @Override
        protected void onPostExecute(String xmlContent){
            if ( xmlContent == null ){
                Helper.showMessage(getApplicationContext(), getResources().getString(R.string.load_сurses_fail));

            }else{
                saveItem("CURSES_XML_CONTENT", xmlContent);
                showResult(xmlContent);
            }
        }
    }

    /*старт активности где отображается результат с передачей ей результата*/
    public void showResult(String xmlContent){
        Intent intent = new Intent(this,ResultActivity.class);
        intent.putExtra(CURSES_XML_DATA, xmlContent);
        intent.putExtra(SELECTED_VALUTE, nameValute);
        startActivity(intent);
    }

    /*заполнение спинера списком валют*/
    public void fillSpinner(Map<String,String> valutesMap){
        valutes = new String[valutesMap.size()];
        int index = 0;
        for (String code: valutesMap.keySet()){
            valutes[index] = valutesMap.get(code); index++;
        }
        Spinner spin = (Spinner)findViewById(R.id.spinner1);
        spin.setOnItemSelectedListener(this);
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, valutes);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spin.setAdapter(adapter);
        ((Button)findViewById(R.id.button)).setEnabled(true);
    }

    /*заполнение полей дат*/
    public void fillDates(){
        String endDate = Helper.getCurrDate();
        String beginDate = Helper.getDate(-10);
        ((TextView)findViewById(R.id.dateBegin)).setText(beginDate);
        ((TextView)findViewById(R.id.dateEnd)).setText(endDate);
    }

    /*проверка сети*/
    public boolean isNetworkOk(){
        ConnectivityManager connMgr = (ConnectivityManager)getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = connMgr.getActiveNetworkInfo();
        return ( networkInfo != null && networkInfo.isConnected() )? true: false;
    }


    /*обработчик кнопки ПОЛУЧИТЬ*/
    public void getCurses(View v){
        String dateBegin = ((TextView)findViewById(R.id.dateBegin)).getText().toString();
        String dateEnd = ((TextView)findViewById(R.id.dateEnd)).getText().toString();
        if (!Helper.checkDateInterval(dateBegin, dateEnd)){
            Helper.showMessage(getApplicationContext(),getResources().getString(R.string.dates_error));
            return;
        }
        String url = CBR_ParserXML.url +"date_req1=" + Helper.convDate(dateBegin) + "&date_req2=" + Helper.convDate(dateEnd) + "&VAL_NM_RQ=" + codeValute;

        Log.d("url:",url);
        if (isNetworkOk()){
            new getCurses().execute("get",url,SERVICE_ENCODE);
        }else{
            Helper.showMessage(getApplicationContext(),getResources().getString(R.string.network_not_avail));
        }
    }

    /*запись строки в файл с именем key*/
    public boolean saveItem(String key, String value){
        try{
            FileOutputStream fos = openFileOutput(key, Context.MODE_PRIVATE);
            fos.write(value.getBytes());
            fos.close();
        }catch(Exception e){
            return false;
        }
        return true;
    }

    /*чтение строки из файла сименем key*/
    public String loadItem(String key){
        try{
            FileInputStream fis = openFileInput(key);
            byte[] buf = new byte[fis.available()];
            fis.read(buf);
            String s = new String(buf);
            return s;
        }catch(Exception e){
            return null;
        }
    }

    /*удаление файла с именем key*/
    public boolean clearItem(String key){
        return deleteFile(key);
    }



    /*показ диалога в случае неудачной загрузки списка валют*/
    public void alertFailValutes(){
        android.app.DialogFragment dialog = new NoticeDialogFragment();
        dialog.show(getFragmentManager(), "NoticeDialogFragment");
    }

    /*повторная попытка получить валюты*/
    @Override
    public void onDialogPositiveClick(android.app.DialogFragment dialog){
        getValuteCodes();
    }

    /*закрытие приложения*/
    @Override
    public void onDialogNegativeClick(android.app.DialogFragment dialog){
        this.finish();
    }
}
