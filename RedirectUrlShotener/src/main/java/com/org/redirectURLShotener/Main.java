package com.org.redirectURLShotener;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

public class Main implements RequestHandler<Map<String, Object>, Map<String, Object>> {
    private final S3Client s3Client = S3Client.builder().build();

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public Map<String, Object> handleRequest(Map<String, Object> input, Context context) {
        String rawPath = (String) input.get("rawPath");
        context.getLogger().log("Request rawPath: " + rawPath);

        String shortUrlCode = extractShortUrlCode(rawPath);
        String objectKey = shortUrlCode + ".json";
        String bucketName = bucketName();
        context.getLogger().log("S3 lookup bucket=" + bucketName + " key=" + objectKey);

        GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                .bucket(bucketName)
                .key(objectKey)
                .build();

        UrlData urlData;
        try (InputStream s3ObjectStream = s3Client.getObject(getObjectRequest)) {
            urlData = objectMapper.readValue(s3ObjectStream, UrlData.class);
        } catch (Exception e) {
            context.getLogger().log("S3 read failed bucket=" + bucketName + " key=" + objectKey + " error=" + e.getMessage());
            throw new RuntimeException("Error reading URL data from S3: " + e.getMessage(), e);
        }

        long currentTimeInSeconds = System.currentTimeMillis() / 1000;

        Map<String, Object> response = new HashMap<>();
        Map<String, String> headers = new HashMap<>();

        if (isExpired(urlData.getExpirationTime(), currentTimeInSeconds)) {
            response.put("statusCode", 410);
            response.put("body", "this URL has expired");

            return response;
        }

        response.put("statusCode", 302);
        headers.put("Location", urlData.getOriginalUrl());
        response.put("headers", headers);

        context.getLogger().log("Redirect 302 to " + urlData.getOriginalUrl());

        return response;
    }

    static String extractShortUrlCode(String rawPath) {
        if (rawPath == null || rawPath.isBlank()) {
            throw new IllegalArgumentException("Invalid input: 'rawPath' is required.");
        }

        String shortUrlCode = rawPath.replace("/", "");
        if (shortUrlCode.isEmpty()) {
            throw new IllegalArgumentException("Invalid input: 'shortUrlCode' is required.");
        }

        return shortUrlCode;
    }

    static boolean isExpired(long expirationTime, long currentTimeInSeconds) {
        return expirationTime < currentTimeInSeconds;
    }

    private static String bucketName() {
        String bucketName = System.getenv("BUCKET_NAME");
        if (bucketName == null || bucketName.isBlank()) {
            throw new IllegalStateException("BUCKET_NAME environment variable is required.");
        }
        return bucketName;
    }
}
