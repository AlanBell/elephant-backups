<?php
//for this endpoint we accept a file hash, or a big list of file hashes
//we reply with the ones we have and the ones we have not got
//if we have the file but the hash is different should we reveal that?
//should the paths be plaintext?

//firstly check this is an athorised client logging in OK
//is the job reference corresponding to something we are expecting?
include "login.php";

// add records to the log
$files=json_decode($_POST['fileinfo']);
$ineed=array();
$ihave=array();
foreach($files as $path=>$hash){
    //look up the path in our database
    //and the hash for that matter
    //if the hash matches, we add it to the ihave array
    //if we don't have it or the hash is different then we add it to the ineed array
    //we respond to the client with a list of paths we have and a list of paths we need
    //strictly speaking we don't need to tell the client what we have
    //but that may be used to reassure the client that we really have the file
    //right now we need everything
    //if we have the file - but the hash is wrong then we may accept a diff - in that case we respond with the
    //hash of what we do have
    //as we will only be accepting encrypted files we can't apply the diff on the server, or create reverse diffs
    //so at some point we will request a new full file
$stmt=$mydb->prepare("select uploadid from files where filepath=? and filehash=?");

if (!$stmt->bind_param("ss", $path, $hash)) {
    echo "Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error;
}

if (!$stmt->execute()) {
    echo "Execute failed: (" . $stmt->errno . ") " . $stmt->error;
}
$uploadid='';
$stmt->bind_result($uploadid);

if($stmt->fetch()) {
    $ihave[]=$path;//do we really want to return this?
  }else{
    $ineed[]=$path;
    $log->addError("Requesting");
  }
  $stmt->close();//really important to close the statement as we are in a loop
}
$mydb->close();
//we either have these or need them
//and there might be some things we have under this job reference which may have been deleted clientside
//we respond with ihave
//ineed - things we want the client to send us.
//didyoudelete - we offer a list of files that we previously knew about but are not in the request
//that might be a problem if we are doing partial checks of large trees of files
header('Content-Type: application/json');
echo json_encode(array('ihave'=>$ihave,'ineed'=>$ineed));

