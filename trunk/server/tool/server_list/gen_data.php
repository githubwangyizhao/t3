<?php

define('PATH', dirname(__FILE__));
define('DATA_DIR', PATH . '/gen_data/');

require_once(PATH . '/db.php');
require_once(PATH . '/config.php');

if (!file_exists(DATA_DIR)) {
    mkdir(DATA_DIR);
}

$platformList = [1];

$db = new Db($Config);
$res = $db->query("select * from c_server_node;");
$serverNodeRows = array();
if ($res) {
    while ($row = mysqli_fetch_assoc($res)) {
        $serverNodeRows[$row["node"]] = $row;
    }
}

mysqli_free_result($res);
foreach ($platformList as $platformId){
    $res = $db->query("select * from c_game_server where platform_id = ".$platformId.";");
    $outRows = array();
    if ($res) {
        while ($row = mysqli_fetch_assoc($res)) {
            $node = $serverNodeRows[ $row["node"]];
            $outRows[] = [
                "id" => $row["id"],
                "desc" =>$row["desc"],
                "ip" =>$node["ip"],
                "port" => $node["port"]
            ];
        }
    }
    $out = array();
    $out["server_list"] = $outRows;
    file_put_contents(DATA_DIR."server_list_".$platformId.".json", stripslashes(json_encode($out, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)));
}


$db->close();
?>
