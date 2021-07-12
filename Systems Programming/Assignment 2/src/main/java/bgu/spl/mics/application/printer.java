package bgu.spl.mics.application;
import com.google.gson.Gson;
import java.io.FileOutputStream;
import java.io.IOException;


public class printer {
    public static void printToFile(String filename, Object... objects2print) {
        try {
            FileOutputStream fos = new FileOutputStream(filename);
            Gson gson = new Gson();
            for (int i = 0; i < objects2print.length; i++) {
                String str = gson.toJson(objects2print[i]).replace("{","{\n").replace("[","[\n").replace(",",",\n").replace("]","\n]").replace("}","\n}");
                fos.write(str.getBytes());
            }
            fos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

