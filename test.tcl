#!/usr/bin/env tclsh
package require httpd

# Start the server on port 8080
Httpd_Server 8080

proc start_container { } {
    # Execute Podman command to start a container
    set result [exec podman run -d nginx]
    return "<html>Container started: $result</html>"
}

proc stop_container {container_id} {
    # Execute Podman command to stop a container
    set result [exec podman stop $container_id]
    return "<html>Container stopped: $result</html>"
}

# Map URL paths to procedures
Httpd_URL /start_container start_container
Httpd_URL /stop_container stop_container

vwait forever
