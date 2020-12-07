# k8s-aws-ssm-env-load
Example project to load Kubernetes env and secret from ssm parameter store paths 

It based on https://github.com/christippett/ssm-parameter-store code.

How it work?

* docker-entrypoint.sh calls load-ssm-parameters.py and then execute CMD
* load-ssm-parameters.py expects SSM_PATHS variable in list format. ` SSM_PATHS='["/dev", "/common"]'`  then it read all ssm parameters from AWS Parameter store and write into /tmp/env.sh (`export ENV=VALUE` lines)
* docker-entrypoint.sh calls `/tmp/env.sh` to load env variables then issue `exec $@` do start actual service.

```
$ cat docker-entrypoint.sh 
#!/bin/bash

/bin/load-ssm-parameters.py
echo "settting env from env.sh"
.  /tmp/env.sh

rm -f /tmp/env.sh

exec "$@"

```

Also sample php codes was written to test env variables in app.

```
<?php
header('Content-Type: text/plain; charset=utf-8');
print "MYENV1: " . getenv('MYENV1') . "\n" .
      "MYENV2: " . getenv('MYENV2') . "\n" .
      "MYSECRETENV: " . getenv('MYSECRETENV') . "\n";
      "COMMONENV1: " . getenv('COMMONENV1') . "\n";
?>⏎ 
```


## How to test it?

### IAM Roles
Ensure that your k8s node or pod has right permission to read from AWS SSM Parameter store.

### Create ssm parameters

```
aws ssm put-parameter --name "/dev/MYENV1" --value "MYENV1" --type String --region eu-west-1
aws ssm put-parameter --name "/dev/MYENV1" --value "MYENV1" --type String --region eu-west-1
aws ssm put-parameter --name "/dev/MYSECRETENV2" --value "secretenv" --type SecureString --region eu-west-1 
aws ssm put-parameter --name "/common/COMMONENV1" --value "MYCOMMONENV1"  --type String --region eu-west-1 

```

### Test with docker

I assume that your user's ~/.aws directory has a configuration to access AWS SSM Parameter store
```
# docker run -d -v /Users/ismail/.aws:/root/.aws -p 8080:80 -e SSM_PATHS='["/dev", "/common"]' yenigul/k8s-aws-ssm-env-load

$ curl localhost:8080/index.php
MYENV1: value1
MYENV2: envvalue2
MYSECRETENV: secretenv
COMMONENV1: MYCOMMONENV1
```



### Test with EKS
```

$ kubectl apply -f sample-deployment.yaml
$ kubectl get pods -o wide 
ssm-deployment-7cb8d5b4c4-59rph                   1/1     Running   0          2m11s   192.168.102.137   ip-192-168-113-188.eu-west-1.compute.internal   <none>           <none>


Let's start another pod in the same namespace to connect ssm deployment pod IP address

kubectl run --rm utils -it  --generator=run-pod/v1 --image yenigul/dockernettools bash
Flag --generator has been deprecated, has no effect and will be removed in the future.

bash-5.0$ curl  192.168.102.137/index.php
MYENV1: value1
MYENV2: envvalue2
MYSECRETENV: secretenv
COMMONENV1: MYCOMMONENV1
bash-5.0$ 
```







