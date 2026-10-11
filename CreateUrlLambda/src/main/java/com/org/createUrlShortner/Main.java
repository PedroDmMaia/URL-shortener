package com.org.createUrlShortner;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import com.fasterxml.jackson.core.type.TypeReference;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class Main implements RequestHandler<Map<String, Object>, Map<String, String>> {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private final S3Client s3Client = S3Client.builder().build();

    @Override
    public Map<String, String> handleRequest(Map<String, Object> input, Context context) {
        String body = String.valueOf(input.get("body"));
        Map<String, String> bodyMap = parseRequestBody(body);

        String originalUrl = bodyMap.get("originalUrl");
        String expirationTime = bodyMap.get("expirationTime");
        long expirationTimeInSecond = Long.parseLong(expirationTime);

        String shortUrlCode = generateShortUrlCode();

        UrlData urlData = new UrlData(originalUrl, expirationTimeInSecond);

        try {
            String urlDataJson = OBJECT_MAPPER.writeValueAsString(urlData);

            PutObjectRequest request  = PutObjectRequest.builder()
                .bucket(bucketName())
                .key(shortUrlCode + ".json")
                .build();

            s3Client.putObject(request, RequestBody.fromString(urlDataJson));
        } catch (Exception e) {
            throw new RuntimeException("Error saving URL data to s3 " + e.getMessage(), e);
        }

        Map<String, String> response = new HashMap<>();
        response.put("code", shortUrlCode);

        return response;
    }

    static Map<String, String> parseRequestBody(String body) {
        if (body == null || body.isBlank() || "null".equals(body)) {
            throw new IllegalArgumentException("Request body is required.");
        }

        try {
            Map<String, String> bodyMap = OBJECT_MAPPER.readValue(
                    body,
                    new TypeReference<Map<String, String>>() {}
            );

            if (bodyMap.get("originalUrl") == null || bodyMap.get("originalUrl").isBlank()) {
                throw new IllegalArgumentException("'originalUrl' is required.");
            }

            if (bodyMap.get("expirationTime") == null || bodyMap.get("expirationTime").isBlank()) {
                throw new IllegalArgumentException("'expirationTime' is required.");
            }

            Long.parseLong(bodyMap.get("expirationTime"));
            return bodyMap;
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid JSON body.", e);
        }
    }

    static String generateShortUrlCode() {
        return UUID.randomUUID().toString().substring(0, 8);
    }

    private static String bucketName() {
        String bucketName = System.getenv("BUCKET_NAME");
        if (bucketName == null || bucketName.isBlank()) {
            throw new IllegalStateException("BUCKET_NAME environment variable is required.");
        }
        return bucketName;
    }
}