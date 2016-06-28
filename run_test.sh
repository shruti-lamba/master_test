#!/bin/bash
#AMI="ami-fce3c696"
#KeyPairName="key_Gunjan"
#SecurityGroup="sg-ee751395"
#InstanceType="t2.micro"
#Subnet="subnet-a28a3dfa"
#NoOfInstances=1
source properties.sh
touch /usr/share/jmeter/extras/slave.log
>/usr/share/jmeter/extras/slave.log

bash -x /usr/share/jmeter/extras/slave.sh >> /usr/share/jmeter/extras/slave.log 2>&1

IPList=$(cat ip.txt |awk 'FNR==1{print $0}')
echo "Wait while slaves are configured!"
sleep 300

#### write properties to jmeter.properties
>/usr/share/jmeter/extras/outputFile.xml
jmeter -n -t /usr/share/jmeter/extras/$jmxFile.jmx -l /usr/share/jmeter/extras/outputFile.xml -R $IPList;
ant -f /usr/share/jmeter/extras/conversion.xml
aws s3 cp /usr/share/jmeter/extras/outputFile.html s3://$BUCKET/$OutputFile.html --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
echo "https://s3.amazonaws.com/$BUCKET/$OutputFile.html"
