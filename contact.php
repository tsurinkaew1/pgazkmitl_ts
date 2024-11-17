<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Sanitize user inputs
    $name = htmlspecialchars($_POST['name']);
    $email = htmlspecialchars($_POST['email']);
    $subject = htmlspecialchars($_POST['subject']);
    $message = htmlspecialchars($_POST['message']);

    // Your email address where you want to receive the messages
    $to = "tossaporn.su@kmitl.ac.th";  // Replace with your actual email address
    
    // Email subject
    $email_subject = "New Contact Form Submission: " . $subject;
    
    // Construct the email body
    $email_body = "
        You have received a new message from the contact form on your website.\n\n
        Name: $name\n
        Email: $email\n
        Subject: $subject\n
        Message: \n$message
    ";

    // Headers
    $headers = "From: " . $email . "\r\n";
    $headers .= "Reply-To: " . $email . "\r\n";
    $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";

    // Send email
    if (mail($to, $email_subject, $email_body, $headers)) {
        echo "Thank you for contacting us. We will get back to you shortly.";
    } else {
        echo "Sorry, there was an error sending your message. Please try again later.";
    }
}
?>