package require Tcl 8.6
package require json
package require Pgtcl
package require httpd

# Connect to the PostgreSQL database
set conn [pg_connect -conninfo "host=localhost dbname=bench user=brycolem password=your_password"]

proc getApplications {} {
    global conn
    set appResults [pg_select $conn "SELECT id, title, link, company_id FROM applications" appResult]

    set applications {}

    foreach appRow $appResults {
        set appId [lindex $appRow 0]
        set title [lindex $appRow 2]
        set link [lindex $appRow 3]
        set companyId [lindex $appRow 4]

        # Get notes for the application
        set noteResults [pg_select $conn "SELECT id, note_text FROM notes WHERE application_id = $appId" noteResult]
        set notes {}

        foreach noteRow $noteResults {
            lappend notes [dict create id [lindex $noteRow 0] noteText [lindex $noteRow 1]]
        }

        # Create an application dictionary
        lappend applications [dict create id $appId employer $employer title $title link $link companyId $companyId notes $notes]
    }
    return [json::jsonify $applications]
}

# Define route for the /applications endpoint
proc get_applications {sock request} {
    puts $sock "HTTP/1.1 200 OK"
    puts $sock "Content-Type: application/json\r\n"
    puts $sock "\r"
    puts $sock [getApplications]
}

# Initialize the HTTP server
set srv [::httpd::server new]

# Add the route to the server
$srv dispatch /applications GET get_applications

# Configure and start the server
$srv configure -port 8080
$srv start

vwait forever
