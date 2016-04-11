<?php
$dbuser="backupserver";
$dbpass="";
$dbhost='localhost';
$dbdatabase=$dbuser;
//we set up the connection to our database and check the login credentials of the request
$mydb = new mysqli($dbhost, $dbuser, $dbpass, $dbdatabase);
if ($mydb->connect_errno) {
    echo "Failed to connect to MySQL: (" . $mydb->connect_errno . ") " . $mydb->connect_error;
}
//having got our admin user, we log to their log file
//or their database bit
//so that the admin can review log files of their own backups

include "vendor/autoload.php";
use Monolog\Logger;
use Monolog\Handler\StreamHandler;

// create a log channel
$log = new Logger('backups');
$log->pushHandler(new StreamHandler('requests.log', Logger::WARNING)); // <<< uses a file

$backuproot="/home/alanbell/backupfiles";//absolutely not in web root
