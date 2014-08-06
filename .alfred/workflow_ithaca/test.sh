port1080=$(ps aux | grep ssh.*1080 | grep -v grep)
port1081=$(ps aux | grep ssh.*1081 | grep -v grep)

ports=

if [[ $port1080 == '' ]];then
  #ssh -D 1080 -N -f -p 8022 tomcat.hvps.tk
  ports=$ports:1080
fi

if [[ $port1081 == '' ]];then
  #ssh -D 1081 -N -f eagle.hvps.tk
  ports=$ports:1081
fi

echo $port1080
echo $port1081
