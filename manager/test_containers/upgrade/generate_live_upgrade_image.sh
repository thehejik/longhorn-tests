#!/bin/bash

# make sure IMAGE wasn't used by any releases
# It is retagged official longhorn-engine image with newer longhorn bin version then the installed one
# Raul was doing a new commit in longhorn-engine repo and a new git tag rc6
# So in the end "rancherlabs/longhornonz-longhorn-engine:v1.2.3-rc6-s390x" was retagged as $IMAGE value
# Deployed version under test was "rancherlabs/longhornonz-longhorn-engine:v1.2.3-rc3-s390x"
IMAGE="thehejik/longhorn-engine:live-upgrade-5-3-1"

version=`docker run $IMAGE longhorn version --client-only`
echo Image version output: $version

CLIAPIVersion=`echo $version|jq -r ".clientVersion.cliAPIVersion"`
CLIAPIMinVersion=`echo $version|jq -r ".clientVersion.cliAPIMinVersion"`
ControllerAPIVersion=`echo $version|jq -r ".clientVersion.controllerAPIVersion"`
ControllerAPIMinVersion=`echo $version|jq -r ".clientVersion.controllerAPIMinVersion"`
DataFormatVersion=`echo $version|jq -r ".clientVersion.dataFormatVersion"`
DataFormatMinVersion=`echo $version|jq -r ".clientVersion.dataFormatMinVersion"`

test_image="thehejik/longhorn-test:upgrade-test.${CLIAPIVersion}-${CLIAPIMinVersion}"\
".${ControllerAPIVersion}-${ControllerAPIMinVersion}"\
".${DataFormatVersion}-${DataFormatMinVersion}"

docker tag $IMAGE $test_image
docker push $test_image

echo
echo $test_image
