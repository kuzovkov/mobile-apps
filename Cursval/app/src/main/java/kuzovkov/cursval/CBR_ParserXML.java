package kuzovkov.cursval;

import java.io.StringReader;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.ArrayList;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import java.util.*;

/**
 * Created by sania on 3/15/2015.
 */
public class CBR_ParserXML {
    public static String url = "http://www.cbr.ru/scripts/XML_dynamic.asp?";
    public static String urlValutes1 = "http://www.cbr.ru/scripts/XML_val.asp?d=0";
    public static String urlValutes2 = "http://www.cbr.ru/scripts/XML_val.asp?d=1";
    public static Map valutes = null;
    public static String code = "R01235";

    public static class Curs{
        String valuta;
        Float curs;
        String date;
        Integer nominal;
        public void setValuta(String valuta){
            this.valuta = valuta;
        }
        public void setCurs(String curs){
            this.curs = new Float(curs.replace(',', '.'));
        }
        public void setDate(String date){
            this.date = date;
        }
        public void setNominal(String nominal){
            this.nominal = new Integer(nominal);
        }
        public String getValuta(){
            return this.valuta;
        }
        public float getCurs(){
            return this.curs;
        }
        public String getDate(){
            return this.date;
        }
        public int getNominal(){
            return this.nominal;
        }
    }

    public static class Valuta{
        String name;
        String nameEng;
        String code;
        public void setName(String name){
            this.name = name;
        }
        public void setNameEng(String nameEng){
            this.nameEng = nameEng;
        }
        public void setCode(String code){
            this.code = code;
        }
        public String getName(){
            return this.name;
        }
        public String getNameEng(){
            return this.nameEng;
        }
        public String getCode(){
            return this.code;
        }
    }

    public static List parseCurses(String xml)throws Exception{
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setValidating(false);
        DocumentBuilder builder = factory.newDocumentBuilder();
        InputSource xml_source = new InputSource(new StringReader(xml));
        Document doc = builder.parse(xml_source);
        List<Curs> curses = new ArrayList<Curs>();
        NodeList list = doc.getElementsByTagName("Record");
        for ( int i = 0; i < list.getLength(); i++){
            Curs curs = new Curs();
            curs.setDate(list.item(i).getAttributes().item(0).getNodeValue());
            curs.setValuta(list.item(i).getAttributes().item(1).getNodeValue());
            NodeList sublist = list.item(i).getChildNodes();
            for ( int j = 0; j < sublist.getLength(); j++ ){
                if ( sublist.item(j).getNodeName().equals("Value") ){
                    curs.setCurs( sublist.item(j).getTextContent());
                }
                if ( sublist.item(j).getNodeName().equals("Nominal") ){
                    curs.setNominal(sublist.item(j).getTextContent());
                }
            }
            curses.add(curs);
        }
        return curses;
    }

    public static void printCurses(List<Curs> curses ){
        for (Curs curs: curses){
            System.out.println("Дата: "+ curs.getDate());
            System.out.println("Валюта: "+ curs.getValuta());
            System.out.println("Курс: "+ curs.getCurs()/curs.getNominal());
        }
    }

    public static Map parseValutes(String xml)throws Exception{
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setValidating(false);
        DocumentBuilder builder = factory.newDocumentBuilder();
        InputSource xml_source = new InputSource(new StringReader(xml));
        Document doc = builder.parse(xml_source);
        Map<String,String> valutesMap = new Hashtable<String,String>();
        List<Valuta> valutesList = new ArrayList<Valuta>();
        NodeList list = doc.getElementsByTagName("Item");
        for ( int i = 0; i < list.getLength(); i++ ){
            Valuta valuta = new Valuta();
            NodeList sublist = list.item(i).getChildNodes();
            for ( int j = 0; j < sublist.getLength(); j++ ){
                if ( sublist.item(j).getNodeName().equals("Name") ) {
                    valuta.setName(sublist.item(j).getTextContent().trim());
                }
                if ( sublist.item(j).getNodeName().equals("EngName") )
                    valuta.setNameEng(sublist.item(j).getTextContent().trim());
                if ( sublist.item(j).getNodeName().equals("ParentCode") )
                    valuta.setCode(sublist.item(j).getTextContent().trim());
            }
            valutesList.add(valuta);
        }
        for ( Valuta valuta: valutesList ){
            valutesMap.put(valuta.getCode(), valuta.getName());
        }
        return valutesMap;
    }

}
