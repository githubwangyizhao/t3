<?php
/**
 * mysql数据库操作类
*/

class Db{
    
    public $con = null;

    function Db ($Config) {
        $this->con = mysqli_connect(
			$Config['mysql_server'],
			$Config['mysql_user'],
			$Config['mysql_pwd'],
			$Config['mysql_db'],
			$Config['mysql_port']
		) or die(mysqli_error($this->con));
        
		mysqli_select_db($this->con, $Config['mysql_db']) or die(mysqli_error($this->con));

        mysqli_query($this->con, 'set names utf8') or die(mysqli_error($this->con));
    }

    /**
	 * 关闭连接
	 */
	public function close () {
		mysqli_close($this->con) or die(mysqli_error($this->con));
	}
    
	/**
	 * 执行sql
	 */
	public function query ($sql) {
		$res = mysqli_query($this->con, $sql) or die(mysqli_error($this->con));
		return $res;
	}
    
    /**
    * 执行多条语句
    */
    public function multi_query ($sql) {
        $query_id = mysqli_multi_query($this->con, $sql) or die(mysqli_error($this->con));
        if ($query_id) {
            while (mysqli_next_result($this->con)) {
                continue;
            }
        }
    }
    
    /**
	 * 获取所有查询记录
	 */
    public function queryAll ($sql) {

		$query_id = mysqli_query($this->con, $sql) or die(mysqli_error($this->con));

		$rows = array();
		if ($query_id) {
			while ($row = mysqli_fetch_assoc($query_id)) {
				array_push($rows, $row);
			}
		}

        mysqli_free_result($query_id);
        
		return $rows;
	}


    /**
	 * 获取单条记录
	 */
	public function queryOne ($sql) {

		$rows = $this->queryAll($sql);
		if (empty ($rows)) {
			return array();
		}

		return $rows[0];
	}
}
?>
