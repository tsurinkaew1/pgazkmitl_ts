<?php
// File to store counter data
$filename = 'counter.txt';

// Check if the file exists, if not create it
if (!file_exists($filename)) {
    file_put_contents($filename, "0|0");
}

// Read the current counts
$data = file_get_contents($filename);
list($visitors, $page_views) = explode('|', $data);

// Increment page views
$page_views++;

// Check for a unique visitor using a cookie
if (!isset($_COOKIE['unique_visitor'])) {
    $visitors++;
    // Set a cookie that expires in 24 hours
    setcookie('unique_visitor', 'true', time() + (86400), "/");
}

// Update the counter file
file_put_contents($filename, "$visitors|$page_views");

// Output the counts
echo "Visitors: $visitors | Views: $page_views";
?>
