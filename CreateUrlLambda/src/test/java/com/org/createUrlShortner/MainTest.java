package com.org.createUrlShortner;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MainTest {

    @Test
    void parsesValidRequestBody() {
        Map<String, String> request = Main.parseRequestBody(
                "{\"originalUrl\":\"https://example.com\",\"expirationTime\":\"1735689600\"}"
        );

        assertEquals("https://example.com", request.get("originalUrl"));
        assertEquals("1735689600", request.get("expirationTime"));
    }

    @Test
    void rejectsRequestWithoutOriginalUrl() {
        assertThrows(
                IllegalArgumentException.class,
                () -> Main.parseRequestBody("{\"expirationTime\":\"1735689600\"}")
        );
    }

    @Test
    void generatesEightCharacterCode() {
        String code = Main.generateShortUrlCode();

        assertEquals(8, code.length());
        assertTrue(code.matches("[a-f0-9]{8}"));
    }
}
