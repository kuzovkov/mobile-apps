package kuzovkov.lab1;

import android.os.AsyncTask;
import android.util.Log;

import java.net.*;
import java.io.*;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import static kuzovkov.lab1.Helper.*;
import java.util.Map;


/**
 * Created by sania on 3/7/2015.
 */
public class MyHttp extends AsyncTask<String,Void,String>{

    @Override
    protected String doInBackground(String... params){
        try{
            if (params[0].equals("post")){
                Map<String, String> data = new Hashtable<String,String>();
                data.put("optype",params[2]);
                data.put("data", params[3]);
                Map<String, String> files = new Hashtable<String,String>();
                if (!params[4].equals("")) {
                    files.put("photo",params[4]);
                }
                return multiPartPostRequest(params[1], data, files);
            }else if(params[0].equals("get")){
                return sendGetRequest(params[1]);
            }else{
                return "Wrong request method!";
            }

        }catch(Exception e){
            return "Unable to retrieve web page. Url may be invalid";
        }

    }

    @Override
    protected void onPostExecute(String result){
        if(result != null )
            Log.d("server response:", result);
    }


    /*send GET request and receive response*/
    public String sendGetRequest(String url){
        try{
            URL currUrl = new URL(url);
            HttpURLConnection connection = (HttpURLConnection)currUrl.openConnection();
            connection.setReadTimeout(10000);
            connection.setConnectTimeout(15000);
            connection.setDoInput(true);
            connection.setRequestMethod("GET");
            connection.connect();

            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String receivedString;
            StringBuffer sb = new StringBuffer();
            while ((receivedString = in.readLine()) != null) {
                sb.append(receivedString);
            }
            in.close();
            return sb.toString();
        }
        catch(IOException e){
            return null;
        }
    }



    /*send POST request and receive response*/
    public String sendPostRequest(String url, String data){
        try{
            URL currUrl = new URL(url);
            HttpURLConnection connection = (HttpURLConnection)currUrl.openConnection();
            connection.setDoOutput(true);
            connection.setRequestMethod("POST");
            OutputStreamWriter out = new OutputStreamWriter(connection.getOutputStream());
            out.write("data=" + data);
            out.close();
            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String receivedString;
            StringBuffer sb = new StringBuffer();
            while ((receivedString = in.readLine()) != null) {
                sb.append(receivedString);
            }
            in.close();
            return sb.toString();
        }
        catch(Exception e){
            return null;
        }
    }


    public static String multiPartPostRequest(String url, Map<String,String> data, Map<String,String> files){
        try{
            File f = null;
            FileInputStream fis = null;
            int c;
            byte[] b = null;
            URL currUrl = new URL(url);
            HttpURLConnection connection = (HttpURLConnection)currUrl.openConnection();
            connection.setDoOutput(true);
            connection.setRequestMethod("POST");
            String boundary = "----------Q3o1lH0sOFGdmsjeitxjAL";
            connection.addRequestProperty("Content-Type", "multipart/form-data; boundary="+boundary);
            OutputStream out = connection.getOutputStream();
            int count = 0;
            for (String key: data.keySet()){
                out.write(("--"+boundary+"\n").getBytes());
                out.write(("Content-Disposition: form-data; name=\""+key+"\"\n\n").getBytes());
                out.write(data.get(key).getBytes());
                count++;
                if ( count < (files.size() + data.size())){
                    out.write(("\n--"+boundary+"\n").getBytes());
                }else{
                    out.write(("\n--"+boundary+"--\n\n").getBytes());
                }
            }
            for (String field: files.keySet()){
                f = new File(files.get(field));
                fis = new FileInputStream(f);
                c = fis.available();
                b = new byte[c];
                fis.read(b);
                fis.close();

                out.write(("Content-Disposition: form-data; name=\""+field+"\"; filename=\""+f.getName() +"\"\n").getBytes());
                out.write(("Content-Type: application/octet-stream\n").getBytes());
                out.write(("Content-Transfer-Encoding: binary\n\n").getBytes());
                out.write(b);
                count++;
                if ( count < (files.size() + data.size())){
                    out.write(("\n--"+boundary+"\n").getBytes());
                }else{
                    out.write(("\n--"+boundary+"--\n\n").getBytes());
                }
            }
            out.flush();
            out.close();
            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String resivedString;
            StringBuffer sb = new StringBuffer();
            while ((resivedString = in.readLine()) != null) {
                sb.append(resivedString);
            }
            in.close();
            return sb.toString();
        }
        catch(Exception e){
            return null;
        }
    }

    public String downloadUrl(String myurl) throws IOException {
        InputStream is = null;
        // Only display the first 500 characters of the retrieved
        // web page content.
        int len = 500;

        try {
            URL url = new URL(myurl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setReadTimeout(10000 /* milliseconds */);
            conn.setConnectTimeout(15000 /* milliseconds */);
            conn.setRequestMethod("GET");
            conn.setDoInput(true);
            // Starts the query
            conn.connect();
            int response = conn.getResponseCode();

            is = conn.getInputStream();

            // Convert the InputStream into a string
            String contentAsString = readIt(is, len);
            return contentAsString;

            // Makes sure that the InputStream is closed after the app is
            // finished using it.
        } finally {
            if (is != null) {
                is.close();
            }
        }
    }

    /*чтение ответа от сервера*/
    public String readIt(InputStream stream, int len) throws IOException, UnsupportedEncodingException {
        Reader reader = null;
        reader = new InputStreamReader(stream, "UTF-8");
        char[] buffer = new char[len];
        reader.read(buffer);
        return new String(buffer);
    }

}
