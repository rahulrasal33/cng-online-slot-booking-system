package CngBooking;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import javax.servlet.*;
import javax.servlet.http.*;

public class ChatServlet extends HttpServlet {
    // ✅ FIX: Read API key from environment variable instead of hardcoding
    private static final String API_KEY = System.getenv("GEMINI_API_KEY") != null
            ? System.getenv("GEMINI_API_KEY") : "";
    private static final String ENDPOINT =
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain; charset=UTF-8");
        String userMessage = request.getParameter("message");

        if (userMessage == null || userMessage.isEmpty()) {
            response.getWriter().write("⚠️ Empty message.");
            return;
        }

        if (API_KEY.isEmpty()) {
            response.getWriter().write("⚠️ Chatbot is not configured. Set GEMINI_API_KEY environment variable.");
            return;
        }

        try {
            String jsonInput = "{"
                    + "\"contents\": ["
                    + "{ \"role\": \"user\", \"parts\": [ { \"text\": \""
                    + userMessage.replace("\"", "\\\"") + "\" } ] }"
                    + "]"
                    + "}";

            URL url = new URL(ENDPOINT);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setRequestProperty("x-goog-api-key", API_KEY);
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(jsonInput.getBytes(StandardCharsets.UTF_8));
            }

            BufferedReader br = new BufferedReader(new InputStreamReader(
                    conn.getInputStream(), StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
            br.close();

            String raw = sb.toString();
            String reply = "Sorry, no reply.";
            int idx = raw.indexOf("\"text\":");
            if (idx != -1) {
                int start = raw.indexOf("\"", idx + 7) + 1;
                int end = raw.indexOf("\"", start);
                reply = raw.substring(start, end).replace("\\n", "\n");
            }

            response.getWriter().write(reply);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("⚠️ Error: " + e.getMessage());
        }
    }
}
