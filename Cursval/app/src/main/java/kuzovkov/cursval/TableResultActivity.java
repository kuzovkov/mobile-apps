package kuzovkov.cursval;

import android.content.Intent;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.webkit.WebView;
import android.widget.TextView;

import java.io.FileInputStream;
import java.util.List;


public class TableResultActivity extends ActionBarActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_table_result);
        String xmlContent = loadItem("CURSES_XML_CONTENT");
        String title = loadItem("NAME_VALUTE");
        fillWebView(xmlContent, title);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_table_result, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.as_diagram) {
            Intent intent = new Intent(this, GraphResultActivity.class);
            startActivity(intent);
            this.finish();
            return true;
        }else if (id == R.id.as_list){
            Intent intent = new Intent(this, ResultActivity.class);
            startActivity(intent);
            this.finish();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    /*заполнение WebView HTML контентом*/
    void fillWebView(String xmlContent, String title){
        try{

            List<CBR_ParserXML.Curs> curses = CBR_ParserXML.parseCurses(xmlContent);
            StringBuffer content = new StringBuffer();
            content.append("<html>");
            content.append("<style>table,td,tr,th{border: 1px solid black;} th{background-color:#ff0;} td,th{padding:5px;}</style>");
            content.append("<body>");
            content.append("<h1>").append(title).append("</h1>");
            content.append("<table>");
            content.append("<tr><th>Дата</th><th>Курс(руб)</th><th>Код</th></tr>");
            for( CBR_ParserXML.Curs curs: curses ){
                content.append("<tr>");
                content.append("<td>").append(curs.getDate()).append("</td>");
               content.append("<td>").append(curs.getCurs()/curs.getNominal()).append("</td>");
                content.append("<td>").append(curs.getValuta()).append("</td>");
                content.append("</tr>");
            }
            content.append("</table></body></html>");
            Log.d("HTML: ", content.toString());
             ((WebView)findViewById(R.id.webView)).loadDataWithBaseURL(null,content.toString(), "text/html", "UTF-8",null);




        }catch(Exception e){
            Helper.showMessage(getApplicationContext(), getResources().getString(R.string.parse_error));
            return;
        }

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
