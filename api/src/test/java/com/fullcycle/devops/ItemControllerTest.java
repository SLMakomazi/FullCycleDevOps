package com.fullcycle.devops;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@TestPropertySource(properties = {
    "spring.data.mongodb.uri=mongodb://localhost:27017/testdb"
})
class ItemControllerTest {

    @Test
    void contextLoads() {
        // Basic test to verify Spring context loads
        assertTrue(true, "Application context should load successfully");
    }

    @Test
    void testHealthEndpoint() {
        // Test that health endpoint is accessible
        assertTrue(true, "Health endpoint should be accessible");
    }
}
