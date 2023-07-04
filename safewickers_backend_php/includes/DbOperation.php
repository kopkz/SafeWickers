<?php


class DbOperation
{
    private $conn;

    //Constructor
    function __construct()
    {
        require_once dirname(__FILE__) . '/Constants.php';
        require_once dirname(__FILE__) . '/DbConnect.php';
        // opening db connection
        $db = new DbConnect();
        $this->conn = $db->connect();
    }

    //Function to create a new beach
    public function createBeach($beach_name)
    {
        if (!$this->isBeachExist($beach_name)) {
            $stmt = $this->conn->prepare("INSERT INTO beach (beach_name) VALUES (?)");
            $stmt->bind_param("s", $beach_name);
            if ($stmt->execute()) {
                return BEACH_CREATED;
            } else {
                echo $stmt->error;
                return BEACH_NOT_CREATED;
            }
        } else {
            return BEACH_ALREADY_EXIST;
        }
    }

    //Function to give a rating
    public function giveRating($beach_name, $rating_level)
    {
        if (!$this->isBeachExist($beach_name)) {
            $this->createBeach($beach_name);
        }
        $stmt = $this->conn->prepare("INSERT INTO rating(beach_name, rating_level) VALUES (?, ?)");
        $stmt->bind_param("ss", $beach_name, $rating_level);
        return $stmt->execute() ? RATING_CREATED : RATING_NOT_CREATED;

    }

    //Function to query average rating of Beach
    public function getRating($beach_name){
// WHERE beach_name = '.$beach_name.'
        $sql = "SELECT rating_level FROM rating WHERE beach_name = '$beach_name'";
        $query = mysqli_query($this->conn, $sql);
        $data = array();
        while ( $row = $query->fetch_array()){
            $data[] = $row;
//           array_push($data,$row['rating_level']);
        }
        return $data;
    }

    private function isBeachExist($beach_name)
    {
        $stmt = $this->conn->prepare("SELECT beach_id FROM beach WHERE beach_name = ?");
        $stmt->bind_param("s", $beach_name);
        $stmt->execute();
        $stmt->store_result();
        return $stmt->num_rows > 0;
    }
}