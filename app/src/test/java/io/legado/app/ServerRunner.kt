package io.legado.app

import io.legado.app.service.WebService
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [33]) // Mock API Level 33 (Android 13)
class ServerRunner {

    @Test
    fun runServer() {
        println("=== Starting Legado WebService on JVM via Robolectric ===")
        
        // Configure database directory for persistence
        System.setProperty("robolectric.active", "true")
        System.setProperty("legado.db.dir", "/storage")
        
        val context = RuntimeEnvironment.getApplication()
        
        // Launch WebService
        WebService.start(context)
        
        println("=== WebService Running on HTTP Port 1122 and WS Port 1123 ===")
        println("Server logs will stream here. Press Ctrl+C to stop.")
        
        // Loop forever to keep the Robolectric test runner and servers alive
        while (true) {
            Thread.sleep(2000)
        }
    }
}
