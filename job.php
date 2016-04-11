<?php

//for this user and machine we give the tasks out
//and a unique run reference, so we know all responses come back to this request
$runref=uniqid();//doesn't really need to be cryptographically strong

//we tell the client what we want them to send to us
//we could try to be evil and ask the client to send us the file with their symetric key in it - but it will be encrypted, so that is still OK.

//file paths are unencrypted, we do have a pretty good idea of the structure of the client filesystem
//but restoring would be a right pain if we didn't, and that tends not to be critical information
//it might reveal to an attacker what is running on a client computer and thereby ways to attack it
//but it isn't a big help.

//so, something connects and asks for it's job definition. If the computer ID and key checks out then we respond with a run reference and the things we want from them
//split into types of job, individual files, folders, databases etc.
//the client is expected to process these in order, but that isn't mandatory.
//ini_set("display_errors",1);
include "login.php";
$jobname="Alan Laptop";
$jobkey="asdf";

$stmt=$mydb->prepare("select jobid,taskname,location,lineid from jobs join joblines on jobs.jobid=joblines.job
			join tasktypes on joblines.tasktype=tasktypes.taskref where jobname=? and serverkey=?");
$stmt->bind_param("ss",$jobname,$jobkey);
$stmt->bind_result($jobid,$tasktype,$location,$lineid);

$stmt->execute();
while ($stmt->fetch()) {
    $jobdefinition[$tasktype][$lineid]=$location;
}
$stmt->close();
$jobdefinition["runref"]=$runref;
//store the runref in our database so we know that a backup attempt is going to start
        $stmt=$mydb->prepare("insert into runreferences(job,runref) values(?,?)");
        $stmt->bind_param("is",$jobid,$runref);
        $stmt->execute();

header('Content-Type: application/json');
echo json_encode($jobdefinition);
