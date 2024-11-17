<?php
// Enable error reporting for debugging
ini_set('display_errors', 1);
error_reporting(E_ALL);

// File to store counter data
$filename = 'counter.txt';

// Check if the file exists, if not, create it with initial counts
if (!file_exists($filename)) {
    if (file_put_contents($filename, "0|0") === false) {
        die("Error: Unable to create counter file.");
    }
}

// Read the current counts from the counter file
$data = file_get_contents($filename);
if ($data === false) {
    die("Error: Unable to read counter file.");
}

list($visitors, $page_views) = explode('|', $data);

// Ensure the values are numeric
if (!is_numeric($visitors) || !is_numeric($page_views)) {
    die("Error: Invalid data format in counter file.");
}

// Increment the page views count
$page_views++;

// Check for a unique visitor using a cookie
if (!isset($_COOKIE['unique_visitor'])) {
    $visitors++;
    // Set a cookie that expires in 24 hours
    setcookie('unique_visitor', 'true', time() + 86400, "/");
}

// Update the counter file
if (file_put_contents($filename, "$visitors|$page_views") === false) {
    die("Error: Unable to update counter file.");
}

// Output the counts
echo "Visitors: $visitors | Views: $page_views";
?>

