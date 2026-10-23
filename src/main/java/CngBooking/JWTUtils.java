package CngBooking;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

import java.nio.charset.StandardCharsets;
import java.util.Date;

public class JWTUtils {
    private static final long EXPIRATION_TIME = 1000 * 60 * 60; // 1 hour

    private static byte[] signingKey() {
        String secret = System.getenv("JWT_SECRET");
        if (secret == null || secret.trim().isEmpty()) {
            throw new IllegalStateException("JWT_SECRET environment variable is not set.");
        }

        byte[] key = secret.getBytes(StandardCharsets.UTF_8);
        if (key.length < 32) {
            throw new IllegalStateException("JWT_SECRET must be at least 32 bytes long.");
        }
        return key;
    }

    // Generate token with email + role
    public static String generateToken(String email, String role) {
        return Jwts.builder()
                .setSubject(email) // email = subject
                .claim("role", role) // extra claim
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(SignatureAlgorithm.HS256, signingKey())
                .compact();
    }

    // Validate token and return Claims
    public static Claims validateToken(String token) {
        return Jwts.parser()
                .setSigningKey(signingKey())
                .parseClaimsJws(token)
                .getBody();
    }
}
