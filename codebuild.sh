#/bin/bash
# $1 - action - install/build/deploy

export IMAGE_TAG=$IMAGE_TAG
export KUBE_URL="https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl"
export AUTHENTICATOR_URL="https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator"

if [ -z $1 ];
  then echo "Argument missing!\nUsage: $0 \$action" && exit 255;
fi

function build_push_ecr () 
  # ARGUMENTS: 
  # ECR Repo - String
  # IMAGE_TAG - String
{
  export IMAGE_URI="$1:$2"

  echo "Building docker image..."
  docker build -t $IMAGE_URI docker --build-arg IMAGE_TAG=$2 > /dev/null
  echo "Docker image build!"

  echo "Pushing image with tag :$1 to repo $2..."
  docker push $IMAGE_URI
  echo "Image pushed to ECR!"
}

function tools_install () {

  echo "Downloading kubectl..."
  curl -o kubectl $KUBE_URL && chmod +x ./kubectl > /dev/null
  mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
  PATH=$PATH:$HOME/bin
  echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
  source ~/.bashrc
  echo "kubectl installed!"
}

function kube_sub_vars () {
  # Args - deploy_type
  local SERVICE_FILE="service.yml"
  local DEPLOY_FILE="deployment.yml"
  local vars_string="\$ECR_REPO \$IMAGE_TAG \$TYPE" 

  for i in blue green rolling
    do
      sed "s|\${DEPLOY_TYPE}|$DEPLOY_TYPE|g;s|\${ECR_REPO}|$ECR_REPO|g;s|\${IMAGE_TAG}|$IMAGE_TAG|g" $DEPLOY_FILE > "${i}_$DEPLOY_FILE"
      sed "s|\${DEPLOY_TYPE}|$DEPLOY_TYPE|g" $SERVICE_FILE > "${i}_$SERVICE_FILE"
    done
}

function kube_deploy () {
  # $1 - manifest path
  cd "${CODEBUILD_SRC_DIR}/k8s"
`  kube_sub_vars $DEPLOY_TYPE
  kubectl apply -f "${DEPLOY_TYPE}_deployment.yml"`
  kubectl apply -f "${DEPLOY_TYPE}_service.yml"

  EXTERNAL_IP=$(kubectl get svc "${DEPLOY_TYPE}-lb" -o 'jsonpath={..status.loadBalancer.ingress[*].hostname}')
  while [ -z $EXTERNAL_IP ]
  do
    echo "Waiting for External IP to be allocated..."
    EXTERNAL_IP=$(kubectl get svc "${DEPLOY_TYPE}-lb" -o 'jsonpath={..status.loadBalancer.ingress[*].hostname}')
  done

  kube_wait $EXTERNAL_IP
  
  if [ $DEPLOY_TYPE == 'green' ]; then
    kubectl delete deployment blue-deployment
    kubectl delete service blue-lb
  fi

  echo "Cleaning k8s files..."
  rm -rf $DEPLOY_TYPE_*
  echo "k8s files cleaned!"
}

function kube_wait () {
  echo "Waiting for $1 to be up..."
  until $(curl --output /dev/null --silent --head --fail $1); do
    printf '.'
    sleep 5
  done
}

# Main operations
case "$1" in
        build)
            build_push_ecr $ECR_REPO $IMAGE_TAG
            ;;

        deploy)
            kube_deploy
            ;;

        install)
            tools_install
            ;;         
esac