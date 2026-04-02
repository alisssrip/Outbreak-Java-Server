<?php
session_start();

$login_result = '';

// 1. Trampa antiaérea: ¿Está cURL instalado?
if (!function_exists('curl_init')) {
    $login_result = 'ERROR FATAL: La extensión php-curl no está instalada en Rebecca.';
} 
// 2. Si cURL existe, procesamos el formulario
else if (isset($_POST["login"])) {
    $username = substr(preg_replace("/[^A-Za-z0-9 _]/", "", $_POST["username"]), 0, 14);
    $password = substr(preg_replace("/[^A-Za-z0-9 _]/", "", $_POST["password"]), 0, 14);

    if($password == "" || $username == "") {
        header('Location: login.php');
        exit();
    }

    $url = "https://yoko.makii.net/api/OutbreakJava/login"; 
    $data = array("username" => $username, "password" => $password, "type" => $_POST["login"]);

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);

    $response = curl_exec($ch);
    
    // 3. Trampa de red: Si cURL falla, guardamos el error en la variable en vez de hacer exit
    if(curl_errno($ch)){
        $login_result = 'ERROR DE cURL: ' . curl_error($ch);
        curl_close($ch);
    } else {
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode == 200) {
            $resData = json_decode($response, true);
            $sessid = $resData["sessionId"];
            $msg = ($_POST["login"] == 'newaccount') ? 'Cuenta creada.' : 'Login exitoso.';
            $login_result = $msg . '<br><br><a href="startsession.php?sessid='.$sessid.'">ENTRAR AL JUEGO</a>';
        } else {
            $login_result = 'Error de API (Código '.$httpCode.'). Revisa credenciales.<br><a href="login.php">Volver</a>';
        }
    }
}

// 4. FORZAMOS la impresión del HTML para que la PS2 no se quede en negro
include('header.php');
echo "<br><br><center><h2 style='color:red; background-color:white; padding:10px;'>$login_result</h2></center><br><br>";
include('footer.php');
?>
