package com.org.redirectURLShotener;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MainTest {

    @Test
    void extractsCodeFromPath() {
        assertEquals("abc123", Main.extractShortUrlCode("/abc123"));
    }

    @Test
    void rejectsEmptyPath() {
        assertThrows(
                IllegalArgumentException.class,
                () -> Main.extractShortUrlCode("/")
        );
    }

    @Test
    void identifiesExpiredAndActiveUrls() {
        assertTrue(Main.isExpired(99, 100));
        assertFalse(Main.isExpired(101, 100));
    }
}
