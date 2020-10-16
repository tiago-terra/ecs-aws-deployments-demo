#/bin/bash

# $1 - action - install/build/deploy

export IMAGE_TAG=$IMAGE_TAG
export KUBE_URL="https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl"
export AWS_IAM_AUTH="https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator"

if [ -z $1 ];then echo "Argument missing!\nUsage: $0 \$action" && exit 255; fi

function build_push_ecr () {
  echo "test"
  #Args - ECR REPO, IMAGE_TAG
  export IMAGE_URI="$1:$2"

  echo "Building docker image..."
  docker build -t $IMAGE_URI docker --build-arg IMAGE_TAG=$2

  echo "Pushing image with tag :$1 to repo $2..."
  docker push $IMAGE_URI  
  echo "Image pushed to ECR!"
}

function tools_install () {
  echo "Downloading kubectl..."
  curl -o kubectl $KUBE_URL
  chmod +x ./kubectl
  mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
  kubectl version --short --client
  PATH=$PATH:$HOME/bin
  echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
  echo "kubectl installed!"
}

function sub_vars () {
  # Args - deploy_type, path
  local SERVICE_FILE="service.yml"
  local DEPLOY_FILE="deployment.yml"
  local vars_string="\$ECR_REPO \$IMAGE_TAG \$TYPE"

  for i in blue green rolling
    do
      export TYPE="$i" && export -p >env_var.sh && . env_var.sh && rm -rf env_var.sh
      envsubst "$vars_string" < "$DEPLOY_FILE" > "${TYPE}_$DEPLOY_FILE"
    done
  
  export TYPE="$1"
  export -p >env_var.sh && . env_var.sh && rm -rf env_var.sh
  envsubst "\$TYPE" < "$SERVICE_FILE" > "tmp_${SERVICE_FILE}"
}

function kube_deploy () {

  cd $CODEBUILD_SRC_DIR/k8s && ls -al

  sub_vars $DEPLOY_TYPE 

  kubectl apply -f "${DEPLOY_TYPE}_deployment.yml"
  kubectl apply -f "tmp_service.yml"

  if [ $DEPLOY_TYPE == 'green' ]; then
    kubectl delete -f "${CODEBUILD_SRC_DIR}/blue_deployment.yml"
  fi

  echo "Cleaning k8s files..."
  rm -rf "${CODEBUILD_SRC_DIR}/"*_deployment.yml "${CODEBUILD_SRC_DIR}/tmp_service.yml"
}

if [ $1 == 'install' ]; then tools_install; fi
if [ $1 == 'build' ] && [ $DEPLOY_TYPE != 'green' ]; then 
  build_push_ecr $ECR_REPO $IMAGE_TAG
fi

if [ $1 == 'deploy' ]; then kube_deploy; fi