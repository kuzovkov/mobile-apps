package kuzovkov.cursval;

import android.os.AsyncTask;
import android.util.Log;

import java.net.*;
import java.io.*;
import java.util.*;

/**
 * Created by sania on 3/15/2015.
 */

    /**
     *
     * @author Alexander
     */
public class HttpReq extends AsyncTask<String, Void, String>{

        @Override
        protected String doInBackground(String... params){
            try{
                if (params[0].equals("post")){
                    Map<String, String> data = new Hashtable<String,String>();
                        return urlencodedPostRequest(params[1], data );
                }else if(params[0].equals("get") && params.length < 3 ) {
                    return sendGetRequest(params[1]);
                }else if ( params[0].equals("get") && params.length > 2 ){
                    return sendGetRequest(params[1], params[2]);
                }else{
                    return "Wrong passed params!";
                }
            }catch(Exception e){
                return e.toString();
            }
        }

        @Override
        protected void onPostExecute(String result){

        }

    /*send GET request and resive response*/
    public static String sendGetRequest(String url){
        try{
            URL currUrl = new URL(url);
            HttpURLConnection connection = (HttpURLConnection)currUrl.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(15000);
            connection.setReadTimeout(10000);
            connection.setDoInput(true);
            connection.connect();
            InputStream is = connection.getInputStream();
            InputStreamReader reader = new InputStreamReader(is, "UTF-8");
            char[] buffer = new char[is.available()];
            reader.read(buffer);
            return new String(buffer);
        }
        catch(Exception e){
            return null;
        }
    }

        /*send GET request and resive response*/
        public static String sendGetRequest(String url, String encode){
            try{
                URL currUrl = new URL(url);
                HttpURLConnection connection = (HttpURLConnection)currUrl.openConnection();
                connection.setRequestMethod("GET");
                connection.setConnectTimeout(15000);
                connection.setReadTimeout(10000);
                connection.setDoInput(true);
                connection.connect();
                InputStream is = connection.getInputStream();
                InputStreamReader reader = new InputStreamReader(is, encode);
                char[] buffer = new char[is.available()];
                reader.read(buffer);
                return new String(buffer);
            }
            catch(Exception e){
                return null;
            }

        }



    /*send POST request and resive response*/
    public static String urlencodedPostRequest(String url, Map<String,String> data){
        try{
            URL currUrl = new URL(url);
            HttpURLConnection connection = (HttpURLConnection)currUrl.openConnection();
            connection.setDoOutput(true);
            connection.setRequestMethod("POST");
            OutputStreamWriter out = new OutputStreamWriter(connection.getOutputStream());
            StringBuffer reqStr = new StringBuffer();
            int count = 0;
            for ( String key: data.keySet() ){
                reqStr.append(key).append("=").append(data.get(key));
                count++;
                if ( count < data.size()) reqStr.append("&");
            }
            out.write(reqStr.toString());
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
    /**
     * multipart form post request: send pairs key=value and files
     **/
    public static String multipartPostRequest(String url, Map<String,String> data, Map<String,String> files){
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

        public String downloadUrl(String myurl, String encode) throws IOException {
            InputStream is = null;


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
                String contentAsString = readIt(is, encode);
                return contentAsString;
                // Makes sure that the InputStream is closed after the app is
                // finished using it.
            } finally {
                if (is != null) {
                    is.close();
                }
            }
        }

        /*Преобразование потока в строку*/
        public String readIt(InputStream stream, String encode) throws IOException, UnsupportedEncodingException {
            Reader reader = null;
            reader = new InputStreamReader(stream, encode);
            char[] buffer = new char[stream.available()];
            reader.read(buffer);
            return new String(buffer);
        }
}



