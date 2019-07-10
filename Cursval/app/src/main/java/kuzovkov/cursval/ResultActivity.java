package kuzovkov.cursval;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.content.Intent;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.io.FileInputStream;
import java.util.List;
import static kuzovkov.cursval.Consts.*;

public class ResultActivity extends ListActivity {

    public Bundle savedInstanceState = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_result);
        Intent intent = getIntent();
        //String xmlContent = intent.getStringExtra(CURSES_XML_DATA);
        String xmlContent = loadItem("CURSES_XML_CONTENT");
        //((TextView)findViewById(R.id.valutaName)).setText(intent.getStringExtra(SELECTED_VALUTE));
        ((TextView)findViewById(R.id.valutaName)).setText(loadItem("NAME_VALUTE"));
        fillViewList(xmlContent);
    }

    /*преобразование строки с XML данными в массив строк, пригодный для вывода(парсинг)*/
    private String[] xml2stringArray(String xmlContent){
        String[] listData = null;
        try{
            List<CBR_ParserXML.Curs> curses = CBR_ParserXML.parseCurses(xmlContent);
            listData = new String[curses.size()];
            int row = 0;
            for (CBR_ParserXML.Curs curs: curses){
                listData[row] = "Дата: " + curs.getDate() + "\n" + "Курс: " + curs.getCurs()/curs.getNominal() + " рублей\n" + "Код валюты: " + curs.getValuta();
                row++;
            }
        }catch(Exception e){
            listData = new String[1];
            listData[0] = getResources().getString(R.string.parse_error);

        }
        return listData;
    }

    public void onListItemClick(ListView parent, View v, int position, long id){

    }

    /*заполнение списка ListView данными из XML строки*/
    private void fillViewList(String xmlContent){
        String[] listCurses = xml2stringArray(xmlContent);
        if (listCurses.length == 0 ){
            listCurses = new String[1];
            listCurses[0] = getResources().getString(R.string.data_not_exists);
        }
        setListAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, listCurses));
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_result, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.as_table) {
            Intent intent = new Intent(this, TableResultActivity.class);
            startActivity(intent);
            this.finish();
            return true;
        }else if(id == R.id.as_diagram){
            //Helper.showMessage(getApplicationContext(),"diagram");
            Intent intent = new Intent(this, GraphResultActivity.class);
            startActivity(intent);
            this.finish();
            return true;
        }


        return super.onOptionsItemSelected(item);
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
}
