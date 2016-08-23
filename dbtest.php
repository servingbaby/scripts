<?php

 $user = 'healthcheck';
 $pass = 'checkhealth';
 $host = '172.22.150.133';
 $database = 'test';
 $query = "select count(*) from health";

 $link = mysql_connect($host,$user,$pass);
 if ($link) {
   if (mysql_select_db($database,$link)) {
     if (mysql_query($query,$link)) {
       mysql_close($link);
       print("OK\n");
       exit(0);
     }
   }
 }
 $status = mysql_error();
 if ($link) { mysql_close(); }

 header("X-Health-Status: down",false,503);
 print($status."\n");

?>

