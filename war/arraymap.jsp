<%@ page language="java" contentType="text/plain; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.util.*,edu.usc.epigenome.eccp.server.ECServiceBackend,edu.usc.epigenome.eccp.client.data.*,com.google.gson" %><%

try {
  Gson gson = new Gson();
  ECServiceBackend e = new ECServiceBackend();
  ArrayList<MethylationData> allBeadArrays = e.getMethFromGeneus();
  for(MethylationData beadArray : allBeadArrays) {
    String strip = gson.toJson(beadArray);
    out.println(strip);
  }
} catch(Exception e) {
  out.println(e.toString());
}

%>
