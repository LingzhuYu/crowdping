<?php

// Put your device token here (without spaces):
//$deviceToken = '3097f1c9720c1c5372baa5dcfb0d62d2218a69f13cf5e8ca3fbe413833f41eed';
    
//$deviceToken = '55a2578aefb7357e2bdbeffbbb271bb4da41577b2fbef21205d791f9e963511e';

$deviceTokens = array('3097f1c9720c1c5372baa5dcfb0d62d2218a69f13cf5e8ca3fbe413833f41eed', '55a2578aefb7357e2bdbeffbbb271bb4da41577b2fbef21205d791f9e963511e');
    
// Put your private key's passphrase here:
$passphrase = ‘AppTest123’;

$message = $argv[1];
$url = $argv[2];

if (!$message || !$url)
    exit('Example Usage: $php newspush.php \'Breaking News!\' \'https://raywenderlich.com\'' . "\n");

////////////////////////////////////////////////////////////////////////////////

$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', 'crowdpingcertificate-p12.pem');
stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

// Open a connection to the APNS server
$fp = stream_socket_client(
  'ssl://gateway.sandbox.push.apple.com:2195', $err,
  $errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

if (!$fp)
  exit("Failed to connect: $err $errstr" . PHP_EOL);

echo 'Connected to APNS' . PHP_EOL;

// Create the payload body
$body['aps'] = array(
  'alert' => $message,
  'sound' => 'default',
  'link_url' => $url,
  );

// Encode the payload as JSON
$payload = json_encode($body);

    foreach($deviceTokens as $deviceToken) {
        // Build the binary notification
        $msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

        // Send it to the server
        $result = fwrite($fp, $msg, strlen($msg));

        if (!$result)
            echo 'Message not delivered' . PHP_EOL;
        else
            echo 'Message successfully delivered' . PHP_EOL;
    }
// Close the connection to the server
fclose($fp);
