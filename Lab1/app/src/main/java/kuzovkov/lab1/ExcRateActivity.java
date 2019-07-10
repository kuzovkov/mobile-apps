package kuzovkov.lab1;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.webkit.WebView;
import android.widget.TextView;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.List;

import static kuzovkov.lab1.Const.*;
import static kuzovkov.lab1.Helper.*;
import static kuzovkov.lab1.MyHttp.*;
import kuzovkov.lab1.XMLParser.*;

public class ExcRateActivity extends ActionBarActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_exc_rate);
        ((TextView)findViewById(R.id.textView2)).setText(R.string.load);
        String reqStr = "http://www.cbr.ru/scripts/XML_dynamic.asp?date_req1=02/03/2015&date_req2=10/03/2015&VAL_NM_RQ=R01235";
        new getExcRate().execute(reqStr);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_exc_rate, menu);
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

    private class getExcRate extends  netRequest{
        @Override
        protected void onPostExecute(InputStream in){
            if(in != null ){
                //((TextView)findViewById(R.id.textView2)).setText(result);
                List<Entry> entries = null;
                XMLParser parser = new XMLParser();
                StringBuffer sb = new StringBuffer();
                try{
                    entries = parser.parse(in);
                }catch(Exception e){
                    showMessage(getApplicationContext(),e.toString());
                }
                for (Entry rec: entries){
                    Log.d("Curs",rec.value);
                    sb.append(rec.value).append(":");
                }

                ((TextView)findViewById(R.id.textView2)).setText(sb.toString());

            }

        }
    }


}
