<?php
//this receives a submission from a backup agent.
//this will consist of some metadata and a file
//we check we are OK with the credentials passed in
//and store the file where we want to, according to the submitter id
//the metadata goes into our SQL database and we respond positively when the file is saved and the metadata committed
//we can give an error if something goes wrong
//we may at some point support multiple files submitted in a single request
//we *really* don't want this stuff in web root


include "login.php";

//so we are going to write the file to a place
$user="alanbell";

$path=$_REQUEST['path'];//we will want to validate this is sensible
$runref=$_REQUEST['runref'];
$jobline=$_REQUEST['jobline'];

$files=json_decode($_REQUEST['fileinfo']);
foreach($files as $filepath=>$hash){
    mkdir("$backuproot/$user/$runref$path",0700,true);
    if (!move_uploaded_file(
        $_FILES[$hash]['tmp_name'],
	"$backuproot/$user/$runref$path/$hash"
    )) {
        $log->addError("failed to move uploaded file ",$path);
        throw new RuntimeException('Failed to move uploaded file $path');
    }else{
	//here we have saved the file with success,
	//now we can write to the database to say we have it
	//then let the client know we are OK with the capture of that file
        $stmt=$mydb->prepare("insert into files(jobline,filepath,filehash,runref) values(?,?,?,?)");
        $stmt->bind_param("isss",$jobline,$filepath,$hash,$runref);
        $stmt->execute();
	//for some reason we don't close this statement
    }
}

$mydb->close();
