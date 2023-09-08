
mkdir .\iscobol\WEB-INF
mkdir .\iscobol\WEB-INF\classes
mkdir .\iscobol\WEB-INF\lib

copy "%iscobol%\lib\decipher.jar" "iscobol\WEB-INF\lib\"
copy "%iscobol%\lib\iscobol.jar" "iscobol\WEB-INF\lib\"
copy "%iscobol%\sample\eis\files\web.xml" "iscobol\WEB-INF\"
move *.class "iscobol\WEB-INF\classes\"
copy *.properties "iscobol\WEB-INF\classes\"

cd iscobol
jar.exe -cfv samplezap.war *

