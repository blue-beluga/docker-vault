#!/usr/bin/env bats

setup() {
  docker history "$REGISTRY/$REPOSITORY:$TAG" >/dev/null 2>&1
  export IMG="$REGISTRY/$REPOSITORY:$TAG"
}

@test "the image has a disk size under 60MB" {
  run docker images $IMG
  echo 'status:' $status
  echo 'output:' $output
  size="$(echo ${lines[1]} | awk -F '   *' '{ print int($5) }')"
  echo 'size:' $size
  [[ $status -eq 0 ]]
  [[ $size -lt 130 ]]
}

@test "the image has the apk-install wrapper" {
  run docker run --rm --entrypoint=/bin/sh $IMG -c '[ -x /usr/sbin/apk-install ]'
  echo 'status:' $status
  [ $status -eq 0 ]
}

@test "the apk-install wrapper can install package cleanly" {
  run docker run --rm --entrypoint /bin/sh $IMG /usr/sbin/apk-install openssl
  echo 'status:' $status
  [ $status -eq 0 ]
}

@test "the image has the Vault CLI installed" {
  run docker run --rm --entrypoint=/bin/sh $IMG -c "which vault"
  [ $status -eq 0 ]
}

@test "that the root password is disabled" {
  run docker run --user nobody $IMG su
  echo 'status:' $status
  [ $status -eq 1 ]
}
