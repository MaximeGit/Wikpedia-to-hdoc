import java.io.BufferedInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;

public class FetchWikipediaXml {

	public static void main(String[] args) throws IOException {
		URL url = new URL(args[0]);
		
		String destination = args[1];
		System.out.println(destination);
		
		BufferedInputStream in = null;
		FileOutputStream fout = null;
		
		in = new BufferedInputStream(url.openStream());
		
		fout = new FileOutputStream("test.xml");
		
		final byte data[] = new byte[1024];
		int count;
        while ((count = in.read(data, 0, 1024)) != -1) {
            fout.write(data, 0, count);
        }
        
        if (in != null) {
            in.close();
        }
        if (fout != null) {
            fout.close();
        }
	}
} 
