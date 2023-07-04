<?php
//importing required script
require_once '../includes/DbOperation.php';

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (!verifyRequiredParams(array('beach_name'))) {
        //getting values
        $beach_name = $_REQUEST['beach_name'];
//        echo $_POST['beach_name'];
//        echo "----";
//        $beach_name = "St Kilda Beach";
        //creating db operation object
        $db = new DbOperation();

        //adding beach to database
        $result = $db->createBeach($beach_name);

        //making the response accordingly
        if ($result == BEACH_CREATED) {
            $response['error'] = false;
            $response['message'] = 'Beach created successfully';
        } elseif ($result == BEACH_ALREADY_EXIST) {
            $response['error'] = true;
            $response['message'] = 'Beach already exist';
        } elseif ($result == BEACH_NOT_CREATED) {
            $response['error'] = true;
            $response['message'] = 'Some error occurred';
        }
    } else {
        $response['error'] = true;
        $response['message'] = 'Required parameters are missing';
    }
} else {
    $response['error'] = true;
    $response['message'] = 'Invalid request';
}

//function to validate the required parameter in request
function verifyRequiredParams($required_fields)
{

    //Getting the request parameters
    $request_params = $_REQUEST;

    //Looping through all the parameters
    foreach ($required_fields as $field) {
        //if any requred parameter is missing
        if (!isset($request_params[$field]) || strlen(trim($request_params[$field])) <= 0) {

            //returning true;
            return true;
        }
    }
    return false;
}

echo json_encode($response);