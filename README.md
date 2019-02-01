[![Build Status](https://travis-ci.org/brentley/tensorflow-container.svg?branch=master)](https://travis-ci.org/brentley/tensorflow-container)

This is a sample tensorflow container used to test cpu and gpu support on ECS.

See corresponding blog post: 

```
export PATH=$HOME/.local/bin:$HOME/bin:$PATH >> ~/.bash_profile
source ~/.bash_profile
pip install --user -U awscli
```

```
aws cloudformation deploy --stack-name tensorflow-test --template-file cluster-cpu-gpu.yml --capabilities CAPABILITY_IAM                            
aws cloudformation deploy --stack-name tensorflow-cpu-taskdef --template-file task-cpu.yml
aws ecs register-task-definition --cli-input-json file://gpu-1-taskdef.json

```

```
export cluster=$(aws cloudformation describe-stacks --stack-name tensorflow-test --query 'Stacks[0].Outputs[?OutputKey==`ClusterName`].OutputValue' --output text) 
echo $cluster
```

```
aws ecs run-task --cluster $cluster --task-definition tensorflow-cpu
aws ecs run-task --cluster $cluster --task-definition tensorflow-gpu
```

```
aws cloudformation deploy --stack-name tensorflow-test --template-file cluster-cpu-gpu.yml --parameter-overrides GPUInstanceType=p3.16xlarge --capabilities CAPABILITY_IAM
```

```
aws ecs register-task-definition --cli-input-json file://gpu-4-taskdef.json
aws ecs register-task-definition --cli-input-json file://gpu-8-taskdef.json
```