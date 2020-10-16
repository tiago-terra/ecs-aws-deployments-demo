#/bin/bash

# $1 - action - install/build/deploy

export IMAGE_TAG=$IMAGE_TAG
export KUBE_URL="https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl"
export MANIFEST_PATH="k8s"

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

function kube_install () {
  echo "Downloading kubectl..."
  curl -o kubectl $1
  chmod +x ./kubectl
  mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl
  PATH=$PATH:$HOME/bin
  echo 'export PATH=$PATH:$HOME/bin' >> ~/.profile
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
      envsubst "$vars_string" < "$2/$DEPLOY_FILE" > "$2/${TYPE}_$DEPLOY_FILE"
    done
  
  export TYPE="$1"
  export -p >env_var.sh && . env_var.sh && rm -rf env_var.sh
  envsubst "\$TYPE" < "$2/$SERVICE_FILE" > "$2/tmp_${SERVICE_FILE}"
}

function kube_deploy () {

  sub_vars $DEPLOY_TYPE $MANIFEST_PATH
  kubectl apply -f "${MANIFEST_PATH}/${DEPLOY_TYPE}_deployment.yml"
  kubectl apply -f "${MANIFEST_PATH}/tmp_service.yml"

  ls k8s

  if [ $DEPLOY_TYPE == 'green' ]; then
    kubectl delete -f "${MANIFEST_PATH}/blue_deployment.yml"
  fi

  echo "Cleaning k8s files..."
  rm -rf "${MANIFEST_PATH}/"*_deployment.yml "${MANIFEST_PATH}/tmp_service.yml"
}

if [ $1 == 'install' ]; then kube_install $KUBE_URL; fi
if [ $1 == 'build' ] && [ $DEPLOY_TYPE != 'green' ]; then 
  build_push_ecr $ECR_REPO $IMAGE_TAG
fi

if [ $1 == 'deploy' ]; then kube_deploy; fi