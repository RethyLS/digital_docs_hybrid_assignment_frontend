<?php
$url = 'http://127.0.0.1:8000/api/login';
$data = ['email' => 'superadmin@system.com', 'password' => 'password'];
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Accept: application/json']);
$response = curl_exec($ch);
$token = json_decode($response, true)['data']['token'] ?? null;
if (!$token) { echo "LOGIN FAILED: $response\n"; exit(1); }

$url = 'http://127.0.0.1:8000/api/employees?status=active&per_page=100';
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Authorization: Bearer ' . $token, 'Accept: application/json']);
$res = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
echo "CODE: $code\nRESPONSE: $res\n";
