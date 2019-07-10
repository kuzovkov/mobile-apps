package kuzovkov.cursval;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.PathShape;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ImageView;
import android.widget.TextView;

import java.io.FileInputStream;
import java.util.List;


public class GraphResultActivity extends ActionBarActivity {

    private DrawCanvasView mView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mView = new DrawCanvasView(this);
        setContentView(mView);
        String xmlContent = loadItem("CURSES_XML_CONTENT");
        String valuteName = loadItem("NAME_VALUTE");
        //((TextView)findViewById(R.id.graph)).setText(xmlContent);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_NOSENSOR);
        try{
            List<CBR_ParserXML.Curs> curses = CBR_ParserXML.parseCurses(xmlContent);
            mView.drawDiagram(valuteName, curses);
        }catch(Exception e){
            Helper.showMessage(getApplicationContext(), getResources().getString(R.string.parse_error));
            return;
        }



    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_graph_result, menu);
        return true;
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
        }else if (id == R.id.as_list){
            Intent intent = new Intent(this, ResultActivity.class);
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
