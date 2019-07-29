Setup Xdebug
===

1. Enale Xdebug and setup host in .env file:

    ```
    PHP_XDEBUG_ENABLED=true
    PHP_XDEBUG_REMOTE_HOST=docker.for.mac.host.internal
    PHP_XDEBUG_REMOTE_PORT=9001
    ```
    
    Hosts list for various OS ([more](https://gist.github.com/chadrien/c90927ec2d160ffea9c4#gistcomment-2398281)):
    
    **MacOS**: `docker.for.mac.host.internal`
    
    **Linux**: `172.18.0.1`
    
    **Windows**: `docker.for.win.host.internal`

1. Run containers:

    ```
    /make up
    ```

1. Setup PhpStorm. Step 1 (Preferences | Languages & Frameworks | PHP | Debug):
    
    ```
    Debug port: 9001
    [V] Can accept external connections
    ```
    
1. Setup PhpStorm. Step 2 (Preferences | Languages & Frameworks | PHP | Debug | DBGp Proxy):

    ```
    IDE Key: PHPSTORM
    Host:
    Port: 9001
    ```

1. Start debugging:
    - Start Listening for PHP Debug Connections (a phone with a bug icon)
    
1. He have done. Setup breakpoint and run the application!