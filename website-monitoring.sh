#!/bin/bash


while read line ; 
do

domain=`echo $line |awk '{print $1}'`
echo $domain
cid=`echo $line |awk '{print $2}'`

status=`curl -m 30 -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/600.1.17 (KHTML, like Gecko) Version/8.0 Safari/600.1.17" -Ls -o /dev/null -w "%{http_code}\n" $domain`



if ! echo $status | egrep '[2,3][0][0-9]' ; then
  echo $domain DOWN
grep $domain /root/downlist.txt
if [[ `cat /root/countlist.txt|grep $domain|wc -l` -ge 2 ]];then
  if ! cat /root/downlist.txt |grep $domain ; then
     echo $domain sending down alert
     echo "Domain : $domain" > clienturl.txt
     echo "Status code: $status" >> clienturl.txt

     /usr/bin/mutt -s  "Website down: $domain" support@support.com < clienturl.txt

     echo  $domain >> /root/downlist.txt

  fi
fi
    echo  $domain >> /root/countlist.txt
else
  echo $domain UP
  if cat /root/downlist.txt |grep $domain ; then
         echo $domain sending UP alert
     echo "Domain : $domain" > clienturl.txt
     echo "Status code: $status" >> clienturl.txt
     /usr/bin/mutt -s  "Website UP: $domain" support@support.com < clienturl.txt
     sed -i "/$domain/d" /root/downlist.txt
        sed -i "/$domain/d" /root/countlist.txt
  fi
fi

done < /root/domainlist.txt

