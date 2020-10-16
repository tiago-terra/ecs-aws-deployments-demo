#!/bin/sh
# Operations
# $1 - Action - install/build/deploy
export COMMIT_HASH=$(git rev-parse HEAD | cut -c 1-7)
export KUBE_URL="https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl"
export MANIFEST_PATH="../../../k8s"
export IMAGE_PULL="Always"

if [ -z $1 ];then echo "Argument missing!\nUsage: $0 \$action" && exit 1; fi

function push_to_ecr () {
  #Args - ECR REPO, ECR IMAGE TAG
  export IMAGE_URI="$1:$2"

  echo "Building docker image..."
  docker build -t $IMAGE_URI docker --build-arg COMMIT_HASH=$2

  if [ "$CODEBUILD_BUILD_SUCCEEDING" == "0" ]; then exit 1; fi

  echo "Pushing image with tag :$1 to repo $2..."
  docker push $IMAGE_URI || echo "Error: Failed to push" && exit 1

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
  # Args - file, deploy_type

  local FILE=$1
  local vars_string="\$ECR_REPO \$COMMIT_HASH \$DEPLOY_TYPE \$IMAGE_PULL"
  echo $DEPLOY_TYPE
  envsubst "$vars_string" < "${MANIFEST_PATH}/$FILE" > "${MANIFEST_PATH}/${DEPLOY_TYPE}_${FILE}"
}

function kube_deploy () {




}


if [ $1 == 'install' ]; then kube_install $KUBE_URL; fi
if [ $1 == 'build' ] && [ $DEPLOY_TYPE != 'green' ]; then push_to_ecr $ECR_REPO $COMMIT_HASH; fi

if [ $1 == 'deploy' ]; then

  kubectl apply -f "${MANIFEST_PATH}/$DEPLOY_TYPE_manifest.yml"
  if [ $1 == 'green' ]; then kubectl delete -f "${MANIFEST_PATH}/blue_manifest.yml"; fi
fi





