<?php
//importing required script
require_once '../includes/DbOperation.php';

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    if (!verifyRequiredParams(array('beach_name'))) {
        //getting values
        $beach_name = $_REQUEST['beach_name'];

        //creating db operation object
        $db = new DbOperation();

        //adding beach to database
        $result = $db->getRating($beach_name);

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


$test = json_encode($result);
echo $test;
//echo "{\"rating\" :".json_encode($result)."}";
