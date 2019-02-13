[![Build Status](https://travis-ci.org/brentley/tensorflow-container.svg?branch=master)](https://travis-ci.org/brentley/tensorflow-container)

This is a sample tensorflow container used to test cpu and gpu support on ECS.

See corresponding blog post: https://aws.amazon.com/blogs/compute/scheduling-gpus-for-deep-learning-tasks-on-amazon-ecs/

```
export PATH=$HOME/.local/bin:$HOME/bin:$PATH >> ~/.bash_profile
source ~/.bash_profile
pip install --user -U awscli
```

```
aws cloudformation deploy --stack-name tensorflow-test --template-file cluster-cpu-gpu.yml --capabilities CAPABILITY_IAM                            
aws ecs register-task-definition --cli-input-json file://gpu-1-taskdef.json

```

```
export cluster=$(aws cloudformation describe-stacks --stack-name tensorflow-test --query 'Stacks[0].Outputs[?OutputKey==`ClusterName`].OutputValue' --output text) 
echo $cluster
aws ecs run-task --cluster $cluster --task-definition tensorflow-1-gpu
```

```
aws cloudformation deploy --stack-name tensorflow-test --template-file cluster-cpu-gpu.yml --parameter-overrides GPUInstanceType=p3.16xlarge --capabilities CAPABILITY_IAM
```

```
aws ecs register-task-definition --cli-input-json file://gpu-4-taskdef.json
aws ecs register-task-definition --cli-input-json file://gpu-8-taskdef.json
```

```
aws ecs run-task --cluster $cluster --task-definition tensorflow-4-gpu
aws ecs run-task --cluster $cluster --task-definition tensorflow-8-gpu
```

```
aws cloudformation delete-stack --stack-name tensorflow-test
```